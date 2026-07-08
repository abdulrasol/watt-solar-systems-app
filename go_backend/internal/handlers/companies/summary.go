package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetCompanySummary handles GET /api/company/{company_id}/summary
// @Security Bearer
// @Summary GetCompanySummary
// @Description GetCompanySummary
// @Tags Companies
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/summary [get]
func GetCompanySummary(c *gin.Context) {
	// The CompanyMemberMiddleware injects "company_member" into the context
	memberInterface, exists := c.Get("company_member")
	if !exists {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	member := memberInterface.(*models.CompanyMember)

	var company models.Company
	if err := database.DB.
		Preload("CompanyType").
		Preload("City").
		Preload("Currency").
		Preload("Categories").
		Preload("Contacts").
		Preload("DeliveryOptions").
		Preload("PublicServices").
		First(&company, member.CompanyID).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	payload := BuildCompanyMemberSummary(&company, member)

	response.Success(c, http.StatusOK, "Company summary retrieved successfully", payload)
}
