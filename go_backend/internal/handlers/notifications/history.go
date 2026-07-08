package notifications

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// History handles GET /api/v1/notification/history
func History(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.NotificationRecord{}).Where("target_user_id = ? AND status = ?", user.ID, "sent").Count(&total)

	var records []models.NotificationRecord
	database.DB.Where("target_user_id = ? AND status = ?", user.ID, "sent").Order("created_at desc").Limit(pageSize).Offset(offset).Find(&records)

	items := make([]map[string]interface{}, 0, len(records))
	for _, r := range records {
		items = append(items, serializeNotification(&r))
	}

	response.Success(c, http.StatusOK, "Notification history retrieved successfully", paginationResponse(page, pageSize, total, items))
}
