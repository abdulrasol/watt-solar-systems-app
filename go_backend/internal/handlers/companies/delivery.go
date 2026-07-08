package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetDeliveryOptions handles GET /api/company/{company_id}/delivery
// @Security Bearer
// @Summary GetDeliveryOptions
// @Description GetDeliveryOptions
// @Tags Companies Delivery
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/delivery [get]
func GetDeliveryOptions(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var options []models.DeliveryOption
	if err := database.DB.Where("company_id = ?", member.CompanyID).Order("cost asc").Find(&options).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب طرق التوصيل"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch delivery options", &msgUser)
		return
	}

	data := make([]map[string]interface{}, 0, len(options))
	for _, opt := range options {
		data = append(data, map[string]interface{}{
			"id":                 opt.ID,
			"name":               opt.Name,
			"cost":               opt.Cost,
			"estimated_days_min": opt.EstimatedDaysMin,
			"estimated_days_max": opt.EstimatedDaysMax,
			"description":        opt.Description,
			"is_active":          opt.IsActive,
			"company":            opt.CompanyID,
			"created_at":         opt.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	c.JSON(http.StatusOK, map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// CreateDeliveryOption handles POST /api/company/{company_id}/delivery
// @Accept json
// @Produce json
// @Param request body models.DeliveryOptionSchema true "Delivery Option details"
// @Security Bearer
// @Summary CreateDeliveryOption
// @Description CreateDeliveryOption
// @Tags Companies Delivery
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/delivery [post]
func CreateDeliveryOption(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Name             string  `json:"name" binding:"required"`
		Cost             float64 `json:"cost"`
		EstimatedDaysMin int     `json:"estimated_days_min"`
		EstimatedDaysMax int     `json:"estimated_days_max"`
		Description      *string `json:"description"`
		IsActive         bool    `json:"is_active"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	opt := models.DeliveryOption{
		CompanyID:        member.CompanyID,
		Name:             payload.Name,
		Cost:             payload.Cost,
		EstimatedDaysMin: &payload.EstimatedDaysMin,
		EstimatedDaysMax: &payload.EstimatedDaysMax,
		Description:      payload.Description,
		IsActive:         payload.IsActive,
	}

	if err := database.DB.Create(&opt).Error; err != nil {
		msgUser := "حدث خطأ أثناء إضافة طريقة التوصيل"
		response.Error(c, http.StatusInternalServerError, "Failed to create delivery option", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Delivery option created successfully.", map[string]interface{}{
		"id":                 opt.ID,
		"name":               opt.Name,
		"cost":               opt.Cost,
		"estimated_days_min": opt.EstimatedDaysMin,
		"estimated_days_max": opt.EstimatedDaysMax,
		"description":        opt.Description,
		"is_active":          opt.IsActive,
		"company":            opt.CompanyID,
		"created_at":         opt.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

// DeleteDeliveryOption handles DELETE /api/company/{company_id}/delivery/{option_id}
// @Security Bearer
// @Summary DeleteDeliveryOption
// @Description DeleteDeliveryOption
// @Tags Companies Delivery
// @Param company_id path int true "company_id"
// @Param option_id path int true "option_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/delivery/{option_id} [delete]
func DeleteDeliveryOption(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	idStr := c.Param("option_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Option ID", nil)
		return
	}

	var opt models.DeliveryOption
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&opt).Error; err != nil {
		msgUser := "طريقة التوصيل غير موجودة"
		response.Error(c, http.StatusNotFound, "Delivery option not found", &msgUser)
		return
	}

	database.DB.Delete(&opt)

	response.Success(c, http.StatusOK, "Delivery option deleted successfully.", map[string]interface{}{})
}
