package repositories

import (
	"context"
	"furniflow-backend/audit"
	"furniflow-backend/models"
	"time"

	"github.com/google/uuid"
	"golang.org/x/sync/errgroup"
	"gorm.io/gorm"
)

type ManufacturingDashboardRepository struct {
	db *gorm.DB
}

func NewManufacturingDashboardRepository(db *gorm.DB) *ManufacturingDashboardRepository {
	return &ManufacturingDashboardRepository{db: db}
}

func (r *ManufacturingDashboardRepository) GetManufacturingDashboardData(tenantID string, filter *models.ManufacturingDashboardFilterRequest) (*models.ManufacturingDashboardResponse, error) {
	resp := &models.ManufacturingDashboardResponse{}

	var startDate time.Time
	now := time.Now()
	switch filter.Timeframe {
	case "1M":
		startDate = now.AddDate(0, -1, 0)
	case "3M":
		startDate = now.AddDate(0, -3, 0)
	case "YTD":
		startDate = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
	case "1Y":
		startDate = now.AddDate(-1, 0, 0)
	default:
		startDate = time.Time{}
	}

	if filter.StartDate != nil && !filter.StartDate.IsZero() {
		startDate = *filter.StartDate
	}

	applyFilters := func(q *gorm.DB, baseTable string) *gorm.DB {
		q = q.Where(baseTable+".tenant_id = ?", tenantID)
		if filter.OrganizationID != nil && *filter.OrganizationID != "" {
			q = q.Where(baseTable+".organization_id = ?", *filter.OrganizationID)
		}
		if filter.ProductID != nil && *filter.ProductID != "" {
			if baseTable == "production_orders" {
				q = q.Where("production_orders.product_id = ?", *filter.ProductID)
			} else if baseTable == "production_trackings" {
				q = q.Where("production_trackings.production_order_id IN (SELECT id FROM production_orders WHERE product_id = ?)", *filter.ProductID)
			}
		}
		if filter.Stage != nil && *filter.Stage != "" {
			if baseTable == "production_trackings" {
				q = q.Where("production_trackings.current_stage = ?", *filter.Stage)
			} else if baseTable == "production_orders" {
				q = q.Where("production_orders.id IN (SELECT production_order_id FROM production_trackings WHERE current_stage = ?)", *filter.Stage)
			}
		}
		if filter.AssignedTeam != nil && *filter.AssignedTeam != "" {
			if baseTable == "production_trackings" {
				q = q.Where("production_trackings.assigned_team = ?", *filter.AssignedTeam)
			} else if baseTable == "production_orders" {
				q = q.Where("production_orders.id IN (SELECT production_order_id FROM production_trackings WHERE assigned_team = ?)", *filter.AssignedTeam)
			}
		}
		if filter.AssignedEmp != nil && *filter.AssignedEmp != "" {
			if baseTable == "production_trackings" {
				q = q.Where("production_trackings.assigned_employee_id = ?", *filter.AssignedEmp)
			} else if baseTable == "production_orders" {
				q = q.Where("production_orders.id IN (SELECT production_order_id FROM production_trackings WHERE assigned_employee_id = ?)", *filter.AssignedEmp)
			}
		}
		if filter.Status != nil && *filter.Status != "" {
			if baseTable == "production_orders" {
				q = q.Where("production_orders.status = ?", *filter.Status)
			} else if baseTable == "production_trackings" {
				q = q.Where("production_trackings.production_order_id IN (SELECT id FROM production_orders WHERE status = ?)", *filter.Status)
			}
		}
		return q
	}

	timeCondition := "1=1"
	var timeArgs []interface{}
	if !startDate.IsZero() {
		timeCondition = "created_on >= ?"
		timeArgs = append(timeArgs, startDate)
	}

	g, _ := errgroup.WithContext(context.Background())

	var total, released, inProgress, completed, onHold, ready int64

	// KPI Counts & Efficiency
	g.Go(func() error {
		q := r.db.Table("production_orders").
			Select("status, COUNT(*) as count")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() {
			q = q.Where("production_orders."+timeCondition, timeArgs...)
		}
		q = q.Group("status")

		type StatusCount struct {
			Status string
			Count  int64
		}
		var counts []StatusCount
		if err := q.Scan(&counts).Error; err != nil {
			return err
		}

		for _, c := range counts {
			total += c.Count
			switch c.Status {
			case "Released":
				released = c.Count
			case "In Progress":
				inProgress = c.Count
			case "Completed":
				completed = c.Count
			case "On Hold":
				onHold = c.Count
			case "Ready for Delivery":
				ready = c.Count
			}
		}

		// Calculate Avg Production Time
		var avgTime float64
		qAvg := r.db.Table("production_orders").Where("status = 'Completed'").Select("COALESCE(AVG(EXTRACT(EPOCH FROM (updated_on - created_on))/3600), 0)")
		qAvg = applyFilters(qAvg, "production_orders")
		if !startDate.IsZero() {
			qAvg = qAvg.Where("production_orders."+timeCondition, timeArgs...)
		}
		qAvg.Scan(&avgTime)
		resp.KPIs.AverageProductionTime = avgTime

		// True Efficiency: % of completed orders finished on or before planned_end_date
		var completedOnTime int64
		qEff := r.db.Table("production_orders").Where("status = 'Completed' AND updated_on <= planned_end_date")
		qEff = applyFilters(qEff, "production_orders")
		if !startDate.IsZero() {
			qEff = qEff.Where("production_orders."+timeCondition, timeArgs...)
		}
		qEff.Count(&completedOnTime)

		var efficiency float64 = 0
		if completed > 0 {
			efficiency = (float64(completedOnTime) / float64(completed)) * 100.0
		}
		resp.KPIs.ProductionEfficiency = efficiency

		return nil
	})

	if err := g.Wait(); err != nil {
		return nil, err
	}

	resp.KPIs.TotalProductionOrders = int(total)
	resp.KPIs.ReleasedOrders = int(released)
	resp.KPIs.InProgressOrders = int(inProgress)
	resp.KPIs.CompletedOrders = int(completed)
	resp.KPIs.OnHoldOrders = int(onHold)
	resp.KPIs.ReadyForDelivery = int(ready)

	// Charts and Widgets
	gCharts, _ := errgroup.WithContext(context.Background())

	// Status Distribution
	gCharts.Go(func() error {
		q := r.db.Table("production_orders")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.ProductionStatusDistribution).Error
	})

	// Stage Distribution
	gCharts.Go(func() error {
		q := r.db.Table("production_trackings")
		q = applyFilters(q, "production_trackings")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("current_stage as label, COUNT(*) as value").
			Group("current_stage").
			Scan(&resp.Charts.ProductionStageDistribution).Error
	})

	// Production Trend
	gCharts.Go(func() error {
		q := r.db.Table("production_orders")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.ProductionTrendByMonth).Error
	})

	// Completion Trend
	gCharts.Go(func() error {
		q := r.db.Table("production_orders").Where("status = 'Completed'")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		return q.Select("TO_CHAR(updated_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(updated_on, 'Mon'), DATE_TRUNC('month', updated_on)").
			Order("DATE_TRUNC('month', updated_on)").
			Scan(&resp.Charts.ProductionCompletionTrend).Error
	})

	// On Hold Trend
	gCharts.Go(func() error {
		q := r.db.Table("production_orders").Where("status = 'On Hold'")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.OnHoldTrend).Error
	})

	// Efficiency Trend (Live)
	gCharts.Go(func() error {
		q := r.db.Table("production_orders").Where("status = 'Completed'")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COALESCE((SUM(CASE WHEN updated_on <= planned_end_date THEN 1 ELSE 0 END)::float / NULLIF(COUNT(*), 0)::float) * 100, 0) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.ProductionEfficiencyTrend).Error
	})

	// Widgets - Stage Analytics
	gCharts.Go(func() error {
		q := r.db.Table("production_trackings").
			Joins("JOIN production_orders po ON production_trackings.production_order_id = po.id")
		q = applyFilters(q, "production_trackings")
		if !startDate.IsZero() { q = q.Where("production_trackings."+timeCondition, timeArgs...) }
		return q.Select("production_trackings.current_stage as stage_name, COUNT(*) as order_count, COALESCE(AVG(EXTRACT(EPOCH FROM (production_trackings.updated_on - production_trackings.created_on))/3600), 0) as average_duration, SUM(CASE WHEN po.status = 'Delayed' THEN 1 ELSE 0 END) as delayed_orders").
			Group("production_trackings.current_stage").
			Scan(&resp.Widgets.StageAnalytics).Error
	})

	fetchOrders := func(statusFilter, stageFilter string, dest *[]models.DashboardProductionOrder) error {
		q := r.db.Table("production_orders").
			Joins("JOIN products p ON production_orders.product_id = p.id").
			Joins("LEFT JOIN production_trackings pt ON pt.production_order_id = production_orders.id").
			Select("SUBSTRING(CAST(production_orders.id AS VARCHAR), 1, 8) as order_number, p.product_name as product, production_orders.status, production_orders.created_on as start_date, production_orders.planned_end_date as target_date, COALESCE(pt.current_stage, 'Not Started') as current_stage")
		q = applyFilters(q, "production_orders")
		if !startDate.IsZero() { q = q.Where("production_orders."+timeCondition, timeArgs...) }
		if statusFilter != "" {
			q = q.Where("production_orders.status = ?", statusFilter)
		}
		if stageFilter != "" {
			q = q.Where("pt.current_stage = ?", stageFilter)
		}
		return q.Order("production_orders.created_on DESC").Limit(5).Scan(dest).Error
	}

	gCharts.Go(func() error { return fetchOrders("In Progress", "", &resp.Widgets.CurrentProductionQueue) })
	gCharts.Go(func() error { return fetchOrders("On Hold", "", &resp.Widgets.OrdersOnHold) })
	gCharts.Go(func() error { return fetchOrders("Ready for Delivery", "", &resp.Widgets.OrdersReadyForDelivery) })
	gCharts.Go(func() error { return fetchOrders("Completed", "", &resp.Widgets.RecentlyCompletedOrders) })
	gCharts.Go(func() error { return fetchOrders("Delayed", "", &resp.Widgets.DelayedProductionOrders) })
	gCharts.Go(func() error { return fetchOrders("Quality Inspection", "", &resp.Widgets.OrdersAwaitingQC) })
	gCharts.Go(func() error { return fetchOrders("Packing", "", &resp.Widgets.OrdersAwaitingPacking) })
	gCharts.Go(func() error { return fetchOrders("Dispatch", "", &resp.Widgets.OrdersAwaitingDispatch) })

	// Most Delayed Products & Stages
	gCharts.Go(func() error {
		// Most Delayed Products
		qProd := r.db.Table("production_orders").
			Joins("JOIN products p ON production_orders.product_id = p.id").
			Where("production_orders.status = 'Delayed'")
		qProd = applyFilters(qProd, "production_orders")
		if !startDate.IsZero() { qProd = qProd.Where("production_orders."+timeCondition, timeArgs...) }
		
		err := qProd.Select("p.product_name as entity_name, COUNT(*) as delay_count, COALESCE(AVG(EXTRACT(EPOCH FROM (production_orders.updated_on - production_orders.planned_end_date))/3600), 0) as avg_delay").
			Group("p.product_name").
			Order("delay_count DESC").
			Limit(5).
			Scan(&resp.Widgets.MostDelayedProducts).Error
		if err != nil { return err }

		// Most Delayed Stages
		qStage := r.db.Table("production_trackings").
			Joins("JOIN production_orders po ON production_trackings.production_order_id = po.id").
			Where("po.status = 'Delayed'")
		qStage = applyFilters(qStage, "production_trackings")
		if !startDate.IsZero() { qStage = qStage.Where("production_trackings."+timeCondition, timeArgs...) }
		
		return qStage.Select("production_trackings.current_stage as entity_name, COUNT(*) as delay_count, COALESCE(AVG(EXTRACT(EPOCH FROM (production_trackings.updated_on - production_trackings.created_on))/3600), 0) as avg_delay").
			Group("production_trackings.current_stage").
			Order("delay_count DESC").
			Limit(5).
			Scan(&resp.Widgets.MostDelayedStages).Error
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
				Action:  "Manufacturing Dashboard Viewed",
				Details: "Manufacturing Dashboard loaded with timeframe: " + filter.Timeframe,
			}
			audit.LogAsync(auditEntry)
		}
	}

	return resp, nil
}
