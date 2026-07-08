package systems

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

func parsePagination(c *gin.Context) (page, pageSize int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ = strconv.Atoi(c.DefaultQuery("page_size", "12"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}
	return
}

func paginationResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	return map[string]interface{}{
		"items":        items,
		"total":        total,
		"page":         page,
		"pages":        totalPages,
		"has_next":     page < totalPages,
		"has_previous": page > 1,
	}
}

func serializeSystem(s *models.System) map[string]interface{} {
	username := ""
	if s.User != nil {
		username = s.User.Username
	}
	return map[string]interface{}{
		"id":             s.ID,
		"user_status":    s.UserStatus,
		"company_status": s.CompanyStatus,
		"panel_power":    s.PanelPower,
		"panel_count":    s.PanelCount,
		"panel_type":     s.PanelType,
		"battery_power":  s.BatteryPower,
		"battery_count":  s.BatteryCount,
		"battery_type":   s.BatteryType,
		"inverter_power": s.InverterPower,
		"inverter_count": s.InverterCount,
		"inverter_type":  s.InverterType,
		"system_type":    s.SystemType,
		"address":        s.Address,
		"city":           s.City,
		"country":        s.Country,
		"lat":            s.Lat,
		"lan":            s.Lan,
		"notes":          s.Notes,
		"created_at":     s.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":     s.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"installed_at":   formatTime(s.InstalledAt),
		"username":       username,
	}
}

func formatTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format("2006-01-02T15:04:05Z07:00")
	return &s
}

// ListMySystems handles GET /api/v1/systems/
func ListMySystems(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.System{}).Where("user_id = ?", userID).Count(&total)

	var systems []models.System
	database.DB.Where("user_id = ?", userID).Order("created_at desc").Limit(pageSize).Offset(offset).Find(&systems)

	items := make([]map[string]interface{}, 0, len(systems))
	for _, s := range systems {
		items = append(items, serializeSystem(&s))
	}

	response.Success(c, http.StatusOK, "Success", paginationResponse(page, pageSize, total, items))
}

// GetMySystem handles GET /api/v1/systems/:sys_id
func GetMySystem(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("sys_id"))
	var s models.System
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&s).Error; err != nil {
		response.Error(c, http.StatusNotFound, "System not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "System retrieved successfully", serializeSystem(&s))
}

// CreateMySystem handles POST /api/v1/systems/
func CreateMySystem(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	var payload models.SystemCreateUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	s := systemFromPayload(&payload)
	s.UserID = &userID
	database.DB.Create(&s)
	response.Success(c, http.StatusOK, "System created successfully", map[string]interface{}{"id": s.ID})
}

// UpdateMySystem handles PUT /api/v1/systems/:sys_id
func UpdateMySystem(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("sys_id"))
	var s models.System
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&s).Error; err != nil {
		response.Error(c, http.StatusNotFound, "System not found", nil)
		return
	}

	var payload models.SystemCreateUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	updateSystemFromPayload(&s, &payload)
	database.DB.Save(&s)
	response.Success(c, http.StatusOK, "System updated successfully", map[string]interface{}{"id": s.ID})
}

// DeleteMySystem handles DELETE /api/v1/systems/:sys_id
func DeleteMySystem(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("sys_id"))
	var s models.System
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&s).Error; err != nil {
		response.Error(c, http.StatusNotFound, "System not found", nil)
		return
	}

	database.DB.Delete(&s)
	response.Success(c, http.StatusOK, "System deleted successfully", nil)
}

func systemFromPayload(payload *models.SystemCreateUpdateSchema) models.System {
	return models.System{
		PanelPower:    payload.PanelPower,
		PanelCount:    payload.PanelCount,
		PanelType:     payload.PanelType,
		PanelNotes:    payload.PanelNotes,
		BatteryPower:  payload.BatteryPower,
		BatteryCount:  payload.BatteryCount,
		BatteryType:   payload.BatteryType,
		BatteryNotes:  payload.BatteryNotes,
		InverterPower: payload.InverterPower,
		InverterCount: payload.InverterCount,
		InverterType:  payload.InverterType,
		InverterNotes: payload.InverterNotes,
		SystemType:    payload.SystemType,
		Notes:         payload.Notes,
		Lat:           payload.Lat,
		Lan:           payload.Lan,
		Address:       payload.Address,
		City:          payload.City,
		Country:       payload.Country,
	}
}

func updateSystemFromPayload(s *models.System, payload *models.SystemCreateUpdateSchema) {
	s.PanelPower = payload.PanelPower
	s.PanelCount = payload.PanelCount
	s.PanelType = payload.PanelType
	s.PanelNotes = payload.PanelNotes
	s.BatteryPower = payload.BatteryPower
	s.BatteryCount = payload.BatteryCount
	s.BatteryType = payload.BatteryType
	s.BatteryNotes = payload.BatteryNotes
	s.InverterPower = payload.InverterPower
	s.InverterCount = payload.InverterCount
	s.InverterType = payload.InverterType
	s.InverterNotes = payload.InverterNotes
	s.SystemType = payload.SystemType
	s.Notes = payload.Notes
	s.Lat = payload.Lat
	s.Lan = payload.Lan
	s.Address = payload.Address
	s.City = payload.City
	s.Country = payload.Country
}
