package models

import (
	"time"
)

// DeliveryDashboardFilterRequest captures frontend filter options for the delivery dashboard
type DeliveryDashboardFilterRequest struct {
	Timeframe      string     `json:"timeframe"` // e.g., "1M", "3M", "YTD", "1Y"
	OrganizationID *string    `json:"organization_id,omitempty"`
	UserID         string     `json:"-"`
	CustomerID     *string    `json:"customer_id,omitempty"`
	Status         *string    `json:"status,omitempty"`
	Driver         *string    `json:"driver,omitempty"`
	Vehicle        *string    `json:"vehicle,omitempty"`
	SalesOrderID   *string    `json:"sales_order_id,omitempty"`
	StartDate      *time.Time `json:"start_date,omitempty"`
	EndDate        *time.Time `json:"end_date,omitempty"`
}

// DeliveryKPIs represents the top-level delivery metrics
type DeliveryKPIs struct {
	TotalDeliveries      int     `json:"total_deliveries"`
	ScheduledDeliveries  int     `json:"scheduled_deliveries"`
	InTransitDeliveries  int     `json:"in_transit_deliveries"`
	DeliveredOrders      int     `json:"delivered_orders"`
	CancelledDeliveries  int     `json:"cancelled_deliveries"`
	TodaysDeliveries     int     `json:"todays_deliveries"`
	ThisWeekDeliveries   int     `json:"this_week_deliveries"`
	DeliverySuccessRate  float64 `json:"delivery_success_rate"`
	AverageDeliveryTime  float64 `json:"average_delivery_time"`
	OnTimeDeliveryPct    float64 `json:"on_time_delivery_pct"`
	DelayedDeliveriesPct float64 `json:"delayed_deliveries_pct"`
	DeliveryCompletionPct float64 `json:"delivery_completion_pct"`
}

// DeliveryCharts represents all chart data formats
type DeliveryCharts struct {
	DeliveryStatusDistribution []ChartDataPoint `json:"delivery_status_distribution"`
	MonthlyDeliveryTrend       []ChartDataPoint `json:"monthly_delivery_trend"`
	DeliverySuccessTrend       []ChartDataPoint `json:"delivery_success_trend"`
	CancelledDeliveriesTrend   []ChartDataPoint `json:"cancelled_deliveries_trend"`
	DeliveryVolumeByMonth      []ChartDataPoint `json:"delivery_volume_by_month"`
	TopDeliveryCustomers       []ChartDataPoint `json:"top_delivery_customers"`
}

// DashboardDelivery represents a delivery in widgets
type DashboardDelivery struct {
	DeliveryNumber       string    `json:"delivery_number"`
	CustomerName         string    `json:"customer_name"`
	Status               string    `json:"status"`
	DeliveryDate         time.Time `json:"delivery_date"`
	ExpectedDeliveryDate time.Time `json:"expected_delivery_date"`
}

// CustomerDeliveryAnalytic represents a customer's delivery stats
type CustomerDeliveryAnalytic struct {
	CustomerName      string  `json:"customer_name"`
	TotalDeliveries   int     `json:"total_deliveries"`
	SuccessRate       float64 `json:"success_rate"`
	PendingAcks       int     `json:"pending_acknowledgements"`
}

// DeliveryWidgets represents the raw lists/tables for widgets
type DeliveryWidgets struct {
	TodaysDeliveries              []DashboardDelivery        `json:"todays_deliveries"`
	UpcomingDeliveries            []DashboardDelivery        `json:"upcoming_deliveries"`
	DelayedDeliveries             []DashboardDelivery        `json:"delayed_deliveries"`
	RecentlyDeliveredOrders       []DashboardDelivery        `json:"recently_delivered_orders"`
	CancelledDeliveries           []DashboardDelivery        `json:"cancelled_deliveries"`
	PendingCustomerAcks           []DashboardDelivery        `json:"pending_customer_acknowledgements"`
	TopCustomersByDeliveries      []CustomerDeliveryAnalytic `json:"top_customers_by_deliveries"`
	CustomerDeliveryHistory       []DashboardDelivery        `json:"customer_delivery_history"`
}

// DeliveryReadinessAnalytics represents production_orders ready for delivery
type DeliveryReadinessAnalytics struct {
	ReadyForDeliveryOrders       int `json:"ready_for_delivery_orders"`
	AwaitingDispatch             int `json:"awaiting_dispatch"`
	AwaitingCustomerConfirmation int `json:"awaiting_customer_confirmation"`
	InTransit                    int `json:"in_transit"`
	Delivered                    int `json:"delivered"`
}

// DeliveryDashboardResponse is the combined payload
type DeliveryDashboardResponse struct {
	KPIs      DeliveryKPIs               `json:"kpis"`
	Charts    DeliveryCharts             `json:"charts"`
	Widgets   DeliveryWidgets            `json:"widgets"`
	Readiness DeliveryReadinessAnalytics `json:"readiness"`
}
