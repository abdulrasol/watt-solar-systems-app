package models

import (
	"time"

	"gorm.io/datatypes"
)

// Product maps to shop.Product
type Product struct {
	ID               uint                 `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID        *uint                `json:"company_id"`
	Company          *Company             `gorm:"foreignKey:CompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	Name             string               `gorm:"type:varchar(255);not null" json:"name"`
	SKU              *string              `gorm:"type:varchar(100)" json:"sku"`
	GlobalCategoryID *uint                `json:"global_category_id"`
	GlobalCategory   *GlobalCategory      `gorm:"foreignKey:GlobalCategoryID;constraint:OnDelete:SET NULL;" json:"-"`
	Description      *string              `gorm:"type:text" json:"description"`
	CostPrice        float64              `gorm:"type:decimal(12,2);default:0" json:"cost_price"`
	RetailPrice      float64              `gorm:"type:decimal(12,2);default:0" json:"retail_price"`
	WholesalePrice   float64              `gorm:"type:decimal(12,2);default:0" json:"wholesale_price"`
	Discount         float64              `gorm:"type:decimal(12,2);default:0" json:"discount"`
	StockQuantity    int                  `gorm:"default:0" json:"stock_quantity"`
	MinStockAlert    int                  `gorm:"default:5" json:"min_stock_alert"`
	Specs            datatypes.JSON       `gorm:"type:json" json:"specs"`
	Status           string               `gorm:"type:varchar(50);default:'active'" json:"status"`
	SourceProductID  *uint                `json:"source_product_id"`
	SourceProduct    *Product             `gorm:"foreignKey:SourceProductID;constraint:OnDelete:SET NULL;" json:"-"`
	CreatedAt        time.Time            `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt        time.Time            `gorm:"autoUpdateTime" json:"updated_at"`
	Images           []ProductImage       `gorm:"many2many:product_product_images;" json:"-"`
	Options          []ProductOption      `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE;" json:"-"`
	PricingTiers     []ProductPricingTier `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE;" json:"-"`
	Categories       []CompanyCategory    `gorm:"many2many:product_company_categories;" json:"-"`
}

// ProductImage maps to shop.ProductImage
type ProductImage struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Image     string    `gorm:"type:varchar(255);not null" json:"image"`
	Name      *string   `gorm:"type:varchar(255)" json:"name"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// ProductOption maps to shop.ProductOption
type ProductOption struct {
	ID             uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	ProductID      uint      `gorm:"not null" json:"product_id"`
	Name           string    `gorm:"type:varchar(255);not null" json:"name"`
	Cost           float64   `gorm:"type:decimal(12,2);default:0" json:"cost"`
	RetailPrice    float64   `gorm:"type:decimal(12,2);default:0" json:"retail_price"`
	WholesalePrice float64   `gorm:"type:decimal(12,2);default:0" json:"wholesale_price"`
	IsRequired     bool      `gorm:"default:false" json:"is_required"`
	CreatedAt      time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// ProductPricingTier maps to shop.ProductPricingTier
type ProductPricingTier struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	ProductID uint      `gorm:"not null" json:"product_id"`
	Quantity  int       `gorm:"default:1" json:"quantity"`
	UnitPrice float64   `gorm:"type:decimal(12,2);default:0" json:"unit_price"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// Order maps to shop.Order
type Order struct {
	ID                      uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	OrderNumber             *int64         `gorm:"uniqueIndex" json:"order_number"`
	SellerCompanyID         *uint          `json:"seller_company_id"`
	SellerCompany           *Company       `gorm:"foreignKey:SellerCompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	BuyerUserID             *uint          `json:"buyer_user_id"`
	BuyerUser               *User          `gorm:"foreignKey:BuyerUserID;constraint:OnDelete:SET NULL;" json:"-"`
	BuyerCompanyID          *uint          `json:"buyer_company_id"`
	BuyerCompany            *Company       `gorm:"foreignKey:BuyerCompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	CustomerID              *uint          `json:"customer_id"`
	Customer                *Customer      `gorm:"foreignKey:CustomerID;constraint:OnDelete:SET NULL;" json:"-"`
	SupplierID              *uint          `json:"supplier_id"`
	Supplier                *Supplier      `gorm:"foreignKey:SupplierID;constraint:OnDelete:SET NULL;" json:"-"`
	OfferID                 *uint          `json:"offer_id"`
	GuestCustomerName       *string        `gorm:"type:varchar(255)" json:"guest_customer_name"`
	OrderType               string         `gorm:"type:varchar(50);default:'b2c'" json:"order_type"`
	Status                  string         `gorm:"type:varchar(50);default:'pending'" json:"status"`
	PaymentStatus           string         `gorm:"type:varchar(50);default:'unpaid'" json:"payment_status"`
	TotalAmount             float64        `gorm:"type:decimal(12,2);default:0" json:"total_amount"`
	DiscountAmount          float64        `gorm:"type:decimal(12,2);default:0" json:"discount_amount"`
	TaxAmount               float64        `gorm:"type:decimal(12,2);default:0" json:"tax_amount"`
	PaidAmount              float64        `gorm:"type:decimal(12,2);default:0" json:"paid_amount"`
	PaymentMethod           string         `gorm:"type:varchar(100);default:'cash'" json:"payment_method"`
	ShippingCost            float64        `gorm:"type:decimal(10,2);default:0" json:"shipping_cost"`
	ShippingMethod          *string        `gorm:"type:varchar(255)" json:"shipping_method"`
	ShippingAddress         datatypes.JSON `gorm:"type:json" json:"shipping_address"`
	CancellationReason      *string        `gorm:"type:text" json:"cancellation_reason"`
	CurrencySymbol          *string        `gorm:"type:varchar(10)" json:"currency_symbol"`
	CurrencyCode            *string        `gorm:"type:varchar(10)" json:"currency_code"`
	CreatedOffline          bool           `gorm:"default:false" json:"created_offline"`
	SyncedAt                *time.Time     `json:"synced_at"`
	BuyerReceiptConfirmed   bool           `gorm:"default:false" json:"buyer_receipt_confirmed"`
	BuyerReceiptConfirmedAt *time.Time     `json:"buyer_receipt_confirmed_at"`
	FulfilledAt             *time.Time     `json:"fulfilled_at"`
	StockTransferredAt      *time.Time     `json:"stock_transferred_at"`
	DueDate                 *time.Time     `json:"due_date"`
	CreatedAt               time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt               time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	Items                   []OrderItem    `gorm:"foreignKey:OrderID;constraint:OnDelete:CASCADE;" json:"-"`
}

// OrderItem maps to shop.OrderItem
type OrderItem struct {
	ID                  uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	OrderID             uint           `gorm:"not null" json:"order_id"`
	ProductID           *uint          `json:"product_id"`
	Product             *Product       `gorm:"foreignKey:ProductID;constraint:OnDelete:SET NULL;" json:"-"`
	Quantity            int            `gorm:"not null" json:"quantity"`
	UnitPrice           float64        `gorm:"type:decimal(12,2);default:0" json:"unit_price"`
	TotalLinePrice      float64        `gorm:"type:decimal(12,2);default:0" json:"total_line_price"`
	ProductNameSnapshot *string        `gorm:"type:varchar(255)" json:"product_name_snapshot"`
	SelectedOptions     datatypes.JSON `gorm:"type:json" json:"selected_options"`
}

// Customer maps to shop.Customer
type Customer struct {
	ID             uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint      `gorm:"not null" json:"company_id"`
	Company        Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	CustomerType   string    `gorm:"type:varchar(50);default:'b2c'" json:"customer_type"`
	BuyerCompanyID *uint     `json:"buyer_company_id"`
	BuyerCompany   *Company  `gorm:"foreignKey:BuyerCompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	BuyerUserID    *uint     `json:"buyer_profile_id"`
	BuyerUser      *User     `gorm:"foreignKey:BuyerUserID;constraint:OnDelete:SET NULL;" json:"-"`
	FullName       *string   `gorm:"type:varchar(255)" json:"full_name"`
	PhoneNumber    *string   `gorm:"type:varchar(50)" json:"phone_number"`
	Email          *string   `gorm:"type:varchar(255)" json:"email"`
	Address        *string   `gorm:"type:text" json:"address"`
	CreatedAt      time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// Supplier maps to shop.Supplier
type Supplier struct {
	ID              uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID       uint      `gorm:"not null" json:"company_id"`
	Company         Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	SupplierType    string    `gorm:"type:varchar(50);default:'external'" json:"supplier_type"`
	SellerCompanyID *uint     `json:"seller_company_id"`
	SellerCompany   *Company  `gorm:"foreignKey:SellerCompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	Name            string    `gorm:"type:varchar(255);not null" json:"name"`
	ContactName     *string   `gorm:"type:varchar(255)" json:"contact_name"`
	PhoneNumber     *string   `gorm:"type:varchar(50)" json:"phone_number"`
	Email           *string   `gorm:"type:varchar(255)" json:"email"`
	Address         *string   `gorm:"type:text" json:"address"`
	TaxID           *string   `gorm:"type:varchar(100)" json:"tax_id"`
	CreatedAt       time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt       time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// Invoice maps to accounting.Invoice
type Invoice struct {
	ID             uint          `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint          `gorm:"not null" json:"company_id"`
	Company        Company       `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	CustomerID     *uint         `json:"customer_id"`
	Customer       *Customer     `gorm:"foreignKey:CustomerID;constraint:OnDelete:SET NULL;" json:"-"`
	OrderID        *uint         `json:"order_id"`
	Order          *Order        `gorm:"foreignKey:OrderID;constraint:OnDelete:SET NULL;" json:"-"`
	InvoiceNumber  string        `gorm:"type:varchar(100);uniqueIndex" json:"invoice_number"`
	IssueDate      time.Time     `gorm:"" json:"issue_date"`
	DueDate        time.Time     `gorm:"" json:"due_date"`
	TotalAmount    float64       `gorm:"type:decimal(12,2);default:0" json:"total_amount"`
	PaidAmount     float64       `gorm:"type:decimal(12,2);default:0" json:"paid_amount"`
	Status         string        `gorm:"type:varchar(20);default:'draft'" json:"status"`
	JournalEntryID *uint         `json:"journal_entry_id"`
	JournalEntry   *JournalEntry `gorm:"foreignKey:JournalEntryID;constraint:OnDelete:SET NULL;" json:"-"`
	CreatedAt      time.Time     `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt      time.Time     `gorm:"autoUpdateTime" json:"updated_at"`
}

// Bill maps to accounting.Bill
type Bill struct {
	ID             uint          `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint          `gorm:"not null" json:"company_id"`
	Company        Company       `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	SupplierID     *uint         `json:"supplier_id"`
	Supplier       *Supplier     `gorm:"foreignKey:SupplierID;constraint:OnDelete:SET NULL;" json:"-"`
	OrderID        *uint         `json:"order_id"`
	Order          *Order        `gorm:"foreignKey:OrderID;constraint:OnDelete:SET NULL;" json:"-"`
	BillNumber     string        `gorm:"type:varchar(100)" json:"bill_number"`
	IssueDate      *time.Time    `json:"issue_date"`
	DueDate        time.Time     `gorm:"" json:"due_date"`
	TotalAmount    float64       `gorm:"type:decimal(12,2);default:0" json:"total_amount"`
	PaidAmount     float64       `gorm:"type:decimal(12,2);default:0" json:"paid_amount"`
	Status         string        `gorm:"type:varchar(20);default:'received'" json:"status"`
	JournalEntryID *uint         `json:"journal_entry_id"`
	JournalEntry   *JournalEntry `gorm:"foreignKey:JournalEntryID;constraint:OnDelete:SET NULL;" json:"-"`
	CreatedAt      time.Time     `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt      time.Time     `gorm:"autoUpdateTime" json:"updated_at"`
}

// Payment maps to accounting.Payment
type Payment struct {
	ID             uint          `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint          `gorm:"not null" json:"company_id"`
	Company        Company       `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	InvoiceID      *uint         `json:"invoice_id"`
	Invoice        *Invoice      `gorm:"foreignKey:InvoiceID;constraint:OnDelete:SET NULL;" json:"-"`
	BillID         *uint         `json:"bill_id"`
	Bill           *Bill         `gorm:"foreignKey:BillID;constraint:OnDelete:SET NULL;" json:"-"`
	PaymentType    string        `gorm:"type:varchar(20)" json:"payment_type"`
	Amount         float64       `gorm:"type:decimal(12,2);default:0" json:"amount"`
	PaymentDate    time.Time     `gorm:"autoCreateTime" json:"payment_date"`
	PaymentMethod  string        `gorm:"type:varchar(100)" json:"payment_method"`
	Reference      *string       `gorm:"type:varchar(255)" json:"reference"`
	JournalEntryID *uint         `json:"journal_entry_id"`
	JournalEntry   *JournalEntry `gorm:"foreignKey:JournalEntryID;constraint:OnDelete:SET NULL;" json:"-"`
	CreatedAt      time.Time     `gorm:"autoCreateTime" json:"created_at"`
}

// Account maps to accounting.Account
type Account struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID   uint      `gorm:"not null" json:"company_id"`
	Company     Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Code        *string   `gorm:"type:varchar(50)" json:"code"`
	AccountType string    `gorm:"type:varchar(20)" json:"account_type"`
	Description *string   `gorm:"type:text" json:"description"`
	IsActive    bool      `gorm:"default:true" json:"is_active"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}
