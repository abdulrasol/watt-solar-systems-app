package models

// CommunityAuthorInfo schema for post/comment author
type CommunityAuthorInfo struct {
	ID    string  `json:"id"`
	Name  string  `json:"name"`
	Type  string  `json:"type"`
	Image *string `json:"image"`
	Role  *string `json:"role"`
	Phone *string `json:"phone"`
}

// PostCreateSchema schema
type PostCreateSchema struct {
	Content   *string `json:"content"`
	PostType  string  `json:"post_type" default:"general"`
	CompanyID *uint   `json:"company_id"`
	SystemID  *uint   `json:"system_id"`
}

// PostUpdateSchema schema
type PostUpdateSchema struct {
	Content  *string `json:"content"`
	PostType *string `json:"post_type"`
}

// CommentCreateSchema schema
type CommentCreateSchema struct {
	Content string `json:"content" binding:"required"`
}

// CommentUpdateSchema schema
type CommentUpdateSchema struct {
	Content string `json:"content" binding:"required"`
}
