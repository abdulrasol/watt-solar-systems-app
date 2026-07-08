package accounting

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// ListPayments handles GET /api/v1/accounting/:company_id/payments
func ListPayments(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize
	ordering := c.DefaultQuery("ordering", "-payment_date")

	query := database.DB.Model(&models.Payment{}).Preload("Invoice").Preload("Bill").Where("company_id = ?", company.ID)
	if t := c.Query("payment_type"); t != "" {
		query = query.Where("payment_type = ?", t)
	}
	if method := c.Query("payment_method"); method != "" {
		query = query.Where("payment_method = ?", method)
	}
	if invoiceID := c.Query("invoice_id"); invoiceID != "" {
		query = query.Where("invoice_id = ?", invoiceID)
	}
	if billID := c.Query("bill_id"); billID != "" {
		query = query.Where("bill_id = ?", billID)
	}
	if from := c.Query("date_from"); from != "" {
		query = query.Where("payment_date >= ?", from)
	}
	if to := c.Query("date_to"); to != "" {
		query = query.Where("payment_date <= ?", to)
	}
	if search := c.Query("search"); search != "" {
		query = query.Where("reference ILIKE ?", "%"+search+"%")
	}

	orderCol := "payment_date desc"
	switch ordering {
	case "payment_date":
		orderCol = "payment_date"
	case "created_at":
		orderCol = "created_at"
	case "-created_at":
		orderCol = "created_at desc"
	case "amount":
		orderCol = "amount"
	case "-amount":
		orderCol = "amount desc"
	}

	var total int64
	query.Count(&total)

	var payments []models.Payment
	query.Order(orderCol).Limit(pageSize).Offset(offset).Find(&payments)

	items := make([]map[string]interface{}, 0, len(payments))
	for _, p := range payments {
		items = append(items, serializePayment(&p))
	}

	response.Success(c, http.StatusOK, "Payments retrieved successfully.", paginationResponse(page, pageSize, total, items))
}

// CreatePayment handles POST /api/v1/accounting/:company_id/payments
func CreatePayment(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.PaymentCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if payload.InvoiceID == nil && payload.BillID == nil {
		response.Error(c, http.StatusBadRequest, "invoice_id or bill_id is required.", nil)
		return
	}
	if payload.InvoiceID != nil && payload.BillID != nil {
		response.Error(c, http.StatusBadRequest, "Provide only one of invoice_id or bill_id.", nil)
		return
	}

	var payment *models.Payment
	if payload.InvoiceID != nil {
		var inv models.Invoice
		if err := database.DB.Where("id = ? AND company_id = ?", *payload.InvoiceID, company.ID).First(&inv).Error; err != nil {
			response.Error(c, http.StatusNotFound, "Invoice not found", nil)
			return
		}
		payment = applyInvoicePayment(&inv, payload.Amount, payload.PaymentMethod, payload.Reference)

		if inv.OrderID != nil {
			var bill models.Bill
			if err := database.DB.Where("order_id = ? AND company_id = ?", *inv.OrderID, company.ID).First(&bill).Error; err == nil {
				ref := payload.Reference
				if ref == nil {
					r := "ORDER-" + strconv.Itoa(int(*inv.OrderID))
					ref = &r
				}
				applyBillPayment(&bill, payload.Amount, payload.PaymentMethod, ref)
			}
		}
	} else {
		var bill models.Bill
		if err := database.DB.Where("id = ? AND company_id = ?", *payload.BillID, company.ID).First(&bill).Error; err != nil {
			response.Error(c, http.StatusNotFound, "Bill not found", nil)
			return
		}
		payment = applyBillPayment(&bill, payload.Amount, payload.PaymentMethod, payload.Reference)

		if bill.OrderID != nil {
			var inv models.Invoice
			if err := database.DB.Where("order_id = ? AND company_id = ?", *bill.OrderID, company.ID).First(&inv).Error; err == nil {
				ref := payload.Reference
				if ref == nil {
					r := "ORDER-" + strconv.Itoa(int(*bill.OrderID))
					ref = &r
				}
				applyInvoicePayment(&inv, payload.Amount, payload.PaymentMethod, ref)
			}
		}
	}

	response.Success(c, http.StatusOK, "Payment recorded successfully.", serializePayment(payment))
}

func applyInvoicePayment(invoice *models.Invoice, amount float64, method string, reference *string) *models.Payment {
	var existing models.Payment
	err := database.DB.Where("company_id = ? AND invoice_id = ? AND amount = ? AND reference = ?", invoice.CompanyID, invoice.ID, amount, reference).First(&existing).Error
	if err == nil {
		return &existing
	}

	payment := models.Payment{
		CompanyID:     invoice.CompanyID,
		InvoiceID:     &invoice.ID,
		PaymentType:   "incoming",
		Amount:        amount,
		PaymentMethod: method,
		Reference:     reference,
	}
	database.DB.Create(&payment)

	invoice.PaidAmount += amount
	balance := invoice.TotalAmount - invoice.PaidAmount
	if balance <= 0 {
		invoice.Status = "paid"
	} else if invoice.PaidAmount > 0 {
		invoice.Status = "partially_paid"
	}
	database.DB.Save(invoice)

	syncOrderFromInvoice(invoice)
	return &payment
}

func applyBillPayment(bill *models.Bill, amount float64, method string, reference *string) *models.Payment {
	var existing models.Payment
	err := database.DB.Where("company_id = ? AND bill_id = ? AND amount = ? AND reference = ?", bill.CompanyID, bill.ID, amount, reference).First(&existing).Error
	if err == nil {
		return &existing
	}

	payment := models.Payment{
		CompanyID:     bill.CompanyID,
		BillID:        &bill.ID,
		PaymentType:   "outgoing",
		Amount:        amount,
		PaymentMethod: method,
		Reference:     reference,
	}
	database.DB.Create(&payment)

	bill.PaidAmount += amount
	balance := bill.TotalAmount - bill.PaidAmount
	if balance <= 0 {
		bill.Status = "paid"
	} else if bill.PaidAmount > 0 {
		bill.Status = "partially_paid"
	}
	database.DB.Save(bill)
	return &payment
}

func syncOrderFromInvoice(invoice *models.Invoice) {
	if invoice.OrderID == nil {
		return
	}
	var order models.Order
	if err := database.DB.First(&order, *invoice.OrderID).Error; err != nil {
		return
	}
	order.PaidAmount = invoice.PaidAmount
	oldPaymentStatus := order.PaymentStatus
	if invoice.PaidAmount <= 0 {
		order.PaymentStatus = "unpaid"
	} else if invoice.TotalAmount-invoice.PaidAmount <= 0 {
		order.PaymentStatus = "paid"
	} else {
		order.PaymentStatus = "partial"
	}
	database.DB.Save(&order)

	if order.PaymentStatus != oldPaymentStatus {
		notifsvc.SendBuyerOrderPaymentStatusNotification(&order)
	}
}
