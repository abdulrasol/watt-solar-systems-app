package accounting

import (
	"fmt"
	"net/http"
	"sort"
	"strings"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// Transactions handles GET /api/v1/accounting/:company_id/transactions
func Transactions(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	ordering := c.DefaultQuery("ordering", "-date")
	search := strings.ToLower(c.Query("search"))

	var transactions []map[string]interface{}

	var invoices []models.Invoice
	database.DB.Preload("Customer").Where("company_id = ?", company.ID).Find(&invoices)
	for _, inv := range invoices {
		counterparty := ""
		if inv.Customer != nil {
			if inv.Customer.FullName != nil {
				counterparty = *inv.Customer.FullName
			}
		}
		transactions = append(transactions, map[string]interface{}{
			"type":         "invoice",
			"id":           inv.ID,
			"number":       inv.InvoiceNumber,
			"counterparty": counterparty,
			"amount":       inv.TotalAmount,
			"balance_due":  inv.TotalAmount - inv.PaidAmount,
			"status":       inv.Status,
			"date":         formatTimeValue(inv.IssueDate),
		})
	}

	var bills []models.Bill
	database.DB.Preload("Supplier").Where("company_id = ?", company.ID).Find(&bills)
	for _, b := range bills {
		counterparty := ""
		if b.Supplier != nil {
			counterparty = b.Supplier.Name
		}
		transactions = append(transactions, map[string]interface{}{
			"type":         "bill",
			"id":           b.ID,
			"number":       b.BillNumber,
			"counterparty": counterparty,
			"amount":       b.TotalAmount,
			"balance_due":  b.TotalAmount - b.PaidAmount,
			"status":       b.Status,
			"date":         formatTime(b.IssueDate),
		})
	}

	var payments []models.Payment
	database.DB.Where("company_id = ?", company.ID).Find(&payments)
	for _, p := range payments {
		ref := p.Reference
		if ref == nil {
			r := fmt.Sprintf("PAY-%d", p.ID)
			ref = &r
		}
		transactions = append(transactions, map[string]interface{}{
			"type":         "payment",
			"id":           p.ID,
			"number":       *ref,
			"counterparty": nil,
			"amount":       p.Amount,
			"balance_due":  0.0,
			"status":       p.PaymentType,
			"date":         formatTimeValue(p.PaymentDate),
		})
	}

	if search != "" {
		filtered := make([]map[string]interface{}, 0)
		for _, item := range transactions {
			number, _ := item["number"].(string)
			counterparty, _ := item["counterparty"].(string)
			if strings.Contains(strings.ToLower(number), search) || strings.Contains(strings.ToLower(counterparty), search) {
				filtered = append(filtered, item)
			}
		}
		transactions = filtered
	}

	reverse := strings.HasPrefix(ordering, "-")
	key := strings.TrimPrefix(ordering, "-")
	sort.Slice(transactions, func(i, j int) bool {
		var si, sj string
		if key == "date" {
			if transactions[i]["date"] != nil {
				si = *transactions[i]["date"].(*string)
			}
			if transactions[j]["date"] != nil {
				sj = *transactions[j]["date"].(*string)
			}
		} else {
			si, _ = transactions[i][key].(string)
			sj, _ = transactions[j][key].(string)
		}
		if reverse {
			return si > sj
		}
		return si < sj
	})

	response.Success(c, http.StatusOK, "Accounting transactions retrieved successfully.", paginationResponse(page, pageSize, int64(len(transactions)), transactions))
}
