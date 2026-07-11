package models

import (
	"time"
)

type SalesOrder struct {
	ID                   string           `gorm:"primaryKey;type:varchar(50)" json:"id"`
	OrderNumber          string           `gorm:"type:varchar(50)" json:"order_number"`
	TenantID             string           `gorm:"type:varchar(50);not null" json:"tenant_id"`
	OrganizationID       string           `gorm:"type:varchar(50)" json:"organization_id"`
	CustomerID           string           `gorm:"type:varchar(50);not null" json:"customer_id"`
	Customer             Customer         `gorm:"foreignKey:CustomerID" json:"customer"`
	QuotationID          *string          `gorm:"type:varchar(50)" json:"quotation_id"`
	SalesPerson          string           `gorm:"type:varchar(100)" json:"sales_person"`
	Status               string           `gorm:"type:varchar(50);not null;default:'Draft'" json:"status"`
	OrderDate            time.Time        `gorm:"not null" json:"order_date"`
	ExpectedDeliveryDate *time.Time       `json:"expected_delivery_date"`
	Subtotal             float64          `gorm:"type:numeric(15,2);not null;default:0" json:"subtotal"`
	Discount             float64          `gorm:"type:numeric(15,2);not null;default:0" json:"discount"`
	Tax                  float64          `gorm:"type:numeric(15,2);not null;default:0" json:"tax"`
	TotalAmount          float64          `gorm:"type:numeric(15,2);not null;default:0" json:"total_amount"`
	Remarks              *string          `gorm:"type:text" json:"remarks"`
	Items                []SalesOrderItem `gorm:"foreignKey:SalesOrderID" json:"items"`
	CreatedBy            string           `gorm:"type:varchar(50)" json:"created_by"`
	CreatedOn            time.Time        `gorm:"autoCreateTime" json:"created_on"`
	UpdatedBy            string           `gorm:"type:varchar(50)" json:"updated_by"`
	UpdatedOn            time.Time        `gorm:"autoUpdateTime" json:"updated_on"`
	IsActive             bool             `gorm:"default:true" json:"is_active"`
}

type SalesOrderItem struct {
	ID           string  `gorm:"primaryKey;type:varchar(50)" json:"id"`
	SalesOrderID string  `gorm:"type:varchar(50);not null" json:"sales_order_id"`
	ProductID    string  `gorm:"type:varchar(50);not null" json:"product_id"`
	Product      Product `gorm:"foreignKey:ProductID" json:"product"`
	Quantity     int     `gorm:"not null;default:1" json:"quantity"`
	UnitPrice    float64 `gorm:"type:numeric(15,2);not null" json:"unit_price"`
	TotalPrice   float64 `gorm:"type:numeric(15,2);not null" json:"total_price"`
}
