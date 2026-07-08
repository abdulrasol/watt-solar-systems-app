package notifications

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// Subscribe handles POST /api/v1/notification/subscribe
func Subscribe(c *gin.Context) {
	cfgVal, ok := c.Get("cfg")
	if !ok {
		response.Error(c, http.StatusInternalServerError, "Configuration not available", nil)
		return
	}
	cfg := cfgVal.(*config.Config)
	user := optionalUserFromHeader(c, cfg.JWTSecret)

	var payload models.SubscribeSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	platform := payload.Platform
	if platform != "ios" && platform != "android" {
		response.Error(c, http.StatusBadRequest, "Invalid platform. Must be \"ios\" or \"android\"", nil)
		return
	}
	if len(payload.Token) < 20 {
		response.Error(c, http.StatusBadRequest, "Invalid token format", nil)
		return
	}

	var device models.PushDevice
	err := database.DB.Where("registration_id = ?", payload.Token).First(&device).Error
	status := http.StatusOK
	if err != nil {
		device = models.PushDevice{RegistrationID: payload.Token}
		status = http.StatusCreated
	}

	device.Type = platform
	device.IsActive = true
	if user != nil {
		device.UserID = &user.ID
	}
	if payload.DeviceID != nil {
		device.DeviceID = payload.DeviceID
	}
	if payload.AppVersion != nil {
		name := "App v" + *payload.AppVersion
		device.Name = &name
	}

	if device.ID == 0 {
		database.DB.Create(&device)
	} else {
		database.DB.Save(&device)
	}

	response.Success(c, status, "Device subscribed successfully", map[string]interface{}{"device_id": device.ID})
}

// Unsubscribe handles POST /api/v1/notification/unsubscribe
func Unsubscribe(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	database.DB.Model(&models.PushDevice{}).Where("user_id = ?", user.ID).Update("is_active", false)
	response.Success(c, http.StatusOK, "Successfully unsubscribed from notifications", nil)
}

// ListDevices handles GET /api/v1/notification/devices
func ListDevices(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	var devices []models.PushDevice
	database.DB.Where("user_id = ?", user.ID).Find(&devices)

	items := make([]map[string]interface{}, 0, len(devices))
	for _, d := range devices {
		items = append(items, serializeDevice(&d))
	}

	c.JSON(http.StatusOK, map[string]interface{}{
		"devices": items,
		"count":   len(items),
	})
}

// DeactivateDevice handles POST /api/v1/notification/tokens/:token_id/deactivate
func DeactivateDevice(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	deviceID, _ := strconv.Atoi(c.Param("token_id"))
	var device models.PushDevice
	if err := database.DB.Where("id = ? AND user_id = ?", deviceID, user.ID).First(&device).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Device not found", nil)
		return
	}

	device.IsActive = false
	database.DB.Save(&device)
	response.Success(c, http.StatusOK, "Device deactivated successfully", nil)
}
