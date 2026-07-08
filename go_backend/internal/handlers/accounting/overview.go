package accounting

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// Overview handles GET /api/v1/accounting/:company_id/overview
func Overview(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var invoicesTotal, billsTotal, paymentsTotal int64
	database.DB.Model(&models.Invoice{}).Where("company_id = ?", company.ID).Count(&invoicesTotal)
	database.DB.Model(&models.Bill{}).Where("company_id = ?", company.ID).Count(&billsTotal)
	database.DB.Model(&models.Payment{}).Where("company_id = ?", company.ID).Count(&paymentsTotal)

	var receivables, payables, incoming, outgoing float64
	database.DB.Model(&models.Invoice{}).Where("company_id = ?", company.ID).Select("COALESCE(SUM(total_amount - paid_amount), 0)").Scan(&receivables)
	database.DB.Model(&models.Bill{}).Where("company_id = ?", company.ID).Select("COALESCE(SUM(total_amount - paid_amount), 0)").Scan(&payables)
	database.DB.Model(&models.Payment{}).Where("company_id = ? AND payment_type = ?", company.ID, "incoming").Select("COALESCE(SUM(amount), 0)").Scan(&incoming)
	database.DB.Model(&models.Payment{}).Where("company_id = ? AND payment_type = ?", company.ID, "outgoing").Select("COALESCE(SUM(amount), 0)").Scan(&outgoing)

	data := map[string]interface{}{
		"invoices_total":          invoicesTotal,
		"bills_total":             billsTotal,
		"payments_total":          paymentsTotal,
		"receivables_total":       receivables,
		"payables_total":          payables,
		"payments_incoming_total": incoming,
		"payments_outgoing_total": outgoing,
	}

	response.Success(c, http.StatusOK, "Accounting overview retrieved successfully.", data)
}
