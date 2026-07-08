package models

import (
	"time"
)

// JournalEntry maps to accounting.JournalEntry
type JournalEntry struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID   uint      `gorm:"not null" json:"company_id"`
	Company     Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Date        time.Time `gorm:"type:date;not null" json:"date"`
	Description string    `gorm:"type:varchar(255)" json:"description"`
	Reference   *string   `gorm:"type:varchar(100)" json:"reference"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
	Lines       []JournalEntryLine `gorm:"foreignKey:JournalEntryID;constraint:OnDelete:CASCADE;" json:"-"`
}

// JournalEntryLine maps to accounting.JournalEntryLine
type JournalEntryLine struct {
	ID              uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	JournalEntryID  uint      `gorm:"not null" json:"journal_entry_id"`
	AccountID       uint      `gorm:"not null" json:"account_id"`
	Account         Account   `gorm:"foreignKey:AccountID;constraint:OnDelete:CASCADE;" json:"-"`
	Description     *string   `gorm:"type:varchar(255)" json:"description"`
	Debit           float64   `gorm:"type:decimal(12,2);default:0" json:"debit"`
	Credit          float64   `gorm:"type:decimal(12,2);default:0" json:"credit"`
}

// Payroll maps to accounting.Payroll
type Payroll struct {
	ID             uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint           `gorm:"not null" json:"company_id"`
	Company        Company        `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	EmployeeID     uint           `gorm:"not null" json:"employee_id"`
	Employee       CompanyMember  `gorm:"foreignKey:EmployeeID;constraint:OnDelete:CASCADE;" json:"-"`
	PeriodStart    time.Time      `gorm:"type:date;not null" json:"period_start"`
	PeriodEnd      time.Time      `gorm:"type:date;not null" json:"period_end"`
	DateProcessed  time.Time      `gorm:"autoCreateTime" json:"date_processed"`
	BaseSalary     float64        `gorm:"type:decimal(10,2);default:0" json:"base_salary"`
	Bonus          float64        `gorm:"type:decimal(10,2);default:0" json:"bonus"`
	Deductions     float64        `gorm:"type:decimal(10,2);default:0" json:"deductions"`
	NetPay         float64        `gorm:"type:decimal(10,2);default:0" json:"net_pay"`
	Status         string         `gorm:"type:varchar(20);default:'pending'" json:"status"`
	JournalEntryID *uint          `json:"journal_entry_id"`
	JournalEntry   *JournalEntry  `gorm:"foreignKey:JournalEntryID;constraint:OnDelete:SET NULL;" json:"-"`
}

// TaxRecord maps to accounting.TaxRecord
type TaxRecord struct {
	ID               uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID        uint      `gorm:"not null" json:"company_id"`
	Company          Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	TaxName          string    `gorm:"type:varchar(100);not null" json:"tax_name"`
	TaxRate          float64   `gorm:"type:decimal(5,2);default:0" json:"tax_rate"`
	Description      *string   `gorm:"type:text" json:"description"`
	LiabilityAccountID *uint   `json:"liability_account_id"`
	LiabilityAccount   *Account `gorm:"foreignKey:LiabilityAccountID;constraint:OnDelete:SET NULL;" json:"-"`
}
