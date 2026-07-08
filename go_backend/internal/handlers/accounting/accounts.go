package accounting

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// ListAccounts handles GET /api/v1/accounting/:company_id/accounts
func ListAccounts(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize
	ordering := c.DefaultQuery("ordering", "code")

	query := database.DB.Model(&models.Account{}).Where("company_id = ?", company.ID)
	if t := c.Query("account_type"); t != "" {
		query = query.Where("account_type = ?", t)
	}
	if active := c.Query("is_active"); active != "" {
		query = query.Where("is_active = ?", active == "true")
	}
	if search := c.Query("search"); search != "" {
		query = query.Where("name ILIKE ? OR code ILIKE ?", "%"+search+"%", "%"+search+"%")
	}

	orderCol := "code"
	switch ordering {
	case "-code":
		orderCol = "code desc"
	case "name":
		orderCol = "name"
	case "-name":
		orderCol = "name desc"
	case "created_at":
		orderCol = "created_at"
	case "-created_at":
		orderCol = "created_at desc"
	}

	var total int64
	query.Count(&total)

	var accounts []models.Account
	query.Order(orderCol).Limit(pageSize).Offset(offset).Find(&accounts)

	items := make([]map[string]interface{}, 0, len(accounts))
	for _, a := range accounts {
		items = append(items, serializeAccount(&a))
	}

	response.Success(c, http.StatusOK, "Accounts retrieved successfully.", paginationResponse(page, pageSize, total, items))
}

// CreateAccount handles POST /api/v1/accounting/:company_id/accounts
func CreateAccount(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.AccountCreateUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	account := models.Account{
		CompanyID:   company.ID,
		Name:        payload.Name,
		Code:        payload.Code,
		AccountType: payload.AccountType,
		Description: payload.Description,
		IsActive:    payload.IsActive,
	}
	database.DB.Create(&account)
	response.Success(c, http.StatusOK, "Account created successfully.", serializeAccount(&account))
}

// UpdateAccount handles PUT /api/v1/accounting/:company_id/accounts/:account_id
func UpdateAccount(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	accountID, _ := strconv.Atoi(c.Param("account_id"))
	var account models.Account
	if err := database.DB.Where("id = ? AND company_id = ?", accountID, company.ID).First(&account).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Account not found", nil)
		return
	}

	var payload models.AccountCreateUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	account.Name = payload.Name
	account.Code = payload.Code
	account.AccountType = payload.AccountType
	account.Description = payload.Description
	account.IsActive = payload.IsActive
	database.DB.Save(&account)
	response.Success(c, http.StatusOK, "Account updated successfully.", serializeAccount(&account))
}

// DeleteAccount handles DELETE /api/v1/accounting/:company_id/accounts/:account_id
func DeleteAccount(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	accountID, _ := strconv.Atoi(c.Param("account_id"))
	var account models.Account
	if err := database.DB.Where("id = ? AND company_id = ?", accountID, company.ID).First(&account).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Account not found", nil)
		return
	}

	database.DB.Delete(&account)
	response.Success(c, http.StatusOK, "Account deleted successfully.", nil)
}
