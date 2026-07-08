package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/response"
)

// GetCompanyServices handles GET /api/v1/companies/:company_id/services
// @Summary GetCompanyServices
// @Description Get service catalog status for a company
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/services [get]
func GetCompanyServices(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	database.DB.Preload("CompanyType").
		Preload("CompanyType.AllowedServices").
		Preload("ServiceTypes").
		First(company, company.ID)

	services := GetCompanyServicesStatus(company)
	response.Success(c, http.StatusOK, "Services retrieved successfully", map[string]interface{}{
		"items": services,
		"count": len(services),
	})
}
