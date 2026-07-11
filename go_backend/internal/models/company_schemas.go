package models

import (
	"time"
)

type CompanyRegisterSchema struct {
	Name        string  `json:"name" form:"name" binding:"required"`
	CompanyType uint    `json:"company_type" form:"company_type" binding:"required"`
	Description *string `json:"description" form:"description"`
	Address     *string `json:"address" form:"address"`
	Phone       *string `json:"phone" form:"phone"`
	AllowsB2B   bool    `json:"allows_b2b" form:"allows_b2b"`
	AllowsB2C   bool    `json:"allows_b2c" form:"allows_b2c"`
	CityID      *uint   `json:"city" form:"city"`
}

type CompanyUpdateSchema struct {
	Name        *string `json:"name" form:"name"`
	CompanyType *uint   `json:"company_type" form:"company_type"`
	Description *string `json:"description" form:"description"`
	Address     *string `json:"address" form:"address"`
	Phone       *string `json:"phone" form:"phone"`
	AllowsB2B   *bool   `json:"allows_b2b" form:"allows_b2b"`
	AllowsB2C   *bool   `json:"allows_b2c" form:"allows_b2c"`
	CityID      *uint   `json:"city" form:"city"`
	CurrencyID  *uint   `json:"currency" form:"currency"`
}

type CompanyOut struct {
	ID                 uint                `json:"id"`
	Name               string              `json:"name"`
	Type               *string             `json:"type"`
	TypeName           *string             `json:"type_name"`
	Description        *string             `json:"description"`
	Address            *string             `json:"address"`
	Phone              *string             `json:"phone"`
	AllowsB2B          bool                `json:"allows_b2b"`
	AllowsB2C          bool                `json:"allows_b2c"`
	Status             string              `json:"status"`
	LogoURL            *string             `json:"logo_url"`
	City               *CityOut            `json:"city"`
	Currency           *CurrencyOut        `json:"currency"`
	SubscriptionPlanID *uint               `json:"subscription_plan"`
	ExpireDate         *time.Time          `json:"expire_date"`
	CreatedAt          *time.Time          `json:"created_at"`
	UpdatedAt          *time.Time          `json:"updated_at"`
	UserPermission     map[string]any      `json:"user_permission"`
	Services           []map[string]any    `json:"services"`
	AllowedFeatures    []string            `json:"allowed_features"`
}

type CompanyMiniOut struct {
	ID          uint         `json:"id"`
	Name        string       `json:"name"`
	Type        *string      `json:"type"`
	TypeName    *string      `json:"type_name"`
	Description *string      `json:"description"`
	Address     *string      `json:"address"`
	Phone       *string      `json:"phone"`
	LogoURL     *string      `json:"logo_url"`
	City        *CityOut     `json:"city"`
	Currency    *CurrencyOut `json:"currency"`
}

type InviteMemberSchema struct {
	Email string `json:"email" binding:"required,email"`
	Role  string `json:"role" default:"staff"`
}

type CreateMemberSchema struct {
	Email     string `json:"email" binding:"required,email"`
	Username  string `json:"username" binding:"required"`
	Password  string `json:"password" binding:"required"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	Role      string `json:"role" default:"staff"`
}

type CompanyCategorySchema struct {
	Name string `json:"name" binding:"required"`
}

type DeliveryOptionSchema struct {
	ID               *uint      `json:"id"`
	Name             *string    `json:"name"`
	Cost             *float64   `json:"cost"`
	EstimatedDaysMin *int       `json:"estimated_days_min"`
	EstimatedDaysMax *int       `json:"estimated_days_max"`
	Description      *string    `json:"description"`
	IsActive         *bool      `json:"is_active"`
	CompanyID        *uint      `json:"company"`
	CreatedAt        *time.Time `json:"created_at"`
}

type ExpenseSchema struct {
	ID          *uint      `json:"id"`
	Amount      *float64   `json:"amount"`
	Category    *string    `json:"category"`
	Description *string    `json:"description"`
	Date        *time.Time `json:"date"`
	CreatedAt   *time.Time `json:"created_at"`
}

type FinancialTransactionSchema struct {
	ID            *uint      `json:"id"`
	Type          string     `json:"type" binding:"required"` // 'income' or 'expense'
	Category      string     `json:"category" binding:"required"`
	Amount        float64    `json:"amount" binding:"required"`
	Description   *string    `json:"description"`
	PaymentMethod string     `json:"payment_method" default:"cash"`
	CompanyID     *uint      `json:"company"`
	CreatedAt     *time.Time `json:"created_at"`
}

type ContactSchema struct {
	ID        *uint      `json:"id"`
	Name      string     `json:"name" binding:"required"`
	Email     *string    `json:"email"`
	Phone     string     `json:"phone" binding:"required"`
	Notes     *string    `json:"notes"`
	CompanyID *uint      `json:"company"`
	CreatedAt *time.Time `json:"created_at"`
}

type CompanyServiceOut struct {
	ID          uint       `json:"id"`
	Title       string     `json:"title"`
	Price       *float64   `json:"price"`
	Description *string    `json:"description"`
	CompanyID   *uint      `json:"company"`
	CreatedAt   *time.Time `json:"created_at"`
	UpdatedAt   *time.Time `json:"updated_at"`
}

type CompanyServiceCreateSchema struct {
	Title       string   `json:"title" binding:"required"`
	Price       *float64 `json:"price"`
	Description *string  `json:"description"`
}

type CompanyServiceUpdateSchema struct {
	Title       *string  `json:"title"`
	Price       *float64 `json:"price"`
	Description *string  `json:"description"`
}

type PublicCompanyTypeOut struct {
	ID                       uint             `json:"id"`
	Code                     string           `json:"code"`
	Name                     string           `json:"name"`
	AllowedServices          []map[string]any `json:"allowed_services"`
	AllowedSubscriptionPlans []map[string]any `json:"allowed_subscription_plans"`
}

type PublicCompanyOut struct {
	ID                   uint                   `json:"id"`
	Name                 string                 `json:"name"`
	Description          *string                `json:"description"`
	Logo                 *string                `json:"logo"`
	Address              *string                `json:"address"`
	Phone                *string                `json:"phone"`
	AllowsB2B            bool                   `json:"allows_b2b"`
	AllowsB2C            bool                   `json:"allows_b2c"`
	CompanyType          *PublicCompanyTypeOut  `json:"company_type"`
	ServiceTypes         []ServiceTypeOut       `json:"service_types"`
	City                 *CityOut               `json:"city"`
	Currency             *CurrencyOut           `json:"currency"`
	Contacts             []ContactSchema        `json:"contacts"`
	DeliveryOptions      []DeliveryOptionSchema `json:"delivery_options"`
	PublicServices       []CompanyServiceOut    `json:"public_services"`
	Services             []map[string]any       `json:"services"`
	SubscriptionIsValid  bool                   `json:"subscription_is_valid"`
	ExpireDate           *time.Time             `json:"expire_date"`
}

type CompanyServiceCatalogOut struct {
	ID          uint    `json:"id"`
	Code        string  `json:"code"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Category    string  `json:"category"`
	IsActive    bool    `json:"is_active"`
	SortOrder   uint    `json:"sort_order"`
	Route       *string `json:"route"`
	IconURL     *string `json:"icon_url"`
}

type CompanyServiceRequestCreateSchema struct {
	ServiceCode string  `json:"service_code" binding:"required"`
	Notes       *string `json:"notes"`
}

type CompanySubscriptionRequestCreateSchema struct {
	SubscriptionPlanID uint    `json:"subscription_plan" form:"subscription_plan" binding:"required"`
	Notes              *string `json:"notes" form:"notes"`
}

type CompanySubscriptionRequestOut struct {
	ID                   uint       `json:"id"`
	CompanyID            uint       `json:"company_id"`
	CompanyName          string     `json:"company_name"`
	SubscriptionPlanID   uint       `json:"subscription_plan_id"`
	SubscriptionPlanName string     `json:"subscription_plan_name"`
	Status               string     `json:"status"`
	RequestedBy          *string    `json:"requested_by"`
	Notes                *string    `json:"notes"`
	Image                *string    `json:"image"`
	CreatedAt            time.Time  `json:"created_at"`
}

type CompanySubscriptionRequestReviewSchema struct {
	Status string  `json:"status" binding:"required"`
	Notes  *string `json:"notes"`
}

type CompanyServiceRequestActionSchema struct {
	Status   string     `json:"status" binding:"required"`
	Notes    *string    `json:"notes"`
	StartsAt *time.Time `json:"starts_at"`
	EndsAt   *time.Time `json:"ends_at"`
}

type CompanyStatusActionSchema struct {
	Status string `json:"status" binding:"required"`
}

type CompanyServiceCatalogCreateSchema struct {
	Code        string  `json:"code" binding:"required"`
	Name        string  `json:"name" binding:"required"`
	Description *string `json:"description"`
	Category    string  `json:"category" default:"general"`
	IsActive    bool    `json:"is_active" default:"true"`
	SortOrder   uint    `json:"sort_order" default:"0"`
	Route       *string `json:"route"`
	Icon        *string `json:"icon"`
}

type CompanyServiceCatalogUpdateSchema struct {
	Name        *string `json:"name"`
	Description *string `json:"description"`
	Category    *string `json:"category"`
	IsActive    *bool   `json:"is_active"`
	SortOrder   *uint   `json:"sort_order"`
	Route       *string `json:"route"`
	Icon        *string `json:"icon"`
}

type CompanyOfferInvolvesSchema struct {
	Name     string  `json:"name" binding:"required"`
	Quantity int     `json:"quantity" default:"1"`
	Cost     float64 `json:"cost" binding:"required"`
}

type CompanyOfferCreateSchema struct {
	PanelPower    int                          `json:"panel_power" default:"610"`
	PanelCount    int                          `json:"panel_count" default:"1"`
	PanelType     string                       `json:"panel_type" default:"mono"`
	PanelNotes    *string                      `json:"panel_notes"`
	BatteryPower  float64                      `json:"battery_power" default:"5.12"`
	BatteryCount  int                          `json:"battery_count" default:"1"`
	BatteryType   string                       `json:"battery_type" default:"lithium"`
	BatteryNotes  *string                      `json:"battery_notes"`
	InverterPower int                          `json:"inverter_power" default:"5"`
	InverterCount int                          `json:"inverter_count" default:"1"`
	InverterType  string                       `json:"inverter_type" default:"hybrid"`
	InverterNotes *string                      `json:"inverter_notes"`
	Notes         *string                      `json:"notes"`
	Price         float64                      `json:"price" binding:"required"`
	ExpiresAt     *time.Time                   `json:"expires_at"`
	Involves      []CompanyOfferInvolvesSchema `json:"involves"`
}

type CompanyTypeOut struct {
	ID                       uint             `json:"id"`
	CType                    string           `json:"ctype"`
	Name                     string           `json:"name"`
	AllowedServices          []map[string]any `json:"allowed_services"`
	AllowedSubscriptionPlans []map[string]any `json:"allowed_subscription_plans"`
}

type ServiceTypeOut struct {
	ID             uint    `json:"id"`
	Name           string  `json:"name"`
	Description    *string `json:"description"`
	Image          *string `json:"image"`
	CompaniesCount *int    `json:"companies_count"`
	IsServed       *bool   `json:"is_served"`
}

type ServiceTypeCreateSchema struct {
	Name        string  `json:"name" form:"name" binding:"required"`
	Description *string `json:"description" form:"description"`
}

type ServiceTypeUpdateSchema struct {
	Name        *string `json:"name" form:"name"`
	Description *string `json:"description" form:"description"`
}

type ServiceTypeSelectionSchema struct {
	ID       uint `json:"id" binding:"required"`
	Selected bool `json:"selected"`
}

type CompanyWorkImageOut struct {
	ID        uint       `json:"id"`
	ImageURL  *string    `json:"image_url"`
	CreatedAt time.Time  `json:"created_at"`
}

type CompanyWorkOut struct {
	ID        uint                  `json:"id"`
	Title     *string               `json:"title"`
	Body      *string               `json:"body"`
	CreatedAt time.Time             `json:"created_at"`
	UpdatedAt time.Time             `json:"updated_at"`
	Images    []CompanyWorkImageOut `json:"images"`
}

type CompanyWorkCreateSchema struct {
	Title *string `json:"title"`
	Body  *string `json:"body"`
}

type CompanyWorkUpdateSchema struct {
	Title *string `json:"title"`
	Body  *string `json:"body"`
}

type PosterCreateSchema struct {
	Text       *string `json:"text"`
	ActionType string  `json:"action_type" default:"company_profile"`
	ActionID   *int    `json:"action_id"`
}

type PosterUpdateSchema struct {
	Text       *string `json:"text"`
	ActionType *string `json:"action_type"`
	ActionID   *int    `json:"action_id"`
}

type PosterOut struct {
	ID           uint       `json:"id"`
	CompanyID    uint       `json:"company_id"`
	CompanyName  *string    `json:"company_name"`
	ImageURL     *string    `json:"image_url"`
	Text         *string    `json:"text"`
	ActionType   string     `json:"action_type"`
	ActionID     *int       `json:"action_id"`
	Status       string     `json:"status"`
	IsActive     bool       `json:"is_active"`
	DurationDays *int       `json:"duration_days"`
	ApprovedAt   *time.Time `json:"approved_at"`
	ExpiresAt    *time.Time `json:"expires_at"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
}

type PosterReviewSchema struct {
	Status       string `json:"status" binding:"required"`
	DurationDays int    `json:"duration_days" default:"7"`
}

type PosterExtendSchema struct {
	ExpiresAt string `json:"expires_at" binding:"required"`
}

type AdminCompanyTypeCreateSchema struct {
	CType                    string `json:"ctype" binding:"required"`
	Name                     string `json:"name" binding:"required"`
	AllowedFeatures          []string `json:"allowed_features"`
	AllowedSubscriptionPlans []uint `json:"allowed_subscription_plans"`
}

type AdminCompanyTypeUpdateSchema struct {
	CType                    string `json:"ctype"`
	Name                     string `json:"name"`
	AllowedFeatures          []string `json:"allowed_features"`
	AllowedSubscriptionPlans []uint `json:"allowed_subscription_plans"`
}
