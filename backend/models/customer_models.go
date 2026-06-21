package models

import (
	"github.com/google/uuid"
)

type Country struct {
	BaseModel
	Code string `gorm:"uniqueIndex:idx_tenant_country_code;size:10;not null" json:"code"`
	Name string `gorm:"size:100;not null" json:"name"`
}

type State struct {
	BaseModel
	CountryID uuid.UUID `gorm:"type:uuid;not null" json:"country_id"`
	Country   Country   `gorm:"foreignKey:CountryID" json:"country,omitempty"`
	Code      string    `gorm:"uniqueIndex:idx_tenant_state_code;size:10;not null" json:"code"`
	Name      string    `gorm:"size:100;not null" json:"name"`
}

type City struct {
	BaseModel
	StateID uuid.UUID `gorm:"type:uuid;not null" json:"state_id"`
	State   State     `gorm:"foreignKey:StateID" json:"state,omitempty"`
	Code    string    `gorm:"uniqueIndex:idx_tenant_city_code;size:10;not null" json:"code"`
	Name    string    `gorm:"size:100;not null" json:"name"`
}

type Customer struct {
	BaseModel
	OrganizationID *string     `gorm:"size:50" json:"organization_id"`
	CustomerTypeID *uuid.UUID  `gorm:"type:uuid" json:"customer_type_id"`
	CustomerType   *MasterData `gorm:"foreignKey:CustomerTypeID" json:"customer_type,omitempty"`
	Name           string      `gorm:"size:200;not null" json:"name"`
	Email          *string     `gorm:"size:100" json:"email"`
	Phone          *string     `gorm:"size:50" json:"phone"`
	AddressLine1   *string     `gorm:"size:255" json:"address_line1"`
	AddressLine2   *string     `gorm:"size:255" json:"address_line2"`
	CountryID      *uuid.UUID  `gorm:"type:uuid" json:"country_id"`
	Country        *Country    `gorm:"foreignKey:CountryID" json:"country,omitempty"`
	StateID        *uuid.UUID  `gorm:"type:uuid" json:"state_id"`
	State          *State      `gorm:"foreignKey:StateID" json:"state,omitempty"`
	CityID         *uuid.UUID  `gorm:"type:uuid" json:"city_id"`
	City           *City       `gorm:"foreignKey:CityID" json:"city,omitempty"`
	ZipCode        *string     `gorm:"size:20" json:"zip_code"`
	TaxID          *string     `gorm:"size:50" json:"tax_id"`
	CreditLimit    float64     `gorm:"type:decimal(15,2);default:0.0" json:"credit_limit"`
}
