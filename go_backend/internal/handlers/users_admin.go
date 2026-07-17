package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// PromoteUserRequest schema
type PromoteUserRequest struct {
	UserID  uint `json:"user_id"`
	Promote bool `json:"promote"`
}

// GetUsers lists all users (Admin only)
// @Summary List all users
// @Description Get a paginated list of all users
// @Tags Users - Admin
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /users [get]
func (h *UserHandler) GetUsers(c *gin.Context) {
	// In a real app, verify superuser status here or in middleware
	// For now we just query all users

	var users []models.User
	if err := database.DB.Find(&users).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب المستخدمين"
		response.Error(c, http.StatusInternalServerError, "Error fetching users", &msgUser)
		return
	}

	var usersOut []models.ProfileOut
	for _, u := range users {
		userCopy := u
		usersOut = append(usersOut, buildProfileOut(&userCopy, h.cfg.BaseURL))
	}

	// TODO: Add pagination

	c.JSON(http.StatusOK, map[string]interface{}{
		"items": usersOut,
		"count": len(usersOut),
	})
}

// PromoteUser promotes or demotes a user to superuser (Admin only)
// @Summary Promote user
// @Description Promote or demote user to superuser
// @Tags Users - Admin
// @Accept json
// @Produce json
// @Security Bearer
// @Param username path string true "Username"
// @Param request body PromoteUserRequest true "Promote request"
// @Success 200 {object} response.APIResponse
// @Router /users/promote/{username} [post]
func (h *UserHandler) PromoteUser(c *gin.Context) {
	username := c.Param("username")

	var req PromoteUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		msgUser := "بيانات الإدخال غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid request", &msgUser)
		return
	}

	var targetUser models.User
	if err := database.DB.Where("username = ? AND id = ?", username, req.UserID).First(&targetUser).Error; err != nil {
		msgUser := "المستخدم غير موجود"
		response.Error(c, http.StatusNotFound, "User not found", &msgUser)
		return
	}

	targetUser.IsSuperuser = req.Promote
	targetUser.IsStaff = req.Promote

	if err := database.DB.Save(&targetUser).Error; err != nil {
		msgUser := "حدث خطأ أثناء ترقية المستخدم"
		response.Error(c, http.StatusInternalServerError, "Failed to update user", &msgUser)
		return
	}

	action := "promoted"
	if !req.Promote {
		action = "demoted"
	}

	response.Success(c, http.StatusOK, "User "+targetUser.Username+" has been "+action+" to Superuser.", nil)
}
