package models

// SystemCreateUpdateSchema schema
type SystemCreateUpdateSchema struct {
	PanelPower    int     `json:"panel_power" default:"610"`
	PanelCount    int     `json:"panel_count" default:"1"`
	PanelType     string  `json:"panel_type" default:"mono"`
	PanelNotes    *string `json:"panel_notes"`
	BatteryPower  float64 `json:"battery_power" default:"5.12"`
	BatteryCount  int     `json:"battery_count" default:"1"`
	BatteryType   string  `json:"battery_type" default:"lithium"`
	BatteryNotes  *string `json:"battery_notes"`
	InverterPower int     `json:"inverter_power" default:"5"`
	InverterCount int     `json:"inverter_count" default:"1"`
	InverterType  string  `json:"inverter_type" default:"hybrid"`
	InverterNotes *string `json:"inverter_notes"`
	SystemType    string  `json:"system_type" default:"hybrid"`
	Notes         *string `json:"notes"`
	Lat           *float64 `json:"lat"`
	Lan           *float64 `json:"lan"`
	Address       *string  `json:"address"`
	City          *string  `json:"city"`
	Country       *string  `json:"country"`
}

// SystemAdminStatusSchema schema
type SystemAdminStatusSchema struct {
	UserStatus    *string `json:"user_status"`
	CompanyStatus *string `json:"company_status"`
}
