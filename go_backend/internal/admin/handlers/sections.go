package admin

import (
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"watt/internal/database"
	"watt/internal/models"
)

var defaultColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
}

func HandleSection(c *gin.Context) {
	section := c.Param("section")
	section = strings.TrimPrefix(section, "/")

	switch section {
	case "overview":
		OverviewSection(c)
	case "configs":
		ConfigsSection(c)
	case "users":
		UsersSection(c)
	case "countries":
		CountriesSection(c)
	case "cities":
		CitiesSection(c)
	case "currencies":
		CurrenciesSection(c)
	case "subscriptions":
		SubscriptionsSection(c)
	case "categories":
		CategoriesSection(c)
	case "companies":
		CompaniesSection(c)
	case "company-types":
		CompanyTypesSection(c)
	case "subscription-requests":
		SubscriptionRequestsSection(c)
	case "service-types":
		ServiceTypesSection(c)
	case "posters":
		PostersSection(c)
	case "systems":
		SystemsSection(c)
	case "notifications":
		NotificationsSection(c)
	case "feedbacks":
		FeedbacksSection(c)
	case "offers":
		OffersSection(c)
	case "products":
		ProductsSection(c)
	default:
		renderSection(c, `<p>القسم غير موجود</p>`)
	}
}

func OverviewSection(c *gin.Context) {
	totalCompanies := countQuery(&models.Company{}, "")
	var totalUsers int64
	database.DB.Model(&models.User{}).Where("is_deleted = ?", false).Count(&totalUsers)
	totalPending := countQuery(&models.CompanySubscriptionRequest{}, "status = ?", "pending")
	totalActive := countQuery(&models.Company{}, "status = ?", "active")

	html := `<div class="overview-grid">`
	html += overviewCard("الشركات النشطة", formatInt(totalActive), "active")
	html += overviewCard("إجمالي الشركات", formatInt(totalCompanies), "")
	html += overviewCard("المستخدمون", formatInt(totalUsers), "")
	html += overviewCard("طلبات معلقة", formatInt(totalPending), "warning")
	html += `</div>`

	var recentCompanies []models.Company
	database.DB.Order("created_at DESC").Limit(5).Find(&recentCompanies)
	html += `<div class="card mt-4"><h4>أحدث الشركات</h4>`
	html += `<table class="data-table"><thead><tr><th>الاسم</th><th>الهاتف</th><th>الحالة</th><th>التاريخ</th></tr></thead><tbody>`
	for _, co := range recentCompanies {
		html += `<tr><td>` + co.Name + `</td><td>` + co.Phone + `</td><td>` + statusBadge(co.Status) + `</td><td>` + formatTime(co.CreatedAt) + `</td></tr>`
	}
	html += `</tbody></table></div>`
	renderSection(c, html)
}

func overviewCard(title, value, extraClass string) string {
	cls := "overview-card"
	if extraClass != "" {
		cls += " " + extraClass
	}
	return `<div class="` + cls + `"><div class="card-value">` + value + `</div><div class="card-label">` + title + `</div></div>`
}

func formatInt(n int64) string {
	return strconv.FormatInt(n, 10)
}

// ──────────────────────────────────────────────
// Configs
// ──────────────────────────────────────────────

var configColumns = []FieldDef{
	{Key: "key", Label: "المفتاح", Type: "text"},
	{Key: "description", Label: "الوصف", Type: "text"},
	{Key: "value", Label: "القيمة", Type: "text"},
}

func ConfigsSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, configColumns)
	var total int64
	database.DB.Model(&models.AppConfig{}).Count(&total)
	p = p.CalcTotal(int(total))

	var configs []models.AppConfig
	database.DB.Offset(p.Offset()).Limit(p.PerPage).Find(&configs)

	rows := []RowData{}
	for _, cfg := range configs {
		val := boolActiveInactive(cfg.Value)
		desc := ""
		if cfg.Description != nil {
			desc = *cfg.Description
		}
		rows = append(rows, RowData{ID: cfg.Key, Cells: []string{cfg.Key, desc, val}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "الإعدادات", Description: "إعدادات التطبيق العامة",
		Section: "configs", Columns: configColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: false, AllowEdit: false, AllowDelete: false,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Users
// ──────────────────────────────────────────────

var userColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "phone", Label: "الهاتف", Type: "text"},
	{Key: "email", Label: "البريد", Type: "text"},
	{Key: "is_active", Label: "نشط", Type: "text"},
	{Key: "is_superuser", Label: "مدير", Type: "text"},
	{Key: "date_joined", Label: "التاريخ", Type: "text"},
}

func UsersSection(c *gin.Context) {
	p := parsePagination(c)
	var total int64
	query := database.DB.Model(&models.User{}).Where("is_deleted = ?", false)
	query = applyFilter(c, query, "name", "first_name LIKE ? OR last_name LIKE ?")
	query = applyFilter(c, query, "phone", "phone LIKE ?")
	query = applyFilter(c, query, "email", "email LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var users []models.User
	query.Order("date_joined DESC").Offset(p.Offset()).Limit(p.PerPage).Find(&users)

	rows := []RowData{}
	for _, u := range users {
		idStr := strconv.Itoa(int(u.ID))
		name := strings.TrimSpace(u.FirstName + " " + u.LastName)
		if name == "" {
			name = u.Username
		}
		rows = append(rows, RowData{ID: idStr, Cells: []string{
			idStr, name, u.Phone, u.Email,
			boolActiveInactive(u.IsActive),
			boolYesNo(u.IsSuperuser),
			formatDate(u.DateJoined),
		}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "المستخدمون", Section: "users", Columns: userColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: false, AllowEdit: false, AllowDelete: false,
	})
}

// ──────────────────────────────────────────────
// Countries
// ──────────────────────────────────────────────

var countryColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "code", Label: "الرمز", Type: "text"},
}

func CountriesSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, countryColumns)
	var total int64
	query := database.DB.Model(&models.Country{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query = applyFilter(c, query, "code", "code LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var countries []models.Country
	query.Offset(p.Offset()).Limit(p.PerPage).Find(&countries)

	rows := []RowData{}
	for _, co := range countries {
		idStr := strconv.Itoa(int(co.ID))
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, co.Name, co.Code}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "الدول", Section: "countries", Columns: countryColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Cities
// ──────────────────────────────────────────────

var cityColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "code", Label: "الرمز", Type: "text"},
	{Key: "country", Label: "الدولة", Type: "text"},
}

func CitiesSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, cityColumns)
	var total int64
	query := database.DB.Model(&models.City{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query = applyFilter(c, query, "code", "code LIKE ?")
	query = applyFilterCountry(c, query, "country")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var cities []models.City
	query.Preload("Country").Order("name ASC").Offset(p.Offset()).Limit(p.PerPage).Find(&cities)

	rows := []RowData{}
	for _, ci := range cities {
		idStr := strconv.Itoa(int(ci.ID))
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, ci.Name, ci.Code, ci.Country.Name}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "المدن", Section: "cities", Columns: cityColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Currencies
// ──────────────────────────────────────────────

var currencyColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "code", Label: "الرمز", Type: "text"},
	{Key: "symbol", Label: "العملة", Type: "text"},
	{Key: "is_default", Label: "افتراضي", Type: "text"},
}

func CurrenciesSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, currencyColumns)
	var total int64
	query := database.DB.Model(&models.Currency{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query = applyFilter(c, query, "code", "code LIKE ?")
	query = applyFilter(c, query, "symbol", "symbol LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var currencies []models.Currency
	query.Offset(p.Offset()).Limit(p.PerPage).Find(&currencies)

	rows := []RowData{}
	for _, cu := range currencies {
		idStr := strconv.Itoa(int(cu.ID))
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, cu.Name, cu.Code, cu.Symbol, boolYesNo(cu.IsDefault)}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "العملات", Section: "currencies", Columns: currencyColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Subscriptions
// ──────────────────────────────────────────────

var subColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "duration", Label: "المدة (يوم)", Type: "text"},
	{Key: "price", Label: "السعر", Type: "text"},
	{Key: "is_active", Label: "الحالة", Type: "text"},
}

func SubscriptionsSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, subColumns)
	var total int64
	query := database.DB.Model(&models.SubscriptionPlan{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var plans []models.SubscriptionPlan
	query.Offset(p.Offset()).Limit(p.PerPage).Find(&plans)

	rows := []RowData{}
	for _, pl := range plans {
		idStr := strconv.Itoa(int(pl.ID))
		price := strconv.FormatFloat(pl.Price, 'f', 2, 64)
		duration := strconv.Itoa(pl.DurationDays)
		rows = append(rows, RowData{ID: idStr, Cells: []string{
			idStr, pl.Name, duration, price,
			boolActiveInactive(pl.IsActive),
		}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "باقات الاشتراك", Section: "subscriptions", Columns: subColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Categories
// ──────────────────────────────────────────────

var catColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "icon", Label: "الأيقونة", Type: "text"},
}

func CategoriesSection(c *gin.Context) {
	p := parsePagination(c)
	var total int64
	database.DB.Model(&models.GlobalCategory{}).Count(&total)
	p = p.CalcTotal(int(total))

	var cats []models.GlobalCategory
	database.DB.Offset(p.Offset()).Limit(p.PerPage).Find(&cats)

	rows := []RowData{}
	for _, ca := range cats {
		idStr := strconv.Itoa(int(ca.ID))
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, ca.Name, safeStr(ca.Icon)}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "التصنيفات العامة", Section: "categories", Columns: catColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: false, AllowEdit: false, AllowDelete: false,
	})
}

// ──────────────────────────────────────────────
// Companies
// ──────────────────────────────────────────────

var companyColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "phone", Label: "الهاتف", Type: "text"},
	{Key: "type", Label: "النوع", Type: "text"},
	{Key: "status", Label: "الحالة", Type: "text"},
	{Key: "created_at", Label: "تاريخ الإضافة", Type: "text"},
}

func CompaniesSection(c *gin.Context) {
	p := parsePagination(c)
	var total int64
	database.DB.Model(&models.Company{}).Count(&total)
	p = p.CalcTotal(int(total))

	var companies []models.Company
	database.DB.Preload("CompanyType").Preload("City").Preload("Currency").Order("created_at DESC").Offset(p.Offset()).Limit(p.PerPage).Find(&companies)

	rows := []RowData{}
	for _, co := range companies {
		idStr := strconv.Itoa(int(co.ID))
		typeName := ""
		if co.CompanyType != nil {
			typeName = co.CompanyType.Name
		}
		rows = append(rows, RowData{ID: idStr, Cells: []string{
			idStr, co.Name, co.Phone, typeName,
			statusBadge(co.Status),
			formatDate(co.CreatedAt),
		}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "الشركات", Section: "companies", Columns: companyColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowEdit: false, AllowDelete: false,
	})
}

// ──────────────────────────────────────────────
// CompanyTypes
// ──────────────────────────────────────────────

var ctColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "ctype", Label: "المفتاح", Type: "text"},
	{Key: "services", Label: "الخدمات", Type: "text"},
}

func CompanyTypesSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, ctColumns)
	var total int64
	query := database.DB.Model(&models.CompanyType{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query = applyFilter(c, query, "ctype", "c_type LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var ctypes []models.CompanyType
	query.Offset(p.Offset()).Limit(p.PerPage).Find(&ctypes)

	rows := []RowData{}
	for _, ct := range ctypes {
		idStr := strconv.Itoa(int(ct.ID))
		services, _ := ct.AllowedFeatures.MarshalJSON()
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, ct.Name, ct.CType, string(services)}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "أنواع الشركات", Section: "company-types", Columns: ctColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// SubscriptionRequests
// ──────────────────────────────────────────────

var srColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "company", Label: "الشركة", Type: "text"},
	{Key: "plan", Label: "الباقة", Type: "text"},
	{Key: "status", Label: "الحالة", Type: "text"},
	{Key: "created_at", Label: "التاريخ", Type: "text"},
}

func SubscriptionRequestsSection(c *gin.Context) {
	p := parsePagination(c)
	var total int64
	database.DB.Model(&models.CompanySubscriptionRequest{}).Count(&total)
	p = p.CalcTotal(int(total))

	var reqs []models.CompanySubscriptionRequest
	database.DB.Preload("Company").Preload("SubscriptionPlan").Order("created_at DESC").Offset(p.Offset()).Limit(p.PerPage).Find(&reqs)

	rows := []RowData{}
	for _, r := range reqs {
		idStr := strconv.Itoa(int(r.ID))
		companyName := ""
		planName := ""
		if r.Company.Name != "" {
			companyName = r.Company.Name
		}
		if r.SubscriptionPlan.Name != "" {
			planName = r.SubscriptionPlan.Name
		}
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, companyName, planName, statusBadge(r.Status), formatDate(r.CreatedAt)}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "طلبات الاشتراك", Section: "subscription-requests", Columns: srColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: false, AllowEdit: false, AllowDelete: false,
	})
}

// ──────────────────────────────────────────────
// ServiceTypes
// ──────────────────────────────────────────────

var stColumns = []FieldDef{
	{Key: "id", Label: "#", Type: "text"},
	{Key: "name", Label: "الاسم", Type: "text"},
	{Key: "description", Label: "الوصف", Type: "text"},
}

func ServiceTypesSection(c *gin.Context) {
	p := parsePagination(c)
	filters := parseFilters(c, stColumns)
	var total int64
	query := database.DB.Model(&models.ServiceType{})
	query = applyFilter(c, query, "name", "name LIKE ?")
	query.Count(&total)
	p = p.CalcTotal(int(total))

	var stypes []models.ServiceType
	query.Offset(p.Offset()).Limit(p.PerPage).Find(&stypes)

	rows := []RowData{}
	for _, st := range stypes {
		idStr := strconv.Itoa(int(st.ID))
		rows = append(rows, RowData{ID: idStr, Cells: []string{idStr, st.Name, safeStr(st.Description)}})
	}

	renderCRUDTable(c, CRUDPageData{
		Title: "أنواع الخدمات", Section: "service-types", Columns: stColumns,
		Rows: rows, Total: p.Total, Page: p.Page, PerPage: p.PerPage, TotalPages: p.TotalPages,
		AllowCreate: true, AllowEdit: true, AllowDelete: true,
		Filters: filters,
	})
}

// ──────────────────────────────────────────────
// Posters
// ──────────────────────────────────────────────

func PostersSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

// ──────────────────────────────────────────────
// Systems
// ──────────────────────────────────────────────

func SystemsSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

// ──────────────────────────────────────────────
// Notifications
// ──────────────────────────────────────────────

func NotificationsSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

// ──────────────────────────────────────────────
// Feedbacks
// ──────────────────────────────────────────────

func FeedbacksSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

// ──────────────────────────────────────────────
// Offers
// ──────────────────────────────────────────────

func OffersSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

// ──────────────────────────────────────────────
// Products
// ──────────────────────────────────────────────

func ProductsSection(c *gin.Context) {
	renderSection(c, `<p>قيد التطوير</p>`)
}

