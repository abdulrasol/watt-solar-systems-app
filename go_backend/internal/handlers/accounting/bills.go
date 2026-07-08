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

// ListBills handles GET /api/v1/accounting/:company_id/bills
func ListBills(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize
	ordering := c.DefaultQuery("ordering", "-created_at")

	query := database.DB.Model(&models.Bill{}).Preload("Supplier").Preload("Order").Where("company_id = ?", company.ID)
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}
	if supplierID := c.Query("supplier_id"); supplierID != "" {
		query = query.Where("supplier_id = ?", supplierID)
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
		query = query.Where("bill_number ILIKE ? OR EXISTS (SELECT 1 FROM shop_suppliers ss WHERE ss.id = bills.supplier_id AND ss.name ILIKE ?)", "%"+search+"%", "%"+search+"%")
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

	var bills []models.Bill
	query.Order(orderCol).Limit(pageSize).Offset(offset).Find(&bills)

	items := make([]map[string]interface{}, 0, len(bills))
	for _, b := range bills {
		items = append(items, serializeBill(&b))
	}

	response.Success(c, http.StatusOK, "Bills retrieved successfully.", paginationResponse(page, pageSize, total, items))
}

// GetBill handles GET /api/v1/accounting/:company_id/bills/:bill_id
func GetBill(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	billID, _ := strconv.Atoi(c.Param("bill_id"))
	var b models.Bill
	if err := database.DB.Preload("Supplier").Preload("Order").Where("id = ? AND company_id = ?", billID, company.ID).First(&b).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Bill not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Bill retrieved successfully.", serializeBill(&b))
}
