package notifications

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetMyNotifications godoc
// @Summary      Get user notifications
// @Description  Get a paginated list of notifications for the current user
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Param        page    query     int  false  "Page number" default(1)
// @Param        limit   query     int  false  "Page size" default(12)
// @Success      200     {object}  response.APIResponse
// @Failure      401     {object}  response.APIResponse
// @Router       /api/v1/notifications [get]
// @Security     BearerAuth
func GetMyNotifications(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.Notification{}).Where("user_id = ?", user.ID).Count(&total)

	var records []models.Notification
	database.DB.Where("user_id = ?", user.ID).Order("created_at desc").Limit(pageSize).Offset(offset).Find(&records)

	items := make([]map[string]interface{}, 0, len(records))
	for _, n := range records {
		items = append(items, serializeInAppNotification(&n))
	}

	response.Success(c, http.StatusOK, "Notifications retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// MarkNotificationRead godoc
// @Summary      Mark notification as read
// @Description  Mark a specific notification as read by its ID
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Param        id      path      int  true  "Notification ID"
// @Success      200     {object}  response.APIResponse
// @Failure      400     {object}  response.APIResponse
// @Failure      401     {object}  response.APIResponse
// @Failure      404     {object}  response.APIResponse
// @Router       /api/v1/notifications/{id}/read [post]
// @Security     BearerAuth
func MarkNotificationRead(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Authentication required", nil)
		return
	}

	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid notification id", nil)
		return
	}

	var n models.Notification
	if err := database.DB.Where("id = ? AND user_id = ?", id, user.ID).First(&n).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Notification not found", nil)
		return
	}

	n.IsRead = true
	database.DB.Save(&n)
	response.Success(c, http.StatusOK, "Notification marked as read", serializeInAppNotification(&n))
}

func serializeInAppNotification(n *models.Notification) map[string]interface{} {
	item := map[string]interface{}{
		"id":               n.ID,
		"user_id":          n.UserID,
		"title":            n.Title,
		"body":             n.Body,
		"notification_type": n.NotificationType,
		"is_read":          n.IsRead,
		"created_at":       n.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
	if n.RelatedEntityType != nil {
		item["related_entity_type"] = *n.RelatedEntityType
	}
	if n.RelatedEntityID != nil {
		item["related_entity_id"] = *n.RelatedEntityID
	}
	return item
}
