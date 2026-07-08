package notifications

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// Statistics handles GET /api/v1/notification/statistics
func Statistics(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var totalDevices, activeDevices, iosDevices, androidDevices int64
	database.DB.Model(&models.PushDevice{}).Count(&totalDevices)
	database.DB.Model(&models.PushDevice{}).Where("is_active = ?", true).Count(&activeDevices)
	database.DB.Model(&models.PushDevice{}).Where("type = ? AND is_active = ?", "ios", true).Count(&iosDevices)
	database.DB.Model(&models.PushDevice{}).Where("type = ? AND is_active = ?", "android", true).Count(&androidDevices)

	var notificationsTotal, notificationsSent, notificationsFailed int64
	database.DB.Model(&models.NotificationRecord{}).Count(&notificationsTotal)
	database.DB.Model(&models.NotificationRecord{}).Where("status = ?", "sent").Count(&notificationsSent)
	database.DB.Model(&models.NotificationRecord{}).Where("status = ?", "failed").Count(&notificationsFailed)

	response.Success(c, http.StatusOK, "Statistics retrieved successfully", map[string]interface{}{
		"devices": map[string]interface{}{
			"total":   totalDevices,
			"active":  activeDevices,
			"ios":     iosDevices,
			"android": androidDevices,
		},
		"notifications": map[string]interface{}{
			"total":  notificationsTotal,
			"sent":   notificationsSent,
			"failed": notificationsFailed,
		},
	})
}
