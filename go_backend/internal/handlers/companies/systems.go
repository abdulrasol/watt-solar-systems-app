package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetCompanySystems handles GET /api/v1/companies/:company_id/systems
// @Summary GetCompanySystems
// @Description Get systems installed by a company
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/systems [get]
func GetCompanySystems(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	pageStr := c.DefaultQuery("page", "1")
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}
	pageSizeStr := c.DefaultQuery("page_size", "12")
	pageSize, err := strconv.Atoi(pageSizeStr)
	if err != nil || pageSize < 1 {
		pageSize = 12
	}
	offset := (page - 1) * pageSize

	var systems []models.System
	var total int64

	query := database.DB.Where("installed_by_id = ?", company.ID)
	query.Model(&models.System{}).Count(&total)

	if err := query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&systems).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الأنظمة"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch systems", &msgUser)
		return
	}

	items := make([]map[string]interface{}, 0, len(systems))
	for _, s := range systems {
		items = append(items, map[string]interface{}{
			"id":             s.ID,
			"user_id":        s.UserID,
			"order_id":       s.OrderID,
			"panel_power":    s.PanelPower,
			"panel_count":    s.PanelCount,
			"battery_power":  s.BatteryPower,
			"battery_count":  s.BatteryCount,
			"inverter_power": s.InverterPower,
			"inverter_count": s.InverterCount,
			"system_type":    s.SystemType,
			"address":        s.Address,
			"city":           s.City,
			"country":        s.Country,
			"installed_at":   formatTime(s.InstalledAt),
			"created_at":     s.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	totalPages := (int(total) + pageSize - 1) / pageSize

	response.Success(c, http.StatusOK, "Systems retrieved successfully", map[string]interface{}{
		"items":        items,
		"total":        total,
		"page":         page,
		"pages":        totalPages,
		"has_next":     page < totalPages,
		"has_previous": page > 1,
	})
}
