package models

// Request Schemas

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Username  string `json:"username" binding:"required"`
	Password  string `json:"password" binding:"required"`
	Email     string `json:"email" binding:"required,email"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	Phone     string `json:"phone" binding:"required"`
	CityID    *uint  `json:"city_id"`
}

type ProfileUpdateSchema struct {
	Username         *string `json:"username" form:"username"`
	FirstName        *string `json:"first_name" form:"first_name"`
	LastName         *string `json:"last_name" form:"last_name"`
	Email            *string `json:"email" form:"email"`
	Phone            *string `json:"phone" form:"phone"`
	CityID           *uint   `json:"city_id" form:"city_id"`
	SecurityQuestion *string `json:"security_question" form:"security_question"`
	SecurityAnswer   *string `json:"security_answer" form:"security_answer"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type ForgotPasswordVerifySchema struct {
	Email          string `json:"email" binding:"required,email"`
	SecurityAnswer string `json:"security_answer" binding:"required"`
	NewPassword    string `json:"new_password" binding:"required"`
}

// Response Schemas

type ProfileOut struct {
	ID               uint        `json:"id"`
	Username         string      `json:"username"`
	Email            *string     `json:"email"`
	FirstName        *string     `json:"first_name"`
	LastName         *string     `json:"last_name"`
	Phone            *string     `json:"phone"`
	City             interface{} `json:"city"` // To be defined later matching CityOut
	ImageURL         *string     `json:"image_url"`
	IsSuperuser      bool        `json:"is_superuser"`
	IsCompanyMember  bool        `json:"is_company_member"`
	SecurityQuestion *string     `json:"security_question"`
	SecurityAnswer   *string     `json:"security_answer"`
	Company          interface{} `json:"company"` // To be defined matching CompanyInProfileOut
	IsDeleted        bool        `json:"is_deleted"`
	DisplayName      *string     `json:"display_name"`
}
