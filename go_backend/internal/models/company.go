package models

import (
	"time"

	"gorm.io/datatypes"
)

// ServiceType maps to Company ServiceType
type ServiceType struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Image       *string   `gorm:"type:varchar(255)" json:"image"`
	Description *string   `gorm:"type:text" json:"description"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`

	Companies []*Company `gorm:"many2many:company_service_types;" json:"-"`
}

// CompanyType maps to CompanyType
type CompanyType struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CType     string    `gorm:"type:varchar(255);uniqueIndex;not null" json:"ctype"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`

	AllowedServices          []*CompanyServiceCatalog `gorm:"many2many:company_type_services;" json:"allowed_services"`
	AllowedSubscriptionPlans []*SubscriptionPlan      `gorm:"many2many:company_type_subscription_plans;" json:"allowed_subscription_plans"`
}

// CompanyCategory maps to CompanyCategory
type CompanyCategory struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID uint      `gorm:"not null" json:"company_id"`
	Company   Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// HasValidSubscription checks if the company has an active, non-expired subscription plan.
func (c *Company) HasValidSubscription() bool {
	if c == nil || c.SubscriptionPlanID == nil || c.SubscriptionStartDate == nil {
		return false
	}
	return c.ExpireDate.After(time.Now())
}

// Company maps to Company
type Company struct {
	ID                       uint              `gorm:"primaryKey;autoIncrement" json:"id"`
	Name                     string            `gorm:"type:varchar(255);not null" json:"name"`
	CompanyTypeID            *uint             `json:"company_type_id"`
	CompanyType              *CompanyType      `gorm:"foreignKey:CompanyTypeID;constraint:OnDelete:RESTRICT;" json:"company_type"`
	Description              *string           `gorm:"type:text" json:"description"`
	Logo                     *string           `gorm:"type:varchar(255)" json:"logo"`
	Address                  *string           `gorm:"type:text" json:"address"`
	Phone                    string            `gorm:"type:varchar(20);default:''" json:"phone"`
	Status                   string            `gorm:"type:varchar(50);default:'pending'" json:"status"`
	AllowsB2B                bool              `gorm:"column:allows_b2b;default:true" json:"allows_b2b"`
	AllowsB2C                bool              `gorm:"column:allows_b2c;default:true" json:"allows_b2c"`
	CityID                   *uint             `json:"city_id"`
	City                     *City             `gorm:"foreignKey:CityID;constraint:OnDelete:RESTRICT;" json:"city"`
	CurrencyID               *uint             `json:"currency_id"`
	Currency                 *Currency         `gorm:"foreignKey:CurrencyID;constraint:OnDelete:RESTRICT;" json:"currency"`
	ServiceTypes             []*ServiceType    `gorm:"many2many:company_service_types;" json:"service_types"`
	CreatedAt                time.Time         `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt                time.Time         `gorm:"autoUpdateTime" json:"updated_at"`
	ExpireDate               time.Time         `gorm:"" json:"expire_date"`
	LastActivationReminderAt *time.Time        `json:"last_activation_reminder_at"`
	SubscriptionPlanID       *uint             `json:"subscription_plan_id"`
	SubscriptionPlan         *SubscriptionPlan `gorm:"foreignKey:SubscriptionPlanID;constraint:OnDelete:RESTRICT;" json:"subscription_plan"`
	SubscriptionStartDate    *time.Time        `json:"subscription_start_date"`

	// Relationships mapping
	Categories            []CompanyCategory            `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Members               []CompanyMember              `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	DeliveryOptions       []DeliveryOption             `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Expenses              []Expense                    `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	FinancialTransactions []FinancialTransaction       `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Contacts              []Contact                    `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	PublicServices        []CompanyService             `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	ServiceSubscriptions  []CompanyServiceSubscription `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	ServiceRequests       []CompanyServiceRequest      `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	SubscriptionRequests  []CompanySubscriptionRequest `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Works                 []CompanyWork                `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Posters               []Poster                     `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
}

// CompanyMember maps to CompanyMember
type CompanyMember struct {
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID   uint           `gorm:"not null" json:"company_id"`
	Company     Company        `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	UserID      uint           `gorm:"uniqueIndex;not null" json:"user_id"`
	User        User           `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE;" json:"-"`
	Role        string         `gorm:"type:varchar(50);default:'staff'" json:"role"`
	Permissions datatypes.JSON `gorm:"type:json" json:"permissions"`
	JoinedAt    time.Time      `gorm:"autoCreateTime" json:"joined_at"`
}

// DeliveryOption maps to DeliveryOption
type DeliveryOption struct {
	ID               uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID        uint      `gorm:"not null" json:"company_id"`
	Company          Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Name             string    `gorm:"type:varchar(255);not null" json:"name"`
	Cost             float64   `gorm:"type:decimal(10,2);default:0" json:"cost"`
	EstimatedDaysMin *int      `json:"estimated_days_min"`
	EstimatedDaysMax *int      `json:"estimated_days_max"`
	Description      *string   `gorm:"type:text" json:"description"`
	IsActive         bool      `gorm:"default:true" json:"is_active"`
	CreatedAt        time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// Expense maps to Expense
type Expense struct {
	ID             uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID      uint      `gorm:"not null" json:"company_id"`
	Company        Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Amount         float64   `gorm:"type:decimal(12,2);not null" json:"amount"`
	Category       string    `gorm:"type:varchar(255);not null" json:"category"`
	Description    *string   `gorm:"type:text" json:"description"`
	Date           time.Time `gorm:"not null" json:"date"`
	JournalEntryID *uint     `json:"journal_entry_id"` // related to accounting.JournalEntry
	CreatedAt      time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// FinancialTransaction maps to FinancialTransaction
type FinancialTransaction struct {
	ID            uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID     uint      `gorm:"not null" json:"company_id"`
	Company       Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Type          string    `gorm:"type:varchar(50);not null" json:"type"` // 'income', 'expense'
	Category      string    `gorm:"type:varchar(255);not null" json:"category"`
	Amount        float64   `gorm:"type:decimal(12,2);default:0" json:"amount"`
	Description   *string   `gorm:"type:text" json:"description"`
	PaymentMethod string    `gorm:"type:varchar(100);default:'cash'" json:"payment_method"`
	ReferenceID   *int      `json:"reference_id"`
	Date          time.Time `gorm:"autoCreateTime" json:"date"`
	CreatedAt     time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// Contact maps to Contact
type Contact struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID uint      `gorm:"not null" json:"company_id"`
	Company   Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	Email     *string   `gorm:"type:varchar(255)" json:"email"`
	Phone     string    `gorm:"type:varchar(20);not null" json:"phone"`
	Notes     *string   `gorm:"type:text" json:"notes"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// CompanyService maps to CompanyService
type CompanyService struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID   uint      `gorm:"not null" json:"company_id"`
	Company     Company   `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Title       string    `gorm:"type:varchar(255);not null" json:"title"`
	Price       *float64  `gorm:"type:decimal(12,2)" json:"price"`
	Description *string   `gorm:"type:text" json:"description"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}

// CompanyServiceCatalog maps to CompanyServiceCatalog
type CompanyServiceCatalog struct {
	ID          uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Code        string    `gorm:"type:varchar(100);uniqueIndex;not null" json:"code"`
	Name        string    `gorm:"type:varchar(255);not null" json:"name"`
	Description string    `gorm:"type:text;default:''" json:"description"`
	Category    string    `gorm:"type:varchar(100);default:'general'" json:"category"`
	IsActive    bool      `gorm:"default:true" json:"is_active"`
	SortOrder   uint      `gorm:"default:0" json:"sort_order"`
	Route       *string   `gorm:"type:varchar(255)" json:"route"`
	Icon        *string   `gorm:"type:varchar(255)" json:"icon"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updated_at"`

	CompanyTypes []*CompanyType `gorm:"many2many:company_type_services;" json:"company_types"`
}

// CompanyServiceSubscription maps to CompanyServiceSubscription
type CompanyServiceSubscription struct {
	ID            uint                  `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID     uint                  `gorm:"uniqueIndex:idx_company_service;not null" json:"company_id"`
	Company       Company               `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	ServiceID     uint                  `gorm:"uniqueIndex:idx_company_service;not null" json:"service_id"`
	Service       CompanyServiceCatalog `gorm:"foreignKey:ServiceID;constraint:OnDelete:CASCADE;" json:"service"`
	Status        string                `gorm:"type:varchar(20);default:'pending'" json:"status"`
	RequestedByID *uint                 `json:"requested_by_id"`
	RequestedBy   *User                 `gorm:"foreignKey:RequestedByID;constraint:OnDelete:SET NULL;" json:"-"`
	ApprovedByID  *uint                 `json:"approved_by_id"`
	ApprovedBy    *User                 `gorm:"foreignKey:ApprovedByID;constraint:OnDelete:SET NULL;" json:"-"`
	RequestedAt   *time.Time            `json:"requested_at"`
	ApprovedAt    *time.Time            `json:"approved_at"`
	ActivatedAt   *time.Time            `json:"activated_at"`
	StartsAt      *time.Time            `json:"starts_at"`
	EndsAt        *time.Time            `json:"ends_at"`
	Notes         string                `gorm:"type:text;default:''" json:"notes"`
	Meta          datatypes.JSON        `gorm:"type:json" json:"meta"`
	CreatedAt     time.Time             `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt     time.Time             `gorm:"autoUpdateTime" json:"updated_at"`
}

// CompanyServiceRequest maps to CompanyServiceRequest
type CompanyServiceRequest struct {
	ID            uint                  `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID     uint                  `gorm:"not null" json:"company_id"`
	Company       Company               `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	ServiceID     uint                  `gorm:"not null" json:"service_id"`
	Service       CompanyServiceCatalog `gorm:"foreignKey:ServiceID;constraint:OnDelete:CASCADE;" json:"service"`
	RequestedByID *uint                 `json:"requested_by_id"`
	RequestedBy   *User                 `gorm:"foreignKey:RequestedByID;constraint:OnDelete:SET NULL;" json:"-"`
	ReviewedByID  *uint                 `json:"reviewed_by_id"`
	ReviewedBy    *User                 `gorm:"foreignKey:ReviewedByID;constraint:OnDelete:SET NULL;" json:"-"`
	Status        string                `gorm:"type:varchar(20);default:'pending'" json:"status"`
	RequestedAt   time.Time             `gorm:"autoCreateTime" json:"requested_at"`
	ReviewedAt    *time.Time            `json:"reviewed_at"`
	Notes         string                `gorm:"type:text;default:''" json:"notes"`
	Image         *string               `gorm:"type:varchar(255)" json:"image"`
	Meta          datatypes.JSON        `gorm:"type:json" json:"meta"`
	CreatedAt     time.Time             `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt     time.Time             `gorm:"autoUpdateTime" json:"updated_at"`
}

// CompanySubscriptionRequest maps to CompanySubscriptionRequest
type CompanySubscriptionRequest struct {
	ID                 uint             `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID          uint             `gorm:"not null" json:"company_id"`
	Company            Company          `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	SubscriptionPlanID uint             `gorm:"not null" json:"subscription_plan_id"`
	SubscriptionPlan   SubscriptionPlan `gorm:"foreignKey:SubscriptionPlanID;constraint:OnDelete:RESTRICT;" json:"subscription_plan"`
	RequestedByID      *uint            `json:"requested_by_id"`
	RequestedBy        *User            `gorm:"foreignKey:RequestedByID;constraint:OnDelete:SET NULL;" json:"-"`
	ApprovedByID       *uint            `json:"approved_by_id"`
	ApprovedBy         *User            `gorm:"foreignKey:ApprovedByID;constraint:OnDelete:SET NULL;" json:"-"`
	Status             string           `gorm:"type:varchar(20);default:'pending'" json:"status"`
	Notes              string           `gorm:"type:text;default:''" json:"notes"`
	Image              *string          `gorm:"type:varchar(255)" json:"image"`
	RequestedAt        *time.Time       `json:"requested_at"`
	ApprovedAt         *time.Time       `json:"approved_at"`
	CreatedAt          time.Time        `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt          time.Time        `gorm:"autoUpdateTime" json:"updated_at"`
}

// CompanyWork maps to CompanyWork
type CompanyWork struct {
	ID        uint               `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID uint               `gorm:"not null" json:"company_id"`
	Company   Company            `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Title     *string            `gorm:"type:varchar(255)" json:"title"`
	Body      *string            `gorm:"type:text" json:"body"`
	CreatedAt time.Time          `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time          `gorm:"autoUpdateTime" json:"updated_at"`
	Images    []CompanyWorkImage `gorm:"foreignKey:WorkID;constraint:OnDelete:CASCADE;" json:"images"`
}

// CompanyWorkImage maps to CompanyWorkImage
type CompanyWorkImage struct {
	ID        uint        `gorm:"primaryKey;autoIncrement" json:"id"`
	WorkID    uint        `gorm:"not null" json:"work_id"`
	Work      CompanyWork `gorm:"foreignKey:WorkID;constraint:OnDelete:CASCADE;" json:"-"`
	Image     string      `gorm:"type:varchar(255);not null" json:"image"`
	CreatedAt time.Time   `gorm:"autoCreateTime" json:"created_at"`
}

// Poster maps to Poster
type Poster struct {
	ID           uint       `gorm:"primaryKey;autoIncrement" json:"id"`
	CompanyID    uint       `gorm:"not null" json:"company_id"`
	Company      Company    `gorm:"foreignKey:CompanyID;constraint:OnDelete:CASCADE;" json:"-"`
	Image        string     `gorm:"type:varchar(255);not null" json:"image"`
	Text         *string    `gorm:"type:varchar(255)" json:"text"`
	ActionType   string     `gorm:"type:varchar(50);default:'company_profile'" json:"action_type"`
	ActionID     *int       `json:"action_id"`
	Status       string     `gorm:"type:varchar(20);default:'pending'" json:"status"`
	IsActive     bool       `gorm:"default:true" json:"is_active"`
	DurationDays *int       `json:"duration_days"`
	ApprovedAt   *time.Time `json:"approved_at"`
	ExpiresAt    *time.Time `json:"expires_at"`
	CreatedAt    time.Time  `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt    time.Time  `gorm:"autoUpdateTime" json:"updated_at"`
}
