package companies

import (
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// GetCompanyMembers handles GET /api/company/{company_id}/members
// @Security Bearer
// @Summary GetCompanyMembers
// @Description GetCompanyMembers
// @Tags Companies Members
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/members [get]
func GetCompanyMembers(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var members []models.CompanyMember
	if err := database.DB.Preload("User").Where("company_id = ?", member.CompanyID).Find(&members).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الأعضاء"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch members", &msgUser)
		return
	}

	var data []map[string]interface{}
	for _, m := range members {
		data = append(data, map[string]interface{}{
			"id":        fmt.Sprintf("%d", m.ID),
			"username":  m.User.Username,
			"email":     m.User.Email,
			"role":      m.Role,
			"joined_at": m.JoinedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Members retrieved successfully", data)
}

// InviteMember handles POST /api/company/{company_id}/members/invite
// @Accept json
// @Produce json
// @Param request body models.InviteMemberSchema true "Invite Member details"
// @Security Bearer
// @Summary InviteMember
// @Description InviteMember
// @Tags Companies Members
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/members/invite [post]
func InviteMember(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Email string `json:"email" binding:"required"`
		Role  string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	if member.Role == "manager" && payload.Role == "admin" {
		msgUser := "لا يمكن للمدير تعيين دور أدمن"
		response.Error(c, http.StatusForbidden, "Managers cannot assign Admin role", &msgUser)
		return
	}

	var targetUser models.User
	if err := database.DB.Where("email = ?", payload.Email).First(&targetUser).Error; err != nil {
		msgUser := "المستخدم غير موجود. الرجاء إنشاء حساب له."
		c.JSON(http.StatusNotFound, response.APIResponse{
			Status:      http.StatusNotFound,
			Message:     "User with this email not found.",
			Error:       true,
			MessageUser: &msgUser,
			Body: map[string]interface{}{
				"requires_registration": true,
			},
		})
		return
	}

	var existing models.CompanyMember
	if err := database.DB.Where("company_id = ? AND user_id = ?", member.CompanyID, targetUser.ID).First(&existing).Error; err == nil {
		msgUser := "المستخدم عضو بالفعل في هذه الشركة."
		response.Error(c, http.StatusBadRequest, "Already a member", &msgUser)
		return
	}

	newMember := models.CompanyMember{
		CompanyID: member.CompanyID,
		UserID:    targetUser.ID,
		Role:      payload.Role,
	}

	if err := database.DB.Create(&newMember).Error; err != nil {
		msgUser := "حدث خطأ أثناء دعوة العضو"
		response.Error(c, http.StatusInternalServerError, "Failed to invite member", &msgUser)
		return
	}

	// Send localized push + in-app notification
	notifsvc.SendCompanyInviteNotification(&newMember)

	response.Success(c, http.StatusOK, "User invited successfully.", map[string]interface{}{})
}

// CreateNewMember handles POST /api/company/{company_id}/members/create
// @Accept json
// @Produce json
// @Param request body models.CreateMemberSchema true "New Member details"
// @Security Bearer
// @Summary CreateNewMember
// @Description CreateNewMember
// @Tags Companies Members
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/members/create [post]
func CreateNewMember(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Username  string `json:"username" binding:"required"`
		Email     string `json:"email" binding:"required"`
		Password  string `json:"password" binding:"required"`
		FirstName string `json:"first_name" binding:"required"`
		LastName  string `json:"last_name" binding:"required"`
		Role      string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	if member.Role == "manager" && payload.Role == "admin" {
		msgUser := "لا يمكن للمدير تعيين دور أدمن"
		response.Error(c, http.StatusForbidden, "Managers cannot assign Admin role", &msgUser)
		return
	}

	var count int64
	database.DB.Model(&models.User{}).Where("email = ?", payload.Email).Count(&count)
	if count > 0 {
		msgUser := "البريد الإلكتروني موجود بالفعل"
		response.Error(c, http.StatusBadRequest, "User with this email already exists", &msgUser)
		return
	}

	database.DB.Model(&models.User{}).Where("username = ?", payload.Username).Count(&count)
	if count > 0 {
		msgUser := "اسم المستخدم موجود بالفعل"
		response.Error(c, http.StatusBadRequest, "User with this username already exists", &msgUser)
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(payload.Password), bcrypt.DefaultCost)
	if err != nil {
		msgUser := "فشل في تشفير كلمة المرور"
		response.Error(c, http.StatusInternalServerError, "Failed to hash password", &msgUser)
		return
	}

	newUser := models.User{
		Username:  payload.Username,
		Email:     payload.Email,
		Password:  string(hashedPassword),
		FirstName: payload.FirstName,
		LastName:  payload.LastName,
	}

	tx := database.DB.Begin()
	if err := tx.Create(&newUser).Error; err != nil {
		tx.Rollback()
		msgUser := "فشل في إنشاء الحساب"
		response.Error(c, http.StatusInternalServerError, "Failed to create user", &msgUser)
		return
	}

	newMember := models.CompanyMember{
		CompanyID: member.CompanyID,
		UserID:    newUser.ID,
		Role:      payload.Role,
	}
	tx.Create(&newMember)

	tx.Commit()

	// Send localized push + in-app notification
	notifsvc.SendCompanyInviteNotification(&newMember)

	response.Success(c, http.StatusOK, "User created and added to company", map[string]interface{}{
		"user_id":  newUser.ID,
		"username": newUser.Username,
	})
}

// RemoveMember handles DELETE /api/company/{company_id}/members/{member_id}
// @Security Bearer
// @Summary RemoveMember
// @Description RemoveMember
// @Tags Companies Members
// @Param company_id path int true "company_id"
// @Param member_id path int true "member_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/members/{member_id} [delete]
func RemoveMember(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	memberIDStr := c.Param("member_id")
	memberID, err := strconv.Atoi(memberIDStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Member ID", nil)
		return
	}

	var targetMember models.CompanyMember
	if err := database.DB.Where("id = ? AND company_id = ?", memberID, member.CompanyID).First(&targetMember).Error; err != nil {
		msgUser := "العضو غير موجود"
		response.Error(c, http.StatusNotFound, "Member not found", &msgUser)
		return
	}

	if targetMember.Role == "admin" && member.Role != "admin" {
		msgUser := "لا يمكن حذف الأدمن"
		response.Error(c, http.StatusForbidden, "Cannot remove admin", &msgUser)
		return
	}

	if targetMember.ID == member.ID {
		msgUser := "لا يمكنك حذف حسابك الخاص"
		response.Error(c, http.StatusBadRequest, "Cannot remove self", &msgUser)
		return
	}

	database.DB.Delete(&targetMember)

	// Notify the removed user
	notifsvc.SendMemberRemovedNotification(&models.Company{ID: member.CompanyID}, targetMember.UserID)

	response.Success(c, http.StatusOK, "Member removed successfully", map[string]interface{}{})
}

// UpdateMemberRole handles PATCH /api/company/{company_id}/members/{member_id}
// @Security Bearer
// @Summary UpdateMemberRole
// @Description UpdateMemberRole
// @Tags Companies Members
// @Param company_id path int true "company_id"
// @Param member_id path int true "member_id"
// @Param body body map[string]interface{} true "body"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/members/{member_id} [patch]
func UpdateMemberRole(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	memberIDStr := c.Param("member_id")
	memberID, err := strconv.Atoi(memberIDStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Member ID", nil)
		return
	}

	var req struct {
		Role string `json:"role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request body", nil)
		return
	}

	var targetMember models.CompanyMember
	if err := database.DB.Where("id = ? AND company_id = ?", memberID, member.CompanyID).First(&targetMember).Error; err != nil {
		msgUser := "العضو غير موجود"
		response.Error(c, http.StatusNotFound, "Member not found", &msgUser)
		return
	}

	if targetMember.Role == "admin" && member.Role != "admin" {
		msgUser := "لا يمكن تعديل صلاحيات الأدمن"
		response.Error(c, http.StatusForbidden, "Cannot update admin role", &msgUser)
		return
	}

	targetMember.Role = req.Role
	database.DB.Save(&targetMember)

	response.Success(c, http.StatusOK, "Member role updated successfully", map[string]interface{}{})
}
