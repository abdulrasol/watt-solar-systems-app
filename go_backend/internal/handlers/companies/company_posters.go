package companies

import (
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
	"watt/internal/utils"
)

// CreatePoster handles POST /api/v1/companies/:company_id/posters
// @Summary CreatePoster
// @Description Create a poster for a company
// @Tags Company Operations
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param image formData file true "Poster Image"
// @Param text formData string false "Text"
// @Param action_type formData string false "Action Type"
// @Param action_id formData int false "Action ID"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/posters [post]
func CreatePoster(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	imagePath, err := utils.SaveUploadedFile(c, "image", "posters")
	if err != nil {
		msgUser := "الصورة مطلوبة"
		response.Error(c, http.StatusBadRequest, "Image required", &msgUser)
		return
	}

	text := c.PostForm("text")
	actionType := c.DefaultPostForm("action_type", "company_profile")
	actionIDStr := c.PostForm("action_id")

	poster := models.Poster{
		CompanyID:  company.ID,
		Image:      *imagePath,
		Text:       &text,
		ActionType: actionType,
		Status:     "pending",
		IsActive:   true,
	}

	if actionIDStr != "" {
		if actionID, err := strconv.Atoi(actionIDStr); err == nil {
			poster.ActionID = &actionID
		}
	}

	if err := database.DB.Create(&poster).Error; err != nil {
		msgUser := "فشل في إنشاء الإعلان"
		response.Error(c, http.StatusInternalServerError, "Failed to create poster", &msgUser)
		return
	}

	// Notify superusers
	notifsvc.SendPosterCreatedNotification(&poster)

	response.Success(c, http.StatusOK, "Poster created successfully and pending review", poster)
}

// GetCompanyPosters handles GET /api/v1/companies/:company_id/posters
// @Summary GetCompanyPosters
// @Description Get posters for a company
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/posters [get]
func GetCompanyPosters(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var posters []models.Poster
	if err := database.DB.Where("company_id = ?", company.ID).Order("created_at desc").Find(&posters).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الإعلانات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch posters", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	items := make([]map[string]interface{}, 0, len(posters))
	for _, p := range posters {
		items = append(items, SerializePoster(&p, baseURL))
	}

	response.Success(c, http.StatusOK, "Posters retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// AdminGetCompanyPosters handles GET /api/v1/admin/companies/:company_id/posters
// @Summary AdminGetCompanyPosters
// @Description Get posters for a company (admin)
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/posters [get]
func AdminGetCompanyPosters(c *gin.Context) {
	companyID, err := strconv.Atoi(c.Param("company_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid company ID", nil)
		return
	}

	var company models.Company
	if err := database.DB.First(&company, companyID).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	var posters []models.Poster
	if err := database.DB.Where("company_id = ?", company.ID).Order("created_at desc").Find(&posters).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الإعلانات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch posters", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	items := make([]map[string]interface{}, 0, len(posters))
	for _, p := range posters {
		items = append(items, SerializePoster(&p, baseURL))
	}

	response.Success(c, http.StatusOK, "Posters retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// AdminReviewPoster handles POST /api/v1/admin/companies/posters/:poster_id/review
// @Summary AdminReviewPoster
// @Description Review a poster (approved/rejected)
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Security Bearer
// @Param poster_id path int true "poster_id"
// @Param request body models.PosterReviewSchema true "Review Action"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/posters/{poster_id}/review [post]
func AdminReviewPoster(c *gin.Context) {
	idStr := c.Param("poster_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Poster ID", nil)
		return
	}

	var payload models.PosterReviewSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	var poster models.Poster
	if err := database.DB.Where("id = ?", id).First(&poster).Error; err != nil {
		msgUser := "المنشور غير موجود"
		response.Error(c, http.StatusNotFound, "Poster not found", &msgUser)
		return
	}

	switch payload.Status {
	case "approved":
		poster.Status = "approved"
		poster.IsActive = true
		now := time.Now()
		poster.ApprovedAt = &now
		duration := payload.DurationDays
		if duration <= 0 {
			duration = 7
		}
		poster.DurationDays = &duration
		exp := now.AddDate(0, 0, duration)
		poster.ExpiresAt = &exp
	case "rejected":
		poster.Status = "rejected"
		poster.IsActive = false
	default:
		response.Error(c, http.StatusBadRequest, "Invalid status", nil)
		return
	}

	if err := database.DB.Save(&poster).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to review poster", nil)
		return
	}

	if payload.Status == "approved" {
		notifsvc.SendPosterApprovedNotification(&poster)
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Poster reviewed successfully", SerializePoster(&poster, baseURL))
}

// AdminExtendPoster handles POST /api/v1/admin/companies/posters/:poster_id/extend
// @Summary AdminExtendPoster
// @Description Extend a poster expiration
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Security Bearer
// @Param poster_id path int true "poster_id"
// @Param request body models.PosterExtendSchema true "Extend payload"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/posters/{poster_id}/extend [post]
func AdminExtendPoster(c *gin.Context) {
	idStr := c.Param("poster_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Poster ID", nil)
		return
	}

	var payload models.PosterExtendSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	var poster models.Poster
	if err := database.DB.Where("id = ?", id).First(&poster).Error; err != nil {
		msgUser := "المنشور غير موجود"
		response.Error(c, http.StatusNotFound, "Poster not found", &msgUser)
		return
	}

	if poster.Status != "approved" {
		msgUser := "لا يمكن تمديد منشور لم يتم الموافقة عليه"
		response.Error(c, http.StatusBadRequest, "Poster not approved", &msgUser)
		return
	}

	expiresAt, err := time.Parse("2006-01-02T15:04:05Z07:00", payload.ExpiresAt)
	if err != nil {
		expiresAt, err = time.Parse("2006-01-02", payload.ExpiresAt)
		if err != nil {
			response.Error(c, http.StatusBadRequest, "Invalid expires_at format", nil)
			return
		}
	}

	poster.ExpiresAt = &expiresAt
	if err := database.DB.Save(&poster).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to extend poster", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Poster extended successfully", SerializePoster(&poster, baseURL))
}

// UpdatePoster handles PUT /api/v1/companies/:company_id/posters/:poster_id
// @Summary UpdatePoster
// @Description Update a company poster (admin/manager)
// @Tags Company Operations
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param poster_id path int true "poster_id"
// @Param text formData string false "Text"
// @Param action_type formData string false "Action Type"
// @Param action_id formData int false "Action ID"
// @Param image formData file false "Poster Image"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/posters/{poster_id} [put]
func UpdatePoster(c *gin.Context) {
	company, member, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	if member.Role != "admin" && member.Role != "manager" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	posterID, err := strconv.Atoi(c.Param("poster_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid poster ID", nil)
		return
	}

	var poster models.Poster
	if err := database.DB.Where("id = ? AND company_id = ?", posterID, company.ID).First(&poster).Error; err != nil {
		msgUser := "الإعلان غير موجود"
		response.Error(c, http.StatusNotFound, "Poster not found", &msgUser)
		return
	}

	if text := c.PostForm("text"); text != "" {
		poster.Text = &text
	}
	if actionType := c.PostForm("action_type"); actionType != "" {
		poster.ActionType = actionType
	}
	if actionIDStr := c.PostForm("action_id"); actionIDStr != "" {
		if actionID, err := strconv.Atoi(actionIDStr); err == nil {
			poster.ActionID = &actionID
		} else {
			poster.ActionID = nil
		}
	}

	imagePath, err := utils.SaveUploadedFileOptional(c, "image", "posters")
	if err != nil {
		msgUser := "فشل في حفظ الصورة"
		response.Error(c, http.StatusInternalServerError, "Failed to save image", &msgUser)
		return
	}
	if imagePath != nil {
		_ = os.Remove(strings.TrimPrefix(poster.Image, "/"))
		poster.Image = *imagePath
	}

	if err := database.DB.Save(&poster).Error; err != nil {
		msgUser := "فشل في تحديث الإعلان"
		response.Error(c, http.StatusInternalServerError, "Failed to update poster", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Poster updated successfully", SerializePoster(&poster, baseURL))
}

// DeletePoster handles DELETE /api/v1/companies/:company_id/posters/:poster_id
// @Summary DeletePoster
// @Description Delete a company poster (admin/manager)
// @Tags Company Operations
// @Security Bearer
// @Param poster_id path int true "poster_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/posters/{poster_id} [delete]
func DeletePoster(c *gin.Context) {
	company, member, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	if member.Role != "admin" && member.Role != "manager" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	posterID, err := strconv.Atoi(c.Param("poster_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid poster ID", nil)
		return
	}

	var poster models.Poster
	if err := database.DB.Where("id = ? AND company_id = ?", posterID, company.ID).First(&poster).Error; err != nil {
		msgUser := "الإعلان غير موجود"
		response.Error(c, http.StatusNotFound, "Poster not found", &msgUser)
		return
	}

	_ = os.Remove(strings.TrimPrefix(poster.Image, "/"))

	if err := database.DB.Delete(&poster).Error; err != nil {
		msgUser := "فشل في حذف الإعلان"
		response.Error(c, http.StatusInternalServerError, "Failed to delete poster", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Poster deleted successfully", nil)
}

// TogglePosterActive handles PATCH /api/v1/companies/:company_id/posters/:poster_id/toggle-active
// @Summary TogglePosterActive
// @Description Toggle active state of an approved poster
// @Tags Company Operations
// @Security Bearer
// @Param poster_id path int true "poster_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/posters/{poster_id}/toggle-active [patch]
func TogglePosterActive(c *gin.Context) {
	company, member, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	if member.Role != "admin" && member.Role != "manager" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	posterID, err := strconv.Atoi(c.Param("poster_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid poster ID", nil)
		return
	}

	var poster models.Poster
	if err := database.DB.Where("id = ? AND company_id = ?", posterID, company.ID).First(&poster).Error; err != nil {
		msgUser := "الإعلان غير موجود"
		response.Error(c, http.StatusNotFound, "Poster not found", &msgUser)
		return
	}

	if poster.Status != "approved" {
		msgUser := "لا يمكن تبديل حالة إعلان لم يتم الموافقة عليه"
		response.Error(c, http.StatusBadRequest, "Poster not approved", &msgUser)
		return
	}

	msg := "Poster activated"
	poster.IsActive = !poster.IsActive
	if poster.IsActive {
		msg = "Poster activated"
	} else {
		msg = "Poster paused"
	}

	if err := database.DB.Save(&poster).Error; err != nil {
		msgUser := "فشل في تبديل حالة الإعلان"
		response.Error(c, http.StatusInternalServerError, "Failed to toggle poster", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, msg, SerializePoster(&poster, baseURL))
}
