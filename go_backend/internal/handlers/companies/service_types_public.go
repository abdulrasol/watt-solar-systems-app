package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// ListServiceTypes handles GET /api/v1/service-types/ and /api/v1/service-types/public
// @Summary ListServiceTypes
// @Description Get all service types (public). If a valid Authorization header is provided,
//              returns is_served for the authenticated user's company.
// @Tags Service Types
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /service-types/ [get]
func ListServiceTypes(c *gin.Context) {
	var serviceTypes []models.ServiceType
	if err := database.DB.Find(&serviceTypes).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب أنواع الخدمات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch service types", &msgUser)
		return
	}

	// Optional auth: if user_id is present, compute is_served for their company
	var company *models.Company
	if userIDVal, exists := c.Get("user_id"); exists {
		userID := userIDVal.(uint)
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", userID).Preload("Company.ServiceTypes").First(&member).Error; err == nil {
			company = &member.Company
		}
	}

	items := make([]map[string]interface{}, 0, len(serviceTypes))
	for _, st := range serviceTypes {
		items = append(items, SerializeServiceType(&st, company))
	}

	response.Success(c, http.StatusOK, "Service types retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}
