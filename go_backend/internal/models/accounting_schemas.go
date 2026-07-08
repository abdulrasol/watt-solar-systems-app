package models

import "time"

// AccountCreateUpdateSchema schema
type AccountCreateUpdateSchema struct {
	Name        string  `json:"name" binding:"required"`
	Code        *string `json:"code"`
	AccountType string  `json:"account_type" binding:"required"`
	Description *string `json:"description"`
	IsActive    bool    `json:"is_active" default:"true"`
}

// JournalEntryLineSchema schema
type JournalEntryLineSchema struct {
	AccountID   uint    `json:"account_id" binding:"required"`
	Description *string `json:"description"`
	Debit       float64 `json:"debit" default:"0"`
	Credit      float64 `json:"credit" default:"0"`
}

// JournalEntryCreateSchema schema
type JournalEntryCreateSchema struct {
	Date        time.Time                `json:"date" binding:"required"`
	Description string                   `json:"description" binding:"required"`
	Reference   *string                  `json:"reference"`
	Lines       []JournalEntryLineSchema `json:"lines" binding:"required"`
}

// PaymentCreateSchema schema
type PaymentCreateSchema struct {
	InvoiceID     *uint   `json:"invoice_id"`
	BillID        *uint   `json:"bill_id"`
	Amount        float64 `json:"amount" binding:"required"`
	PaymentMethod string  `json:"payment_method" binding:"required"`
	Reference     *string `json:"reference"`
}

// PayrollCreateSchema schema
type PayrollCreateSchema struct {
	EmployeeID  uint      `json:"employee_id" binding:"required"`
	PeriodStart time.Time `json:"period_start" binding:"required"`
	PeriodEnd   time.Time `json:"period_end" binding:"required"`
	BaseSalary  float64   `json:"base_salary" binding:"required"`
	Bonus       float64   `json:"bonus" default:"0"`
	Deductions  float64   `json:"deductions" default:"0"`
	NetPay      float64   `json:"net_pay" binding:"required"`
}

// TaxRecordCreateSchema schema
type TaxRecordCreateSchema struct {
	TaxName            string  `json:"tax_name" binding:"required"`
	TaxRate            float64 `json:"tax_rate" binding:"required"`
	Description        *string `json:"description"`
	LiabilityAccountID *uint   `json:"liability_account_id"`
}
