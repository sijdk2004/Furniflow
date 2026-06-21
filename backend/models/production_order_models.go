package models

import (
	"time"
)

// ProductionOrder model
type ProductionOrder struct {
	BaseModel
	SalesOrderID       *string   `gorm:"type:varchar(50)" json:"sales_order_id,omitempty"`
	ProductID          string    `gorm:"type:uuid;not null;index" json:"product_id"`
	Product            Product   `gorm:"foreignKey:ProductID" json:"product,omitempty"`
	BOMID              string    `gorm:"type:uuid;not null" json:"bom_id"`
	BOMVersion         int       `gorm:"not null" json:"bom_version"`
	Quantity           int       `gorm:"not null;default:1" json:"quantity"`
	PlannedStartDate   *time.Time `json:"planned_start_date,omitempty"`
	PlannedEndDate     *time.Time `json:"planned_end_date,omitempty"`
	Status             string    `gorm:"type:varchar(50);not null;default:'Draft'" json:"status"` // Draft, Released, In Progress, Completed, Cancelled
	MaterialCost       float64   `gorm:"type:decimal(12,2);default:0" json:"material_cost"`
	LaborCost          float64   `gorm:"type:decimal(12,2);default:0" json:"labor_cost"`
	OverheadCost       float64   `gorm:"type:decimal(12,2);default:0" json:"overhead_cost"`
	TotalCost          float64   `gorm:"type:decimal(12,2);default:0" json:"total_cost"`
}

// DTOs
type CreateProductionOrderRequest struct {
	SalesOrderID     *string    `json:"sales_order_id"`
	ProductID        string     `json:"product_id" binding:"required"`
	Quantity         int        `json:"quantity" binding:"required,gt=0"`
	PlannedStartDate *time.Time `json:"planned_start_date"`
	PlannedEndDate   *time.Time `json:"planned_end_date"`
	Remarks          *string    `json:"remarks"`
}

type UpdateProductionOrderStatusRequest struct {
	Status string `json:"status" binding:"required,oneof=Draft Released 'In Progress' Completed Cancelled"`
}
