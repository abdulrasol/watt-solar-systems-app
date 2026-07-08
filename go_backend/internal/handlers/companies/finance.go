package companies

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetExpenses handles GET /api/company/{company_id}/expense
// @Security Bearer
// @Summary GetExpenses
// @Description GetExpenses
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/expense [get]
func GetExpenses(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var expenses []models.Expense
	if err := database.DB.Where("company_id = ?", member.CompanyID).Order("created_at desc").Find(&expenses).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب المصروفات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch expenses", &msgUser)
		return
	}

	var data []map[string]interface{}
	for _, e := range expenses {
		data = append(data, map[string]interface{}{
			"id":          e.ID,
			"amount":      e.Amount,
			"category":    e.Category,
			"date":        e.Date.Format("2006-01-02"),
			"description": e.Description,
			"created_at":  e.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Expense list retrieved successfully.", map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// CreateExpense handles POST /api/company/{company_id}/expense
// @Accept json
// @Produce json
// @Param request body models.ExpenseSchema true "Expense details"
// @Security Bearer
// @Summary CreateExpense
// @Description CreateExpense
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/expense [post]
func CreateExpense(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Amount      float64 `json:"amount" binding:"required"`
		Category    string  `json:"category" binding:"required"`
		Date        string  `json:"date" binding:"required"`
		Description *string `json:"description"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	dateParsed, err := time.Parse("2006-01-02", payload.Date)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid date format, expected YYYY-MM-DD", nil)
		return
	}

	expense := models.Expense{
		CompanyID:   member.CompanyID,
		Amount:      payload.Amount,
		Category:    payload.Category,
		Date:        dateParsed,
		Description: payload.Description,
	}

	if err := database.DB.Create(&expense).Error; err != nil {
		msgUser := "حدث خطأ أثناء إضافة المصروف"
		response.Error(c, http.StatusInternalServerError, "Failed to create expense", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Expense created successfully.", map[string]interface{}{
		"id":          expense.ID,
		"amount":      expense.Amount,
		"category":    expense.Category,
		"date":        expense.Date.Format("2006-01-02"),
		"description": expense.Description,
		"created_at":  expense.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

// DeleteExpense handles DELETE /api/company/{company_id}/expense/{expense_id}
// @Security Bearer
// @Summary DeleteExpense
// @Description DeleteExpense
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Param expense_id path int true "expense_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/expense/{expense_id} [delete]
func DeleteExpense(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	idStr := c.Param("expense_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Expense ID", nil)
		return
	}

	var exp models.Expense
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&exp).Error; err != nil {
		msgUser := "المصروف غير موجود"
		response.Error(c, http.StatusNotFound, "Expense not found", &msgUser)
		return
	}

	database.DB.Delete(&exp)

	response.Success(c, http.StatusOK, "Expense deleted successfully.", map[string]interface{}{})
}

// GetFinancialTransactions handles GET /api/company/{company_id}/finance
// @Security Bearer
// @Summary GetFinancialTransactions
// @Description GetFinancialTransactions
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/finance [get]
func GetFinancialTransactions(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var txs []models.FinancialTransaction
	if err := database.DB.Where("company_id = ?", member.CompanyID).Order("created_at desc").Find(&txs).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب المعاملات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch transactions", &msgUser)
		return
	}

	var data []map[string]interface{}
	for _, tx := range txs {
		data = append(data, map[string]interface{}{
			"id":             tx.ID,
			"type":           tx.Type,
			"category":       tx.Category,
			"amount":         tx.Amount,
			"description":    tx.Description,
			"payment_method": tx.PaymentMethod,
			"company":        tx.CompanyID,
			"created_at":     tx.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Financial transactions retrieved successfully.", map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// CreateFinancialTransaction handles POST /api/company/{company_id}/finance
// @Accept json
// @Produce json
// @Param request body models.FinancialTransactionSchema true "Financial Transaction details"
// @Security Bearer
// @Summary CreateFinancialTransaction
// @Description CreateFinancialTransaction
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/finance [post]
func CreateFinancialTransaction(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Type          string  `json:"type" binding:"required"`
		Category      string  `json:"category" binding:"required"`
		Amount        float64 `json:"amount" binding:"required"`
		Description   *string `json:"description"`
		PaymentMethod string  `json:"payment_method"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	if payload.PaymentMethod == "" {
		payload.PaymentMethod = "cash"
	}

	tx := models.FinancialTransaction{
		CompanyID:     member.CompanyID,
		Type:          payload.Type,
		Category:      payload.Category,
		Amount:        payload.Amount,
		Description:   payload.Description,
		PaymentMethod: payload.PaymentMethod,
	}

	if err := database.DB.Create(&tx).Error; err != nil {
		msgUser := "حدث خطأ أثناء إضافة المعاملة"
		response.Error(c, http.StatusInternalServerError, "Failed to create transaction", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Financial transaction created successfully.", map[string]interface{}{
		"id":             tx.ID,
		"type":           tx.Type,
		"category":       tx.Category,
		"amount":         tx.Amount,
		"description":    tx.Description,
		"payment_method": tx.PaymentMethod,
		"company":        tx.CompanyID,
		"created_at":     tx.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

// DeleteFinancialTransaction handles DELETE /api/company/{company_id}/finance/{tx_id}
// @Security Bearer
// @Summary DeleteFinancialTransaction
// @Description DeleteFinancialTransaction
// @Tags Companies Finance
// @Param company_id path int true "company_id"
// @Param tx_id path int true "tx_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/finance/{tx_id} [delete]
func DeleteFinancialTransaction(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	idStr := c.Param("tx_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Transaction ID", nil)
		return
	}

	var tx models.FinancialTransaction
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&tx).Error; err != nil {
		msgUser := "المعاملة غير موجودة"
		response.Error(c, http.StatusNotFound, "Transaction not found", &msgUser)
		return
	}

	database.DB.Delete(&tx)

	response.Success(c, http.StatusOK, "Financial transaction deleted successfully.", map[string]interface{}{})
}
