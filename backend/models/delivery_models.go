package models

import (
	"time"

	"github.com/google/uuid"
)

type Delivery struct {
	BaseModel
	DeliveryNumber          string     `gorm:"type:varchar(50);unique;not null" json:"delivery_number"`
	QuotationID             *string    `gorm:"type:varchar(50)" json:"quotation_id"`
	SalesOrderID            *string    `gorm:"type:varchar(50)" json:"sales_order_id"`
	ProductionOrderID       uuid.UUID  `gorm:"type:uuid;not null" json:"production_order_id"`
	CustomerID              uuid.UUID  `gorm:"type:uuid;not null" json:"customer_id"`
	
	DeliveryDate            *time.Time `gorm:"type:timestamp" json:"delivery_date"`
	ExpectedDeliveryDate    time.Time  `gorm:"type:timestamp;not null" json:"expected_delivery_date"`
	Status                  string     `gorm:"type:varchar(50);not null;default:'Scheduled'" json:"status"`
	AssignedVehicle         *string    `gorm:"type:varchar(100)" json:"assigned_vehicle"`
	AssignedDriver          *string    `gorm:"type:varchar(100)" json:"assigned_driver"`
	DeliveryNotes           *string    `gorm:"type:text" json:"delivery_notes"`
	CustomerAcknowledgement bool       `gorm:"default:false" json:"customer_acknowledgement"`
}

type DeliveryTimelineHistory struct {
	ID        uuid.UUID  `gorm:"type:uuid;primary_key;default:uuid_generate_v4()" json:"id"`
	TenantID  string     `gorm:"type:varchar(50);not null" json:"tenant_id"`
	DeliveryID uuid.UUID `gorm:"type:uuid;not null" json:"delivery_id"`
	Stage     string     `gorm:"type:varchar(50);not null" json:"stage"`
	Timestamp time.Time  `gorm:"type:timestamp;default:CURRENT_TIMESTAMP" json:"timestamp"`
	UserID    *uuid.UUID `gorm:"type:uuid" json:"user_id"`
	Remarks   *string    `gorm:"type:text" json:"remarks"`
}

type CreateDeliveryRequest struct {
	ProductionOrderID    uuid.UUID `json:"production_order_id" validate:"required"`
	ExpectedDeliveryDate time.Time `json:"expected_delivery_date" validate:"required"`
	AssignedVehicle      *string   `json:"assigned_vehicle"`
	AssignedDriver       *string   `json:"assigned_driver"`
	DeliveryNotes        *string   `json:"delivery_notes"`
}

type UpdateDeliveryStatusRequest struct {
	Status                  string  `json:"status" validate:"required"`
	Remarks                 *string `json:"remarks"`
	CustomerAcknowledgement bool    `json:"customer_acknowledgement"`
}

type DeliveryDetailResponse struct {
	Delivery
	CustomerName      string                    `json:"customer_name"`
	Product           string                    `json:"product"`
	OrderNumber       string                    `json:"order_number"`
	Histories         []DeliveryTimelineHistory `json:"histories"`
}
