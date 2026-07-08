package models

// OfferRequestCreateSchema schema
type OfferRequestCreateSchema struct {
	CityID              *uint   `json:"city_id"`
	AllCities           bool    `json:"all_cities" default:"false"`
	TotalPanelPower     int     `json:"total_panel_power" default:"0"`
	PanelPower          *int    `json:"panel_power"`
	PanelCount          *int    `json:"panel_count"`
	PanelNote           *string `json:"panel_note"`
	TotalBatteryPower   float64 `json:"total_battery_power" default:"0"`
	BatterySize         *float64 `json:"battery_size"`
	BatteryCount        *int    `json:"battery_count"`
	BatteryNote         *string `json:"battery_note"`
	BatteryType         string  `json:"battery_type" default:"gel"`
	TotalInvertersPower float64 `json:"total_inverters_power" default:"0"`
	InverterSize        *float64 `json:"inverter_size"`
	InverterCount       *int    `json:"inverter_count"`
	InverterNote        *string `json:"inverter_note"`
	InverterType        string  `json:"inverter_type" default:"hybrid"`
	Note                *string `json:"note"`
}

// OfferRequestUpdateSchema schema
type OfferRequestUpdateSchema = OfferRequestCreateSchema

// OfferCreateSchema schema
type OfferCreateSchema struct {
	Price           float64                    `json:"price" binding:"required"`
	TemplateInvolves []OfferInvolvementSnapshot `json:"template_involves"`
	TotalPanelPower int                        `json:"total_panel_power" default:"0"`
	PanelPower      int                        `json:"panel_power" default:"0"`
	PanelCount      int                        `json:"panel_count" default:"0"`
	PanelNote       *string                    `json:"panel_note"`
	BatterySize     float64                    `json:"battery_size" default:"0"`
	BatteryCount    int                        `json:"battery_count" default:"0"`
	BatteryNote     *string                    `json:"battery_note"`
	BatteryType     string                     `json:"battery_type" default:"gel"`
	InverterSize    float64                    `json:"inverter_size" default:"0"`
	InverterCount   int                        `json:"inverter_count" default:"0"`
	InverterNote    *string                    `json:"inverter_note"`
	InverterType    string                     `json:"inverter_type" default:"hybrid"`
	Note            *string                    `json:"note"`
}

// OfferInvolvementSnapshot schema
type OfferInvolvementSnapshot struct {
	TemplateID int `json:"template_id" binding:"required"`
	Quantity   int `json:"quantity" default:"1"`
}

// OfferResponseSchema schema
type OfferResponseSchema struct {
	State string `json:"state" binding:"required"`
}

// InvolvementTemplateCreateSchema schema
type InvolvementTemplateCreateSchema struct {
	Name string  `json:"name" binding:"required"`
	Cost float64 `json:"cost" binding:"required"`
}
