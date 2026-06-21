package repositories

import (
	"context"
	"furniflow-backend/models"
	"time"

	"furniflow-backend/audit"
	"golang.org/x/sync/errgroup"
	"gorm.io/gorm"
	"github.com/google/uuid"
)

type DashboardRepository struct {
	db *gorm.DB
}

func NewDashboardRepository(db *gorm.DB) *DashboardRepository {
	return &DashboardRepository{db: db}
}

func (r *DashboardRepository) GetDashboardData(tenantID string, filter *models.DashboardFilterRequest) (*models.DashboardResponse, error) {
	resp := &models.DashboardResponse{}

	// Query Timeframe logic
	var startDate, prevStartDate, prevEndDate time.Time
	now := time.Now()
	switch filter.Timeframe {
	case "1M":
		startDate = now.AddDate(0, -1, 0)
		prevEndDate = startDate
		prevStartDate = prevEndDate.AddDate(0, -1, 0)
	case "3M":
		startDate = now.AddDate(0, -3, 0)
		prevEndDate = startDate
		prevStartDate = prevEndDate.AddDate(0, -3, 0)
	case "YTD":
		startDate = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
		prevEndDate = startDate.Add(-1 * time.Second)
		prevStartDate = time.Date(now.Year()-1, 1, 1, 0, 0, 0, 0, now.Location())
	case "1Y":
		startDate = now.AddDate(-1, 0, 0)
		prevEndDate = startDate
		prevStartDate = prevEndDate.AddDate(-1, 0, 0)
	default:
		startDate = time.Time{}
		prevStartDate = time.Time{}
	}

	if filter.StartDate != nil && !filter.StartDate.IsZero() {
		startDate = *filter.StartDate
		duration := now.Sub(startDate)
		prevEndDate = startDate.Add(-1 * time.Second)
		prevStartDate = startDate.Add(-duration)
	}

	// Helper to apply common filters (Tenant, Org)
	applyFilters := func(q *gorm.DB, table string) *gorm.DB {
		q = q.Where(table+".tenant_id = ?", tenantID)
		if filter.OrganizationID != nil && *filter.OrganizationID != "" {
			q = q.Where(table+".organization_id = ?", *filter.OrganizationID)
		}
		return q
	}
	
	applyCustomerFilter := func(q *gorm.DB, col string) *gorm.DB {
		if filter.CustomerID != nil && *filter.CustomerID != "" {
			q = q.Where(col+" = ?", *filter.CustomerID)
		}
		return q
	}

	applyStatusFilter := func(q *gorm.DB, col string) *gorm.DB {
		if filter.Status != nil && *filter.Status != "" {
			q = q.Where(col+" = ?", *filter.Status)
		}
		return q
	}

	timeCondition := "1=1"
	var timeArgs []interface{}
	if !startDate.IsZero() {
		timeCondition = "created_on >= ?"
		timeArgs = append(timeArgs, startDate)
	}

	prevTimeCondition := "1=1"
	var prevTimeArgs []interface{}
	if !prevStartDate.IsZero() {
		prevTimeCondition = "created_on >= ? AND created_on <= ?"
		prevTimeArgs = append(prevTimeArgs, prevStartDate, prevEndDate)
	} else {
		prevTimeCondition = "1=0"
	}

	g, _ := errgroup.WithContext(context.Background())

	var tc, aq, so, po, rfd, do int64
	var prevTc, prevAq, prevSo int64
	var currentRevenue, prevRevenue float64

	// KPI: Customers
	g.Go(func() error {
		q := r.db.Table("customers")
		q = applyFilters(q, "customers")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Count(&tc).Error
	})
	g.Go(func() error {
		q := r.db.Table("customers")
		q = applyFilters(q, "customers")
		q = q.Where(prevTimeCondition, prevTimeArgs...)
		return q.Count(&prevTc).Error
	})

	// KPI: Quotations
	g.Go(func() error {
		q := r.db.Table("quotations").Where("status NOT IN ('Rejected', 'Cancelled')")
		q = applyFilters(q, "quotations")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Count(&aq).Error
	})
	g.Go(func() error {
		q := r.db.Table("quotations").Where("status NOT IN ('Rejected', 'Cancelled')")
		q = applyFilters(q, "quotations")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		q = q.Where(prevTimeCondition, prevTimeArgs...)
		return q.Count(&prevAq).Error
	})

	// KPI: Sales Orders & Revenue
	g.Go(func() error {
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		q.Count(&so)
		q.Select("COALESCE(SUM(total_amount), 0)").Scan(&currentRevenue)
		return nil
	})
	g.Go(func() error {
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		q = q.Where(prevTimeCondition, prevTimeArgs...)
		q.Count(&prevSo)
		q.Select("COALESCE(SUM(total_amount), 0)").Scan(&prevRevenue)
		return nil
	})

	// KPI: Production Orders
	g.Go(func() error {
		q := r.db.Table("production_orders")
		q = applyFilters(q, "production_orders")
		q = applyStatusFilter(q, "status")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Count(&po).Error
	})

	// KPI: Ready for Delivery
	g.Go(func() error {
		q := r.db.Table("production_trackings").Where("current_stage = 'Ready For Delivery'")
		q = applyFilters(q, "production_trackings")
		return q.Count(&rfd).Error
	})

	// KPI: Delivered Orders
	g.Go(func() error {
		q := r.db.Table("deliveries").Where("status = 'Delivered'")
		q = applyFilters(q, "deliveries")
		q = applyCustomerFilter(q, "customer_id")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Count(&do).Error
	})

	// Monthly Revenue (Current Month)
	g.Go(func() error {
		startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
		q := r.db.Table("sales_orders").Where("created_on >= ?", startOfMonth)
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("COALESCE(SUM(total_amount), 0)").Scan(&resp.KPIs.MonthlyRevenue).Error
	})

	// Wait for KPIs
	if err := g.Wait(); err != nil {
		return nil, err
	}

	resp.KPIs.TotalCustomers = int(tc)
	resp.KPIs.ActiveQuotations = int(aq)
	resp.KPIs.SalesOrders = int(so)
	resp.KPIs.ProductionOrders = int(po)
	resp.KPIs.ReadyForDelivery = int(rfd)
	resp.KPIs.DeliveredOrders = int(do)
	resp.KPIs.TotalRevenue = currentRevenue

	// Growth Calculations
	calcGrowth := func(curr, prev float64) float64 {
		if prev == 0 {
			if curr > 0 { return 100.0 }
			return 0.0
		}
		return ((curr - prev) / prev) * 100.0
	}

	resp.KPIs.CustomersGrowth = calcGrowth(float64(tc), float64(prevTc))
	resp.KPIs.QuotationsGrowth = calcGrowth(float64(aq), float64(prevAq))
	resp.KPIs.ActiveOrdersGrowth = calcGrowth(float64(so), float64(prevSo))
	resp.KPIs.RevenueGrowth = calcGrowth(currentRevenue, prevRevenue)

	// Charts & Widgets
	gCharts, _ := errgroup.WithContext(context.Background())

	// Monthly Sales Trend
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COALESCE(SUM(total_amount), 0) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.MonthlySalesTrend).Error
	})

	// Hierarchical Sales Trend
	gCharts.Go(func() error {
		type HierarchicalRow struct {
			Year    string
			Quarter string
			Month   string
			Amount  float64
		}
		var hRows []HierarchicalRow
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		
		err := q.Select(`TO_CHAR(created_on, 'YYYY') as year, 'Q' || TO_CHAR(created_on, 'Q') as quarter, TO_CHAR(created_on, 'Mon') as month, COALESCE(SUM(total_amount), 0) as amount`).
			Group(`TO_CHAR(created_on, 'YYYY'), 'Q' || TO_CHAR(created_on, 'Q'), TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)`).
			Order(`DATE_TRUNC('month', created_on)`).
			Scan(&hRows).Error

		var tree []models.RevenueTrendNode
		yMap := make(map[string]int)
		qMap := make(map[string]int)
		for _, row := range hRows {
			if _, exists := yMap[row.Year]; !exists {
				tree = append(tree, models.RevenueTrendNode{Label: row.Year, Children: []models.RevenueTrendNode{}})
				yMap[row.Year] = len(tree) - 1
			}
			yIdx := yMap[row.Year]
			tree[yIdx].Value += row.Amount

			qKey := row.Year + "-" + row.Quarter
			if _, exists := qMap[qKey]; !exists {
				tree[yIdx].Children = append(tree[yIdx].Children, models.RevenueTrendNode{Label: row.Quarter, Children: []models.RevenueTrendNode{}})
				qMap[qKey] = len(tree[yIdx].Children) - 1
			}
			qIdx := qMap[qKey]
			tree[yIdx].Children[qIdx].Value += row.Amount

			tree[yIdx].Children[qIdx].Children = append(tree[yIdx].Children[qIdx].Children, models.RevenueTrendNode{
				Label: row.Month,
				Value: row.Amount,
			})
		}
		resp.Charts.HierarchicalSalesTrend = tree
		return err
	})

	// Top Customers
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders").Joins("JOIN customers c ON sales_orders.customer_id = c.id")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("sales_orders."+timeCondition, timeArgs...) }
		return q.Select("c.name as label, COALESCE(SUM(sales_orders.total_amount), 0) as value").
			Group("c.name").Order("value DESC").Limit(5).
			Scan(&resp.Charts.TopCustomers).Error
	})

	// Top Products
	gCharts.Go(func() error {
		q := r.db.Table("sales_order_items").
			Joins("JOIN sales_orders so ON so.id = sales_order_items.sales_order_id").
			Joins("JOIN products p ON sales_order_items.product_id = p.id")
		q = applyFilters(q, "so")
		if !startDate.IsZero() { q = q.Where("so."+timeCondition, timeArgs...) }
		return q.Select("p.product_name as label, COALESCE(SUM(sales_order_items.quantity * sales_order_items.unit_price), 0) as value").
			Group("p.product_name").Order("value DESC").Limit(4).
			Scan(&resp.Charts.TopProducts).Error
	})

	// Quotation Conversion Trend
	gCharts.Go(func() error {
		q := r.db.Table("quotations")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.QuotationConversionTrend).Error
	})
	
	// Production Status Distribution
	gCharts.Go(func() error {
		q := r.db.Table("production_orders")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.ProductionStatusDistribution).Error
	})

	// Delivery Status Distribution
	gCharts.Go(func() error {
		q := r.db.Table("deliveries")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.DeliveryStatusDistribution).Error
	})

	// Recent Orders
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders").Joins("JOIN customers c ON sales_orders.customer_id = c.id")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("sales_orders."+timeCondition, timeArgs...) }
		return q.Select("sales_orders.id as order_number, c.name as customer, sales_orders.total_amount as amount, sales_orders.created_on as date, sales_orders.status").
			Order("sales_orders.created_on DESC").Limit(5).
			Scan(&resp.Widgets.RecentOrders).Error
	})

	// Recent Deliveries
	gCharts.Go(func() error {
		q := r.db.Table("deliveries").Joins("JOIN customers c ON deliveries.customer_id = c.id")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where("deliveries."+timeCondition, timeArgs...) }
		return q.Select("deliveries.delivery_number, c.name as customer, deliveries.expected_delivery_date as expected_date, deliveries.status").
			Order("deliveries.created_on DESC").Limit(5).
			Scan(&resp.Widgets.RecentDeliveries).Error
	})

	// Pending Approvals
	gCharts.Go(func() error {
		q := r.db.Table("quotations").Joins("JOIN customers c ON quotations.customer_id = c.id").Where("quotations.status = 'Draft'")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where("quotations."+timeCondition, timeArgs...) }
		return q.Select("quotations.id as quotation_number, c.name as customer, quotations.total as amount, quotations.created_on as date").
			Order("quotations.created_on ASC").Limit(5).
			Scan(&resp.Widgets.PendingApprovals).Error
	})

	// Delayed Production
	gCharts.Go(func() error {
		q := r.db.Table("production_orders").Joins("JOIN products p ON production_orders.product_id = p.id").
			Where("production_orders.status != 'Completed' AND production_orders.planned_end_date < NOW()")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("production_orders."+timeCondition, timeArgs...) }
		return q.Select("production_orders.id as order_number, p.product_name as product, production_orders.planned_end_date as expected_date, production_orders.status").
			Order("production_orders.planned_end_date ASC").Limit(5).
			Scan(&resp.Widgets.DelayedProduction).Error
	})

	// Delayed Deliveries
	gCharts.Go(func() error {
		q := r.db.Table("deliveries").Joins("JOIN customers c ON deliveries.customer_id = c.id").
			Where("deliveries.status != 'Delivered' AND deliveries.expected_delivery_date < NOW()")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where("deliveries."+timeCondition, timeArgs...) }
		return q.Select("deliveries.delivery_number, c.name as customer, deliveries.expected_delivery_date as expected_date, deliveries.status").
			Order("deliveries.expected_delivery_date ASC").Limit(5).
			Scan(&resp.Widgets.DelayedDeliveries).Error
	})

	if err := gCharts.Wait(); err != nil {
		return nil, err
	}

	// Audit Log
	if filter.UserID != "" {
		uid, err := uuid.Parse(filter.UserID)
		if err == nil {
			auditEntry := models.AuditLog{
				BaseModel: models.BaseModel{
					TenantID:       tenantID,
					OrganizationID: filter.OrganizationID,
				},
				UserID:  &uid,
				Action:  "Dashboard Viewed",
				Details: "Executive Dashboard loaded with timeframe: " + filter.Timeframe,
			}
			audit.LogAsync(auditEntry)
		}
	}

	return resp, nil
}
