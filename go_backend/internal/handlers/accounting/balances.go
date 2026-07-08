package accounting

import (
	"net/http"
	"sort"
	"strings"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// Receivables handles GET /api/v1/accounting/:company_id/receivables
func Receivables(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	ordering := c.DefaultQuery("ordering", "-balance_due")

	var invoices []models.Invoice
	database.DB.Preload("Customer").Where("company_id = ? AND customer_id IS NOT NULL", company.ID).Find(&invoices)

	balances := map[uint]map[string]interface{}{}
	for _, inv := range invoices {
		entry, exists := balances[*inv.CustomerID]
		if !exists {
			name := ""
			if inv.Customer != nil && inv.Customer.FullName != nil {
				name = *inv.Customer.FullName
			}
			entry = map[string]interface{}{
				"customer_id":    *inv.CustomerID,
				"customer_name":  name,
				"total_amount":   0.0,
				"paid_amount":    0.0,
				"balance_due":    0.0,
				"invoices_count": 0,
			}
			balances[*inv.CustomerID] = entry
		}
		entry["total_amount"] = entry["total_amount"].(float64) + inv.TotalAmount
		entry["paid_amount"] = entry["paid_amount"].(float64) + inv.PaidAmount
		entry["balance_due"] = entry["balance_due"].(float64) + (inv.TotalAmount - inv.PaidAmount)
		entry["invoices_count"] = entry["invoices_count"].(int) + 1
	}

	items := make([]map[string]interface{}, 0, len(balances))
	for _, item := range balances {
		items = append(items, item)
	}

	items = filterAndSort(items, ordering)
	response.Success(c, http.StatusOK, "Customer receivables retrieved successfully.", paginationResponse(page, pageSize, int64(len(items)), items))
}

// Payables handles GET /api/v1/accounting/:company_id/payables
func Payables(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	ordering := c.DefaultQuery("ordering", "-balance_due")

	var bills []models.Bill
	database.DB.Preload("Supplier").Where("company_id = ? AND supplier_id IS NOT NULL", company.ID).Find(&bills)

	balances := map[uint]map[string]interface{}{}
	for _, b := range bills {
		entry, exists := balances[*b.SupplierID]
		if !exists {
			name := ""
			if b.Supplier != nil {
				name = b.Supplier.Name
			}
			entry = map[string]interface{}{
				"supplier_id":   *b.SupplierID,
				"supplier_name": name,
				"total_amount":  0.0,
				"paid_amount":   0.0,
				"balance_due":   0.0,
				"bills_count":   0,
			}
			balances[*b.SupplierID] = entry
		}
		entry["total_amount"] = entry["total_amount"].(float64) + b.TotalAmount
		entry["paid_amount"] = entry["paid_amount"].(float64) + b.PaidAmount
		entry["balance_due"] = entry["balance_due"].(float64) + (b.TotalAmount - b.PaidAmount)
		entry["bills_count"] = entry["bills_count"].(int) + 1
	}

	items := make([]map[string]interface{}, 0, len(balances))
	for _, item := range balances {
		items = append(items, item)
	}

	items = filterAndSort(items, ordering)
	response.Success(c, http.StatusOK, "Supplier payables retrieved successfully.", paginationResponse(page, pageSize, int64(len(items)), items))
}

func filterAndSort(items []map[string]interface{}, ordering string) []map[string]interface{} {
	reverse := strings.HasPrefix(ordering, "-")
	key := strings.TrimPrefix(ordering, "-")

	sort.Slice(items, func(i, j int) bool {
		var vi, vj float64
		switch key {
		case "balance_due", "total_amount", "paid_amount":
			vi = items[i][key].(float64)
			vj = items[j][key].(float64)
		default:
			vi = items[i]["balance_due"].(float64)
			vj = items[j]["balance_due"].(float64)
		}
		if reverse {
			return vi > vj
		}
		return vi < vj
	})
	return items
}
