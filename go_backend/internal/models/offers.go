package models

import (
	"time"
)

// OfferRequest maps to offers.OfferRequest
type OfferRequest struct {
	ID                  uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID              *uint     `json:"user_id"`
	User                *User     `gorm:"foreignKey:UserID;constraint:OnDelete:SET NULL;" json:"-"`
	CityID              *uint     `json:"city_id"`
	City                *City     `gorm:"foreignKey:CityID;constraint:OnDelete:SET NULL;" json:"-"`
	AllCities           bool      `gorm:"default:false" json:"all_cities"`
	TotalPanelPower     int       `gorm:"default:0" json:"total_panel_power"`
	PanelPower          *int      `json:"panel_power"`
	PanelCount          *int      `json:"panel_count"`
	PanelNote           *string   `gorm:"type:text" json:"panel_note"`
	TotalBatteryPower   float64   `gorm:"type:decimal(10,2);default:0" json:"total_battery_power"`
	BatterySize         *float64  `json:"battery_size"`
	BatteryCount        *int      `json:"battery_count"`
	BatteryNote         *string   `gorm:"type:text" json:"battery_note"`
	BatteryType         string    `gorm:"type:varchar(50);default:'gel'" json:"battery_type"`
	TotalInvertersPower float64   `gorm:"type:decimal(10,2);default:0" json:"total_inverters_power"`
	InverterSize        *float64  `json:"inverter_size"`
	InverterCount       *int      `json:"inverter_count"`
	InverterNote        *string   `gorm:"type:text" json:"inverter_note"`
	InverterType        string    `gorm:"type:varchar(50);default:'hybrid'" json:"inverter_type"`
	Note                *string   `gorm:"type:text" json:"note"`
	Status              string    `gorm:"type:varchar(50);default:'open'" json:"status"`
	CreatedAt           time.Time `gorm:"autoCreateTime" json:"created_at"`
	Offers              []Offer   `gorm:"foreignKey:OfferRequestID;constraint:OnDelete:CASCADE;" json:"-"`
}

// Offer maps to offers.Offer
type Offer struct {
	ID               uint                `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID           *uint               `json:"user_id"`
	User             *User               `gorm:"foreignKey:UserID;constraint:OnDelete:SET NULL;" json:"-"`
	OfferRequestID   uint                `json:"offer_request_id"`
	OfferRequest     *OfferRequest       `gorm:"foreignKey:OfferRequestID;constraint:OnDelete:CASCADE;" json:"-"`
	CompanyID        *uint               `json:"company_id"`
	Company          *Company            `gorm:"foreignKey:CompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	Price             float64            `gorm:"type:decimal(12,2);default:0" json:"price"`
	TotalPanelPower   int                `gorm:"default:0" json:"total_panel_power"`
	PanelPower        int                `gorm:"default:0" json:"panel_power"`
	PanelCount        int                `gorm:"default:0" json:"panel_count"`
	PanelNote         *string            `gorm:"type:text" json:"panel_note"`
	BatterySize       float64            `gorm:"type:decimal(10,2);default:0" json:"battery_size"`
	BatteryCount      int                `gorm:"default:0" json:"battery_count"`
	BatteryNote       *string            `gorm:"type:text" json:"battery_note"`
	BatteryType       string             `gorm:"type:varchar(50);default:'gel'" json:"battery_type"`
	InverterSize      float64            `gorm:"type:decimal(10,2);default:0" json:"inverter_size"`
	InverterCount     int                `gorm:"default:0" json:"inverter_count"`
	InverterNote      *string            `gorm:"type:text" json:"inverter_note"`
	InverterType      string             `gorm:"type:varchar(50);default:'hybrid'" json:"inverter_type"`
	Note              *string            `gorm:"type:text" json:"note"`
	Status            string             `gorm:"type:varchar(50);default:'pending'" json:"status"`
	CreatedAt         time.Time          `gorm:"autoCreateTime" json:"created_at"`
	Involves          []OfferInvolvement `gorm:"many2many:offer_involvements_link;" json:"-"`
}

// OfferInvolvement maps to offers.OfferInvolvement
type OfferInvolvement struct {
	ID       uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name     string    `gorm:"type:varchar(255);not null" json:"name"`
	Quantity int       `gorm:"default:1" json:"quantity"`
	Cost     float64   `gorm:"type:decimal(12,2);default:0" json:"cost"`
	CompanyID *uint    `json:"company_id"`
	Company  *Company  `gorm:"foreignKey:CompanyID;constraint:OnDelete:SET NULL;" json:"-"`
}

// InvolvementTemplate maps to offers.InvolvementTemplate
type InvolvementTemplate struct {
	ID       uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name     string    `gorm:"type:varchar(255);not null" json:"name"`
	Cost     float64   `gorm:"type:decimal(12,2);default:0" json:"cost"`
	CompanyID *uint    `json:"company_id"`
	Company  *Company  `gorm:"foreignKey:CompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	IsActive bool      `gorm:"default:true" json:"is_active"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}
