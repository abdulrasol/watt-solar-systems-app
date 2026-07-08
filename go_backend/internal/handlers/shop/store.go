package shop

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// StoreCatalogMeta handles GET /api/v1/shop/catalog/meta
// @Summary StoreCatalogMeta
// @Description Get global categories for storefront
// @Tags Shop
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /shop/catalog/meta [get]
func StoreCatalogMeta(c *gin.Context) {
	var cats []models.GlobalCategory
	database.DB.Find(&cats)

	items := make([]map[string]interface{}, 0, len(cats))
	for _, cat := range cats {
		items = append(items, map[string]interface{}{
			"id":   cat.ID,
			"name": cat.Name,
		})
	}

	response.Success(c, http.StatusOK, "Store catalog metadata retrieved successfully", map[string]interface{}{
		"global_categories": items,
	})
}

// ListStoreCompanies handles GET /api/v1/shop/store/companies
// @Summary ListStoreCompanies
// @Description List companies eligible for storefront (b2c/b2b)
// @Tags Shop
// @Produce json
// @Param page query int false "Page"
// @Param page_size query int false "Page size"
// @Param search query string false "Search"
// @Param sales_channel query string false "b2c or b2b"
// @Param ordering query string false "Ordering"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/companies [get]
func ListStoreCompanies(c *gin.Context) {
	channel := c.DefaultQuery("sales_channel", "b2c")
	if channel != "b2b" {
		channel = "b2c"
	}

	page, pageSize := parsePagination(c)
	search := c.Query("search")
	offset := (page - 1) * pageSize

	var comps []models.Company
	query := database.DB.
		Preload("City").
		Preload("CompanyType").
		Preload("CompanyType.AllowedServices").
		Where("status = ?", "active")

	if search != "" {
		like := "%" + search + "%"
		query = query.Where("name ILIKE ? OR phone ILIKE ?", like, like)
	}

	var total int64
	query.Model(&models.Company{}).Count(&total)

	if err := query.Order("name asc").Limit(pageSize).Offset(offset).Find(&comps).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch companies", nil)
		return
	}

	var items []map[string]interface{}
	for _, comp := range comps {
		if !companies.IsCompanyPubliclyVisible(&comp, channel) {
			continue
		}
		items = append(items, map[string]interface{}{
			"id":   comp.ID,
			"name": comp.Name,
			"logo": comp.Logo,
			"city": serializeCity(comp.City),
		})
	}

	response.Success(c, http.StatusOK, "Store companies retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// ListStoreCompanyCategories handles GET /api/v1/shop/store/companies/:id/company-categories
// @Summary ListStoreCompanyCategories
// @Description Get company categories for a storefront company
// @Tags Shop
// @Produce json
// @Param id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/companies/{id}/company-categories [get]
func ListStoreCompanyCategories(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid company ID", nil)
		return
	}

	var comp models.Company
	if err := database.DB.Preload("CompanyType").Preload("CompanyType.AllowedServices").First(&comp, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Company not found", nil)
		return
	}

	if !companies.IsCompanyPubliclyVisible(&comp, "b2c") && !companies.IsCompanyPubliclyVisible(&comp, "b2b") {
		response.Error(c, http.StatusNotFound, "Company not publicly visible", nil)
		return
	}

	var cats []models.CompanyCategory
	database.DB.Where("company_id = ?", comp.ID).Order("created_at desc").Find(&cats)

	items := make([]map[string]interface{}, 0, len(cats))
	for _, cat := range cats {
		items = append(items, map[string]interface{}{
			"id":         cat.ID,
			"name":       cat.Name,
			"company":    map[string]interface{}{"id": comp.ID, "name": comp.Name},
			"created_at": cat.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Company categories retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// ListStoreProducts handles GET /api/v1/shop/store/products
// @Summary ListStoreProducts
// @Description List B2C storefront products
// @Tags Shop
// @Produce json
// @Param page query int false "Page"
// @Param page_size query int false "Page size"
// @Param search query string false "Search"
// @Param company_id query int false "Company ID"
// @Param global_category_id query int false "Global category ID"
// @Param company_category_id query int false "Company category ID"
// @Param min_price query number false "Min price"
// @Param max_price query number false "Max price"
// @Param ordering query string false "Ordering"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/products [get]
func ListStoreProducts(c *gin.Context) {
	listPublicProducts(c, "b2c")
}

// ListStoreSearch handles GET /api/v1/shop/store/search
// @Summary ListStoreSearch
// @Description Search B2C storefront products
// @Tags Shop
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /shop/store/search [get]
func ListStoreSearch(c *gin.Context) {
	listPublicProducts(c, "b2c")
}

// ListStoreCompanyProducts handles GET /api/v1/shop/store/companies/:id/products
// @Summary ListStoreCompanyProducts
// @Description List products for a specific storefront company (B2C)
// @Tags Shop
// @Produce json
// @Param id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/companies/{id}/products [get]
func ListStoreCompanyProducts(c *gin.Context) {
	c.Set("_store_company_id", c.Param("id"))
	listPublicProducts(c, "b2c")
}

// ListStoreCategoryProducts handles GET /api/v1/shop/store/categories/:type/:id/products
// @Summary ListStoreCategoryProducts
// @Description List products by category (B2C)
// @Tags Shop
// @Produce json
// @Param type path string true "global or company"
// @Param id path int true "category_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/categories/{type}/{id}/products [get]
func ListStoreCategoryProducts(c *gin.Context) {
	c.Set("_store_category_type", c.Param("type"))
	c.Set("_store_category_id", c.Param("id"))
	listPublicProducts(c, "b2c")
}

// ListB2BProducts handles GET /api/v1/shop/b2b/products
// @Summary ListB2BProducts
// @Description List B2B storefront products
// @Tags Shop
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/products [get]
func ListB2BProducts(c *gin.Context) {
	listPublicProducts(c, "b2b")
}

// ListB2BSearch handles GET /api/v1/shop/b2b/search
// @Summary ListB2BSearch
// @Description Search B2B storefront products
// @Tags Shop
// @Produce json
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/search [get]
func ListB2BSearch(c *gin.Context) {
	listPublicProducts(c, "b2b")
}

// ListB2BCompanyProducts handles GET /api/v1/shop/b2b/companies/:id/products
// @Summary ListB2BCompanyProducts
// @Description List products for a specific B2B company
// @Tags Shop
// @Produce json
// @Param id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/companies/{id}/products [get]
func ListB2BCompanyProducts(c *gin.Context) {
	c.Set("_store_company_id", c.Param("id"))
	listPublicProducts(c, "b2b")
}

// ListB2BCategoryProducts handles GET /api/v1/shop/b2b/categories/:type/:id/products
// @Summary ListB2BCategoryProducts
// @Description List B2B products by category
// @Tags Shop
// @Produce json
// @Param type path string true "global or company"
// @Param id path int true "category_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/categories/{type}/{id}/products [get]
func ListB2BCategoryProducts(c *gin.Context) {
	c.Set("_store_category_type", c.Param("type"))
	c.Set("_store_category_id", c.Param("id"))
	listPublicProducts(c, "b2b")
}

func listPublicProducts(c *gin.Context, channel string) {
	page, pageSize := parsePagination(c)
	search := c.Query("search")
	minPrice := parseFloatQuery(c, "min_price")
	maxPrice := parseFloatQuery(c, "max_price")
	ordering := c.DefaultQuery("ordering", "-created_at")

	var companyID *uint
	if val := c.Query("company_id"); val != "" {
		if id, err := strconv.Atoi(val); err == nil {
			uid := uint(id)
			companyID = &uid
		}
	}
	if val, exists := c.Get("_store_company_id"); exists {
		if id, err := strconv.Atoi(val.(string)); err == nil {
			uid := uint(id)
			companyID = &uid
		}
	}

	var globalCategoryID, companyCategoryID *uint
	if val := c.Query("global_category_id"); val != "" {
		if id, err := strconv.Atoi(val); err == nil {
			uid := uint(id)
			globalCategoryID = &uid
		}
	}
	if val := c.Query("company_category_id"); val != "" {
		if id, err := strconv.Atoi(val); err == nil {
			uid := uint(id)
			companyCategoryID = &uid
		}
	}
	if val, exists := c.Get("_store_category_type"); exists {
		if catID, err := strconv.Atoi(c.GetString("_store_category_id")); err == nil {
			uid := uint(catID)
			switch val.(string) {
			case "global":
				globalCategoryID = &uid
			case "company":
				companyCategoryID = &uid
			}
		}
	}

	offset := (page - 1) * pageSize

	query := database.DB.
		Preload("Company").
		Preload("Company.CompanyType").
		Preload("Company.CompanyType.AllowedServices").
		Preload("Company.City").
		Preload("Company.City.Country").
		Preload("Company.Currency").
		Preload("GlobalCategory").
		Preload("Categories").
		Preload("Options").
		Preload("PricingTiers").
		Preload("Images").
		Where("status = ?", "active").
		Where("stock_quantity > ?", 0)

	if companyID != nil {
		query = query.Where("company_id = ?", *companyID)
	}
	if globalCategoryID != nil {
		query = query.Where("global_category_id = ?", *globalCategoryID)
	}
	if companyCategoryID != nil {
		query = query.Joins("JOIN product_company_categories pcc ON pcc.product_id = products.id").
			Where("pcc.company_category_id = ?", *companyCategoryID)
	}

	if minPrice != nil {
		query = query.Where("retail_price >= ?", *minPrice)
	}
	if maxPrice != nil {
		query = query.Where("retail_price <= ?", *maxPrice)
	}

	if search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies sc ON sc.id = products.company_id").
			Where("products.name ILIKE ? OR products.sku ILIKE ? OR products.description ILIKE ? OR sc.name ILIKE ?",
				like, like, like, like)
	}

	var total int64
	query.Model(&models.Product{}).Count(&total)

	orderCol := "created_at"
	desc := false
	if len(ordering) > 0 && ordering[0] == '-' {
		desc = true
		orderCol = ordering[1:]
	} else {
		orderCol = ordering
	}
	if orderCol != "created_at" && orderCol != "updated_at" && orderCol != "name" && orderCol != "retail_price" && orderCol != "wholesale_price" {
		orderCol = "created_at"
	}
	order := orderCol + " asc"
	if desc {
		order = orderCol + " desc"
	}

	var products []models.Product
	if err := query.Limit(pageSize).Offset(offset).Order(order).Find(&products).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch products", nil)
		return
	}

	var items []map[string]interface{}
	for _, p := range products {
		if p.Company == nil || !companies.IsCompanyPubliclyVisible(p.Company, channel) {
			continue
		}
		items = append(items, serializeProduct(&p, channel, false))
	}

	response.Success(c, http.StatusOK, "Products retrieved successfully", paginationResponse(page, pageSize, total, items))
}

