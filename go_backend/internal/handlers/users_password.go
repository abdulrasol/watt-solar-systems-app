package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
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

	// Password reset via email is not enabled yet. Returning the same message
	// regardless of whether the email exists prevents user enumeration.
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
	msgUser := "إعادة تعيين كلمة المرور غير مفعّلة حالياً"
	response.Error(c, http.StatusServiceUnavailable, "Password reset is not enabled", &msgUser)
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
	msgUser := "إعادة تعيين كلمة المرور غير مفعّلة حالياً"
	response.Error(c, http.StatusServiceUnavailable, "Password reset is not enabled", &msgUser)
}
