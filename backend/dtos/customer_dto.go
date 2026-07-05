package dtos

type CustomerRequest struct {
	CustomerTypeID *string  `json:"customer_type_id" validate:"omitempty,uuid"`
	Name           string   `json:"name" validate:"required,min=2,max=200"`
	Email          *string  `json:"email" validate:"omitempty,email"`
	Phone          *string  `json:"phone" validate:"omitempty,max=50"`
	AddressLine1   *string  `json:"address_line1" validate:"omitempty,max=255"`
	AddressLine2   *string  `json:"address_line2" validate:"omitempty,max=255"`
	CountryID      *string  `json:"country_id" validate:"omitempty,uuid"`
	StateID        *string  `json:"state_id" validate:"omitempty,uuid"`
	CityID         *string  `json:"city_id" validate:"omitempty,uuid"`
	CustomCityName *string  `json:"custom_city_name" validate:"omitempty,max=100"`
	ZipCode        *string  `json:"zip_code" validate:"omitempty,max=20"`
	TaxID          *string  `json:"tax_id" validate:"omitempty,max=50"`
	CreditLimit    float64  `json:"credit_limit" validate:"omitempty,min=0"`
	IsActive       bool     `json:"is_active"`
}
