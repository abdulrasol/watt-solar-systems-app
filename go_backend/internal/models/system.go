package models

import "time"

// System maps to systems.System
type System struct {
	ID                 uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID             *uint     `json:"user_id"`
	User               *User     `gorm:"foreignKey:UserID;constraint:OnDelete:SET NULL;" json:"-"`
	OrderID            *uint     `json:"order_id"`
	InstalledByID      *uint     `json:"installed_by"`
	InstalledBy        *Company  `gorm:"foreignKey:InstalledByID;constraint:OnDelete:SET NULL;" json:"-"`
	UserPhoneReference *string   `gorm:"type:varchar(50)" json:"user_phone_reference"`
	UserStatus         string    `gorm:"type:varchar(50);default:'pending'" json:"user_status"`
	CompanyStatus      string    `gorm:"type:varchar(50);default:'pending'" json:"company_status"`
	PanelPower         int       `gorm:"default:610" json:"panel_power"`
	PanelCount         int       `gorm:"default:1" json:"panel_count"`
	PanelType          string    `gorm:"type:varchar(50);default:'mono'" json:"panel_type"`
	PanelNotes         *string   `gorm:"type:text" json:"panel_notes"`
	BatteryPower       float64   `gorm:"type:decimal(10,2);default:5.12" json:"battery_power"`
	BatteryCount       int       `gorm:"default:1" json:"battery_count"`
	BatteryType        string    `gorm:"type:varchar(50);default:'lithium'" json:"battery_type"`
	BatteryNotes       *string   `gorm:"type:text" json:"battery_notes"`
	InverterPower      int       `gorm:"default:5" json:"inverter_power"`
	InverterCount      int       `gorm:"default:1" json:"inverter_count"`
	InverterType       string    `gorm:"type:varchar(50);default:'hybrid'" json:"inverter_type"`
	InverterNotes      *string   `gorm:"type:text" json:"inverter_notes"`
	SystemType         string    `gorm:"type:varchar(50);default:'hybrid'" json:"system_type"`
	Notes              *string   `gorm:"type:text" json:"notes"`
	Lat                *float64  `json:"lat"`
	Lan                *float64  `json:"lan"`
	Address            *string   `gorm:"type:text" json:"address"`
	City               *string   `gorm:"type:varchar(100)" json:"city"`
	Country            *string   `gorm:"type:varchar(100)" json:"country"`
	InstalledAt        *time.Time `json:"installed_at"`
	CreatedAt          time.Time `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt          time.Time `gorm:"autoUpdateTime" json:"updated_at"`
}
