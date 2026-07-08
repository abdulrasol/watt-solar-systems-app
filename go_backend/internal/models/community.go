package models

import (
	"time"
)

// Post maps to community.Post
type Post struct {
	ID         uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	AuthorID   *uint     `json:"author_id"`
	Author     *User     `gorm:"foreignKey:AuthorID;constraint:OnDelete:SET NULL;" json:"-"`
	CompanyID  *uint     `json:"company_id"`
	Company    *Company  `gorm:"foreignKey:CompanyID;constraint:OnDelete:SET NULL;" json:"-"`
	SystemID   *uint     `json:"system_id"`
	System     *System   `gorm:"foreignKey:SystemID;constraint:OnDelete:SET NULL;" json:"-"`
	Content    *string   `gorm:"type:text" json:"content"`
	Image      *string   `gorm:"type:varchar(255)" json:"image"`
	PostType   string    `gorm:"type:varchar(50);default:'general'" json:"post_type"`
	LikesCount int       `gorm:"default:0" json:"likes_count"`
	CreatedAt  time.Time `gorm:"autoCreateTime" json:"created_at"`
	Comments   []Comment `gorm:"foreignKey:PostID;constraint:OnDelete:CASCADE;" json:"-"`
}

// Comment maps to community.Comment
type Comment struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	PostID    uint      `gorm:"not null" json:"post_id"`
	Post      *Post     `gorm:"foreignKey:PostID;constraint:OnDelete:CASCADE;" json:"-"`
	AuthorID  uint      `gorm:"not null" json:"author_id"`
	Author    *User     `gorm:"foreignKey:AuthorID;constraint:OnDelete:CASCADE;" json:"-"`
	Content   string    `gorm:"type:text;not null" json:"content"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}
