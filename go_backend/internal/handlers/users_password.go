package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/services"
	"watt/internal/utils"
)

// PasswordResetRequestSchema schema
type PasswordResetRequestSchema struct {
	Email string `json:"email" binding:"required,email"`
}

// PasswordResetTokenSchema schema
type PasswordResetTokenSchema struct {
	Token string `json:"token" binding:"required"`
}

// PasswordResetConfirmSchema schema
type PasswordResetConfirmSchema struct {
	Token    string `json:"token" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// PasswordResetRequest requests a password reset
// @Summary Request password reset
// @Description Sends a password reset email if account exists
// @Tags Users
// @Accept json
// @Produce json
// @Param request body PasswordResetRequestSchema true "Email"
// @Success 200 {object} response.APIResponse
// @Router /users/password-reset [post]
func (h *UserHandler) PasswordResetRequest(c *gin.Context) {
	var req PasswordResetRequestSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "البريد الإلكتروني غير صالح"
		response.Error(c, http.StatusBadRequest, "Invalid email", &msgUser)
		return
	}

	// Always return the same message to prevent user enumeration.
	successMsg := "If the account exists, a password reset email has been sent."
	successMsgUser := "إذا كان الحساب موجودًا، فقد تم إرسال رابط إعادة التعيين إلى بريدك"

	// Check if user exists.
	var user models.User
	if err := database.DB.Where("email = ? AND is_deleted = ?", req.Email, false).First(&user).Error; err != nil {
		response.Success(c, http.StatusOK, successMsg, gin.H{"message_user": successMsgUser})
		return
	}

	// Delete any existing tokens for this email.
	database.DB.Where("email = ?", req.Email).Delete(&models.PasswordReset{})

	// Generate token.
	token, err := utils.GenerateSecureToken(32)
	if err != nil {
		response.Success(c, http.StatusOK, successMsg, gin.H{"message_user": successMsgUser})
		return
	}

	// Store token.
	reset := models.PasswordReset{
		Email:     req.Email,
		Token:     token,
		ExpiresAt: time.Now().Add(1 * time.Hour),
	}
	if err := database.DB.Create(&reset).Error; err != nil {
		response.Success(c, http.StatusOK, successMsg, gin.H{"message_user": successMsgUser})
		return
	}

	// Send email.
	emailService := services.NewEmailService(h.cfg)
	if err := emailService.SendPasswordResetEmail(req.Email, token); err != nil {
		// Log error but still return success to prevent enumeration.
		response.Success(c, http.StatusOK, successMsg, gin.H{"message_user": successMsgUser})
		return
	}

	response.Success(c, http.StatusOK, successMsg, gin.H{"message_user": successMsgUser})
}

// ValidateResetToken validates a password reset token
// @Summary Validate reset token
// @Description Validates if a password reset token is still valid
// @Tags Users
// @Accept json
// @Produce json
// @Param request body PasswordResetTokenSchema true "Token"
// @Success 200 {object} response.APIResponse
// @Router /users/password-reset/validate-token [post]
func (h *UserHandler) ValidateResetToken(c *gin.Context) {
	var req PasswordResetTokenSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "الرمز مطلوب"
		response.Error(c, http.StatusBadRequest, "Token is required", &msgUser)
		return
	}

	var reset models.PasswordReset
	if err := database.DB.Where("token = ?", req.Token).First(&reset).Error; err != nil || !reset.IsValid() {
		msgUser := "الرمز غير صالح أو منتهي الصلاحية"
		response.Error(c, http.StatusBadRequest, "Invalid or expired token", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Token is valid", nil)
}

// ConfirmPasswordReset confirms and resets the password
// @Summary Confirm password reset
// @Description Resets the password using a valid token
// @Tags Users
// @Accept json
// @Produce json
// @Param request body PasswordResetConfirmSchema true "Password Reset Details"
// @Success 200 {object} response.APIResponse
// @Router /users/password-reset/confirm [post]
func (h *UserHandler) ConfirmPasswordReset(c *gin.Context) {
	var req PasswordResetConfirmSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "الرمز وكلمة المرور الجديدة مطلوبان"
		response.Error(c, http.StatusBadRequest, "Token and password are required", &msgUser)
		return
	}

	var reset models.PasswordReset
	if err := database.DB.Where("token = ?", req.Token).First(&reset).Error; err != nil || !reset.IsValid() {
		msgUser := "الرمز غير صالح أو منتهي الصلاحية"
		response.Error(c, http.StatusBadRequest, "Invalid or expired token", &msgUser)
		return
	}

	hashedPassword, err := services.GenerateDjangoPassword(req.Password)
	if err != nil {
		msgUser := "حدث خطأ أثناء معالجة كلمة المرور"
		response.Error(c, http.StatusInternalServerError, "Failed to hash password", &msgUser)
		return
	}

	// Update user password.
	if err := database.DB.Model(&models.User{}).
		Where("email = ? AND is_deleted = ?", reset.Email, false).
		Update("password", hashedPassword).Error; err != nil {
		msgUser := "حدث خطأ أثناء تحديث كلمة المرور"
		response.Error(c, http.StatusInternalServerError, "Failed to update password", &msgUser)
		return
	}

	// Mark token as used.
	now := time.Now()
	reset.UsedAt = &now
	database.DB.Save(&reset)

	msgUser := "تم تغيير كلمة المرور بنجاح"
	response.Success(c, http.StatusOK, "Password reset successfully", gin.H{"message_user": msgUser})
}
