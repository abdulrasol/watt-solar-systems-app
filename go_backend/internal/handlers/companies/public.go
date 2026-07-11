package companies

import (
	"fmt"
	"log"
	"encoding/json"
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// RegisterCompany handles POST /api/companies/register
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Name"
// @Param company_type formData int true "Company Type ID"
// @Param description formData string false "Description"
// @Param address formData string false "Address"
// @Param phone formData string false "Phone"
// @Param allows_b2b formData bool false "Allows B2B"
// @Param allows_b2c formData bool false "Allows B2C"
// @Param city formData int false "City ID"
// @Param image formData file false "Logo"
// @Security Bearer
// @Summary RegisterCompany
// @Description RegisterCompany
// @Tags Companies
// @Success 200 {object} response.APIResponse
// @Router /companies/register [post]
func RegisterCompany(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		msgUser := "الرجاء تسجيل الدخول"
		response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
		return
	}

	var data models.CompanyRegisterSchema
	if err := c.ShouldBind(&data); err != nil {
		msgUser := "البيانات المرسلة غير صحيحة"
		response.Error(c, http.StatusBadRequest, err.Error(), &msgUser)
		return
	}

	// Fetch company type
	var companyType models.CompanyType
	if err := database.DB.First(&companyType, data.CompanyType).Error; err != nil {
		msgUser := "نوع الشركة غير موجود"
		response.Error(c, http.StatusBadRequest, "Company type not found", &msgUser)
		return
	}

	// Check City if provided
	var city *models.City
	if data.CityID != nil {
		var tempCity models.City
		if err := database.DB.First(&tempCity, *data.CityID).Error; err != nil {
			msgUser := "المدينة غير موجودة"
			response.Error(c, http.StatusBadRequest, "City not found", &msgUser)
			return
		}
		city = &tempCity
	}

	// Handle logo upload
	var logoPath *string
	file, err := c.FormFile("image")
	if err == nil {
		filename := fmt.Sprintf("%s%s", uuid.New().String(), filepath.Ext(file.Filename))
		savePath := filepath.Join("uploads", "company_logos", filename)
		if err := c.SaveUploadedFile(file, savePath); err != nil {
			msgUser := "فشل في حفظ الصورة"
			response.Error(c, http.StatusInternalServerError, "Failed to save image", &msgUser)
			return
		}
		pathStr := "/" + savePath
		logoPath = &pathStr
	}

	phone := ""
	if data.Phone != nil {
		phone = *data.Phone
	}

	company := models.Company{
		Name:          data.Name,
		CompanyTypeID: &companyType.ID,
		Description:   data.Description,
		Address:       data.Address,
		Phone:         phone,
		AllowsB2B:     data.AllowsB2B,
		AllowsB2C:     data.AllowsB2C,
		Status:        "pending",
		Logo:          logoPath,
		CityID:        data.CityID,
	}

	// Use a transaction
	tx := database.DB.Begin()
	if err := tx.Create(&company).Error; err != nil {
		tx.Rollback()
		msgUser := "حدث خطأ أثناء تسجيل الشركة"
		response.Error(c, http.StatusInternalServerError, "Failed to create company", &msgUser)
		return
	}

	member := models.CompanyMember{
		CompanyID: company.ID,
		UserID:    userID.(uint),
		Role:      "admin",
	}
	if err := tx.Create(&member).Error; err != nil {
		tx.Rollback()
		msgUser := "حدث خطأ أثناء تسجيل عضوية الشركة"
		response.Error(c, http.StatusInternalServerError, "Failed to create company member", &msgUser)
		return
	}

	// Notify Superusers
	notifsvc.SendNewCompanyRegistrationNotification(&company)

	tx.Commit()

	// Build the response
	cityOut := (*models.CityOut)(nil)
	if city != nil {
		cityOut = &models.CityOut{
			ID:   city.ID,
			Name: city.Name,
			Code: city.Code,
		}
	}

	out := models.CompanyOut{
		ID:          company.ID,
		Name:        company.Name,
		Type:        &companyType.CType,
		TypeName:    &companyType.Name,
		Description: company.Description,
		Address:     company.Address,
		Phone:       &company.Phone,
		AllowsB2B:   company.AllowsB2B,
		AllowsB2C:   company.AllowsB2C,
		Status:      company.Status,
		LogoURL:     company.Logo,
		City:        cityOut,
		CreatedAt:   &company.CreatedAt,
		UpdatedAt:   &company.UpdatedAt,
	}

	response.Success(c, http.StatusOK, "Company registered successfully and is pending approval.", out)
}

// GetCompanyTypes handles GET /api/companies/types
// @Summary GetCompanyTypes
// @Description GetCompanyTypes
// @Tags Companies
// @Success 200 {object} response.APIResponse
// @Router /companies/types [get]
func GetCompanyTypes(c *gin.Context) {
	var companyTypes []models.CompanyType
	// Preload AllowedServices and AllowedSubscriptionPlans
	if err := database.DB.Preload("AllowedSubscriptionPlans", "is_active = ?", true).
		Find(&companyTypes).Error; err != nil {
		log.Printf("Error fetching company types: %v", err)
		response.Error(c, http.StatusInternalServerError, "Failed to fetch company types", nil)
		return
	}

	data := make([]map[string]interface{}, 0, len(companyTypes))
	for _, ct := range companyTypes {
		var allowedFeatures []string
		if len(ct.AllowedFeatures) > 0 {
			_ = json.Unmarshal(ct.AllowedFeatures, &allowedFeatures)
		}

		allowedPlans := []map[string]interface{}{}
		for _, p := range ct.AllowedSubscriptionPlans {
			allowedPlans = append(allowedPlans, map[string]interface{}{
				"id":   p.ID,
				"name": p.Name,
			})
		}

		data = append(data, map[string]interface{}{
			"id":                         ct.ID,
			"code":                       ct.CType,
			"name":                       ct.Name,
			"allowed_features":           allowedFeatures,
			"allowed_subscription_plans": allowedPlans,
		})
	}

	response.Success(c, http.StatusOK, "Company types retrieved successfully.", data)
}
