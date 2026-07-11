package dtos

import "time"

type QuotationItemRequest struct {
	ProductID string  `json:"product_id" validate:"required"`
	Quantity  int     `json:"quantity" validate:"required,min=1"`
	UnitPrice float64 `json:"unit_price" validate:"required,min=0"`
}

type QuotationRequest struct {
	QuotationNumber *string                `json:"quotation_number"`
	CustomerID      string                 `json:"customer_id" validate:"required"`
	SalesPerson     *string                `json:"sales_person"`
	ValidUntil      time.Time              `json:"valid_until" validate:"required"`
	Discount        float64                `json:"discount" validate:"min=0"`
	Tax             float64                `json:"tax" validate:"min=0"`
	AdvanceAmount   float64                `json:"advance_amount" validate:"min=0"`
	Notes           *string                `json:"notes"`
	Items           []QuotationItemRequest `json:"items" validate:"required,min=1,dive"`
}

type QuotationStatusUpdateRequest struct {
	Status string `json:"status" validate:"required,oneof=Draft Submitted Approved Converted Rejected"`
}
