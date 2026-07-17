package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/services"
	"watt/internal/utils"
)

type UserHandler struct {
	cfg *config.Config
}

func NewUserHandler(cfg *config.Config) *UserHandler {
	return &UserHandler{cfg: cfg}
}

// Login handles user authentication
// @Summary Login user
// @Description Authenticates a user and returns a JWT token
// @Tags Users
// @Accept json
// @Produce json
// @Param request body models.LoginRequest true "Login Credentials"
// @Success 200 {object} response.APIResponse
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /users/login [post]
func (h *UserHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid request body", &msgUser)
		return
	}

	var user models.User
	// Load the user by username or email
	result := database.DB.Where("username = ? OR email = ?", req.Username, req.Username).First(&user)
	if result.Error != nil {
		msgUser := "اسم المستخدم أو كلمة المرور غير صحيحة"
		response.Error(c, http.StatusUnauthorized, "User not found", &msgUser)
		return
	}

	// Verify Password
	if !services.VerifyDjangoPassword(req.Password, user.Password) {
		msgUser := "اسم المستخدم أو كلمة المرور غير صحيحة"
		response.Error(c, http.StatusUnauthorized, "Invalid credentials", &msgUser)
		return
	}

	// Generate tokens
	access, _, err := services.GenerateJWT(&user, h.cfg)
	if err != nil {
		msgUser := "حدث خطأ أثناء توليد الرمز"
		response.Error(c, http.StatusInternalServerError, "Failed to generate token", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Login successful", gin.H{
		"token": access,
		"user":  buildProfileOut(&user, h.cfg.BaseURL),
	})
}

// Register handles new user registration
// @Summary Register a new user
// @Description Registers a new user and returns a user_id
// @Tags Users
// @Accept json
// @Produce json
// @Param request body models.RegisterRequest true "User Details"
// @Success 201 {object} response.APIResponse
// @Failure 400 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /users/register [post]
func (h *UserHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "الرجاء التأكد من الحقول"
		response.Error(c, http.StatusBadRequest, "Invalid request body", &msgUser)
		return
	}

	// Check if username exists
	var count int64
	database.DB.Model(&models.User{}).Where("username = ?", req.Username).Count(&count)
	if count > 0 {
		msgUser := "اسم المستخدم موجود مسبقاً"
		response.Error(c, http.StatusBadRequest, "Username exists", &msgUser)
		return
	}

	// Check if email exists
	database.DB.Model(&models.User{}).Where("email = ?", req.Email).Count(&count)
	if count > 0 {
		msgUser := "البريد الإلكتروني مسجل مسبقاً"
		response.Error(c, http.StatusBadRequest, "Email exists", &msgUser)
		return
	}

	// Hash password
	hashedPassword, err := services.GenerateDjangoPassword(req.Password)
	if err != nil {
		msgUser := "حدث خطأ"
		response.Error(c, http.StatusInternalServerError, "Hash error", &msgUser)
		return
	}

	// Create user
	user := models.User{
		Username:  req.Username,
		Email:     req.Email,
		Password:  hashedPassword,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Phone:     req.Phone,
		CityID:    req.CityID,
		IsActive:  true,
		IsStaff:   false,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		msgUser := "فشل في التسجيل"
		response.Error(c, http.StatusInternalServerError, "Failed to create user", &msgUser)
		return
	}

	// Generate token
	access, _, _ := services.GenerateJWT(&user, h.cfg)

	response.Success(c, http.StatusCreated, "Registration successful", gin.H{
		"token": access,
		"user":  buildProfileOut(&user, h.cfg.BaseURL),
	})
}

// GetProfile retrieves the currently logged in user's profile
// @Summary Get user profile
// @Description Retrieves the authenticated user's profile
// @Tags Users
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Router /users/profile [get]
func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		msgUser := "غير مصرح لك"
		response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	if user.IsDeleted {
		msgUser := "الحساب محذوف"
		response.Error(c, http.StatusNotFound, "Profile not available", &msgUser)
		return
	}

	profileOut := buildProfileOut(&user, h.cfg.BaseURL)
	response.Success(c, http.StatusOK, "Profile fetched successfully", profileOut)
}

// UpdateProfile updates the current user's profile
// @Summary Update user profile
// @Description Updates the authenticated user's profile information (multipart/form-data supported)
// @Tags Users
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param username formData string false "Username"
// @Param first_name formData string false "First Name"
// @Param last_name formData string false "Last Name"
// @Param email formData string false "Email"
// @Param phone formData string false "Phone"
// @Param city_id formData int false "City ID"
// @Param security_question formData string false "Security Question"
// @Param security_answer formData string false "Security Answer"
// @Param image formData file false "Profile Image"
// @Success 200 {object} response.APIResponse
// @Failure 400 {object} response.APIResponse
// @Failure 401 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Failure 500 {object} response.APIResponse
// @Router /users/profile [put]
func (h *UserHandler) UpdateProfile(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req models.ProfileUpdateSchema
	if err := c.ShouldBind(&req); err != nil {
		msgUser := "بيانات الإدخال غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid request", &msgUser)
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	// Validate username uniqueness
	if req.Username != nil && *req.Username != user.Username {
		var count int64
		database.DB.Model(&models.User{}).Where("username = ? AND id != ?", *req.Username, user.ID).Count(&count)
		if count > 0 {
			msgUser := "اسم المستخدم مستخدم مسبقاً"
			response.Error(c, http.StatusBadRequest, "Username taken", &msgUser)
			return
		}
		user.Username = *req.Username
	}

	// Validate email uniqueness
	if req.Email != nil && *req.Email != user.Email {
		var count int64
		database.DB.Model(&models.User{}).Where("email = ? AND id != ?", *req.Email, user.ID).Count(&count)
		if count > 0 {
			msgUser := "البريد الإلكتروني مستخدم مسبقاً"
			response.Error(c, http.StatusBadRequest, "Email taken", &msgUser)
			return
		}
		user.Email = *req.Email
	}

	// Validate phone uniqueness
	if req.Phone != nil && *req.Phone != user.Phone {
		var count int64
		database.DB.Model(&models.User{}).Where("phone = ? AND id != ?", *req.Phone, user.ID).Count(&count)
		if count > 0 {
			msgUser := "رقم الهاتف مستخدم مسبقاً"
			response.Error(c, http.StatusBadRequest, "Phone taken", &msgUser)
			return
		}
		user.Phone = *req.Phone
	}

	if req.FirstName != nil {
		user.FirstName = *req.FirstName
	}
	if req.LastName != nil {
		user.LastName = *req.LastName
	}
	if req.CityID != nil {
		user.CityID = req.CityID
	}
	if req.SecurityQuestion != nil {
		user.SecurityQuestion = req.SecurityQuestion
	}
	if req.SecurityAnswer != nil {
		user.SecurityAnswer = req.SecurityAnswer
	}

	// Handle image upload
	imagePath, err := utils.SaveUploadedFileOptional(c, "image", "user_images")
	if err != nil {
		msgUser := "فشل في حفظ الصورة"
		response.Error(c, http.StatusInternalServerError, "Failed to save image", &msgUser)
		return
	}
	if imagePath != nil {
		user.Image = imagePath
	}

	if err := database.DB.Save(&user).Error; err != nil {
		msgUser := "تعذر تحديث الملف الشخصي"
		response.Error(c, http.StatusInternalServerError, "Failed to update profile", &msgUser)
		return
	}

	profileOut := buildProfileOut(&user, h.cfg.BaseURL)
	response.Success(c, http.StatusOK, "Profile updated successfully", profileOut)
}
