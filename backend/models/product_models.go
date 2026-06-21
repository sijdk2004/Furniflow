package models

import "github.com/google/uuid"

type Product struct {
	BaseModel
	OrganizationID *string     `gorm:"size:50" json:"organization_id"`
	ProductCode    string      `gorm:"size:50;not null" json:"product_code"`
	ProductName    string      `gorm:"size:200;not null" json:"product_name"`
	CategoryID     *uuid.UUID  `gorm:"type:uuid" json:"category_id"`
	Category       *MasterData `gorm:"foreignKey:CategoryID" json:"category,omitempty"`
	WoodTypeID     *uuid.UUID  `gorm:"type:uuid" json:"wood_type_id"`
	WoodType       *MasterData `gorm:"foreignKey:WoodTypeID" json:"wood_type,omitempty"`
	UOMID          *uuid.UUID  `gorm:"type:uuid" json:"uom_id"`
	UOM            *MasterData `gorm:"foreignKey:UOMID" json:"uom,omitempty"`
	BasePrice      float64     `gorm:"type:decimal(15,2);default:0.0" json:"base_price"`
	Description    *string     `gorm:"type:text" json:"description"`
	ImageURL       *string     `gorm:"size:500" json:"image_url"`
}
