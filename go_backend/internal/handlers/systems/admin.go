package systems

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// AdminListSystems handles GET /api/v1/admin/systems/
func AdminListSystems(c *gin.Context) {
	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.System{}).Preload("User")
	if status := c.Query("status"); status != "" {
		query = query.Where("user_status = ?", status)
	}
	if city := c.Query("city"); city != "" {
		query = query.Where("city ILIKE ?", "%"+city+"%")
	}

	var total int64
	query.Count(&total)

	var systems []models.System
	query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&systems)

	items := make([]map[string]interface{}, 0, len(systems))
	for _, s := range systems {
		items = append(items, serializeSystem(&s))
	}

	response.Success(c, http.StatusOK, "Systems retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// AdminUpdateSystemStatus handles PUT /api/v1/admin/systems/:sys_id/status
func AdminUpdateSystemStatus(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("sys_id"))
	var s models.System
	if err := database.DB.First(&s, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "System not found", nil)
		return
	}

	var payload models.SystemAdminStatusSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if payload.UserStatus != nil {
		s.UserStatus = *payload.UserStatus
	}
	if payload.CompanyStatus != nil {
		s.CompanyStatus = *payload.CompanyStatus
	}
	database.DB.Save(&s)
	response.Success(c, http.StatusOK, "System status updated", map[string]interface{}{"id": s.ID})
}
