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

type SalesDashboardRepository struct {
	db *gorm.DB
}

func NewSalesDashboardRepository(db *gorm.DB) *SalesDashboardRepository {
	return &SalesDashboardRepository{db: db}
}

func (r *SalesDashboardRepository) GetSalesDashboardData(tenantID string, filter *models.SalesDashboardFilterRequest) (*models.SalesDashboardResponse, error) {
	resp := &models.SalesDashboardResponse{}

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

	var tc, aq, appQ, rejQ, conQ, so int64
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
		q := r.db.Table("quotations")
		q = applyFilters(q, "quotations")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		
		qActive := q.Session(&gorm.Session{}).Where("status NOT IN ('Rejected', 'Cancelled', 'Converted')")
		qActive.Count(&aq)
		
		qApp := q.Session(&gorm.Session{}).Where("status = 'Approved'")
		qApp.Count(&appQ)

		qRej := q.Session(&gorm.Session{}).Where("status = 'Rejected'")
		qRej.Count(&rejQ)

		qCon := q.Session(&gorm.Session{}).Where("status = 'Converted'")
		qCon.Count(&conQ)

		return nil
	})
	g.Go(func() error {
		q := r.db.Table("quotations").Where("status NOT IN ('Rejected', 'Cancelled', 'Converted')")
		q = applyFilters(q, "quotations")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		q = q.Where(prevTimeCondition, prevTimeArgs...)
		return q.Count(&prevAq).Error
	})

	// KPI: Sales Orders & Revenue (exclude Cancelled & Rejected)
	g.Go(func() error {
		q := r.db.Table("sales_orders").Where("status NOT IN ('Cancelled', 'Rejected')")
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		q.Count(&so)
		q.Select("COALESCE(SUM(total_amount), 0)").Scan(&currentRevenue)
		return nil
	})
	g.Go(func() error {
		q := r.db.Table("sales_orders").Where("status NOT IN ('Cancelled', 'Rejected')")
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		q = applyStatusFilter(q, "status")
		q = q.Where(prevTimeCondition, prevTimeArgs...)
		q.Count(&prevSo)
		q.Select("COALESCE(SUM(total_amount), 0)").Scan(&prevRevenue)
		return nil
	})

	// Monthly Revenue (Current Month, exclude Cancelled & Rejected)
	g.Go(func() error {
		startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
		q := r.db.Table("sales_orders").Where("created_on >= ? AND status NOT IN ('Cancelled', 'Rejected')", startOfMonth)
		q = applyFilters(q, "sales_orders")
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("COALESCE(SUM(total_amount), 0)").Scan(&resp.KPIs.MonthlySalesRevenue).Error
	})

	if err := g.Wait(); err != nil {
		return nil, err
	}

	resp.KPIs.TotalCustomers = int(tc)
	resp.KPIs.ActiveQuotations = int(aq)
	resp.KPIs.ApprovedQuotations = int(appQ)
	resp.KPIs.RejectedQuotations = int(rejQ)
	resp.KPIs.ConvertedQuotations = int(conQ)
	resp.KPIs.SalesOrders = int(so)
	resp.KPIs.TotalSalesRevenue = currentRevenue

	if (appQ + rejQ + conQ + aq) > 0 {
		resp.KPIs.QuotationConversionRate = (float64(conQ) / float64(appQ+rejQ+conQ+aq)) * 100.0
	}
	if so > 0 {
		resp.KPIs.AverageOrderValue = currentRevenue / float64(so)
	}

	calcGrowth := func(curr, prev float64) float64 {
		if prev == 0 {
			if curr > 0 { return 100.0 }
			return 0.0
		}
		return ((curr - prev) / prev) * 100.0
	}

	resp.KPIs.CustomersGrowth = calcGrowth(float64(tc), float64(prevTc))
	resp.KPIs.QuotationsGrowth = calcGrowth(float64(aq), float64(prevAq))
	resp.KPIs.SalesOrdersGrowth = calcGrowth(float64(so), float64(prevSo))
	resp.KPIs.RevenueGrowth = calcGrowth(currentRevenue, prevRevenue)

	gCharts, _ := errgroup.WithContext(context.Background())

	// Monthly Revenue Trend
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COALESCE(SUM(total_amount), 0) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.MonthlyRevenueTrend).Error
	})

	// Quotation Trend
	gCharts.Go(func() error {
		q := r.db.Table("quotations")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.QuotationTrend).Error
	})

	// Sales Order Trend
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		q = applyCustomerFilter(q, "customer_id")
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.SalesOrderTrend).Error
	})

	// Quotation Status Distribution
	gCharts.Go(func() error {
		q := r.db.Table("quotations")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.QuotationStatusDistribution).Error
	})

	// Quotation Conversion Funnel (Mocked format using actual counts)
	gCharts.Go(func() error {
		resp.Charts.QuotationConversionFunnel = []models.ChartDataPoint{
			{Label: "Total", Value: float64(aq + appQ + rejQ + conQ)},
			{Label: "Approved", Value: float64(appQ + conQ)},
			{Label: "Converted", Value: float64(conQ)},
		}
		return nil
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
			Group("p.product_name").Order("value DESC").Limit(5).
			Scan(&resp.Charts.TopProducts).Error
	})

	// Recent Quotations
	gCharts.Go(func() error {
		q := r.db.Table("quotations").Joins("JOIN customers c ON quotations.customer_id = c.id")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where("quotations."+timeCondition, timeArgs...) }
		return q.Select("quotations.id as quotation_number, c.name as customer, quotations.total as amount, quotations.created_on as date").
			Order("quotations.created_on DESC").Limit(5).
			Scan(&resp.Widgets.RecentQuotations).Error
	})

	// Recent Sales Orders
	gCharts.Go(func() error {
		q := r.db.Table("sales_orders").Joins("JOIN customers c ON sales_orders.customer_id = c.id")
		q = applyFilters(q, "sales_orders")
		if !startDate.IsZero() { q = q.Where("sales_orders."+timeCondition, timeArgs...) }
		return q.Select("sales_orders.id as order_number, c.name as customer, sales_orders.total_amount as amount, sales_orders.created_on as date, sales_orders.status").
			Order("sales_orders.created_on DESC").Limit(5).
			Scan(&resp.Widgets.RecentSalesOrders).Error
	})

	// Pending Approvals
	gCharts.Go(func() error {
		q := r.db.Table("quotations").Joins("JOIN customers c ON quotations.customer_id = c.id").Where("quotations.status = 'Draft'")
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where("quotations."+timeCondition, timeArgs...) }
		return q.Select("quotations.id as quotation_number, c.name as customer, quotations.total as amount, quotations.created_on as date").
			Order("quotations.created_on ASC").Limit(5).
			Scan(&resp.Widgets.PendingQuotationApprovals).Error
	})

	// Expiring Quotations
	gCharts.Go(func() error {
		q := r.db.Table("quotations").Joins("JOIN customers c ON quotations.customer_id = c.id").
			Where("quotations.status NOT IN ('Converted', 'Rejected', 'Cancelled') AND quotations.valid_until < ?", now.AddDate(0,0,7))
		q = applyFilters(q, "quotations")
		if !startDate.IsZero() { q = q.Where("quotations."+timeCondition, timeArgs...) }
		return q.Select("quotations.id as quotation_number, c.name as customer, quotations.total as amount, quotations.created_on as date").
			Order("quotations.valid_until ASC").Limit(5).
			Scan(&resp.Widgets.ExpiringQuotations).Error
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
				Action:  "Sales Dashboard Viewed",
				Details: "Sales Dashboard loaded with timeframe: " + filter.Timeframe,
			}
			audit.LogAsync(auditEntry)
		}
	}

	return resp, nil
}
