package models

import (
	"github.com/google/uuid"
)

// BOM (Bill of Materials) model
type BOM struct {
	BaseModel
	ProductID     string  `gorm:"type:uuid;not null;index" json:"product_id"`
	Product       Product `gorm:"foreignKey:ProductID" json:"product,omitempty"`
	VersionNumber int     `gorm:"default:1;not null" json:"version_number"`
	ActiveVersion bool    `gorm:"default:false" json:"active_version"`
	Status        string  `gorm:"type:varchar(50);default:'Draft';not null" json:"status"` // Draft, Approved, Active
	MaterialCost  float64 `gorm:"type:decimal(12,2);default:0" json:"material_cost"`
	LaborCost     float64 `gorm:"type:decimal(12,2);default:0" json:"labor_cost"`
	OverheadCost  float64 `gorm:"type:decimal(12,2);default:0" json:"overhead_cost"`
	TotalCost     float64 `gorm:"type:decimal(12,2);default:0" json:"total_cost"`

	Items []BOMItem `gorm:"foreignKey:BOMID" json:"items"`
}

// BOMItem model
type BOMItem struct {
	ID          uuid.UUID   `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	BOMID       string      `gorm:"type:uuid;not null;index" json:"bom_id"`
	ComponentID string      `gorm:"type:uuid;not null" json:"component_id"`
	Component   Product     `gorm:"foreignKey:ComponentID" json:"component,omitempty"`
	Quantity    float64     `gorm:"type:decimal(10,2);not null" json:"quantity"`
	UomID       string      `gorm:"type:uuid;not null" json:"uom_id"`
	Uom         MasterData  `gorm:"foreignKey:UomID" json:"uom,omitempty"`
	UnitCost    float64     `gorm:"type:decimal(12,2);default:0" json:"unit_cost"`
	TotalCost   float64     `gorm:"type:decimal(12,2);default:0" json:"total_cost"`
}

// DTOs
type CreateBOMRequest struct {
	ProductID    string               `json:"product_id" binding:"required"`
	MaterialCost float64              `json:"material_cost"`
	LaborCost    float64              `json:"labor_cost"`
	OverheadCost float64              `json:"overhead_cost"`
	Remarks      *string              `json:"remarks"`
	Items        []CreateBOMItemRequest `json:"items" binding:"required,min=1"`
}

type CreateBOMItemRequest struct {
	ComponentID string  `json:"component_id" binding:"required"`
	Quantity    float64 `json:"quantity" binding:"required,gt=0"`
	UomID       string  `json:"uom_id" binding:"required"`
	UnitCost    float64 `json:"unit_cost"`
}

type UpdateBOMStatusRequest struct {
	Status string `json:"status" binding:"required,oneof=Draft Approved Active"`
}
