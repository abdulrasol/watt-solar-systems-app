package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetServiceCatalog handles GET /api/companies/catalog/services
// @Security Bearer
// @Summary GetServiceCatalog
// @Description GetServiceCatalog
// @Tags Companies
// @Success 200 {object} response.APIResponse
// @Router /companies/catalog/services [get]
func GetServiceCatalog(c *gin.Context) {
	var services []models.CompanyServiceCatalog
	if err := database.DB.Where("is_active = ?", true).
		Preload("CompanyTypes").
		Order("sort_order asc, name asc").
		Find(&services).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب دليل الخدمات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch services", &msgUser)
		return
	}

	var data []map[string]interface{}
	for _, item := range services {
		var types []map[string]interface{}
		for _, ct := range item.CompanyTypes {
			types = append(types, map[string]interface{}{
				"id":   ct.ID,
				"code": ct.CType,
				"name": ct.Name,
			})
		}

		data = append(data, map[string]interface{}{
			"id":          item.ID,
			"code":        item.Code,
			"name":        item.Name,
			"description": item.Description,
			"category":    item.Category,
			"sort_order":  item.SortOrder,
			"route":       item.Route,
			"icon":        item.Icon,
			"types":       types,
		})
	}

	response.Success(c, http.StatusOK, "Service catalog retrieved successfully.", map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// GetSubscriptionPlans handles GET /api/companies/subscriptions
// @Security Bearer
// @Summary GetSubscriptionPlans
// @Description GetSubscriptionPlans
// @Tags Companies
// @Success 200 {object} response.APIResponse
// @Router /companies/subscriptions [get]
func GetSubscriptionPlans(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		msgUser := "الرجاء تسجيل الدخول"
		response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
		return
	}

	// Get the user's company member record to find their company
	var member models.CompanyMember
	if err := database.DB.Where("user_id = ?", userID).Preload("Company").First(&member).Error; err != nil {
		response.Success(c, http.StatusOK, "Subscription plans retrieved successfully.", map[string]interface{}{
			"items": []interface{}{},
			"count": 0,
		})
		return
	}

	company := member.Company
	if company.CompanyTypeID == nil {
		response.Success(c, http.StatusOK, "Subscription plans retrieved successfully.", map[string]interface{}{
			"items": []interface{}{},
			"count": 0,
		})
		return
	}

	// Get the allowed subscription plans for the company type
	var companyType models.CompanyType
	if err := database.DB.Preload("AllowedSubscriptionPlans", "is_active = ?", true).
		First(&companyType, *company.CompanyTypeID).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب باقات الاشتراك"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch plans", &msgUser)
		return
	}

	var data []map[string]interface{}
	for _, plan := range companyType.AllowedSubscriptionPlans {
		data = append(data, map[string]interface{}{
			"id":            plan.ID,
			"name":          plan.Name,
			"duration_days": plan.DurationDays,
			"price":         plan.Price,
			"description":   plan.Description,
			"is_active":     plan.IsActive,
			"created_at":    plan.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Subscription plans retrieved successfully.", map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}
