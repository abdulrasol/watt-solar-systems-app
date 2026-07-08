package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetPublicServices handles GET /api/v1/companies/:company_id/public-services
// @Summary GetPublicServices
// @Description Get public services for a company
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/public-services [get]
func GetPublicServices(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var services []models.CompanyService
	if err := database.DB.Where("company_id = ?", company.ID).Order("created_at desc").Find(&services).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الخدمات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch services", &msgUser)
		return
	}

	items := make([]map[string]interface{}, 0, len(services))
	for _, s := range services {
		items = append(items, map[string]interface{}{
			"id":          s.ID,
			"title":       s.Title,
			"price":       s.Price,
			"description": s.Description,
			"company":     s.CompanyID,
			"created_at":  s.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at":  s.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Public services retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// CreatePublicService handles POST /api/v1/companies/:company_id/public-services
// @Summary CreatePublicService
// @Description Create a public service for a company
// @Tags Company Operations
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.CompanyServiceCreateSchema true "Service"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/public-services [post]
func CreatePublicService(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.CompanyServiceCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid payload", &msgUser)
		return
	}

	service := models.CompanyService{
		CompanyID:   company.ID,
		Title:       payload.Title,
		Price:       payload.Price,
		Description: payload.Description,
	}

	if err := database.DB.Create(&service).Error; err != nil {
		msgUser := "فشل في إنشاء الخدمة"
		response.Error(c, http.StatusInternalServerError, "Failed to create service", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Public service created successfully", service)
}

// UpdatePublicService handles PUT /api/v1/companies/:company_id/public-services/:service_id
// @Summary UpdatePublicService
// @Description Update a public service
// @Tags Company Operations
// @Accept json
// @Produce json
// @Security Bearer
// @Param service_id path int true "service_id"
// @Param request body models.CompanyServiceUpdateSchema true "Service"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/public-services/{service_id} [put]
func UpdatePublicService(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	serviceID, err := strconv.Atoi(c.Param("service_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid service ID", nil)
		return
	}

	var service models.CompanyService
	if err := database.DB.Where("id = ? AND company_id = ?", serviceID, company.ID).First(&service).Error; err != nil {
		msgUser := "الخدمة غير موجودة"
		response.Error(c, http.StatusNotFound, "Service not found", &msgUser)
		return
	}

	var payload models.CompanyServiceUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid payload", &msgUser)
		return
	}

	if payload.Title != nil {
		service.Title = *payload.Title
	}
	if payload.Price != nil {
		service.Price = payload.Price
	}
	if payload.Description != nil {
		service.Description = payload.Description
	}

	if err := database.DB.Save(&service).Error; err != nil {
		msgUser := "فشل في تحديث الخدمة"
		response.Error(c, http.StatusInternalServerError, "Failed to update service", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Public service updated successfully", service)
}

// DeletePublicService handles DELETE /api/v1/companies/:company_id/public-services/:service_id
// @Summary DeletePublicService
// @Description Delete a public service
// @Tags Company Operations
// @Security Bearer
// @Param service_id path int true "service_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/public-services/{service_id} [delete]
func DeletePublicService(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	serviceID, err := strconv.Atoi(c.Param("service_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid service ID", nil)
		return
	}

	var service models.CompanyService
	if err := database.DB.Where("id = ? AND company_id = ?", serviceID, company.ID).First(&service).Error; err != nil {
		msgUser := "الخدمة غير موجودة"
		response.Error(c, http.StatusNotFound, "Service not found", &msgUser)
		return
	}

	if err := database.DB.Delete(&service).Error; err != nil {
		msgUser := "فشل في حذف الخدمة"
		response.Error(c, http.StatusInternalServerError, "Failed to delete service", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Public service deleted successfully", nil)
}
