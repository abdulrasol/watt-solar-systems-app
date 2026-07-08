package accounting

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/models"
)

func parsePagination(c *gin.Context) (page, pageSize int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ = strconv.Atoi(c.DefaultQuery("page_size", "12"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}
	return
}

func paginationResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	return map[string]interface{}{
		"items": items,
		"count": total,
		"pagination": map[string]interface{}{
			"page":         page,
			"page_size":    pageSize,
			"total_items":  total,
			"total_pages":  totalPages,
			"has_next":     page < totalPages,
			"has_previous": page > 1,
		},
	}
}

func toFloat(v float64) float64 { return v }

func formatTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format("2006-01-02T15:04:05Z07:00")
	return &s
}

func formatTimeValue(t time.Time) *string {
	if t.IsZero() {
		return nil
	}
	s := t.Format("2006-01-02T15:04:05Z07:00")
	return &s
}

func serializeAccount(a *models.Account) map[string]interface{} {
	return map[string]interface{}{
		"id":           a.ID,
		"name":         a.Name,
		"code":         a.Code,
		"account_type": a.AccountType,
		"description":  a.Description,
		"is_active":    a.IsActive,
		"created_at":   a.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":   a.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeInvoice(inv *models.Invoice) map[string]interface{} {
	var customer map[string]interface{}
	if inv.Customer != nil {
		name := ""
		if inv.Customer.FullName != nil {
			name = *inv.Customer.FullName
		}
		customer = map[string]interface{}{"id": inv.CustomerID, "name": name}
	}
	return map[string]interface{}{
		"id":               inv.ID,
		"invoice_number":   inv.InvoiceNumber,
		"company_id":       inv.CompanyID,
		"customer":         customer,
		"order_id":         inv.OrderID,
		"issue_date":       formatTimeValue(inv.IssueDate),
		"due_date":         formatTimeValue(inv.DueDate),
		"total_amount":     inv.TotalAmount,
		"paid_amount":      inv.PaidAmount,
		"balance_due":      inv.TotalAmount - inv.PaidAmount,
		"status":           inv.Status,
		"journal_entry_id": inv.JournalEntryID,
		"created_at":       inv.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":       inv.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeBill(b *models.Bill) map[string]interface{} {
	var supplier map[string]interface{}
	if b.Supplier != nil {
		supplier = map[string]interface{}{"id": b.SupplierID, "name": b.Supplier.Name}
	}
	issueDate := formatTime(b.IssueDate)
	return map[string]interface{}{
		"id":               b.ID,
		"bill_number":      b.BillNumber,
		"company_id":       b.CompanyID,
		"supplier":         supplier,
		"order_id":         b.OrderID,
		"issue_date":       issueDate,
		"due_date":         formatTimeValue(b.DueDate),
		"total_amount":     b.TotalAmount,
		"paid_amount":      b.PaidAmount,
		"balance_due":      b.TotalAmount - b.PaidAmount,
		"status":           b.Status,
		"journal_entry_id": b.JournalEntryID,
		"created_at":       b.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":       b.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializePayment(p *models.Payment) map[string]interface{} {
	return map[string]interface{}{
		"id":               p.ID,
		"company_id":       p.CompanyID,
		"invoice_id":       p.InvoiceID,
		"bill_id":          p.BillID,
		"payment_type":     p.PaymentType,
		"amount":           p.Amount,
		"payment_date":     formatTimeValue(p.PaymentDate),
		"payment_method":   p.PaymentMethod,
		"reference":        p.Reference,
		"journal_entry_id": p.JournalEntryID,
		"created_at":       p.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeJournalEntry(entry *models.JournalEntry) map[string]interface{} {
	lines := make([]map[string]interface{}, 0, len(entry.Lines))
	for _, line := range entry.Lines {
		name := ""
		if line.Account.ID != 0 {
			name = line.Account.Name
		}
		lines = append(lines, map[string]interface{}{
			"id":           line.ID,
			"account_id":   line.AccountID,
			"account_name": name,
			"description":  line.Description,
			"debit":        line.Debit,
			"credit":       line.Credit,
		})
	}
	isBalanced := true
	var debitSum, creditSum float64
	for _, l := range entry.Lines {
		debitSum += l.Debit
		creditSum += l.Credit
	}
	isBalanced = debitSum == creditSum
	return map[string]interface{}{
		"id":          entry.ID,
		"date":        formatTimeValue(entry.Date),
		"description": entry.Description,
		"reference":   entry.Reference,
		"company_id":  entry.CompanyID,
		"is_balanced": isBalanced,
		"lines":       lines,
		"created_at":  entry.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":  entry.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}
