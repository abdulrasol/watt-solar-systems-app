package accounting

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// LedgerSummary handles GET /api/v1/accounting/:company_id/ledger
func LedgerSummary(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	summary := map[string]float64{
		"asset":      0,
		"liability":  0,
		"equity":     0,
		"revenue":    0,
		"expense":    0,
		"net_income": 0,
	}

	var accounts []models.Account
	database.DB.Where("company_id = ?", company.ID).Find(&accounts)

	for _, account := range accounts {
		var debitTotal, creditTotal float64
		database.DB.Model(&models.JournalEntryLine{}).Where("account_id = ?", account.ID).Select("COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0)").Row().Scan(&debitTotal, &creditTotal)

		var balance float64
		if account.AccountType == "asset" || account.AccountType == "expense" {
			balance = debitTotal - creditTotal
		} else {
			balance = creditTotal - debitTotal
		}
		summary[account.AccountType] += balance
	}

	summary["net_income"] = summary["revenue"] - summary["expense"]

	data := map[string]interface{}{
		"asset":      summary["asset"],
		"liability":  summary["liability"],
		"equity":     summary["equity"],
		"revenue":    summary["revenue"],
		"expense":    summary["expense"],
		"net_income": summary["net_income"],
	}
	response.Success(c, http.StatusOK, "Ledger summary retrieved successfully.", data)
}
