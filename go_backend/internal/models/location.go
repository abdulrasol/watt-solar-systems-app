package models

import (
	"time"
)

// Country represents a country location
type Country struct {
	ID        uint      `gorm:"primaryKey;column:id"`
	Name      string    `gorm:"column:name;not null"`
	Code      string    `gorm:"column:code;unique;not null"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
}

// City represents a city location
type City struct {
	ID        uint      `gorm:"primaryKey;column:id"`
	Name      string    `gorm:"column:name;not null"`
	CountryID uint      `gorm:"column:country_id;not null"`
	Country   Country   `gorm:"foreignKey:CountryID"`
	Code      string    `gorm:"column:code;not null"`
	CreatedAt time.Time `gorm:"column:created_at;autoCreateTime"`
}
