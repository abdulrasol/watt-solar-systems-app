package models

import (
	"time"

	"gorm.io/datatypes"
)

// PushDevice maps to fcm_django.FCMDevice (simplified)
type PushDevice struct {
	ID             uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID         *uint     `json:"user_id"`
	User           *User     `gorm:"foreignKey:UserID;constraint:OnDelete:SET NULL;" json:"-"`
	RegistrationID string    `gorm:"type:varchar(255);not null" json:"registration_id"`
	Type           string    `gorm:"type:varchar(20)" json:"type"`
	DeviceID       *string   `gorm:"type:varchar(255)" json:"device_id"`
	Name           *string   `gorm:"type:varchar(255)" json:"name"`
	IsActive       bool      `gorm:"default:true" json:"is_active"`
	CreatedAt      time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// NotificationRecord maps to notifications.Notification
type NotificationRecord struct {
	ID            uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Title         string         `gorm:"type:varchar(255);not null" json:"title"`
	Body          string         `gorm:"type:text" json:"body"`
	Data          datatypes.JSON `gorm:"type:json" json:"data"`
	DataExtra     datatypes.JSON `gorm:"type:json" json:"data_extra"`
	Type          string         `gorm:"type:varchar(20);default:'general'" json:"type"`
	TargetUserID  *uint          `json:"target_user_id"`
	TargetUser    *User          `gorm:"foreignKey:TargetUserID;constraint:OnDelete:SET NULL;" json:"-"`
	Topic         *string        `gorm:"type:varchar(100)" json:"topic"`
	Status        string         `gorm:"type:varchar(20);default:'pending'" json:"status"`
	DevicesCount  int            `gorm:"default:0" json:"devices_count"`
	SuccessCount  int            `gorm:"default:0" json:"success_count"`
	FailureCount  int            `gorm:"default:0" json:"failure_count"`
	CreatedAt     time.Time      `gorm:"autoCreateTime" json:"created_at"`
	SentAt        *time.Time     `json:"sent_at"`
	ErrorMessage  *string        `gorm:"type:text" json:"error_message"`
}
