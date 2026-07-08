package companies

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetCompanyAnalytics handles GET /api/v1/companies/:company_id/analytics
// @Summary GetCompanyAnalytics
// @Description Get company analytics aggregate
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/analytics [get]
func GetCompanyAnalytics(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var productsCount int64
	database.DB.Model(&models.Product{}).Where("company_id = ? AND status = ?", company.ID, "active").Count(&productsCount)

	var ordersCount, completedOrdersCount int64
	var totalOrderAmount, totalPaidAmount float64
	database.DB.Model(&models.Order{}).Where("seller_company_id = ?", company.ID).Count(&ordersCount)
	database.DB.Model(&models.Order{}).Where("seller_company_id = ? AND status = ?", company.ID, "completed").Count(&completedOrdersCount)
	database.DB.Model(&models.Order{}).Where("seller_company_id = ? AND status != ?", company.ID, "cancelled").Select("COALESCE(SUM(total_amount), 0)").Scan(&totalOrderAmount)
	database.DB.Model(&models.Order{}).Where("seller_company_id = ? AND status != ?", company.ID, "cancelled").Select("COALESCE(SUM(paid_amount), 0)").Scan(&totalPaidAmount)

	var expensesCount, transactionsCount int64
	database.DB.Model(&models.Expense{}).Where("company_id = ?", company.ID).Count(&expensesCount)
	database.DB.Model(&models.FinancialTransaction{}).Where("company_id = ?", company.ID).Count(&transactionsCount)

	response.Success(c, http.StatusOK, "Analytics retrieved successfully", map[string]interface{}{
		"products_count":         productsCount,
		"orders_count":           ordersCount,
		"completed_orders_count": completedOrdersCount,
		"total_order_amount":     totalOrderAmount,
		"total_paid_amount":      totalPaidAmount,
		"expenses_count":         expensesCount,
		"transactions_count":     transactionsCount,
	})
}
