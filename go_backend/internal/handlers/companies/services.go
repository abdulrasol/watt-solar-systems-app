package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

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
