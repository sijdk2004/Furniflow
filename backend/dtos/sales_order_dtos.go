package dtos

import (
	"time"
)

type SalesOrderUpdateRequest struct {
	ExpectedDeliveryDate *time.Time               `json:"expected_delivery_date"`
	Remarks              *string                  `json:"remarks"`
	Discount             float64                  `json:"discount"`
	Items                []SalesOrderItemRequest  `json:"items"`
}

type SalesOrderItemRequest struct {
	ProductID string  `json:"product_id" binding:"required"`
	Quantity  int     `json:"quantity" binding:"required,min=1"`
	UnitPrice float64 `json:"unit_price" binding:"required"`
}

type SalesOrderStatusUpdateRequest struct {
	Status string `json:"status" binding:"required,oneof=Confirmed 'In Production' 'Ready For Delivery' Delivered Cancelled"`
}
