package shop

import (
	"encoding/json"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

// ListCompanyProducts handles GET /api/v1/companies/:company_id/products
// @Summary ListCompanyProducts
// @Description List products for a company
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products [get]
func ListCompanyProducts(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	search := c.Query("search")
	minPrice := parseFloatQuery(c, "min_price")
	maxPrice := parseFloatQuery(c, "max_price")
	status := c.Query("status")
	isAvailable := parseBoolQuery(c, "is_available")
	offset := (page - 1) * pageSize

	query := database.DB.
		Preload("Company").
		Preload("GlobalCategory").
		Preload("Categories").
		Preload("Options").
		Preload("PricingTiers").
		Preload("Images").
		Where("company_id = ?", company.ID)

	if search != "" {
		like := "%" + search + "%"
		query = query.Where("name LIKE ? OR sku LIKE ? OR description LIKE ?", like, like, like)
	}
	if status != "" {
		query = query.Where("status = ?", status)
	}
	if isAvailable != nil {
		if *isAvailable {
			query = query.Where("status = ? AND stock_quantity > ?", "active", 0)
		} else {
			query = query.Where("status != ? OR stock_quantity <= ?", "active", 0)
		}
	}
	if minPrice != nil {
		query = query.Where("retail_price >= ?", *minPrice)
	}
	if maxPrice != nil {
		query = query.Where("retail_price <= ?", *maxPrice)
	}

	var total int64
	query.Model(&models.Product{}).Count(&total)

	var products []models.Product
	if err := query.Order("products.created_at desc").Limit(pageSize).Offset(offset).Find(&products).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch products", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	items := make([]map[string]interface{}, 0, len(products))
	for _, p := range products {
		items = append(items, serializeProduct(&p, "b2c", true, baseURL))
	}

	response.Success(c, http.StatusOK, "Company products retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetCompanyProductFilterOptions handles GET /api/v1/companies/:company_id/products/filter-options
// @Summary GetCompanyProductFilterOptions
// @Description Get filter options for company products
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products/filter-options [get]
func GetCompanyProductFilterOptions(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var globalCats []models.GlobalCategory
	database.DB.Find(&globalCats)

	var companyCats []models.CompanyCategory
	database.DB.Where("company_id = ?", company.ID).Find(&companyCats)

	globalItems := make([]map[string]interface{}, 0, len(globalCats))
	for _, cat := range globalCats {
		globalItems = append(globalItems, map[string]interface{}{
			"id":   cat.ID,
			"name": cat.Name,
		})
	}

	companyItems := make([]map[string]interface{}, 0, len(companyCats))
	for _, cat := range companyCats {
		companyItems = append(companyItems, map[string]interface{}{
			"id":      cat.ID,
			"name":    cat.Name,
			"company": map[string]interface{}{"id": company.ID, "name": company.Name},
			"created_at": cat.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Company product filters retrieved successfully", map[string]interface{}{
		"global_categories":  globalItems,
		"company_categories": companyItems,
	})
}

// GetCompanyProduct handles GET /api/v1/companies/:company_id/products/:product_id
// @Summary GetCompanyProduct
// @Description Get a single company product
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products/{product_id} [get]
func GetCompanyProduct(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var product models.Product
	if err := database.DB.
		Preload("Company").
		Preload("GlobalCategory").
		Preload("Categories").
		Preload("Options").
		Preload("PricingTiers").
		Preload("Images").
		Where("id = ? AND company_id = ?", productID, company.ID).First(&product).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Product not found", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product retrieved successfully", serializeProduct(&product, "b2c", true, baseURL))
}

// CreateCompanyProduct handles POST /api/v1/companies/:company_id/products
// @Summary CreateCompanyProduct
// @Description Create a product for a company
// @Tags Shop
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Param payload formData string true "JSON payload"
// @Param images formData file false "Product images"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products [post]
func CreateCompanyProduct(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	product, err := saveProductFromPayload(c, company.ID, nil)
	if err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product created successfully", serializeProduct(product, "b2c", true, baseURL))
}

// UpdateCompanyProduct handles PUT /api/v1/companies/:company_id/products/:product_id
// @Summary UpdateCompanyProduct
// @Description Update a company product
// @Tags Shop
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Param payload formData string true "JSON payload"
// @Param images formData file false "Product images"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products/{product_id} [put]
func UpdateCompanyProduct(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var existing models.Product
	if err := database.DB.Where("id = ? AND company_id = ?", productID, company.ID).First(&existing).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Product not found", nil)
		return
	}

	product, err := saveProductFromPayload(c, company.ID, &existing)
	if err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product updated successfully", serializeProduct(product, "b2c", true, baseURL))
}

// DeleteCompanyProduct handles DELETE /api/v1/companies/:company_id/products/:product_id
// @Summary DeleteCompanyProduct
// @Description Delete a company product
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/products/{product_id} [delete]
func DeleteCompanyProduct(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var product models.Product
	if err := database.DB.Where("id = ? AND company_id = ?", productID, company.ID).First(&product).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Product not found", nil)
		return
	}

	for _, img := range product.Images {
		_ = os.Remove(strings.TrimPrefix(img.Image, "/"))
	}

	if err := database.DB.Delete(&product).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete product", nil)
		return
	}

	response.Success(c, http.StatusOK, "Product deleted successfully", nil)
}

func saveProductFromPayload(c *gin.Context, companyID uint, existing *models.Product) (*models.Product, error) {
	payloadStr := c.PostForm("payload")
	var payload models.ProductCreateSchema
	if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
		return nil, err
	}

	var product models.Product
	if existing != nil {
		product = *existing
	} else {
		product = models.Product{
			CompanyID:     &companyID,
			Status:        "active",
			StockQuantity: 0,
			MinStockAlert: 5,
			Specs:         datatypes.JSON("{}"),
		}
	}

	product.Name = payload.Name
	product.SKU = payload.SKU
	product.GlobalCategoryID = payload.GlobalCategoryID
	product.Description = payload.Description
	product.CostPrice = payload.CostPrice
	product.RetailPrice = payload.RetailPrice
	product.WholesalePrice = payload.WholesalePrice
	product.Discount = payload.Discount
	product.StockQuantity = payload.StockQuantity
	product.MinStockAlert = payload.MinStockAlert
	product.Status = payload.Status
	if product.Status == "" {
		product.Status = "active"
	}
	if payload.Specs != nil {
		specsBytes, _ := json.Marshal(payload.Specs)
		product.Specs = datatypes.JSON(specsBytes)
	}

	if err := database.DB.Save(&product).Error; err != nil {
		return nil, err
	}

	// Replace categories
	if len(payload.CompanyCategoryIDs) > 0 {
		var cats []models.CompanyCategory
		database.DB.Where("id IN ?", payload.CompanyCategoryIDs).Find(&cats)
		database.DB.Model(&product).Association("Categories").Replace(cats)
	}

	// Replace options
	if len(payload.Options) > 0 {
		database.DB.Where("product_id = ?", product.ID).Delete(&models.ProductOption{})
		for _, opt := range payload.Options {
			database.DB.Create(&models.ProductOption{
				ProductID:      product.ID,
				Name:           opt.Name,
				Cost:           opt.Cost,
				RetailPrice:    opt.RetailPrice,
				WholesalePrice: opt.WholesalePrice,
				IsRequired:     opt.IsRequired,
			})
		}
	}

	// Replace pricing tiers
	if len(payload.PricingTiers) > 0 {
		database.DB.Where("product_id = ?", product.ID).Delete(&models.ProductPricingTier{})
		for _, tier := range payload.PricingTiers {
			database.DB.Create(&models.ProductPricingTier{
				ProductID: product.ID,
				Quantity:  tier.Quantity,
				UnitPrice: tier.UnitPrice,
			})
		}
	}

	// Handle images
	if payload.ReplaceImages {
		for _, img := range product.Images {
			_ = os.Remove(strings.TrimPrefix(img.Image, "/"))
		}
		database.DB.Model(&product).Association("Images").Clear()
	}

	form, err := c.MultipartForm()
	if err == nil {
		files := form.File["images"]
		for _, file := range files {
			path, err := utils.SaveUploadedFileWithName(c, file, "products/images")
			if err != nil {
				continue
			}
			img := models.ProductImage{Image: *path}
			database.DB.Create(&img)
			database.DB.Model(&product).Association("Images").Append(&img)
		}
	}

	database.DB.Preload("Company").Preload("GlobalCategory").Preload("Categories").Preload("Options").Preload("PricingTiers").Preload("Images").First(&product, product.ID)
	return &product, nil
}
