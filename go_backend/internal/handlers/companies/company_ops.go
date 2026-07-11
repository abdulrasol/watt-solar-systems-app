package companies

import (
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
	"watt/internal/utils"

	"github.com/gin-gonic/gin"
)

// UpdateCompany handles PUT /api/v1/companies/:company_id
// @Summary UpdateCompany
// @Description Update company details (admin or owner)
// @Tags Companies
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Param name formData string false "Name"
// @Param company_type formData int false "Company Type ID"
// @Param description formData string false "Description"
// @Param address formData string false "Address"
// @Param phone formData string false "Phone"
// @Param allows_b2b formData bool false "Allows B2B"
// @Param allows_b2c formData bool false "Allows B2C"
// @Param city formData int false "City ID"
// @Param currency formData int false "Currency ID"
// @Param image formData file false "Logo"
// @Success 200 {object} response.APIResponse
// @Failure 400 {object} response.APIResponse
// @Failure 403 {object} response.APIResponse
// @Failure 404 {object} response.APIResponse
// @Router /companies/{company_id} [put]
func UpdateCompany(c *gin.Context) {
	companyID, err := strconv.Atoi(c.Param("company_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid company ID", nil)
		return
	}

	userID, ok := GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	var company models.Company
	if err := database.DB.Preload("CompanyType").First(&company, companyID).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	// Only company admin/manager or superuser can update
	isSuperuser, _ := c.Get("is_superuser")
	var member models.CompanyMember
	memberErr := database.DB.Where("company_id = ? AND user_id = ?", company.ID, userID).First(&member).Error
	canUpdate := memberErr == nil && (member.Role == "admin" || member.Role == "manager")
	if isSuperuser != true && !canUpdate {
		msgUser := "ليس لديك صلاحية تعديل هذه الشركة"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	var payload models.CompanyUpdateSchema
	if err := c.ShouldBind(&payload); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid payload", &msgUser)
		return
	}

	if payload.Name != nil {
		company.Name = *payload.Name
	}
	if payload.CompanyType != nil {
		var ctype models.CompanyType
		if err := database.DB.First(&ctype, *payload.CompanyType).Error; err != nil {
			msgUser := "نوع الشركة غير موجود"
			response.Error(c, http.StatusBadRequest, "Company type not found", &msgUser)
			return
		}
		company.CompanyTypeID = &ctype.ID
	}
	if payload.Description != nil {
		company.Description = payload.Description
	}
	if payload.Address != nil {
		company.Address = payload.Address
	}
	if payload.Phone != nil {
		company.Phone = *payload.Phone
	}
	if payload.AllowsB2B != nil {
		company.AllowsB2B = *payload.AllowsB2B
	}
	if payload.AllowsB2C != nil {
		company.AllowsB2C = *payload.AllowsB2C
	}
	if payload.CityID != nil {
		var city models.City
		if err := database.DB.First(&city, *payload.CityID).Error; err != nil {
			msgUser := "المدينة غير موجودة"
			response.Error(c, http.StatusBadRequest, "City not found", &msgUser)
			return
		}
		company.CityID = payload.CityID
	}
	if payload.CurrencyID != nil {
		var currency models.Currency
		if err := database.DB.First(&currency, *payload.CurrencyID).Error; err != nil {
			msgUser := "العملة غير موجودة"
			response.Error(c, http.StatusBadRequest, "Currency not found", &msgUser)
			return
		}
		company.CurrencyID = payload.CurrencyID
	}

	logoPath, err := utils.SaveUploadedFileOptional(c, "image", "company_logos")
	if err != nil {
		msgUser := "فشل في حفظ الشعار"
		response.Error(c, http.StatusInternalServerError, "Failed to save logo", &msgUser)
		return
	}
	if logoPath != nil {
		company.Logo = logoPath
	}

	if err := database.DB.Save(&company).Error; err != nil {
		msgUser := "فشل في تحديث الشركة"
		response.Error(c, http.StatusInternalServerError, "Failed to update company", &msgUser)
		return
	}

	database.DB.Preload("CompanyType").Preload("City").Preload("Currency").First(&company)
	
	// Notify superusers about the update
	notifsvc.SendCompanyUpdateNotification(&company)
	
	response.Success(c, http.StatusOK, "Company updated successfully", SerializeCompanyForAdmin(&company))
}

// RequestSubscription handles POST /api/v1/companies/:company_id/subscription-request
// @Summary RequestSubscription
// @Description Create a subscription request for a company (auto-approves free plans)
// @Tags Company Operations
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Param subscription_plan formData int true "Subscription Plan ID"
// @Param notes formData string false "Notes"
// @Param image formData file false "Receipt / Image"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/subscription-request [post]
func RequestSubscription(c *gin.Context) {
	company, member, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	if member.Role != "admin" && member.Role != "manager" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	var payload models.CompanySubscriptionRequestCreateSchema
	if err := c.ShouldBind(&payload); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid payload", &msgUser)
		return
	}

	var plan models.SubscriptionPlan
	if err := database.DB.First(&plan, payload.SubscriptionPlanID).Error; err != nil {
		msgUser := "خطة الاشتراك غير موجودة"
		response.Error(c, http.StatusBadRequest, "Plan not found", &msgUser)
		return
	}

	// Preload CompanyType and AllowedSubscriptionPlans
	var cType models.CompanyType
	if company.CompanyTypeID != nil {
		database.DB.Preload("AllowedSubscriptionPlans").First(&cType, *company.CompanyTypeID)
	}

	// Check allowed for company type
	allowed := false
	for _, p := range cType.AllowedSubscriptionPlans {
		if p.ID == plan.ID {
			allowed = true
			break
		}
	}
	if !allowed {
		msgUser := "خطة الاشتراك غير متاحة لنوع الشركة"
		response.Error(c, http.StatusBadRequest, "Plan not allowed for company type", &msgUser)
		return
	}

	userID, _ := GetUserIDFromContext(c)

	// Remove any existing pending request
	var existing []models.CompanySubscriptionRequest
	database.DB.Where("company_id = ? AND status = ?", company.ID, "pending").Find(&existing)
	for _, old := range existing {
		if old.Image != nil {
			_ = os.Remove(strings.TrimPrefix(*old.Image, "/"))
		}
		database.DB.Delete(&old)
	}

	imagePath, err := utils.SaveUploadedFileOptional(c, "image", "subscription_requests")
	if err != nil {
		msgUser := "فشل في حفظ الصورة"
		response.Error(c, http.StatusInternalServerError, "Failed to save image", &msgUser)
		return
	}

	request := models.CompanySubscriptionRequest{
		CompanyID:          company.ID,
		SubscriptionPlanID: plan.ID,
		RequestedByID:      &userID,
		Status:             "pending",
		Notes:              "",
		Image:              imagePath,
	}
	if payload.Notes != nil {
		request.Notes = *payload.Notes
	}

	if err := database.DB.Create(&request).Error; err != nil {
		msgUser := "فشل في إنشاء طلب الاشتراك"
		response.Error(c, http.StatusInternalServerError, "Failed to create subscription request", &msgUser)
		return
	}

	autoApproved := false
	effectiveStart := time.Now()
	resultingExpiry := effectiveStart

	if plan.Price == 0 {
		autoApproved = true
		request.Status = "approved"
		now := time.Now()
		request.ApprovedAt = &now

		if company.SubscriptionStartDate != nil && company.ExpireDate.After(now) {
			effectiveStart = company.ExpireDate
		}
		resultingExpiry = effectiveStart.AddDate(0, 0, plan.DurationDays)

		company.SubscriptionPlanID = &plan.ID
		company.SubscriptionStartDate = &effectiveStart
		company.ExpireDate = resultingExpiry
		company.Status = "active"
		if err := database.DB.Save(&company).Error; err != nil {
			msgUser := "فشل في تفعيل الاشتراك المجاني"
			response.Error(c, http.StatusInternalServerError, "Failed to activate free plan", &msgUser)
			return
		}
	} else {
		// Notify superusers
		notifsvc.SendNewCompanySubscriptionRequestNotification(&request)
	}

	response.Success(c, http.StatusOK, "Subscription request created successfully", map[string]interface{}{
		"request":                      request,
		"auto_approved":                autoApproved,
		"effective_start":              effectiveStart.Format("2006-01-02T15:04:05Z07:00"),
		"resulting_expiry":             resultingExpiry.Format("2006-01-02T15:04:05Z07:00"),
		"company_subscription_plan_id": company.SubscriptionPlanID,
	})
}

// ActivationReminder handles POST /api/v1/companies/:company_id/activation-reminder
// @Summary ActivationReminder
// @Description Send an activation reminder for a pending company (admin/manager/superuser)
// @Tags Company Operations
// @Accept json
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/activation-reminder [post]
func ActivationReminder(c *gin.Context) {
	company, member, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	isSuperuser, _ := c.Get("is_superuser")
	if isSuperuser != true && member.Role != "admin" && member.Role != "manager" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	if company.Status != "pending" {
		msgUser := "التذكير متاح فقط للشركات المعلقة"
		response.Error(c, http.StatusBadRequest, "Reminder only for pending companies", &msgUser)
		return
	}

	now := time.Now()
	lastReminder := company.LastActivationReminderAt
	if lastReminder == nil {
		lastReminder = &company.CreatedAt
	}
	cooldownEnd := lastReminder.Add(24 * time.Hour)
	if now.Before(cooldownEnd) {
		msgUser := "يمكن إرسال تذكير تنشيط مرة واحدة كل 24 ساعة"
		response.Error(c, http.StatusBadRequest, "Activation reminder on cooldown", &msgUser)
		return
	}

	company.LastActivationReminderAt = &now
	if err := database.DB.Save(&company).Error; err != nil {
		msgUser := "فشل في تحديث حالة التذكير"
		response.Error(c, http.StatusInternalServerError, "Failed to save reminder", &msgUser)
		return
	}

	// Notify superusers about pending activation
	var currentUser models.User
	if userID, ok := GetUserIDFromContext(c); ok {
		database.DB.First(&currentUser, userID)
	}
	notifsvc.SendCompanyActivationReminderNotification(company, &currentUser)

	response.Success(c, http.StatusOK, "Activation reminder sent successfully", map[string]interface{}{
		"company_id":                       company.ID,
		"reminded_at":                      now.Format("2006-01-02T15:04:05Z07:00"),
		"activation_reminder_available_at": now.Add(24 * time.Hour).Format("2006-01-02T15:04:05Z07:00"),
	})
}

// ToggleCompanyActive handles POST /api/v1/companies/:company_id/toggle-active
// @Summary ToggleCompanyActive
// @Description Toggle company active status
// @Tags Company Operations
// @Accept json
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/toggle-active [post]
func ToggleCompanyActive(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	// Only company admin can toggle
	userID, _ := GetUserIDFromContext(c)
	var member models.CompanyMember
	if err := database.DB.Where("company_id = ? AND user_id = ?", company.ID, userID).First(&member).Error; err != nil || member.Role != "admin" {
		msgUser := "ليس لديك صلاحية"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	switch company.Status {
	case "active":
		company.Status = "inactive"
	case "inactive":
		company.Status = "active"
	default:
		msgUser := "لا يمكن تغيير حالة الشركة الحالية"
		response.Error(c, http.StatusBadRequest, "Cannot toggle current status", &msgUser)
		return
	}

	if err := database.DB.Save(&company).Error; err != nil {
		msgUser := "فشل في تحديث الحالة"
		response.Error(c, http.StatusInternalServerError, "Failed to toggle status", &msgUser)
		return
	}

	// Notify superusers about the status toggle
	notifsvc.SendCompanyUpdateNotification(company)

	response.Success(c, http.StatusOK, "Status toggled successfully", map[string]interface{}{
		"id":     company.ID,
		"status": company.Status,
	})
}
