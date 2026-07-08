package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
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

	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err == nil {
		// TODO: Generate and send password reset token via email
		// For now we just pretend it was sent successfully
	}

	response.Success(c, http.StatusOK, "If the account exists, a password reset email has been sent.", nil)
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
		msgUser := "الرمز غير صالح"
		response.Error(c, http.StatusBadRequest, "Invalid token", &msgUser)
		return
	}

	// TODO: Validate the token from DB/Cache
	// Placeholder: assuming token is valid

	response.Success(c, http.StatusOK, "Token is valid.", gin.H{"valid": true})
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
		msgUser := "البيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid request", &msgUser)
		return
	}

	// TODO: Validate token, get user, and update password
	// Placeholder logic

	response.Success(c, http.StatusOK, "Password reset successfully.", nil)
}
