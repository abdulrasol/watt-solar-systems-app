package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
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

	data := make([]map[string]interface{}, 0, len(serviceTypes))
	for _, st := range serviceTypes {
		data = append(data, SerializeServiceType(&st, nil))
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

	response.Success(c, http.StatusOK, "Service type retrieved successfully", SerializeServiceType(&st, nil))
}

// ToggleCompanyServiceType handles POST /api/v1/companies/service-types/:id/toggle
// @Summary ToggleCompanyServiceType
// @Description Toggle a service type for the authenticated user's company
// @Tags Companies
// @Accept json
// @Produce json
// @Security Bearer
// @Param id path int true "id"
// @Success 200 {object} response.APIResponse
// @Router /companies/service-types/{id}/toggle [post]
func ToggleCompanyServiceType(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		msgUser := "الرجاء تسجيل الدخول"
		response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
		return
	}

	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid service type ID", nil)
		return
	}

	var serviceType models.ServiceType
	if err := database.DB.First(&serviceType, id).Error; err != nil {
		msgUser := "نوع الخدمة غير موجود"
		response.Error(c, http.StatusNotFound, "Service type not found", &msgUser)
		return
	}

	// Find user's company
	var member models.CompanyMember
	if err := database.DB.Where("user_id = ?", userID).Preload("Company").First(&member).Error; err != nil {
		msgUser := "أنت لست عضواً في أي شركة"
		response.Error(c, http.StatusForbidden, "Not a company member", &msgUser)
		return
	}

	company := member.Company

	// Determine current selection state
	selected := false
	for _, st := range company.ServiceTypes {
		if st.ID == serviceType.ID {
			selected = true
			break
		}
	}

	if selected {
		if err := database.DB.Model(&company).Association("ServiceTypes").Delete(&serviceType); err != nil {
			msgUser := "فشل في إزالة نوع الخدمة"
			response.Error(c, http.StatusInternalServerError, "Failed to remove service type", &msgUser)
			return
		}
		selected = false
	} else {
		if err := database.DB.Model(&company).Association("ServiceTypes").Append(&serviceType); err != nil {
			msgUser := "فشل في إضافة نوع الخدمة"
			response.Error(c, http.StatusInternalServerError, "Failed to add service type", &msgUser)
			return
		}
		selected = true
	}

	response.Success(c, http.StatusOK, "Service type toggled successfully", map[string]interface{}{
		"id":       serviceType.ID,
		"selected": selected,
	})
}

// AdminCreateServiceTypeMultipart handles multipart image upload for service types
// (used by admin routes).
func adminSaveServiceTypeImage(c *gin.Context) (*string, error) {
	return utils.SaveUploadedFileOptional(c, "image", "service_type_images")
}
