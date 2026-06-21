package models

import (
	"time"
)

type RevokedToken struct {
	Token     string    `gorm:"primaryKey;type:varchar(512)" json:"token"`
	RevokedAt time.Time `gorm:"not null" json:"revoked_at"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
}

func (RevokedToken) TableName() string {
	return "revoked_tokens"
}
