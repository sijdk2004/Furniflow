package models

import (
	"time"
)

// ManufacturingDashboardFilterRequest captures frontend filter options for the manufacturing dashboard
type ManufacturingDashboardFilterRequest struct {
	Timeframe      string     `json:"timeframe"` // e.g., "1M", "3M", "YTD", "1Y"
	OrganizationID *string    `json:"organization_id,omitempty"`
	UserID         string     `json:"-"`
	ProductID      *string    `json:"product_id,omitempty"`
	Status         *string    `json:"status,omitempty"`
	Stage          *string    `json:"stage,omitempty"`
	AssignedTeam   *string    `json:"assigned_team,omitempty"`
	AssignedEmp    *string    `json:"assigned_employee,omitempty"`
	StartDate      *time.Time `json:"start_date,omitempty"`
	EndDate        *time.Time `json:"end_date,omitempty"`
}

// ManufacturingKPIs represents the top-level manufacturing metrics
type ManufacturingKPIs struct {
	TotalProductionOrders int     `json:"total_production_orders"`
	ReleasedOrders        int     `json:"released_orders"`
	InProgressOrders      int     `json:"in_progress_orders"`
	CompletedOrders       int     `json:"completed_orders"`
	OnHoldOrders          int     `json:"on_hold_orders"`
	ReadyForDelivery      int     `json:"ready_for_delivery_orders"`
	AverageProductionTime float64 `json:"average_production_time"` // in hours or days, will use hours
	ProductionEfficiency  float64 `json:"production_efficiency_percentage"`
}

// StageAnalyticsItem represents analytics for a specific production stage
type StageAnalyticsItem struct {
	StageName      string  `json:"stage_name"`
	OrderCount     int     `json:"order_count"`
	AverageDuration float64 `json:"average_duration"` // hours
	DelayedOrders  int     `json:"delayed_orders"`
}

// DashboardProductionOrder represents an order in widgets
type DashboardProductionOrder struct {
	OrderNumber  string    `json:"order_number"`
	Product      string    `json:"product"`
	Status       string    `json:"status"`
	CurrentStage string    `json:"current_stage"`
	StartDate    time.Time `json:"start_date"`
	TargetDate   time.Time `json:"target_date"`
}

// DashboardDelayItem represents delayed analysis items
type DashboardDelayItem struct {
	EntityName string  `json:"entity_name"` // e.g. Stage name or Product name
	DelayCount int     `json:"delay_count"`
	AvgDelay   float64 `json:"average_delay_duration"` // hours
}

// ManufacturingCharts represents all chart data formats
type ManufacturingCharts struct {
	ProductionStatusDistribution []ChartDataPoint `json:"production_status_distribution"`
	ProductionStageDistribution  []ChartDataPoint `json:"production_stage_distribution"`
	ProductionTrendByMonth       []ChartDataPoint `json:"production_trend_by_month"`
	ProductionCompletionTrend    []ChartDataPoint `json:"production_completion_trend"`
	OnHoldTrend                  []ChartDataPoint `json:"on_hold_trend"`
	ProductionEfficiencyTrend    []ChartDataPoint `json:"production_efficiency_trend"`
}

// ManufacturingWidgets represents the raw lists/tables for widgets
type ManufacturingWidgets struct {
	StageAnalytics             []StageAnalyticsItem       `json:"stage_analytics"`
	CurrentProductionQueue     []DashboardProductionOrder `json:"current_production_queue"`
	OrdersOnHold               []DashboardProductionOrder `json:"orders_on_hold"`
	DelayedProductionOrders    []DashboardProductionOrder `json:"delayed_production_orders"`
	OrdersReadyForDelivery     []DashboardProductionOrder `json:"orders_ready_for_delivery"`
	RecentlyCompletedOrders    []DashboardProductionOrder `json:"recently_completed_orders"`
	OrdersAwaitingQC           []DashboardProductionOrder `json:"orders_awaiting_quality_inspection"`
	OrdersAwaitingPacking      []DashboardProductionOrder `json:"orders_awaiting_packing"`
	OrdersAwaitingDispatch     []DashboardProductionOrder `json:"orders_awaiting_dispatch"`
	MostDelayedProducts        []DashboardDelayItem       `json:"most_delayed_products"`
	MostDelayedStages          []DashboardDelayItem       `json:"most_delayed_stages"`
}

// ManufacturingDashboardResponse is the combined payload
type ManufacturingDashboardResponse struct {
	KPIs    ManufacturingKPIs    `json:"kpis"`
	Charts  ManufacturingCharts  `json:"charts"`
	Widgets ManufacturingWidgets `json:"widgets"`
}
