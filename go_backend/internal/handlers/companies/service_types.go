package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetServiceTypes handles GET /api/v1/companies/service-types
// @Summary GetServiceTypes
// @Description Get all service types
// @Tags Companies
// @Success 200 {object} response.APIResponse
// @Router /companies/service-types [get]
func GetServiceTypes(c *gin.Context) {
	var serviceTypes []models.ServiceType
	if err := database.DB.Find(&serviceTypes).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب أنواع الخدمات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch service types", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	data := make([]map[string]interface{}, 0, len(serviceTypes))
	for _, st := range serviceTypes {
		data = append(data, SerializeServiceType(&st, nil, baseURL))
	}

	response.Success(c, http.StatusOK, "Service types retrieved successfully", map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// GetServiceTypeByID handles GET /api/v1/companies/service-types/:id
// @Summary GetServiceTypeByID
// @Description Get a single service type
// @Tags Companies
// @Param id path int true "id"
// @Success 200 {object} response.APIResponse
// @Router /companies/service-types/{id} [get]
func GetServiceTypeByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid service type ID", nil)
		return
	}

	var st models.ServiceType
	if err := database.DB.First(&st, id).Error; err != nil {
		msgUser := "نوع الخدمة غير موجود"
		response.Error(c, http.StatusNotFound, "Service type not found", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Service type retrieved successfully", SerializeServiceType(&st, nil, baseURL))
}


