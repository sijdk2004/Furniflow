package models

type MasterData struct {
	BaseModel
	Type        string `gorm:"type:varchar(50);not null;index:idx_master_data_type" json:"type"`
	Code        string `gorm:"type:varchar(50);not null" json:"code"`
	Name        string `gorm:"type:varchar(100);not null" json:"name"`
	Description string `gorm:"type:text" json:"description"`
	SortOrder   int    `gorm:"default:0" json:"sort_order"`
}
