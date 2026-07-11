package models

import (
	"time"

	"gorm.io/datatypes"
)

// ConfigOut schema
type ConfigOut struct {
	Key         string    `json:"key"`
	Value       bool      `json:"value"`
	Description *string   `json:"description"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ConfigCreateSchema schema
type ConfigCreateSchema struct {
	Key         string  `json:"key" binding:"required"`
	Value       bool    `json:"value"`
	Description *string `json:"description"`
}

// ConfigUpdateSchema schema
type ConfigUpdateSchema struct {
	Value       *bool   `json:"value"`
	Description *string `json:"description"`
}

// CurrencySchema for create/update
type CurrencySchema struct {
	Name      string `json:"name" binding:"required"`
	Code      string `json:"code" binding:"required"`
	Symbol    string `json:"symbol" binding:"required"`
	IsDefault bool   `json:"is_default"`
}

// CurrencyOut schema
type CurrencyOut struct {
	ID        uint      `json:"id"`
	Name      string    `json:"name"`
	Code      string    `json:"code"`
	Symbol    string    `json:"symbol"`
	IsDefault bool      `json:"is_default"`
	CreatedAt time.Time `json:"created_at"`
}

// CountryOut schema
type CountryOut struct {
	ID        uint   `json:"id"`
	Name      string `json:"name" binding:"required"`
	Code      string `json:"code" binding:"required"`
	CreatedAt string `json:"created_at,omitempty"`
}

// CitySchema for create
type CitySchema struct {
	Name      string `json:"name" binding:"required"`
	CountryID uint   `json:"country_id" binding:"required"`
	Code      string `json:"code" binding:"required"`
}

// CityUpdateSchema for update
type CityUpdateSchema struct {
	Name      *string `json:"name"`
	CountryID *uint   `json:"country_id"`
	Code      *string `json:"code"`
}

// CityOut schema
type CityOut struct {
	ID        uint       `json:"id"`
	Name      string     `json:"name"`
	Country   CountryOut `json:"country"`
	Code      string     `json:"code"`
	CreatedAt string     `json:"created_at,omitempty"`
}

// SubscriptionPlanSchema for create/update
type SubscriptionPlanSchema struct {
	Name         string  `json:"name" binding:"required"`
	DurationDays int     `json:"duration_days" binding:"required"`
	Price        float64 `json:"price"`
	Description  *string                `json:"description"`
	IsActive     bool                   `json:"is_active"`
	Features     map[string]interface{} `json:"features"`
}

// SubscriptionPlanOut schema
type SubscriptionPlanOut struct {
	ID           uint      `json:"id"`
	Name         string    `json:"name"`
	DurationDays int       `json:"duration_days"`
	Price        float64   `json:"price"`
	Description  *string        `json:"description"`
	IsActive     bool           `json:"is_active"`
	Features     datatypes.JSON `json:"features"`
	CreatedAt    time.Time      `json:"created_at"`
}

// GlobalCategorySchema schema
type GlobalCategorySchema struct {
	Name string `json:"name" form:"name" binding:"required"`
}

// GlobalCategoryOut schema
type GlobalCategoryOut struct {
	ID   uint    `json:"id"`
	Name string  `json:"name"`
	Icon *string `json:"icon"`
}

// NotificationOut schema
type NotificationOut struct {
	ID                uint      `json:"id"`
	UserID            uint      `json:"user_id"`
	Title             string    `json:"title"`
	Body              string    `json:"body"`
	NotificationType  string    `json:"notification_type"`
	IsRead            bool      `json:"is_read"`
	RelatedEntityType *string   `json:"related_entity_type"`
	RelatedEntityID   *uint     `json:"related_entity_id"`
	CreatedAt         time.Time `json:"created_at"`
}

// FeedbackSchema schema
type FeedbackSchema struct {
	ID          uint      `json:"id"`
	Name        string    `json:"name"`
	PhoneNumber *int      `json:"phone_number"`
	Message     string    `json:"message"`
	Image       *string   `json:"image"`
	IsRead      bool      `json:"is_read"`
	CreatedAt   time.Time `json:"created_at"`
}

// FeedbackUpdateFormSchema schema
type FeedbackUpdateFormSchema struct {
	IsRead *bool `json:"is_read" binding:"required"`
}
