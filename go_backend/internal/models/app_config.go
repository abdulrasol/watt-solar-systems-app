package models

import (
	"time"
)

// AppConfig represents a global application configuration key-value pair
type AppConfig struct {
	Key         string    `gorm:"primaryKey;column:key"`
	Value       bool      `gorm:"column:value;default:false"`
	Description *string   `gorm:"column:description"`
	UpdatedAt   time.Time `gorm:"column:updated_at;autoUpdateTime"`
}

// Currency represents a financial currency
type Currency struct {
	ID        uint      `gorm:"primaryKey;column:id"`
	Name      string    `gorm:"column:name;not null"`
	Code      string    `gorm:"column:code;not null"`
	Symbol    string    `gorm:"column:symbol;not null"`
	IsDefault bool      `gorm:"column:is_default;default:false"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
}

// GlobalCategory represents a general category used across the app
type GlobalCategory struct {
	ID   uint    `gorm:"primaryKey;column:id"`
	Name string  `gorm:"column:name;unique;not null"`
	Icon *string `gorm:"column:icon"`
}

// Notification represents a user notification
type Notification struct {
	ID                uint      `gorm:"primaryKey;column:id"`
	UserID            uint      `gorm:"column:user_id;not null"`
	User              User      `gorm:"foreignKey:UserID"`
	Title             string    `gorm:"column:title;not null"`
	Body              string    `gorm:"column:body;not null"`
	NotificationType  string    `gorm:"column:notification_type;default:'info'"`
	IsRead            bool      `gorm:"column:is_read;default:false"`
	RelatedEntityType *string   `gorm:"column:related_entity_type"`
	RelatedEntityID   *uint     `gorm:"column:related_entity_id"`
	CreatedAt         time.Time `gorm:"column:created_at;autoCreateTime"`
}

// SubscriptionPlan represents a company subscription tier
type SubscriptionPlan struct {
	ID           uint      `gorm:"primaryKey;column:id"`
	Name         string    `gorm:"column:name;not null"`
	DurationDays int       `gorm:"column:duration_days;not null"`
	Price        float64   `gorm:"column:price;default:0"`
	Description  *string   `gorm:"column:description"`
	IsActive     bool      `gorm:"column:is_active;default:true"`
	CreatedAt    time.Time `gorm:"column:created_at;autoCreateTime"`
}

// Feedback represents a user contact/feedback message
type Feedback struct {
	ID          uint      `gorm:"primaryKey;column:id"`
	Name        string    `gorm:"column:name;not null"`
	PhoneNumber *int      `gorm:"column:phone_number"`
	Message     string    `gorm:"column:message;not null"`
	Image       *string   `gorm:"column:image"`
	IsRead      bool      `gorm:"column:is_read;default:false"`
	CreatedAt   time.Time `gorm:"column:created_at;autoCreateTime"`
}
