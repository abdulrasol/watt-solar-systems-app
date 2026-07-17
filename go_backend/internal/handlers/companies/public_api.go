package companies

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

// PublicListCompanies handles GET /api/v1/public/companies/
// @Summary PublicListCompanies
// @Description PublicListCompanies
// @Tags Public Companies API
// @Param page query int false "Page"
// @Param search query string false "Search"
// @Param type query string false "Company type code"
// @Param company_type query string false "Company type code"
// @Param city query int false "City ID"
// @Param channel query string false "Channel: b2b|b2c"
// @Param services query []int false "Service type IDs"
// @Param allows_b2b query bool false "Allows B2B"
// @Param allows_b2c query bool false "Allows B2C"
// @Param has_active_subscription query bool false "Has active subscription"
// @Success 200 {object} response.APIResponse
// @Router /public/companies/ [get]
func PublicListCompanies(c *gin.Context) {
	pageStr := c.DefaultQuery("page", "1")
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}
	pageSize := 12

	offset := (page - 1) * pageSize

	channel := c.DefaultQuery("channel", "b2c")
	if channel != "b2b" && channel != "b2c" {
		channel = "b2c"
	}

	search := c.Query("search")
	companyType := c.Query("type")
	if companyType == "" {
		companyType = c.Query("company_type")
	}
	cityStr := c.Query("city")
	allowsB2BStr := c.Query("allows_b2b")
	allowsB2CStr := c.Query("allows_b2c")
	hasActiveSubStr := c.Query("has_active_subscription")
	servicesQuery := c.QueryArray("services")

	// Load companies with required relationships
	var companies []models.Company
	query := database.DB.
		Preload("CompanyType").
		Preload("City").
		// Preload("ServiceTypes") -- removed, field no longer exists.
		Preload("SubscriptionPlan").
		Where("status = ?", "active")

	if search != "" {
		like := "%" + search + "%"
		query = query.Where("name LIKE ? OR description LIKE ?", like, like)
	}

	if companyType != "" {
		query = query.Joins("JOIN company_types ct ON companies.company_type_id = ct.id").
			Where("ct.ctype = ?", companyType)
	}

	if cityStr != "" {
		if cityID, err := strconv.Atoi(cityStr); err == nil {
			query = query.Where("companies.city_id = ?", cityID)
		}
	}

	if allowsB2BStr != "" {
		if val, err := strconv.ParseBool(allowsB2BStr); err == nil {
			query = query.Where("companies.allows_b2b = ?", val)
		}
	}

	if allowsB2CStr != "" {
		if val, err := strconv.ParseBool(allowsB2CStr); err == nil {
			query = query.Where("companies.allows_b2c = ?", val)
		}
	}

	if hasActiveSubStr != "" {
		if val, err := strconv.ParseBool(hasActiveSubStr); err == nil {
			if val {
				query = query.Where("companies.expire_date > ?", time.Now())
			}
		}
	}

	if len(servicesQuery) > 0 {
		var ids []uint
		for _, s := range servicesQuery {
			if id, err := strconv.ParseUint(s, 10, 64); err == nil {
				ids = append(ids, uint(id))
			}
		}
		if len(ids) > 0 {
			query = query.Joins("JOIN company_service_types cst ON cst.company_id = companies.id").
				Where("cst.service_type_id IN ?", ids)
		}
	}

	var totalItems int64
	countQuery := query.Session(&gorm.Session{})
	countQuery.Model(&models.Company{}).Count(&totalItems)

	if err := query.Limit(pageSize).Offset(offset).Order("companies.created_at desc").Find(&companies).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch companies", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	data := make([]map[string]interface{}, 0)
	for _, comp := range companies {
		if !IsCompanyPubliclyVisible(&comp, channel) {
			continue
		}
		data = append(data, SerializePublicCompany(&comp, baseURL))
	}

	// Adjust totalItems for visibility-filtered results if needed.
	// Django returns count before visibility filtering? We'll keep raw count.
	totalPages := (int(totalItems) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}

	response.Success(c, http.StatusOK, "Public companies retrieved successfully.", map[string]interface{}{
		"items":          data,
		"total":          totalItems,
		"page":           page,
		"pages":          totalPages,
		"has_next":       page < totalPages,
		"has_previous":   page > 1,
	})
}

// PublicListPosters handles GET /api/v1/public/companies/posters
// @Summary PublicListPosters
// @Description PublicListPosters
// @Tags Public Companies API
// @Success 200 {object} response.APIResponse
// @Router /public/companies/posters [get]
func PublicListPosters(c *gin.Context) {
	var posters []models.Poster
	if err := database.DB.Preload("Company").Where("status = ?", "approved").Where("is_active = ?", true).Order("created_at desc").Find(&posters).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch posters", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	data := make([]map[string]interface{}, 0, len(posters))
	for _, p := range posters {
		var companyName string
		if p.Company.ID != 0 {
			companyName = p.Company.Name
		}
		approvedAt := ""
		if p.ApprovedAt != nil {
			approvedAt = p.ApprovedAt.Format("2006-01-02T15:04:05Z07:00")
		}
		expiresAt := ""
		if p.ExpiresAt != nil {
			expiresAt = p.ExpiresAt.Format("2006-01-02T15:04:05Z07:00")
		}
		data = append(data, map[string]interface{}{
			"id":            p.ID,
			"company_id":    p.CompanyID,
			"company_name":  companyName,
			"image_url":     utils.ResolveMediaURL(baseURL, p.Image),
			"text":          p.Text,
			"action_type":   p.ActionType,
			"action_id":     p.ActionID,
			"status":        p.Status,
			"is_active":     p.IsActive,
			"duration_days": p.DurationDays,
			"approved_at":   approvedAt,
			"expires_at":    expiresAt,
			"created_at":    p.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at":    p.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	c.JSON(http.StatusOK, data)
}

// PublicGetCompany handles GET /api/v1/public/companies/{company_id}
// @Summary PublicGetCompany
// @Description PublicGetCompany
// @Tags Public Companies API
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /public/companies/{company_id} [get]
func PublicGetCompany(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	channel := c.DefaultQuery("channel", "b2c")
	if channel != "b2b" && channel != "b2c" {
		channel = "b2c"
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		Preload("City").
		Preload("Currency").
		// Preload("ServiceTypes") -- removed, field no longer exists.
		Preload("Contacts").
		Preload("DeliveryOptions").
		Preload("PublicServices").
		Preload("SubscriptionPlan").
		Where("id = ?", id).First(&comp).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	if !IsCompanyPubliclyVisible(&comp, channel) {
		msgUser := "الشركة غير متاحة للعرض العام"
		response.Error(c, http.StatusNotFound, "Company not publicly visible", &msgUser)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Company retrieved successfully.", SerializePublicCompany(&comp, baseURL))
}

// PublicListCompanyWorks handles GET /api/v1/public/companies/{company_id}/works
// @Summary PublicListCompanyWorks
// @Description PublicListCompanyWorks
// @Tags Public Companies API
// @Param company_id path int true "company_id"
// @Param page query int false "Page"
// @Success 200 {object} response.APIResponse
// @Router /public/companies/{company_id}/works [get]
func PublicListCompanyWorks(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	channel := c.DefaultQuery("channel", "b2c")
	if channel != "b2b" && channel != "b2c" {
		channel = "b2c"
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		First(&comp, id).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	if !IsCompanyPubliclyVisible(&comp, channel) {
		msgUser := "الشركة غير متاحة للعرض العام"
		response.Error(c, http.StatusNotFound, "Company not publicly visible", &msgUser)
		return
	}

	pageStr := c.DefaultQuery("page", "1")
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		page = 1
	}
	pageSize := 12

	offset := (page - 1) * pageSize

	var works []models.CompanyWork
	query := database.DB.Preload("Images").Where("company_id = ?", id)

	var totalItems int64
	query.Model(&models.CompanyWork{}).Count(&totalItems)

	if err := query.Limit(pageSize).Offset(offset).Order("created_at desc").Find(&works).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch company works", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	items := make([]map[string]interface{}, 0, len(works))
	for _, work := range works {
		images := make([]map[string]interface{}, 0, len(work.Images))
		for _, img := range work.Images {
			images = append(images, map[string]interface{}{
				"id":        img.ID,
				"image_url": utils.ResolveMediaURL(baseURL, img.Image),
			})
		}
		items = append(items, map[string]interface{}{
			"id":         work.ID,
			"title":      work.Title,
			"body":       work.Body,
			"images":     images,
			"company_id": work.CompanyID,
			"created_at": work.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	totalPages := (int(totalItems) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}

	response.Success(c, http.StatusOK, "Public company works retrieved successfully.", map[string]interface{}{
		"items": items,
		"pagination": map[string]interface{}{
			"page":          page,
			"page_size":     pageSize,
			"total_items":   totalItems,
			"total_pages":   totalPages,
			"has_next":      page < totalPages,
			"has_previous":  page > 1,
		},
	})
}

// PublicGetCompanyServices handles GET /api/v1/public/companies/{company_id}/services
// @Summary PublicGetCompanyServices
// @Description Get services catalog for a public company
// @Tags Public Companies API
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /public/companies/{company_id}/services [get]
func PublicGetCompanyServices(c *gin.Context) {
	idStr := c.Param("company_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Company ID", nil)
		return
	}

	channel := c.DefaultQuery("channel", "b2c")
	if channel != "b2b" && channel != "b2c" {
		channel = "b2c"
	}

	var comp models.Company
	if err := database.DB.
		Preload("CompanyType").
		// Preload("ServiceTypes") -- removed, field no longer exists.
		First(&comp, id).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return
	}

	if !IsCompanyPubliclyVisible(&comp, channel) {
		msgUser := "الشركة غير متاحة للعرض العام"
		response.Error(c, http.StatusNotFound, "Company not publicly visible", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Services retrieved successfully.", GetCompanyServicesStatus(&comp))
}

