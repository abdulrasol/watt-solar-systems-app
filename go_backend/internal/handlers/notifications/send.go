package notifications

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/services/fcm"
)

// SendBroadcast handles POST /api/v1/notification/send-broadcast
func SendBroadcast(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var payload models.BroadcastSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if !fcm.IsConfigured() {
		response.Error(c, http.StatusServiceUnavailable, "FCM not configured", nil)
		return
	}

	var devices []models.PushDevice
	database.DB.Where("is_active = ?", true).Find(&devices)

	var tokens []string
	for _, d := range devices {
		tokens = append(tokens, d.RegistrationID)
	}

	success, failure, err := fcm.SendMulticast(tokens, payload.Title, payload.Body, payload.Data)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, err.Error(), nil)
		return
	}

	record := models.NotificationRecord{
		Title:        payload.Title,
		Body:         payload.Body,
		Type:         "broadcast",
		Status:       "sent",
		DevicesCount: success + failure,
		SuccessCount: success,
		FailureCount: failure,
	}
	if len(payload.Data) > 0 {
		b, _ := json.Marshal(payload.Data)
		record.Data = datatypes.JSON(b)
	}
	database.DB.Create(&record)

	response.Success(c, http.StatusOK, "Broadcast sent successfully", map[string]interface{}{
		"success_count": success,
		"failure_count": failure,
	})
}

// SendGroup handles POST /api/v1/notification/send-group
func SendGroup(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var payload models.GroupNotificationSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if !fcm.IsConfigured() {
		response.Error(c, http.StatusServiceUnavailable, "FCM not configured", nil)
		return
	}

	userIDs, err := resolveGroupUserIDs(payload.GroupType, payload.GroupID)
	if err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var devices []models.PushDevice
	database.DB.Where("user_id IN ? AND is_active = ?", userIDs, true).Find(&devices)

	var tokens []string
	for _, d := range devices {
		tokens = append(tokens, d.RegistrationID)
	}

	success, failure, sendErr := fcm.SendMulticast(tokens, payload.Title, payload.Body, payload.Data)
	if sendErr != nil {
		response.Error(c, http.StatusInternalServerError, sendErr.Error(), nil)
		return
	}

	record := models.NotificationRecord{
		Title:        payload.Title,
		Body:         payload.Body,
		Type:         "group",
		Status:       "sent",
		DevicesCount: success + failure,
		SuccessCount: success,
		FailureCount: failure,
	}
	if len(payload.Data) > 0 {
		b, _ := json.Marshal(payload.Data)
		record.Data = datatypes.JSON(b)
	}
	dataExtra, _ := json.Marshal(map[string]interface{}{
		"group_type": payload.GroupType,
		"group_id":   payload.GroupID,
	})
	record.DataExtra = datatypes.JSON(dataExtra)
	database.DB.Create(&record)

	response.Success(c, http.StatusOK, "Group notification sent successfully", map[string]interface{}{
		"success_count": success,
		"failure_count": failure,
		"group_type":    payload.GroupType,
		"group_id":      payload.GroupID,
	})
}

// SendUser handles POST /api/v1/notification/send-user
func SendUser(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var payload models.UserNotificationSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if !fcm.IsConfigured() {
		response.Error(c, http.StatusServiceUnavailable, "FCM not configured", nil)
		return
	}

	var devices []models.PushDevice
	database.DB.Where("user_id = ? AND is_active = ?", payload.UserID, true).Find(&devices)

	var tokens []string
	for _, d := range devices {
		tokens = append(tokens, d.RegistrationID)
	}

	success, failure, sendErr := fcm.SendMulticast(tokens, payload.Title, payload.Body, payload.Data)
	if sendErr != nil {
		response.Error(c, http.StatusInternalServerError, sendErr.Error(), nil)
		return
	}

	record := models.NotificationRecord{
		Title:        payload.Title,
		Body:         payload.Body,
		Type:         "user",
		Status:       "sent",
		TargetUserID: &payload.UserID,
		DevicesCount: success + failure,
		SuccessCount: success,
		FailureCount: failure,
	}
	if len(payload.Data) > 0 {
		b, _ := json.Marshal(payload.Data)
		record.Data = datatypes.JSON(b)
	}
	database.DB.Create(&record)

	response.Success(c, http.StatusOK, "Notification sent to user", map[string]interface{}{
		"success_count": success,
		"failure_count": failure,
		"user_id":       payload.UserID,
	})
}

// SendTopic handles POST /api/v1/notification/send-topic/:topic
func SendTopic(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	topic := c.Param("topic")
	var payload models.TopicNotificationSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if !fcm.IsConfigured() {
		response.Error(c, http.StatusServiceUnavailable, "FCM not configured", nil)
		return
	}

	messageID, sendErr := fcm.SendTopic(topic, payload.Title, payload.Body, payload.Data)
	if sendErr != nil {
		response.Error(c, http.StatusInternalServerError, sendErr.Error(), nil)
		return
	}

	record := models.NotificationRecord{
		Title:        payload.Title,
		Body:         payload.Body,
		Type:         "topic",
		Status:       "sent",
		Topic:        &topic,
		DevicesCount: 0,
		SuccessCount: 1,
		FailureCount: 0,
	}
	if len(payload.Data) > 0 {
		b, _ := json.Marshal(payload.Data)
		record.Data = datatypes.JSON(b)
	}
	database.DB.Create(&record)

	response.Success(c, http.StatusOK, "Topic notification sent successfully", map[string]interface{}{
		"success_count": 1,
		"topic":         topic,
		"message_id":    messageID,
	})
}

func resolveGroupUserIDs(groupType string, groupID interface{}) ([]uint, error) {
	switch groupType {
	case "company":
		id, ok := groupID.(float64)
		if !ok {
			return nil, fmt.Errorf("group_id must be numeric for company group")
		}
		var userIDs []uint
		database.DB.Model(&models.CompanyMember{}).
			Where("company_id = ?", uint(id)).
			Pluck("user_id", &userIDs)
		return userIDs, nil
	case "custom":
		ids, ok := groupID.([]interface{})
		if !ok {
			return nil, fmt.Errorf("group_id must be an array for custom group")
		}
		userIDs := make([]uint, 0, len(ids))
		for _, id := range ids {
			if f, ok := id.(float64); ok {
				userIDs = append(userIDs, uint(f))
			}
		}
		return userIDs, nil
	default:
		return nil, fmt.Errorf("unknown group type: %s", groupType)
	}
}
