package companies

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// AdminListCompanies handles GET /api/v1/admin/companies
// @Accept json
// @Produce json
// @Security Bearer
// @Summary AdminListCompanies
// @Description AdminListCompanies
// @Tags Admin Companies API
// @Param page query int false "Page number" default(1)
// @Param page_size query int false "Page size" default(12)
// @Param status query string false "Status filter"
// @Param search query string false "Search"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies [get]
func AdminListCompanies(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "12"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}

	status := c.Query("status")
	search := c.Query("search")

	offset := (page - 1) * pageSize
	var comps []models.Company
	var total int64

	query := database.DB.Model(&models.Company{}).
		Preload("CompanyType").
		Preload("City").
		Preload("Currency")

	if status != "" {
		query = query.Where("status = ?", status)
	}
	if search != "" {
		like := "%" + search + "%"
		query = query.Where("name LIKE ? OR phone LIKE ?", like, like)
	}

	query.Count(&total)
	if err := query.Offset(offset).Limit(pageSize).Order("created_at desc").Find(&comps).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch companies", nil)
		return
	}

	items := make([]map[string]interface{}, 0, len(comps))
	for _, comp := range comps {
		items = append(items, SerializeCompanyForAdmin(&comp))
	}

	totalPages := (int(total) + pageSize - 1) / pageSize

	response.Success(c, http.StatusOK, "Companies fetched successfully", map[string]interface{}{
		"items": items,
		"pagination": map[string]interface{}{
			"page":        page,
			"page_size":   pageSize,
			"total_items": total,
			"total_pages": totalPages,
		},
	})
}

// AdminGetCompany handles GET /api/v1/admin/companies/:company_id
// @Summary AdminGetCompany
// @Description Get company details for admin
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id} [get]
func AdminGetCompany(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		Preload("City").
		Preload("Currency").
		// Preload("ServiceTypes") -- removed.
		Preload("Categories").
		Preload("Contacts").
		Preload("DeliveryOptions").
		Preload("PublicServices").
		Preload("Members.User").
		First(&comp, id).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Company fetched successfully", SerializeCompanyForAdmin(&comp))
}

// AdminGetCompanyServices handles GET /api/v1/admin/companies/:company_id/services
// @Summary AdminGetCompanyServices
// @Description Get service catalog status for admin
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/services [get]
func AdminGetCompanyServices(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		// Preload("ServiceTypes") -- removed.
		First(&comp, id).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Services fetched successfully", GetCompanyServicesStatus(&comp))
}

// AdminGetCompanyDetails handles GET /api/v1/admin/companies/:company_id/details
// @Summary AdminGetCompanyDetails
// @Description Get detailed company information for admin
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/details [get]
func AdminGetCompanyDetails(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		Preload("City").
		Preload("City.Country").
		Preload("Currency").
		// Preload("ServiceTypes") -- removed.
		Preload("Categories").
		Preload("DeliveryOptions").
		Preload("Contacts").
		Preload("PublicServices").
		Preload("Members.User").
		Preload("Expenses").
		Preload("FinancialTransactions").
		First(&comp, id).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	var expenses []map[string]interface{}
	for _, e := range comp.Expenses {
		expenses = append(expenses, map[string]interface{}{
			"id":          e.ID,
			"amount":      e.Amount,
			"category":    e.Category,
			"description": e.Description,
			"date":        e.Date.Format("2006-01-02"),
			"created_at":  e.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var transactions []map[string]interface{}
	for _, t := range comp.FinancialTransactions {
		transactions = append(transactions, map[string]interface{}{
			"id":             t.ID,
			"type":           t.Type,
			"category":       t.Category,
			"amount":         t.Amount,
			"description":    t.Description,
			"payment_method": t.PaymentMethod,
			"date":           t.Date.Format("2006-01-02"),
			"created_at":     t.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var members []map[string]interface{}
	for _, m := range comp.Members {
		members = append(members, map[string]interface{}{
			"id":       m.ID,
			"username": m.User.Username,
			"email":    m.User.Email,
			"role":     m.Role,
		})
	}

	response.Success(c, http.StatusOK, "Company details fetched successfully", map[string]interface{}{
		"company":          SerializeCompanyForAdmin(&comp),
		"categories":       SerializeCompanyCategories(comp.Categories),
		"delivery_options": SerializeDeliveryOptions(comp.DeliveryOptions),
		"contacts":         SerializeContacts(comp.Contacts),
		"public_services":  SerializePublicServices(comp.PublicServices),
		"financials": map[string]interface{}{
			"expenses":     expenses,
			"transactions": transactions,
		},
		"services": GetCompanyServicesStatus(&comp),
		"members":  members,
	})
}

// AdminListAdminPosters handles GET /api/v1/admin/companies/posters
// @Summary AdminListAdminPosters
// @Description List all posters globally for admin moderation
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param status query string false "Status"
// @Param search query string false "Search"
// @Param validity query string false "active|expired"
// @Param page query int false "Page"
// @Param page_size query int false "Page size"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/posters [get]
func AdminListAdminPosters(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "12"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}

	status := c.Query("status")
	search := c.Query("search")
	validity := c.Query("validity")

	offset := (page - 1) * pageSize
	var posters []models.Poster
	var total int64

	query := database.DB.Model(&models.Poster{}).Preload("Company")

	if status != "" {
		query = query.Where("status = ?", status)
	}
	if search != "" {
		like := "%" + search + "%"
		query = query.Joins("JOIN companies c ON posters.company_id = c.id").
			Where("c.name LIKE ? OR posters.text LIKE ?", like, like)
	}
	now := time.Now()
	switch validity {
	case "active":
		query = query.Where("is_active = ? AND (expires_at IS NULL OR expires_at > ?)", true, now)
	case "expired":
		query = query.Where("is_active = ? OR expires_at <= ?", false, now)
	}

	query.Count(&total)
	if err := query.Order("CASE WHEN status = 'pending' THEN 0 ELSE 1 END, created_at desc").
		Limit(pageSize).Offset(offset).Find(&posters).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الإعلانات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch posters", &msgUser)
		return
	}

	items := make([]map[string]interface{}, 0, len(posters))
	for _, p := range posters {
		items = append(items, SerializePoster(&p))
	}

	totalPages := (int(total) + pageSize - 1) / pageSize

	response.Success(c, http.StatusOK, "Posters fetched successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
		"pagination": map[string]interface{}{
			"page":        page,
			"page_size":   pageSize,
			"total_items": total,
			"total_pages": totalPages,
		},
	})
}

// AdminGetCompanyMembers handles GET /api/v1/admin/companies/:company_id/members
// @Summary AdminGetCompanyMembers
// @Description Get company members for admin
// @Tags Admin Companies API
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/members [get]
func AdminGetCompanyMembers(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	var members []models.CompanyMember
	if err := database.DB.Where("company_id = ?", id).Preload("User").Find(&members).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب الأعضاء"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch members", &msgUser)
		return
	}

	items := make([]map[string]interface{}, 0, len(members))
	for _, m := range members {
		items = append(items, map[string]interface{}{
			"id":          m.ID,
			"user_id":     m.UserID,
			"username":    m.User.Username,
			"email":       m.User.Email,
			"role":        m.Role,
			"permissions": m.Permissions,
			"joined_at":   m.JoinedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Members fetched successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// AdminUpdateCompanyStatus handles POST /api/v1/admin/companies/{company_id}/status
// @Accept json
// @Produce json
// @Param request body models.CompanyStatusActionSchema true "Status Action"
// @Security Bearer
// @Summary AdminUpdateCompanyStatus
// @Description AdminUpdateCompanyStatus
// @Tags Admin Companies API
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/status [post]
func AdminUpdateCompanyStatus(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	var payload struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	allowedStatuses := map[string]bool{"pending": true, "active": true, "inactive": true, "rejected": true}
	if !allowedStatuses[payload.Status] {
		msgUser := "حالة غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid status", &msgUser)
		return
	}

	var comp models.Company
	if err := database.DB.Where("id = ?", id).First(&comp).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	comp.Status = payload.Status

	if err := database.DB.Save(&comp).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update status", nil)
		return
	}

	response.Success(c, http.StatusOK, "Company status updated successfully.", map[string]interface{}{
		"id":     comp.ID,
		"status": comp.Status,
	})
}

// AdminReviewSubscriptionRequest handles POST /api/v1/admin/companies/:company_id/subscription-requests/:request_id/review
// @Summary AdminReviewSubscriptionRequest
// @Description Review a company's subscription request (active/rejected)
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Param request_id path int true "request_id"
// @Param request body models.CompanySubscriptionRequestReviewSchema true "Review payload"
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/{company_id}/subscription-requests/{request_id}/review [post]
func AdminReviewSubscriptionRequest(c *gin.Context) {
	companyID, err := strconv.Atoi(c.Param("company_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid company ID", nil)
		return
	}
	requestID, err := strconv.Atoi(c.Param("request_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request ID", nil)
		return
	}

	var payload models.CompanySubscriptionRequestReviewSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	if payload.Status != "active" && payload.Status != "rejected" {
		response.Error(c, http.StatusBadRequest, "Status must be active or rejected", nil)
		return
	}

	var req models.CompanySubscriptionRequest
	if err := database.DB.Preload("Company").Preload("SubscriptionPlan").First(&req, requestID).Error; err != nil || req.CompanyID != uint(companyID) {
		msgUser := "طلب الاشتراك غير موجود"
		response.Error(c, http.StatusNotFound, "Subscription request not found", &msgUser)
		return
	}

	var company models.Company
	if err := database.DB.First(&company, companyID).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	notes := ""
	if payload.Notes != nil {
		notes = *payload.Notes
	}

	var effectiveStart, resultingExpiry *time.Time
	if payload.Status == "active" {
		now := time.Now()
		start := now
		if company.ExpireDate.After(now) {
			start = company.ExpireDate
		}
		expiry := start.AddDate(0, 0, req.SubscriptionPlan.DurationDays)
		effectiveStart = &start
		resultingExpiry = &expiry

		company.SubscriptionPlanID = &req.SubscriptionPlanID
		company.SubscriptionStartDate = effectiveStart
		company.ExpireDate = expiry
		company.Status = "active"
		if err := database.DB.Save(&company).Error; err != nil {
			response.Error(c, http.StatusInternalServerError, "Failed to activate subscription", nil)
			return
		}
	}

	notifsvc.SendCompanySubscriptionRequestReviewNotification(&company, &req.SubscriptionPlan, payload.Status, notes, effectiveStart, resultingExpiry)

	database.DB.Delete(&req)

	response.Success(c, http.StatusOK, "Subscription request reviewed successfully", map[string]interface{}{
		"status":           payload.Status,
		"effective_start":  formatTimePtr(effectiveStart),
		"resulting_expiry": formatTimePtr(resultingExpiry),
	})
}

func formatTimePtr(t *time.Time) interface{} {
	if t == nil {
		return nil
	}
	return t.Format(time.RFC3339)
}



// AdminListSubscriptionRequests handles GET /api/v1/admin/companies/subscription-requests
// @Summary AdminListSubscriptionRequests
// @Description List all subscription requests
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param page query int false "page"
// @Param page_size query int false "page_size"
// @Param status query string false "status (pending, active, rejected)"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/subscription-requests [get]
func AdminListSubscriptionRequests(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "12"))
	status := c.Query("status")

	query := database.DB.Model(&models.CompanySubscriptionRequest{})

	if status != "" {
		query = query.Where("status = ?", status)
	}

	var count int64
	query.Count(&count)

	var requests []models.CompanySubscriptionRequest
	offset := (page - 1) * pageSize

	if err := query.Preload("Company").
		Preload("SubscriptionPlan").
		Preload("RequestedBy").
		Order("created_at desc").
		Limit(pageSize).
		Offset(offset).
		Find(&requests).Error; err != nil {
		msgUser := "خطأ أثناء جلب طلبات الاشتراك"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch subscription requests", &msgUser)
		return
	}

	var out []models.CompanySubscriptionRequestOut
	for _, r := range requests {
		reqOut := models.CompanySubscriptionRequestOut{
			ID:                   r.ID,
			CompanyID:            r.CompanyID,
			CompanyName:          r.Company.Name,
			SubscriptionPlanID:   r.SubscriptionPlanID,
			SubscriptionPlanName: r.SubscriptionPlan.Name,
			Status:               r.Status,
			Notes:                nil,
			Image:                r.Image,
			CreatedAt:            r.CreatedAt,
		}

		if r.Notes != "" {
			reqOut.Notes = &r.Notes
		}

		if r.RequestedBy != nil {
			var fullName string
			if r.RequestedBy.FirstName != "" {
				fullName += r.RequestedBy.FirstName
			}
			if r.RequestedBy.LastName != "" {
				if fullName != "" {
					fullName += " "
				}
				fullName += r.RequestedBy.LastName
			}
			if fullName == "" {
				fullName = r.RequestedBy.Phone
			}
			reqOut.RequestedBy = &fullName
		}

		out = append(out, reqOut)
	}

	paginationData := map[string]interface{}{
		"items":     out,
		"page":      page,
		"page_size": pageSize,
		"count":     count,
	}

	response.Success(c, http.StatusOK, "Subscription requests retrieved successfully", paginationData)
}
