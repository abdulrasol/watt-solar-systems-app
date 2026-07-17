package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/services"
)

// DeleteAccountSchema schema
type DeleteAccountSchema struct {
	Password string `json:"password" binding:"required"`
	Reason   string `json:"reason" binding:"required"`
}

// LanguageUpdateSchema schema
type LanguageUpdateSchema struct {
	Language string `json:"language" binding:"required"`
}

// DeleteAccount softly deletes the user account
// @Summary Delete account
// @Description Soft deletes the user account after password verification
// @Tags Users
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body DeleteAccountSchema true "Delete Account Details"
// @Success 200 {object} response.APIResponse
// @Router /users/delete-account [post]
func (h *UserHandler) DeleteAccount(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req DeleteAccountSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "البيانات غير مكتملة"
		response.Error(c, http.StatusBadRequest, "Invalid request", &msgUser)
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	if user.IsDeleted {
		msgUser := "الحساب محذوف بالفعل"
		response.Error(c, http.StatusBadRequest, "Account already deleted.", &msgUser)
		return
	}

	if !services.VerifyDjangoPassword(req.Password, user.Password) {
		msgUser := "كلمة المرور غير صحيحة"
		response.Error(c, http.StatusBadRequest, "Password is incorrect.", &msgUser)
		return
	}

	// Soft delete
	now := time.Now()
	user.IsDeleted = true
	user.DeletedAt = &now
	user.DeletedReason = &req.Reason
	user.IsActive = false

	if err := database.DB.Save(&user).Error; err != nil {
		msgUser := "فشل حذف الحساب"
		response.Error(c, http.StatusInternalServerError, "Failed to delete account", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Account deleted successfully.", nil)
}

// UpdateLanguage updates the user's preferred language
// @Summary Update language
// @Description Updates the user's language setting
// @Tags Users
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body LanguageUpdateSchema true "Language Update"
// @Success 200 {object} response.APIResponse
// @Router /users/language [put]
func (h *UserHandler) UpdateLanguage(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req LanguageUpdateSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid request", &msgUser)
		return
	}

	if req.Language != "ar" && req.Language != "en" {
		msgUser := "لغة غير صالحة، يرجى اختيار ar أو en"
		response.Error(c, http.StatusBadRequest, "Invalid language choice. Use 'ar' or 'en'.", &msgUser)
		return
	}

	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	user.Language = req.Language
	if err := database.DB.Save(&user).Error; err != nil {
		msgUser := "فشل تحديث اللغة"
		response.Error(c, http.StatusInternalServerError, "Failed to update language", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Language updated successfully", nil)
}

// GetUser fetches a user profile by username
// @Summary Get user by username
// @Description Fetch public profile of a user by username
// @Tags Users
// @Produce json
// @Param username path string true "Username"
// @Success 200 {object} response.APIResponse
// @Router /users/{username} [get]
func (h *UserHandler) GetUser(c *gin.Context) {
	username := c.Param("username")

	var user models.User
	if err := database.DB.Where("username = ?", username).First(&user).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	profileOut := buildProfileOut(&user, h.cfg.BaseURL)
	response.Success(c, http.StatusOK, "Success", profileOut)
}
