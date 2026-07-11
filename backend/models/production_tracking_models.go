package models

import (
	"time"

	"github.com/google/uuid"
)

// ProductionTracking tracks the current manufacturing stage of a production order
type ProductionTracking struct {
	BaseModel
	ProductionOrderID    uuid.UUID   `gorm:"type:uuid;not null;unique" json:"production_order_id"`
	CurrentStage         string      `gorm:"type:varchar(100);not null" json:"current_stage"`
	AssignedTeam         *string     `gorm:"type:varchar(100)" json:"assigned_team"`
	AssignedEmployeeID   *uuid.UUID  `gorm:"type:uuid" json:"assigned_employee_id"`
	CompletionPercentage int         `gorm:"type:integer;default:0" json:"completion_percentage"`
	IsOnHold             bool        `gorm:"type:boolean;default:false" json:"is_on_hold"`
	StageStartDate       *time.Time  `gorm:"type:timestamp" json:"stage_start_date"`
	StageEndDate         *time.Time  `gorm:"type:timestamp" json:"stage_end_date"`

	// Associations
	ProductionOrder *ProductionOrder         `gorm:"foreignKey:ProductionOrderID" json:"production_order,omitempty"`
	Histories       []ProductionStageHistory `gorm:"foreignKey:TrackingID" json:"histories,omitempty"`
}

// ProductionStageHistory holds immutable logs of stage transitions
type ProductionStageHistory struct {
	BaseModel
	TrackingID         uuid.UUID   `gorm:"type:uuid;not null" json:"tracking_id"`
	Stage              string      `gorm:"type:varchar(100);not null" json:"stage"`
	StageEnteredAt     time.Time   `gorm:"type:timestamp;not null" json:"stage_entered_at"`
	StageStartedAt     *time.Time  `gorm:"type:timestamp" json:"stage_started_at"`
	StageCompletedAt   *time.Time  `gorm:"type:timestamp" json:"stage_completed_at"`
	DurationMinutes    *int        `gorm:"type:integer" json:"duration_minutes"`
	DelayReason        *string     `gorm:"type:varchar(255)" json:"delay_reason"`
	CompletedByUserID  *uuid.UUID  `gorm:"type:uuid" json:"completed_by_user_id"`
}

// Data Transfer Objects

type CreateProductionTrackingRequest struct {
	ProductionOrderID uuid.UUID `json:"production_order_id" validate:"required"`
}

type UpdateTrackingStageRequest struct {
	NextStage          string      `json:"next_stage" validate:"required"`
	AssignedTeam       *string     `json:"assigned_team"`
	AssignedEmployeeID *uuid.UUID  `json:"assigned_employee_id"`
	Remarks            *string     `json:"remarks"`
	DelayReason        *string     `json:"delay_reason"`
}

type ToggleHoldRequest struct {
	IsOnHold bool   `json:"is_on_hold"`
	Reason   string `json:"reason"`
}

type CompleteStageRequest struct {
	Remarks     *string `json:"remarks"`
	DelayReason *string `json:"delay_reason"`
}

type UpdateCompletionRequest struct {
	CompletionPercentage int `json:"completion_percentage" validate:"required,min=0,max=100"`
}

// Board Item DTO
type ProductionBoardItem struct {
	TrackingID           uuid.UUID `json:"tracking_id"`
	ProductionOrderID    uuid.UUID `json:"production_order_id"`
	OrderNumber          string    `json:"order_number"` // This doesn't exist natively, mapped from ID or PO reference
	SalesOrderID         *string   `json:"sales_order_id"`
	ProductID            uuid.UUID `json:"product_id"`
	ProductName          string    `json:"product_name"`
	CustomerName         string    `json:"customer_name"`
	CurrentStage         string    `json:"current_stage"`
	Status               string    `json:"status"`
	PlannedEndDate       *time.Time`json:"planned_end_date"`
	CompletionPercentage int       `json:"completion_percentage"`
	IsOnHold             bool      `json:"is_on_hold"`
	AssignedTeam         *string   `json:"assigned_team"`
}
