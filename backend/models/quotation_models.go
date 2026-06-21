package models

import (
	"time"
)

type Quotation struct {
	ID             string          `gorm:"primaryKey;type:varchar(50)" json:"id"`
	TenantID       string          `gorm:"type:varchar(50);not null" json:"tenant_id"`
	OrganizationID string          `gorm:"type:varchar(50)" json:"organization_id"`
	CustomerID     string          `gorm:"type:varchar(50);not null" json:"customer_id"`
	Customer       Customer        `gorm:"foreignKey:CustomerID" json:"customer"`
	Status         string          `gorm:"type:varchar(50);not null;default:'Draft'" json:"status"`
	DateCreated    time.Time       `gorm:"not null" json:"date_created"`
	ValidUntil     time.Time       `gorm:"not null" json:"valid_until"`
	Subtotal       float64         `gorm:"type:numeric(15,2);not null;default:0" json:"subtotal"`
	Discount       float64         `gorm:"type:numeric(15,2);not null;default:0" json:"discount"`
	Tax            float64         `gorm:"type:numeric(15,2);not null;default:0" json:"tax"`
	Total          float64         `gorm:"type:numeric(15,2);not null;default:0" json:"total"`
	Notes          *string         `gorm:"type:text" json:"notes"`
	Items          []QuotationItem `gorm:"foreignKey:QuotationID" json:"items"`
	CreatedBy      string          `gorm:"type:varchar(50)" json:"created_by"`
	CreatedOn      time.Time       `gorm:"autoCreateTime" json:"created_on"`
	UpdatedBy      string          `gorm:"type:varchar(50)" json:"updated_by"`
	UpdatedOn      time.Time       `gorm:"autoUpdateTime" json:"updated_on"`
	IsActive       bool            `gorm:"default:true" json:"is_active"`
}

type QuotationItem struct {
	ID          string    `gorm:"primaryKey;type:varchar(50)" json:"id"`
	QuotationID string    `gorm:"type:varchar(50);not null" json:"quotation_id"`
	ProductID   string    `gorm:"type:varchar(50);not null" json:"product_id"`
	Product     Product   `gorm:"foreignKey:ProductID" json:"product"`
	Quantity    int       `gorm:"not null;default:1" json:"quantity"`
	UnitPrice   float64   `gorm:"type:numeric(15,2);not null" json:"unit_price"`
	TotalPrice  float64   `gorm:"type:numeric(15,2);not null" json:"total_price"`
}
