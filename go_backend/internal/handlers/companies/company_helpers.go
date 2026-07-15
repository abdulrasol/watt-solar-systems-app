package companies

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// BuildCompanyMemberSummary builds the company summary dictionary like Django
func BuildCompanyMemberSummary(company *models.Company, member *models.CompanyMember) map[string]interface{} {
	cityOut := SerializeCity(company.City)
	currencyOut := SerializeCurrency(company.Currency)

	companyOut := models.CompanyOut{
		ID:          company.ID,
		Name:        company.Name,
		Description: company.Description,
		Address:     company.Address,
		Phone:       &company.Phone,
		AllowsB2B:   company.AllowsB2B,
		AllowsB2C:   company.AllowsB2C,
		Status:      company.Status,
		LogoURL:     company.Logo,
		City:        cityOut,
		Currency:    currencyOut,
		CreatedAt:   &company.CreatedAt,
		UpdatedAt:   &company.UpdatedAt,
	}

	if company.CompanyType != nil {
		companyOut.Type = &company.CompanyType.CType
		companyOut.TypeName = &company.CompanyType.Name
		companyOut.AllowedFeatures = company.CompanyType.GetCompanyAllowedServices()
	}

	if company.SubscriptionPlanID != nil {
		companyOut.SubscriptionPlanID = company.SubscriptionPlanID
	}
	if company.HasValidSubscription() {
		expireDate := company.ExpireDate
		companyOut.ExpireDate = &expireDate
	}
	companyOut.Services = GetCompanyServicesStatus(company)

	var categories []map[string]interface{}
	for _, cat := range company.Categories {
		categories = append(categories, map[string]interface{}{
			"id":   cat.ID,
			"name": cat.Name,
		})
	}

	var contacts []map[string]interface{}
	for _, contact := range company.Contacts {
		contacts = append(contacts, map[string]interface{}{
			"id":         contact.ID,
			"name":       contact.Name,
			"email":      contact.Email,
			"phone":      contact.Phone,
			"notes":      contact.Notes,
			"company":    contact.CompanyID,
			"created_at": contact.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var deliveryOptions []map[string]interface{}
	for _, opt := range company.DeliveryOptions {
		deliveryOptions = append(deliveryOptions, map[string]interface{}{
			"id":                 opt.ID,
			"name":               opt.Name,
			"cost":               opt.Cost,
			"estimated_days_min": opt.EstimatedDaysMin,
			"estimated_days_max": opt.EstimatedDaysMax,
			"description":        opt.Description,
			"is_active":          opt.IsActive,
			"company":            opt.CompanyID,
			"created_at":         opt.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var publicServices []map[string]interface{}
	for _, srv := range company.PublicServices {
		publicServices = append(publicServices, map[string]interface{}{
			"id":          srv.ID,
			"title":       srv.Title,
			"price":       srv.Price,
			"description": srv.Description,
			"company":     srv.CompanyID,
			"created_at":  srv.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at":  srv.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var membersCount, expensesCount, financialTransactionsCount, deliveryOptionsCount, contactsCount int64
	database.DB.Model(&models.CompanyMember{}).Where("company_id = ?", company.ID).Count(&membersCount)
	database.DB.Model(&models.Expense{}).Where("company_id = ?", company.ID).Count(&expensesCount)
	database.DB.Model(&models.FinancialTransaction{}).Where("company_id = ?", company.ID).Count(&financialTransactionsCount)
	database.DB.Model(&models.DeliveryOption{}).Where("company_id = ?", company.ID).Count(&deliveryOptionsCount)
	database.DB.Model(&models.Contact{}).Where("company_id = ?", company.ID).Count(&contactsCount)

	payload := map[string]interface{}{
		"id":                         companyOut.ID,
		"name":                       companyOut.Name,
		"type":                       companyOut.Type,
		"type_name":                  companyOut.TypeName,
		"allowed_features":           companyOut.AllowedFeatures,
		"description":                companyOut.Description,
		"address":                    companyOut.Address,
		"phone":                      companyOut.Phone,
		"allows_b2b":                 companyOut.AllowsB2B,
		"allows_b2c":                 companyOut.AllowsB2C,
		"status":                     companyOut.Status,
		"logo":                       companyOut.LogoURL,
		"logo_url":                   companyOut.LogoURL,
		"city":                       companyOut.City,
		"currency":                   companyOut.Currency,
		"subscription_plan":          companyOut.SubscriptionPlanID,
		"subscription_is_valid":      company.HasValidSubscription(),
		"expire_date":                nil,
		"created_at":                 companyOut.CreatedAt,
		"updated_at":                 companyOut.UpdatedAt,
		"service_types":              []interface{}{},
		"categories":                 categories,
		"contacts":                   contacts,
		"delivery_options":           deliveryOptions,
		"public_services":            publicServices,
		"member_role":                member.Role,
		"permissions":                member.Permissions,
		"activation_reminder_active": false,
		"services":                   companyOut.Services,
		"stats": map[string]interface{}{
			"members":                membersCount,
			"orders":                 0,
			"my_purchases":           0,
			"offers":                 0,
			"customers":              0,
			"systems":                0,
			"contacts":               contactsCount,
			"financial_transactions": financialTransactionsCount,
			"delivery_options":       deliveryOptionsCount,
			"expenses":               expensesCount,
			"products":               0,
		},
	}

	if company.HasValidSubscription() {
		expireDate := company.ExpireDate
		payload["expire_date"] = expireDate.Format("2006-01-02T15:04:05Z07:00")
	}

	return payload
}

// SerializeCity converts a City model to CityOut
func SerializeCity(city *models.City) *models.CityOut {
	if city == nil {
		return nil
	}
	return &models.CityOut{
		ID:   city.ID,
		Name: city.Name,
		Code: city.Code,
	}
}

// SerializeCurrency converts a Currency model to CurrencyOut
func SerializeCurrency(currency *models.Currency) *models.CurrencyOut {
	if currency == nil {
		return nil
	}
	return &models.CurrencyOut{
		ID:        currency.ID,
		Name:      currency.Name,
		Code:      currency.Code,
		Symbol:    currency.Symbol,
		IsDefault: currency.IsDefault,
		CreatedAt: currency.CreatedAt,
	}
}

// SerializeCountry converts a Country model to CountryOut
func SerializeCountry(country *models.Country) *models.CountryOut {
	if country == nil {
		return nil
	}
	return &models.CountryOut{
		ID:   country.ID,
		Name: country.Name,
		Code: country.Code,
	}
}

// SerializeCompanyType converts a CompanyType model to a map.
func SerializeCompanyType(companyType *models.CompanyType) map[string]interface{} {
	if companyType == nil {
		return nil
	}

	var allowedPlans []map[string]interface{}
	for _, p := range companyType.AllowedSubscriptionPlans {
		allowedPlans = append(allowedPlans, map[string]interface{}{
			"id":   p.ID,
			"name": p.Name,
		})
	}

	return map[string]interface{}{
		"id":                         companyType.ID,
		"code":                       companyType.CType,
		"name":                       companyType.Name,
		"allowed_features":           companyType.GetCompanyAllowedServices(),
		"allowed_subscription_plans": allowedPlans,
	}
}

// SerializeServiceType converts a ServiceType model to a map.
func SerializeServiceType(st *models.ServiceType, company *models.Company) map[string]interface{} {
	return map[string]interface{}{
		"id":          st.ID,
		"name":        st.Name,
		"description": st.Description,
		"image":       st.Image,
	}
}

// SerializeServiceTypes converts a slice of ServiceType models.
func SerializeServiceTypes(serviceTypes []*models.ServiceType, company *models.Company) []map[string]interface{} {
	result := make([]map[string]interface{}, 0, len(serviceTypes))
	for _, st := range serviceTypes {
		result = append(result, SerializeServiceType(st, company))
	}
	return result
}

// IsCompanyPubliclyVisible checks if a company is publicly visible for the given channel (b2b/b2c).
// Conditions (matching Django):
// 1. status == active
// 2. has valid subscription
// 3. company_type allows the channel's storefront service
// 4. company allows the requested channel (allows_b2b / allows_b2c)
func IsCompanyPubliclyVisible(company *models.Company, channel string) bool {
	if company == nil || company.Status != "active" {
		return false
	}
	if !company.HasValidSubscription() {
		return false
	}

	if channel == "b2b" && !company.AllowsB2B {
		return false
	}
	if channel == "b2c" && !company.AllowsB2C {
		return false
	}

	if company.CompanyType != nil {
		for _, f := range company.CompanyType.GetCompanyAllowedServices() {
			if f == "store" {
				return true
			}
		}
	}

	return false
}

// GetCompanyServicesStatus returns the available services for a company.
// Logic:
// 1. Get allowed features from CompanyType.AllowedFeatures
// 2. Get disabled_services from SubscriptionPlan.Features
// 3. Return: allowed services minus disabled ones, each with status
func GetCompanyServicesStatus(company *models.Company) []map[string]interface{} {
	if company.CompanyTypeID == nil {
		return []map[string]interface{}{}
	}

	allowedFeatures := company.CompanyType.GetCompanyAllowedServices()
	if len(allowedFeatures) == 0 {
		return []map[string]interface{}{}
	}

	// Build disabled set from subscription plan features.disabled_services
	disabledSet := make(map[string]bool)
	if company.SubscriptionPlan != nil && company.SubscriptionPlan.Features != nil {
		var featData struct {
			DisabledServices []string `json:"disabled_services"`
		}
		if err := json.Unmarshal(company.SubscriptionPlan.Features, &featData); err == nil {
			for _, d := range featData.DisabledServices {
				disabledSet[d] = true
			}
		}
	}

	hasValidSub := company.HasValidSubscription()
	result := make([]map[string]interface{}, 0)

	for _, svcCode := range allowedFeatures {
		svc := models.GetServiceByName(svcCode)
		if svc == nil {
			continue
		}

		isDisabled := disabledSet[svcCode]
		status := "active"
		if isDisabled || !hasValidSub {
			status = "inactive"
		}

		result = append(result, map[string]interface{}{
			"service_code": svc.Code,
			"service_name": svc.Name,
			"status":       status,
			"route":        svc.Code,
		})
	}
	return result
}

func formatTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format("2006-01-02T15:04:05Z07:00")
	return &s
}

// GetCompanyFromContext retrieves the company and member from gin context.
// Returns false if member is missing; sends an error response.
func GetCompanyFromContext(c *gin.Context) (*models.Company, *models.CompanyMember, bool) {
	memberInterface, exists := c.Get("company_member")
	if !exists {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return nil, nil, false
	}

	member := memberInterface.(*models.CompanyMember)

	var company models.Company
	if err := database.DB.First(&company, member.CompanyID).Error; err != nil {
		msgUser := "الشركة غير موجودة"
		response.Error(c, http.StatusNotFound, "Company not found", &msgUser)
		return nil, nil, false
	}

	return &company, member, true
}

// GetUserIDFromContext returns the user_id from context.
func GetUserIDFromContext(c *gin.Context) (uint, bool) {
	userID, exists := c.Get("user_id")
	if !exists {
		return 0, false
	}
	return userID.(uint), true
}

// SerializeCompanyCategories converts a slice of CompanyCategory models.
func SerializeCompanyCategories(categories []models.CompanyCategory) []map[string]interface{} {
	result := make([]map[string]interface{}, 0, len(categories))
	for _, cat := range categories {
		result = append(result, map[string]interface{}{
			"id":         cat.ID,
			"name":       cat.Name,
			"company":    cat.CompanyID,
			"created_at": cat.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	return result
}

// SerializeDeliveryOptions converts a slice of DeliveryOption models.
func SerializeDeliveryOptions(options []models.DeliveryOption) []map[string]interface{} {
	result := make([]map[string]interface{}, 0, len(options))
	for _, opt := range options {
		result = append(result, map[string]interface{}{
			"id":                 opt.ID,
			"name":               opt.Name,
			"cost":               opt.Cost,
			"estimated_days_min": opt.EstimatedDaysMin,
			"estimated_days_max": opt.EstimatedDaysMax,
			"description":        opt.Description,
			"is_active":          opt.IsActive,
			"company":            opt.CompanyID,
			"created_at":         opt.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	return result
}

// SerializeContacts converts a slice of Contact models.
func SerializeContacts(contacts []models.Contact) []map[string]interface{} {
	result := make([]map[string]interface{}, 0, len(contacts))
	for _, contact := range contacts {
		result = append(result, map[string]interface{}{
			"id":         contact.ID,
			"name":       contact.Name,
			"email":      contact.Email,
			"phone":      contact.Phone,
			"notes":      contact.Notes,
			"company":    contact.CompanyID,
			"created_at": contact.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	return result
}

// SerializePublicServices converts a slice of CompanyService models.
func SerializePublicServices(services []models.CompanyService) []map[string]interface{} {
	result := make([]map[string]interface{}, 0, len(services))
	for _, srv := range services {
		result = append(result, map[string]interface{}{
			"id":          srv.ID,
			"title":       srv.Title,
			"price":       srv.Price,
			"description": srv.Description,
			"company":     srv.CompanyID,
			"created_at":  srv.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at":  srv.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	return result
}

// SerializePoster converts a Poster model to Django-like map
func SerializePoster(poster *models.Poster) map[string]interface{} {
	companyName := ""
	if poster.Company.Name != "" {
		companyName = poster.Company.Name
	}

	return map[string]interface{}{
		"id":            poster.ID,
		"company_id":    poster.CompanyID,
		"company_name":  companyName,
		"image_url":     poster.Image,
		"text":          poster.Text,
		"action_type":   poster.ActionType,
		"action_id":     poster.ActionID,
		"status":        poster.Status,
		"is_active":     poster.IsActive,
		"duration_days": poster.DurationDays,
		"approved_at":   formatTime(poster.ApprovedAt),
		"expires_at":    formatTime(poster.ExpiresAt),
		"created_at":    poster.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":    poster.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

// SerializeCompanyForAdmin returns a Django-like company object for admin responses.
func SerializeCompanyForAdmin(company *models.Company) map[string]interface{} {
	cityOut := SerializeCity(company.City)
	currencyOut := SerializeCurrency(company.Currency)

	expireDate := interface{}(nil)
	if company.HasValidSubscription() {
		t := company.ExpireDate.Format("2006-01-02T15:04:05Z07:00")
		expireDate = t
	}

	subPlanID := interface{}(nil)
	if company.SubscriptionPlanID != nil {
		subPlanID = *company.SubscriptionPlanID
	}

	cTypeName := ""
	cTypeCode := ""
	if company.CompanyType != nil {
		cTypeCode = company.CompanyType.CType
		cTypeName = company.CompanyType.Name
	}

	return map[string]interface{}{
		"id":                    company.ID,
		"name":                  company.Name,
		"type":                  cTypeCode,
		"type_name":             cTypeName,
		"allowed_features":      company.CompanyType.GetCompanyAllowedServices(),
		"service_types":         []interface{}{},
		"description":           company.Description,
		"address":               company.Address,
		"phone":                 company.Phone,
		"allows_b2b":            company.AllowsB2B,
		"allows_b2c":            company.AllowsB2C,
		"status":                company.Status,
		"logo":                  company.Logo,
		"logo_url":              company.Logo,
		"city":                  cityOut,
		"currency":              currencyOut,
		"subscription_plan":     subPlanID,
		"subscription_is_valid": company.HasValidSubscription(),
		"expire_date":           expireDate,
		"created_at":            company.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":            company.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"services":              GetCompanyServicesStatus(company),
	}
}

// SerializePublicCompany returns a Django-like public company object.
func SerializePublicCompany(company *models.Company) map[string]interface{} {
	var contacts []map[string]interface{}
	for _, contact := range company.Contacts {
		contacts = append(contacts, map[string]interface{}{
			"id":         contact.ID,
			"name":       contact.Name,
			"email":      contact.Email,
			"phone":      contact.Phone,
			"notes":      contact.Notes,
			"company":    contact.CompanyID,
			"created_at": contact.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var deliveryOptions []map[string]interface{}
	for _, opt := range company.DeliveryOptions {
		if !opt.IsActive {
			continue
		}
		deliveryOptions = append(deliveryOptions, map[string]interface{}{
			"id":                 opt.ID,
			"name":               opt.Name,
			"cost":               opt.Cost,
			"estimated_days_min": opt.EstimatedDaysMin,
			"estimated_days_max": opt.EstimatedDaysMax,
			"description":        opt.Description,
			"is_active":          opt.IsActive,
			"company":            opt.CompanyID,
			"created_at":         opt.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var publicServices []map[string]interface{}
	for _, srv := range company.PublicServices {
		publicServices = append(publicServices, map[string]interface{}{
			"id":          srv.ID,
			"title":       srv.Title,
			"price":       srv.Price,
			"description": srv.Description,
			"company":     srv.CompanyID,
			"created_at":  srv.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at":  srv.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	expireDate := interface{}(nil)
	if company.HasValidSubscription() {
		expireDate = company.ExpireDate.Format("2006-01-02T15:04:05Z07:00")
	}

	return map[string]interface{}{
		"id":                    company.ID,
		"name":                  company.Name,
		"description":           company.Description,
		"logo":                  company.Logo,
		"logo_url":              company.Logo,
		"address":               company.Address,
		"phone":                 company.Phone,
		"allows_b2b":            company.AllowsB2B,
		"allows_b2c":            company.AllowsB2C,
		"company_type":          SerializeCompanyType(company.CompanyType),
		"service_types":         []interface{}{},
		"city":                  SerializeCity(company.City),
		"currency":              SerializeCurrency(company.Currency),
		"contacts":              contacts,
		"delivery_options":      deliveryOptions,
		"public_services":       publicServices,
		"services":              GetCompanyServicesStatus(company),
		"subscription_is_valid": company.HasValidSubscription(),
		"expire_date":           expireDate,
	}
}
