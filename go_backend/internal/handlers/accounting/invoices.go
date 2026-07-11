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

// ListInvoices handles GET /api/v1/accounting/:company_id/invoices
func ListInvoices(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize
	ordering := c.DefaultQuery("ordering", "-created_at")

	query := database.DB.Model(&models.Invoice{}).Preload("Customer").Preload("Order").Where("company_id = ?", company.ID)
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}
	if customerID := c.Query("customer_id"); customerID != "" {
		query = query.Where("customer_id = ?", customerID)
	}
	if orderID := c.Query("order_id"); orderID != "" {
		query = query.Where("order_id = ?", orderID)
	}
	if from := c.Query("date_from"); from != "" {
		query = query.Where("issue_date >= ?", from)
	}
	if to := c.Query("date_to"); to != "" {
		query = query.Where("issue_date <= ?", to)
	}
	if search := c.Query("search"); search != "" {
		query = query.Where("invoice_number LIKE ? OR EXISTS (SELECT 1 FROM shop_customers sc WHERE sc.id = invoices.customer_id AND sc.full_name LIKE ?)", "%"+search+"%", "%"+search+"%")
	}

	orderCol := "created_at desc"
	switch ordering {
	case "created_at":
		orderCol = "created_at"
	case "issue_date":
		orderCol = "issue_date"
	case "-issue_date":
		orderCol = "issue_date desc"
	case "due_date":
		orderCol = "due_date"
	case "-due_date":
		orderCol = "due_date desc"
	case "total_amount":
		orderCol = "total_amount"
	case "-total_amount":
		orderCol = "total_amount desc"
	}

	var total int64
	query.Count(&total)

	var invoices []models.Invoice
	query.Order(orderCol).Limit(pageSize).Offset(offset).Find(&invoices)

	items := make([]map[string]interface{}, 0, len(invoices))
	for _, inv := range invoices {
		items = append(items, serializeInvoice(&inv))
	}

	response.Success(c, http.StatusOK, "Invoices retrieved successfully.", paginationResponse(page, pageSize, total, items))
}

// GetInvoice handles GET /api/v1/accounting/:company_id/invoices/:invoice_id
func GetInvoice(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	invoiceID, _ := strconv.Atoi(c.Param("invoice_id"))
	var inv models.Invoice
	if err := database.DB.Preload("Customer").Preload("Order").Where("id = ? AND company_id = ?", invoiceID, company.ID).First(&inv).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Invoice not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Invoice retrieved successfully.", serializeInvoice(&inv))
}
