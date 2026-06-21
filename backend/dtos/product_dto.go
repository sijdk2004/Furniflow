package dtos

type ProductRequest struct {
	ProductCode  string  `json:"product_code" validate:"required,max=50"`
	ProductName  string  `json:"product_name" validate:"required,max=200"`
	CategoryID   *string `json:"category_id" validate:"omitempty,uuid"`
	WoodTypeID   *string `json:"wood_type_id" validate:"omitempty,uuid"`
	UOMID        *string `json:"uom_id" validate:"omitempty,uuid"`
	BasePrice    float64 `json:"base_price" validate:"min=0"`
	Description  *string `json:"description" validate:"omitempty"`
	ImageURL     *string `json:"image_url" validate:"omitempty,max=500"`
	IsActive     bool    `json:"is_active"`
}
