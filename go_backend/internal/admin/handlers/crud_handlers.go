package admin

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"

	"watt/internal/database"
	"watt/internal/models"
)

// ──────────────────────────────────────────────
// COUNTRIES CRUD
// ──────────────────────────────────────────────

var countryFormFields = []FieldDef{
	{Key: "name", Label: "الاسم", Type: "text", Required: true},
	{Key: "code", Label: "الرمز", Type: "text", Required: true},
}

func CreateCountryForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/countries/create",
		Method: "post",
		Fields: countryFormFields,
		Data:   map[string]string{},
	})
}

func CreateCountry(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	if name == "" || code == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/countries/create", Method: "post",
			Fields: countryFormFields,
			Data:   map[string]string{"name": name, "code": code},
		}, "جميع الحقول مطلوبة")
		return
	}
	database.DB.Create(&models.Country{Name: name, Code: code})
	c.Redirect(http.StatusFound, "/admin/config/section/countries")
}

func EditCountryForm(c *gin.Context) {
	idStr := c.Param("id")
	var country models.Country
	if err := database.DB.First(&country, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	renderForm(c, FormData{
		Action: "/admin/config/countries/" + idStr + "/edit",
		Method: "put",
		Fields: countryFormFields,
		Data: map[string]string{
			"name": country.Name,
			"code": country.Code,
		},
	})
}

func EditCountry(c *gin.Context) {
	idStr := c.Param("id")
	var country models.Country
	if err := database.DB.First(&country, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	if name == "" || code == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/countries/" + idStr + "/edit", Method: "put",
			Fields: countryFormFields,
			Data:   map[string]string{"name": name, "code": code},
		}, "جميع الحقول مطلوبة")
		return
	}
	database.DB.Model(&country).Updates(map[string]interface{}{
		"name": name,
		"code": code,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/countries")
}

func DeleteCountry(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.Country{}, idStr)
	c.Status(http.StatusOK)
}

// ──────────────────────────────────────────────
// CITIES CRUD
// ──────────────────────────────────────────────

var cityFormFields = []FieldDef{
	{Key: "name", Label: "الاسم", Type: "text", Required: true},
	{Key: "code", Label: "الرمز", Type: "text", Required: true},
	{Key: "country_id", Label: "الدولة", Type: "select", Required: true},
}

func cityFormFieldOptions() []FieldDef {
	var countries []models.Country
	database.DB.Find(&countries)
	fields := make([]FieldDef, len(cityFormFields))
	copy(fields, cityFormFields)
	opts := []SelectOption{}
	for _, co := range countries {
		opts = append(opts, SelectOption{Value: strconv.Itoa(int(co.ID)), Label: co.Name})
	}
	fields[2].Options = opts
	return fields
}

func CreateCityForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/cities/create", Method: "post",
		Fields: cityFormFieldOptions(),
		Data:   map[string]string{},
	})
}

func CreateCity(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	countryIDStr := c.PostForm("country_id")

	if name == "" || code == "" || countryIDStr == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/cities/create", Method: "post",
			Fields: cityFormFieldOptions(),
			Data:   map[string]string{"name": name, "code": code, "country_id": countryIDStr},
		}, "جميع الحقول مطلوبة")
		return
	}
	countryID, _ := strconv.Atoi(countryIDStr)
	database.DB.Create(&models.City{Name: name, Code: code, CountryID: uint(countryID)})
	c.Redirect(http.StatusFound, "/admin/config/section/cities")
}

func EditCityForm(c *gin.Context) {
	idStr := c.Param("id")
	var city models.City
	if err := database.DB.First(&city, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	renderForm(c, FormData{
		Action: "/admin/config/cities/" + idStr + "/edit", Method: "put",
		Fields: cityFormFieldOptions(),
		Data: map[string]string{
			"name":       city.Name,
			"code":       city.Code,
			"country_id": strconv.Itoa(int(city.CountryID)),
		},
	})
}

func EditCity(c *gin.Context) {
	idStr := c.Param("id")
	var city models.City
	if err := database.DB.First(&city, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	countryIDStr := c.PostForm("country_id")

	if name == "" || code == "" || countryIDStr == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/cities/" + idStr + "/edit", Method: "put",
			Fields: cityFormFieldOptions(),
			Data:   map[string]string{"name": name, "code": code, "country_id": countryIDStr},
		}, "جميع الحقول مطلوبة")
		return
	}
	countryID, _ := strconv.Atoi(countryIDStr)
	database.DB.Model(&city).Updates(map[string]interface{}{
		"name": name, "code": code, "country_id": uint(countryID),
	})
	c.Redirect(http.StatusFound, "/admin/config/section/cities")
}

func DeleteCity(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.City{}, idStr)
	c.Status(http.StatusOK)
}

// ──────────────────────────────────────────────
// CURRENCIES CRUD
// ──────────────────────────────────────────────

var currencyFormFields = []FieldDef{
	{Key: "name", Label: "الاسم", Type: "text", Required: true},
	{Key: "code", Label: "الرمز", Type: "text", Required: true},
	{Key: "symbol", Label: "العملة", Type: "text", Required: true},
	{Key: "is_default", Label: "افتراضي", Type: "bool"},
}

func CreateCurrencyForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/currencies/create", Method: "post",
		Fields: currencyFormFields, Data: map[string]string{},
	})
}

func CreateCurrency(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	symbol := strings.TrimSpace(c.PostForm("symbol"))
	isDefault := c.PostForm("is_default") == "true"

	if name == "" || code == "" || symbol == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/currencies/create", Method: "post",
			Fields: currencyFormFields,
			Data:   map[string]string{"name": name, "code": code, "symbol": symbol},
		}, "جميع الحقول مطلوبة")
		return
	}
	database.DB.Create(&models.Currency{Name: name, Code: code, Symbol: symbol, IsDefault: isDefault})
	c.Redirect(http.StatusFound, "/admin/config/section/currencies")
}

func EditCurrencyForm(c *gin.Context) {
	idStr := c.Param("id")
	var currency models.Currency
	if err := database.DB.First(&currency, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	isDefault := "false"
	if currency.IsDefault {
		isDefault = "true"
	}
	renderForm(c, FormData{
		Action: "/admin/config/currencies/" + idStr + "/edit", Method: "put",
		Fields: currencyFormFields,
		Data: map[string]string{
			"name": currency.Name, "code": currency.Code,
			"symbol": currency.Symbol, "is_default": isDefault,
		},
	})
}

func EditCurrency(c *gin.Context) {
	idStr := c.Param("id")
	var currency models.Currency
	if err := database.DB.First(&currency, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	code := strings.TrimSpace(c.PostForm("code"))
	symbol := strings.TrimSpace(c.PostForm("symbol"))
	isDefault := c.PostForm("is_default") == "true"

	if name == "" || code == "" || symbol == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/currencies/" + idStr + "/edit", Method: "put",
			Fields: currencyFormFields,
			Data:   map[string]string{"name": name, "code": code, "symbol": symbol},
		}, "جميع الحقول مطلوبة")
		return
	}
	database.DB.Model(&currency).Updates(map[string]interface{}{
		"name": name, "code": code, "symbol": symbol, "is_default": isDefault,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/currencies")
}

func DeleteCurrency(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.Currency{}, idStr)
	c.Status(http.StatusOK)
}

// ──────────────────────────────────────────────
// SUBSCRIPTION PLANS CRUD
// ──────────────────────────────────────────────

var subFormFields = []FieldDef{
	{Key: "name", Label: "الاسم", Type: "text", Required: true},
	{Key: "duration_days", Label: "المدة (يوم)", Type: "number", Required: true},
	{Key: "price", Label: "السعر", Type: "number", Required: true},
	{Key: "description", Label: "الوصف", Type: "textarea"},
	{Key: "is_active", Label: "مفعل", Type: "bool"},
	{Key: "features", Label: "الميزات (JSON)", Type: "json"},
}

func CreateSubscriptionForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/subscriptions/create", Method: "post",
		Fields: subFormFields, Data: map[string]string{},
	})
}

func CreateSubscription(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	durationStr := c.PostForm("duration_days")
	priceStr := c.PostForm("price")
	desc := c.PostForm("description")
	isActive := c.PostForm("is_active") == "true"
	featuresStr := c.PostForm("features")

	if name == "" || durationStr == "" || priceStr == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/subscriptions/create", Method: "post",
			Fields: subFormFields,
			Data:   map[string]string{"name": name, "duration_days": durationStr, "price": priceStr},
		}, "الحقول المطلوبة ناقصة")
		return
	}
	duration, _ := strconv.Atoi(durationStr)
	price, _ := strconv.ParseFloat(priceStr, 64)
	var descPtr *string
	if desc != "" {
		descPtr = &desc
	}
	features := datatypes.JSON([]byte(featuresStr))
	if featuresStr == "" {
		features = datatypes.JSON([]byte("{}"))
	}
	database.DB.Create(&models.SubscriptionPlan{
		Name: name, DurationDays: duration, Price: price,
		Description: descPtr, IsActive: isActive, Features: features,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/subscriptions")
}

func EditSubscriptionForm(c *gin.Context) {
	idStr := c.Param("id")
	var plan models.SubscriptionPlan
	if err := database.DB.First(&plan, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	featuresStr := "{}"
	if plan.Features != nil {
		featuresStr = string(plan.Features)
	}
	isActive := "false"
	if plan.IsActive {
		isActive = "true"
	}
	desc := ""
	if plan.Description != nil {
		desc = *plan.Description
	}
	renderForm(c, FormData{
		Action: "/admin/config/subscriptions/" + idStr + "/edit", Method: "put",
		Fields: subFormFields,
		Data: map[string]string{
			"name": plan.Name, "duration_days": strconv.Itoa(plan.DurationDays),
			"price": strconv.FormatFloat(plan.Price, 'f', 2, 64),
			"description": desc, "is_active": isActive,
			"features": featuresStr,
		},
	})
}

func EditSubscription(c *gin.Context) {
	idStr := c.Param("id")
	var plan models.SubscriptionPlan
	if err := database.DB.First(&plan, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	durationStr := c.PostForm("duration_days")
	priceStr := c.PostForm("price")
	desc := c.PostForm("description")
	isActive := c.PostForm("is_active") == "true"
	featuresStr := c.PostForm("features")

	if name == "" || durationStr == "" || priceStr == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/subscriptions/" + idStr + "/edit", Method: "put",
			Fields: subFormFields,
			Data:   map[string]string{"name": name, "duration_days": durationStr, "price": priceStr},
		}, "الحقول المطلوبة ناقصة")
		return
	}
	duration, _ := strconv.Atoi(durationStr)
	price, _ := strconv.ParseFloat(priceStr, 64)
	var descPtr *string
	if desc != "" {
		descPtr = &desc
	}
	features := datatypes.JSON([]byte(featuresStr))
	if featuresStr == "" {
		features = datatypes.JSON([]byte("{}"))
	}
	database.DB.Model(&plan).Updates(map[string]interface{}{
		"name": name, "duration_days": duration, "price": price,
		"description": descPtr, "is_active": isActive, "features": features,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/subscriptions")
}

func DeleteSubscription(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.SubscriptionPlan{}, idStr)
	c.Status(http.StatusOK)
}

// ──────────────────────────────────────────────
// COMPANY TYPES CRUD
// ──────────────────────────────────────────────

func ctFormFieldOptions() []FieldDef {
	serviceOpts := []SelectOption{}
	for _, s := range models.AllAvailableServices {
		serviceOpts = append(serviceOpts, SelectOption{Value: s.Code, Label: s.Name})
	}
	return []FieldDef{
		{Key: "name", Label: "الاسم", Type: "text", Required: true},
		{Key: "ctype", Label: "المفتاح", Type: "text", Required: true},
		{Key: "allowed_features", Label: "الخدمات المسموحة", Type: "select", Options: serviceOpts},
	}
}

func CreateCompanyTypeForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/company-types/create", Method: "post",
		Fields: ctFormFieldOptions(), Data: map[string]string{},
	})
}

func CreateCompanyType(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	ctype := strings.TrimSpace(c.PostForm("ctype"))
	featuresStr := c.PostForm("allowed_features")
	if name == "" || ctype == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/company-types/create", Method: "post",
			Fields: ctFormFieldOptions(),
			Data:   map[string]string{"name": name, "ctype": ctype},
		}, "جميع الحقول مطلوبة")
		return
	}
	features := datatypes.JSON([]byte(featuresStr))
	if featuresStr == "" {
		features = datatypes.JSON([]byte("[]"))
	}
	database.DB.Create(&models.CompanyType{
		Name: name, CType: ctype, AllowedFeatures: features,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/company-types")
}

func EditCompanyTypeForm(c *gin.Context) {
	idStr := c.Param("id")
	var ct models.CompanyType
	if err := database.DB.First(&ct, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	features := "[]"
	if ct.AllowedFeatures != nil {
		features = string(ct.AllowedFeatures)
	}
	renderForm(c, FormData{
		Action: "/admin/config/company-types/" + idStr + "/edit", Method: "put",
		Fields: ctFormFieldOptions(),
		Data: map[string]string{
			"name": ct.Name, "ctype": ct.CType, "allowed_features": features,
		},
	})
}

func EditCompanyType(c *gin.Context) {
	idStr := c.Param("id")
	var ct models.CompanyType
	if err := database.DB.First(&ct, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	ctype := strings.TrimSpace(c.PostForm("ctype"))
	featuresStr := c.PostForm("allowed_features")
	if name == "" || ctype == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/company-types/" + idStr + "/edit", Method: "put",
			Fields: ctFormFieldOptions(),
			Data:   map[string]string{"name": name, "ctype": ctype},
		}, "جميع الحقول مطلوبة")
		return
	}
	features := datatypes.JSON([]byte(featuresStr))
	if featuresStr == "" {
		features = datatypes.JSON([]byte("[]"))
	}
	database.DB.Model(&ct).Updates(map[string]interface{}{
		"name": name, "c_type": ctype, "allowed_features": features,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/company-types")
}

func DeleteCompanyType(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.CompanyType{}, idStr)
	c.Status(http.StatusOK)
}

// ──────────────────────────────────────────────
// SERVICE TYPES CRUD
// ──────────────────────────────────────────────

var stFormFields = []FieldDef{
	{Key: "name", Label: "الاسم", Type: "text", Required: true},
	{Key: "description", Label: "الوصف", Type: "textarea"},
}

func CreateServiceTypeForm(c *gin.Context) {
	renderForm(c, FormData{
		Action: "/admin/config/service-types/create", Method: "post",
		Fields: stFormFields, Data: map[string]string{},
	})
}

func CreateServiceType(c *gin.Context) {
	name := strings.TrimSpace(c.PostForm("name"))
	desc := c.PostForm("description")
	if name == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/service-types/create", Method: "post",
			Fields: stFormFields,
			Data:   map[string]string{"name": name, "description": desc},
		}, "اسم الخدمة مطلوب")
		return
	}
	var descPtr *string
	if desc != "" {
		descPtr = &desc
	}
	database.DB.Create(&models.ServiceType{Name: name, Description: descPtr})
	c.Redirect(http.StatusFound, "/admin/config/section/service-types")
}

func EditServiceTypeForm(c *gin.Context) {
	idStr := c.Param("id")
	var st models.ServiceType
	if err := database.DB.First(&st, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	renderForm(c, FormData{
		Action: "/admin/config/service-types/" + idStr + "/edit", Method: "put",
		Fields: stFormFields,
		Data: map[string]string{
			"name": st.Name, "description": safeStr(st.Description),
		},
	})
}

func EditServiceType(c *gin.Context) {
	idStr := c.Param("id")
	var st models.ServiceType
	if err := database.DB.First(&st, idStr).Error; err != nil {
		c.String(http.StatusNotFound, "غير موجود")
		return
	}
	name := strings.TrimSpace(c.PostForm("name"))
	desc := c.PostForm("description")
	if name == "" {
		renderFormError(c, FormData{
			Action: "/admin/config/service-types/" + idStr + "/edit", Method: "put",
			Fields: stFormFields,
			Data:   map[string]string{"name": name, "description": desc},
		}, "اسم الخدمة مطلوب")
		return
	}
	var descPtr *string
	if desc != "" {
		descPtr = &desc
	}
	database.DB.Model(&st).Updates(map[string]interface{}{
		"name": name, "description": descPtr,
	})
	c.Redirect(http.StatusFound, "/admin/config/section/service-types")
}

func DeleteServiceType(c *gin.Context) {
	idStr := c.Param("id")
	database.DB.Delete(&models.ServiceType{}, idStr)
	c.Status(http.StatusOK)
}
