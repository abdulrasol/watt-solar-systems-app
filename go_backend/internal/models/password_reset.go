package models

import (
	"time"
)

// PasswordReset stores tokens for email-based password reset.
type PasswordReset struct {
	ID        uint       `gorm:"primaryKey;column:id"`
	Email     string     `gorm:"column:email;index;not null"`
	Token     string     `gorm:"column:token;uniqueIndex;not null"`
	ExpiresAt time.Time  `gorm:"column:expires_at;not null"`
	UsedAt    *time.Time `gorm:"column:used_at"`
	CreatedAt time.Time  `gorm:"column:created_at;autoCreateTime"`
}

// TableName overrides the table name used by GORM.
func (PasswordReset) TableName() string {
	return "password_resets"
}

// IsValid returns true if the token is not expired and not used.
func (pr *PasswordReset) IsValid() bool {
	return pr.UsedAt == nil && time.Now().Before(pr.ExpiresAt)
}
