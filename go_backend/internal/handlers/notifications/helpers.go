package notifications

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/datatypes"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

func parsePagination(c *gin.Context) (page, pageSize int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ = strconv.Atoi(c.DefaultQuery("page_size", "20"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}
	return
}

func paginationResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	return map[string]interface{}{
		"notifications": items,
		"count":         total,
		"pagination": map[string]interface{}{
			"page":         page,
			"page_size":    pageSize,
			"total_items":  total,
			"total_pages":  totalPages,
			"has_next":     page < totalPages,
			"has_previous": page > 1,
		},
	}
}

func currentUser(c *gin.Context) (*models.User, bool) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		return nil, false
	}
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return nil, false
	}
	return &user, true
}

func isSuperuser(c *gin.Context) bool {
	v, exists := c.Get("is_superuser")
	if !exists {
		return false
	}
	b, ok := v.(bool)
	return ok && b
}

func optionalUserFromHeader(c *gin.Context, secret string) *models.User {
	auth := c.GetHeader("Authorization")
	if !strings.HasPrefix(auth, "Bearer ") {
		return nil
	}
	tokenStr := strings.TrimPrefix(auth, "Bearer ")
	token, err := jwt.Parse(tokenStr, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})
	if err != nil || !token.Valid {
		return nil
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil
	}
	uidFloat, ok := claims["user_id"].(float64)
	if !ok {
		return nil
	}
	var user models.User
	if err := database.DB.First(&user, uint(uidFloat)).Error; err != nil {
		return nil
	}
	return &user
}

func serializeDevice(d *models.PushDevice) map[string]interface{} {
	return map[string]interface{}{
		"id":         d.ID,
		"user_id":    d.UserID,
		"platform":   d.Type,
		"device_id":  d.DeviceID,
		"name":       d.Name,
		"is_active":  d.IsActive,
		"created_at": d.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeNotification(n *models.NotificationRecord, baseURL string) map[string]interface{} {
	sentAt := ""
	if n.SentAt != nil {
		sentAt = n.SentAt.Format("2006-01-02T15:04:05Z07:00")
	}
	data := map[string]interface{}{}
	if len(n.Data) > 0 {
		_ = json.Unmarshal(n.Data, &data)
	}
	if content, ok := data["content"].(map[string]interface{}); ok {
		utils.ResolveMediaURLsInMap(baseURL, content)
	}
	return map[string]interface{}{
		"id":         n.ID,
		"title":      n.Title,
		"body":       n.Body,
		"data":       data,
		"type":       n.Type,
		"status":     n.Status,
		"created_at": n.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"sent_at":    sentAt,
	}
}

func recordResult(title, body, ntype string, data map[string]interface{}, success, failure int) map[string]interface{} {
	now := time.Now()
	rec := models.NotificationRecord{
		Title:        title,
		Body:         body,
		Type:         ntype,
		Status:       "sent",
		SuccessCount: success,
		FailureCount: failure,
		DevicesCount: success + failure,
		SentAt:       &now,
	}
	if len(data) > 0 {
		b, _ := json.Marshal(data)
		rec.Data = datatypes.JSON(b)
	}
	database.DB.Create(&rec)
	return map[string]interface{}{
		"success_count": success,
		"failure_count": failure,
	}
}

func requireSuperuser(c *gin.Context) bool {
	if !isSuperuser(c) {
		response.Error(c, http.StatusForbidden, "Superuser required", nil)
		return false
	}
	return true
}
