package models

import (
	"time"
)

// User is a unified model combining Django's auth_user and users_profile
type User struct {
	ID               uint       `gorm:"primaryKey;column:id"`
	Username         string     `gorm:"column:username;unique;not null"`
	Password         string     `gorm:"column:password;not null"`
	Email            string     `gorm:"column:email;unique;not null"`
	FirstName        string     `gorm:"column:first_name"`
	LastName         string     `gorm:"column:last_name"`
	Phone            string     `gorm:"column:phone"`
	CityID           *uint      `gorm:"column:city_id"`
	Image            *string    `gorm:"column:image"`
	SecurityQuestion *string    `gorm:"column:security_question"`
	SecurityAnswer   *string    `gorm:"column:security_answer"`
	Language         string     `gorm:"column:language;default:'ar'"`
	IsActive         bool       `gorm:"column:is_active;default:true"`
	IsStaff          bool       `gorm:"column:is_staff;default:false"`
	IsSuperuser      bool       `gorm:"column:is_superuser;default:false"`
	IsDeleted        bool       `gorm:"column:is_deleted;default:false"`
	DeletedAt        *time.Time `gorm:"column:deleted_at"`
	DeletedReason    *string    `gorm:"column:deleted_reason"`
	LastLogin        *time.Time `gorm:"column:last_login"`
	DateJoined       time.Time  `gorm:"column:date_joined;autoCreateTime"`
}

// TableName overrides the table name used by GORM
func (User) TableName() string {
	return "users"
}
