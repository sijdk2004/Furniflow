package repositories

import (
	"time"

	"furniflow-backend/models"
	"golang.org/x/sync/errgroup"
	"gorm.io/gorm"
)

type DeliveryDashboardRepository struct {
	db *gorm.DB
}

func NewDeliveryDashboardRepository(db *gorm.DB) *DeliveryDashboardRepository {
	return &DeliveryDashboardRepository{db: db}
}

func (r *DeliveryDashboardRepository) GetDeliveryDashboardData(tenantID string, filter models.DeliveryDashboardFilterRequest) (*models.DeliveryDashboardResponse, error) {
	resp := &models.DeliveryDashboardResponse{}
	
	now := time.Now()
	var startDate time.Time
	
	timeCondition := "created_on >= ?"
	var timeArgs []interface{}

	if filter.Timeframe != "" && filter.Timeframe != "All Time" {
		switch filter.Timeframe {
		case "1M":
			startDate = now.AddDate(0, -1, 0)
		case "3M":
			startDate = now.AddDate(0, -3, 0)
		case "YTD":
			startDate = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
		case "1Y":
			startDate = now.AddDate(-1, 0, 0)
		}
		timeArgs = append(timeArgs, startDate)
	}

	if filter.StartDate != nil {
		startDate = *filter.StartDate
		timeArgs = []interface{}{startDate}
	}

	applyFilters := func(q *gorm.DB, baseTable string) *gorm.DB {
		q = q.Where(baseTable+".tenant_id = ?", tenantID)
		if filter.OrganizationID != nil && *filter.OrganizationID != "" {
			q = q.Where(baseTable+".organization_id = ?", *filter.OrganizationID)
		}
		if filter.CustomerID != nil && *filter.CustomerID != "" {
			q = q.Where(baseTable+".customer_id = ?", *filter.CustomerID)
		}
		if filter.Status != nil && *filter.Status != "" {
			q = q.Where(baseTable+".status = ?", *filter.Status)
		}
		if filter.Driver != nil && *filter.Driver != "" {
			if baseTable == "deliveries" {
				q = q.Where("deliveries.assigned_driver = ?", *filter.Driver)
			}
		}
		if filter.Vehicle != nil && *filter.Vehicle != "" {
			if baseTable == "deliveries" {
				q = q.Where("deliveries.assigned_vehicle = ?", *filter.Vehicle)
			}
		}
		if filter.SalesOrderID != nil && *filter.SalesOrderID != "" {
			q = q.Where(baseTable+".sales_order_id = ?", *filter.SalesOrderID)
		}
		return q
	}

	var g errgroup.Group

	// 1. KPIs
	g.Go(func() error {
		q := r.db.Table("deliveries").Select("status, COUNT(*) as count")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() {
			q = q.Where("deliveries."+timeCondition, timeArgs...)
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

		var total, scheduled, inTransit, delivered, cancelled int64
		for _, c := range counts {
			total += c.Count
			switch c.Status {
			case "Scheduled": scheduled = c.Count
			case "In Transit": inTransit = c.Count
			case "Delivered": delivered = c.Count
			case "Cancelled": cancelled = c.Count
			}
		}
		resp.KPIs.TotalDeliveries = int(total)
		resp.KPIs.ScheduledDeliveries = int(scheduled)
		resp.KPIs.InTransitDeliveries = int(inTransit)
		resp.KPIs.DeliveredOrders = int(delivered)
		resp.KPIs.CancelledDeliveries = int(cancelled)

		if total > 0 {
			resp.KPIs.DeliverySuccessRate = (float64(delivered) / float64(total)) * 100.0
			resp.KPIs.DelayedDeliveriesPct = (float64(cancelled) / float64(total)) * 100.0 // Approximated
			resp.KPIs.DeliveryCompletionPct = (float64(delivered) / float64(total)) * 100.0
		}

		return nil
	})

	// 2. Today and This Week Deliveries
	g.Go(func() error {
		todayStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		weekStart := todayStart.AddDate(0, 0, int(time.Sunday)-int(todayStart.Weekday()))

		qToday := r.db.Table("deliveries").Where("expected_delivery_date >= ? AND expected_delivery_date < ?", todayStart, todayStart.AddDate(0, 0, 1))
		qToday = applyFilters(qToday, "deliveries")
		var todays int64
		qToday.Count(&todays)
		resp.KPIs.TodaysDeliveries = int(todays)

		qWeek := r.db.Table("deliveries").Where("expected_delivery_date >= ? AND expected_delivery_date < ?", weekStart, weekStart.AddDate(0, 0, 7))
		qWeek = applyFilters(qWeek, "deliveries")
		var weekly int64
		qWeek.Count(&weekly)
		resp.KPIs.ThisWeekDeliveries = int(weekly)

		return nil
	})

	// 3. Charts
	var gCharts errgroup.Group

	gCharts.Go(func() error {
		q := r.db.Table("deliveries")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where(timeCondition, timeArgs...) }
		return q.Select("status as label, COUNT(*) as value").
			Group("status").
			Scan(&resp.Charts.DeliveryStatusDistribution).Error
	})

	gCharts.Go(func() error {
		q := r.db.Table("deliveries")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.MonthlyDeliveryTrend).Error
	})

	gCharts.Go(func() error {
		q := r.db.Table("deliveries").Where("status = 'Delivered'")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where("created_on >= ?", now.AddDate(0, -6, 0)) }
		return q.Select("TO_CHAR(created_on, 'Mon') as label, COUNT(*) as value").
			Group("TO_CHAR(created_on, 'Mon'), DATE_TRUNC('month', created_on)").
			Order("DATE_TRUNC('month', created_on)").
			Scan(&resp.Charts.DeliverySuccessTrend).Error
	})

	gCharts.Go(func() error {
		q := r.db.Table("deliveries").
			Joins("JOIN customers c ON deliveries.customer_id = c.id")
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() { q = q.Where("deliveries."+timeCondition, timeArgs...) }
		return q.Select("c.name as label, COUNT(*) as value").
			Group("c.name").
			Order("value DESC").
			Limit(5).
			Scan(&resp.Charts.TopDeliveryCustomers).Error
	})

	// 4. Widgets
	fetchDeliveries := func(statusFilter string, orderBy string, dest *[]models.DashboardDelivery) error {
		q := r.db.Table("deliveries").
			Select("deliveries.delivery_number, c.name as customer_name, deliveries.status, COALESCE(deliveries.delivery_date, deliveries.expected_delivery_date) as delivery_date, deliveries.expected_delivery_date").
			Joins("JOIN customers c ON deliveries.customer_id = c.id")
		
		if statusFilter != "" {
			if statusFilter == "Delayed" {
				q = q.Where("deliveries.expected_delivery_date < ? AND deliveries.status != 'Delivered' AND deliveries.status != 'Cancelled'", now)
			} else if statusFilter == "PendingAcks" {
				q = q.Where("deliveries.status = 'Delivered' AND deliveries.customer_acknowledgement = false")
			} else {
				q = q.Where("deliveries.status = ?", statusFilter)
			}
		}
		
		q = applyFilters(q, "deliveries")
		if !startDate.IsZero() {
			q = q.Where("deliveries."+timeCondition, timeArgs...)
		}
		return q.Order(orderBy).Limit(5).Scan(dest).Error
	}

	g.Go(func() error { return fetchDeliveries("Scheduled", "expected_delivery_date ASC", &resp.Widgets.UpcomingDeliveries) })
	g.Go(func() error { return fetchDeliveries("Delayed", "expected_delivery_date ASC", &resp.Widgets.DelayedDeliveries) })
	g.Go(func() error { return fetchDeliveries("Delivered", "deliveries.delivery_date DESC", &resp.Widgets.RecentlyDeliveredOrders) })
	g.Go(func() error { return fetchDeliveries("Cancelled", "deliveries.updated_on DESC", &resp.Widgets.CancelledDeliveries) })
	g.Go(func() error { return fetchDeliveries("PendingAcks", "deliveries.delivery_date DESC", &resp.Widgets.PendingCustomerAcks) })
	
	// Today's Deliveries Widget
	g.Go(func() error {
		todayStart := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		q := r.db.Table("deliveries").
			Select("deliveries.delivery_number, c.name as customer_name, deliveries.status, deliveries.expected_delivery_date as delivery_date, deliveries.expected_delivery_date").
			Joins("JOIN customers c ON deliveries.customer_id = c.id").
			Where("deliveries.expected_delivery_date >= ? AND deliveries.expected_delivery_date < ?", todayStart, todayStart.AddDate(0, 0, 1))
		q = applyFilters(q, "deliveries")
		return q.Order("expected_delivery_date ASC").Limit(5).Scan(&resp.Widgets.TodaysDeliveries).Error
	})

	// 5. Readiness Analytics (from Production Orders)
	g.Go(func() error {
		q := r.db.Table("production_orders").Select("status, COUNT(*) as count")
		q = applyFilters(q, "production_orders")
		// if filtering by time, we can apply to PO too if needed.
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
			if c.Status == "Ready for Delivery" {
				resp.Readiness.ReadyForDeliveryOrders = int(c.Count)
			}
		}
		return nil
	})

	if err := g.Wait(); err != nil {
		return nil, err
	}
	if err := gCharts.Wait(); err != nil {
		return nil, err
	}

	return resp, nil
}
