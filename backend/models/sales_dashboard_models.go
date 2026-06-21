package models

import (
	"time"
)

// SalesDashboardFilterRequest captures frontend filter options for the sales dashboard
type SalesDashboardFilterRequest struct {
	Timeframe      string     `json:"timeframe"` // e.g., "1M", "3M", "YTD", "1Y", "ALL"
	CustomerID     *string    `json:"customer_id,omitempty"`
	OrganizationID *string    `json:"organization_id,omitempty"`
	UserID         string     `json:"-"`
	ProductID      *string    `json:"product_id,omitempty"`
	Status         *string    `json:"status,omitempty"`
	StartDate      *time.Time `json:"start_date,omitempty"`
	EndDate        *time.Time `json:"end_date,omitempty"`
	SalesRepID     *string    `json:"sales_rep_id,omitempty"`
}

// SalesKPIs represents the top-level sales metrics
type SalesKPIs struct {
	TotalCustomers          int     `json:"total_customers"`
	CustomersGrowth         float64 `json:"customers_growth"`
	ActiveQuotations        int     `json:"active_quotations"`
	QuotationsGrowth        float64 `json:"quotations_growth"`
	ApprovedQuotations      int     `json:"approved_quotations"`
	RejectedQuotations      int     `json:"rejected_quotations"`
	ConvertedQuotations     int     `json:"converted_quotations"`
	SalesOrders             int     `json:"sales_orders"`
	SalesOrdersGrowth       float64 `json:"sales_orders_growth"`
	QuotationConversionRate float64 `json:"quotation_conversion_rate"`
	TotalSalesRevenue       float64 `json:"total_sales_revenue"`
	RevenueGrowth           float64 `json:"revenue_growth"`
	MonthlySalesRevenue     float64 `json:"monthly_sales_revenue"`
	AverageOrderValue       float64 `json:"average_order_value"`
}

// SalesCharts represents all chart data formats
type SalesCharts struct {
	MonthlyRevenueTrend         []ChartDataPoint `json:"monthly_revenue_trend"`
	QuotationTrend              []ChartDataPoint `json:"quotation_trend"`
	QuotationStatusDistribution []ChartDataPoint `json:"quotation_status_distribution"`
	QuotationConversionFunnel   []ChartDataPoint `json:"quotation_conversion_funnel"`
	SalesOrderTrend             []ChartDataPoint `json:"sales_order_trend"`
	TopCustomers                []ChartDataPoint `json:"top_customers"`
	TopProducts                 []ChartDataPoint `json:"top_products"`
}

type DashboardQuotation struct {
	QuotationNumber string    `json:"quotation_number"`
	Customer        string    `json:"customer"`
	Amount          float64   `json:"amount"`
	Date            time.Time `json:"date"`
	Status          string    `json:"status"`
}

type DashboardOrder struct {
	OrderNumber string    `json:"order_number"`
	Customer    string    `json:"customer"`
	Amount      float64   `json:"amount"`
	Date        time.Time `json:"date"`
	Status      string    `json:"status"`
}

// SalesWidgets represents the raw lists/tables for widgets
type SalesWidgets struct {
	RecentQuotations          []DashboardQuotation  `json:"recent_quotations"`
	RecentSalesOrders         []DashboardOrder      `json:"recent_sales_orders"`
	PendingQuotationApprovals []DashboardQuotation  `json:"pending_quotation_approvals"`
	ExpiringQuotations        []DashboardQuotation  `json:"expiring_quotations"`
}

// SalesDashboardResponse is the combined payload
type SalesDashboardResponse struct {
	KPIs    SalesKPIs    `json:"kpis"`
	Charts  SalesCharts  `json:"charts"`
	Widgets SalesWidgets `json:"widgets"`
}
