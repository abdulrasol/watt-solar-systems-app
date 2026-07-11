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

// Subscribe godoc
// @Summary      Subscribe device to push notifications
// @Description  Register a device token for push notifications (FCM)
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Param        payload body      models.SubscribeSchema true "Subscribe Payload"
// @Success      200     {object}  response.APIResponse
// @Success      201     {object}  response.APIResponse
// @Failure      400     {object}  response.APIResponse
// @Router       /api/v1/notification/subscribe [post]
// @Security     BearerAuth
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

// Unsubscribe godoc
// @Summary      Unsubscribe device from push notifications
// @Description  Deactivates push notification tokens for the current user
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Success      200     {object}  response.APIResponse
// @Failure      401     {object}  response.APIResponse
// @Router       /api/v1/notification/unsubscribe [post]
// @Security     BearerAuth
func Unsubscribe(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	database.DB.Model(&models.PushDevice{}).Where("user_id = ?", user.ID).Update("is_active", false)
	response.Success(c, http.StatusOK, "Successfully unsubscribed from notifications", nil)
}

// ListDevices godoc
// @Summary      List active push devices
// @Description  Get a list of registered push notification devices for the user
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Success      200     {object}  map[string]interface{}
// @Failure      401     {object}  response.APIResponse
// @Router       /api/v1/notification/devices [get]
// @Security     BearerAuth
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

// DeactivateDevice godoc
// @Summary      Deactivate a specific device token
// @Description  Deactivate a push notification token by its ID
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Param        token_id path      int  true  "Device Token ID"
// @Success      200     {object}  response.APIResponse
// @Failure      401     {object}  response.APIResponse
// @Failure      404     {object}  response.APIResponse
// @Router       /api/v1/notification/tokens/{token_id}/deactivate [post]
// @Security     BearerAuth
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
