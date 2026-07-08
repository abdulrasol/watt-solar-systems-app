package models

import "gorm.io/datatypes"

// SubscribeSchema schema
type SubscribeSchema struct {
	Token      string  `json:"token" binding:"required"`
	Platform   string  `json:"platform" binding:"required"`
	DeviceID   *string `json:"device_id"`
	AppVersion *string `json:"app_version"`
}

// BroadcastSchema schema
type BroadcastSchema struct {
	Title string                 `json:"title" binding:"required"`
	Body  string                 `json:"body" binding:"required"`
	Data  map[string]interface{} `json:"data"`
}

// GroupNotificationSchema schema
type GroupNotificationSchema struct {
	GroupType string                 `json:"group_type" binding:"required"`
	GroupID   interface{}            `json:"group_id" binding:"required"`
	Title     string                 `json:"title" binding:"required"`
	Body      string                 `json:"body" binding:"required"`
	Data      map[string]interface{} `json:"data"`
}

// UserNotificationSchema schema
type UserNotificationSchema struct {
	UserID uint                   `json:"user_id" binding:"required"`
	Title  string                 `json:"title" binding:"required"`
	Body   string                 `json:"body" binding:"required"`
	Data   map[string]interface{} `json:"data"`
}

// TopicNotificationSchema schema
type TopicNotificationSchema struct {
	Title string                 `json:"title" binding:"required"`
	Body  string                 `json:"body" binding:"required"`
	Data  map[string]interface{} `json:"data"`
}

// NotificationRecordData converts datatypes.JSON
type NotificationRecordData struct {
	Data datatypes.JSON `json:"data"`
}
