package models

import (
	"time"
)

// DashboardFilterRequest captures frontend filter options
type DashboardFilterRequest struct {
	Timeframe      string     `json:"timeframe"` // e.g., "1M", "3M", "YTD", "1Y", "ALL"
	CustomerID     *string    `json:"customer_id,omitempty"`
	OrganizationID *string    `json:"organization_id,omitempty"`
	UserID         string     `json:"-"`
	ProductID      *string    `json:"product_id,omitempty"`
	Status         *string    `json:"status,omitempty"`
	StartDate      *time.Time `json:"start_date,omitempty"`
	EndDate        *time.Time `json:"end_date,omitempty"`
}

// ExecutiveKPIs represents the top-level metrics
type ExecutiveKPIs struct {
	TotalCustomers      int     `json:"total_customers"`
	ActiveQuotations    int     `json:"active_quotations"`
	SalesOrders         int     `json:"sales_orders"`
	ProductionOrders    int     `json:"production_orders"`
	ReadyForDelivery    int     `json:"ready_for_delivery"`
	DeliveredOrders     int     `json:"delivered_orders"`
	TotalRevenue        float64 `json:"total_revenue"`
	MonthlyRevenue      float64 `json:"monthly_revenue"`
	// Additional computed percentages for UI trends (mocked as +5%, etc. if no historical comparison is implemented, but we'll leave fields for them)
	RevenueGrowth       float64 `json:"revenue_growth"`
	ActiveOrdersGrowth  float64 `json:"active_orders_growth"`
	QuotationsGrowth    float64 `json:"quotations_growth"`
	CustomersGrowth     float64 `json:"customers_growth"`
}

// ChartDataPoint generic point for charts
type ChartDataPoint struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}

type RevenueTrendNode struct {
	Label    string             `json:"label"`
	Value    float64            `json:"value"`
	Children []RevenueTrendNode `json:"children,omitempty"`
}

// DashboardCharts represents all chart data
type DashboardCharts struct {
	HierarchicalSalesTrend       []RevenueTrendNode `json:"hierarchical_sales_trend"`
	MonthlySalesTrend            []ChartDataPoint   `json:"monthly_sales_trend"` // keep for fallback/backward compatibility if needed
	QuotationConversionTrend     []ChartDataPoint   `json:"quotation_conversion_trend"`
	ProductionStatusDistribution []ChartDataPoint   `json:"production_status_distribution"`
	DeliveryStatusDistribution   []ChartDataPoint   `json:"delivery_status_distribution"`
	TopCustomers                 []ChartDataPoint   `json:"top_customers"`
	TopProducts                  []ChartDataPoint   `json:"top_products"`
}

// DashboardWidgetData for lists and tables
type RecentOrderWidget struct {
	OrderNumber string    `json:"order_number"`
	Customer    string    `json:"customer"`
	Amount      float64   `json:"amount"`
	Date        time.Time `json:"date"`
	Status      string    `json:"status"`
}

type RecentDeliveryWidget struct {
	DeliveryNumber string    `json:"delivery_number"`
	Customer       string    `json:"customer"`
	ExpectedDate   time.Time `json:"expected_date"`
	Status         string    `json:"status"`
}

type PendingApprovalWidget struct {
	QuotationNumber string    `json:"quotation_number"`
	Customer        string    `json:"customer"`
	Amount          float64   `json:"amount"`
	Date            time.Time `json:"date"`
}

type DelayedProductionWidget struct {
	OrderNumber  string    `json:"order_number"`
	Product      string    `json:"product"`
	ExpectedDate time.Time `json:"expected_date"`
	Status       string    `json:"status"`
}

type DelayedDeliveryWidget struct {
	DeliveryNumber string    `json:"delivery_number"`
	Customer       string    `json:"customer"`
	ExpectedDate   time.Time `json:"expected_date"`
	Status         string    `json:"status"`
}

// DashboardWidgets contains all widget data lists
type DashboardWidgets struct {
	RecentOrders          []RecentOrderWidget       `json:"recent_orders"`
	RecentDeliveries      []RecentDeliveryWidget    `json:"recent_deliveries"`
	PendingApprovals      []PendingApprovalWidget   `json:"pending_approvals"`
	DelayedProduction     []DelayedProductionWidget `json:"delayed_production"`
	DelayedDeliveries     []DelayedDeliveryWidget   `json:"delayed_deliveries"`
}

// DashboardResponse aggregates KPIs, Charts, and Widgets
type DashboardResponse struct {
	KPIs    ExecutiveKPIs    `json:"kpis"`
	Charts  DashboardCharts  `json:"charts"`
	Widgets DashboardWidgets `json:"widgets"`
}
