package dtos

type MasterDataRequest struct {
	Code        string `json:"code" validate:"required,min=2,max=50"`
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	SortOrder   int    `json:"sort_order"`
	IsActive    bool   `json:"is_active"`
}
