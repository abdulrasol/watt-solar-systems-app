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
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

// AdminListProducts handles GET /api/v1/admin/shop/products
// @Summary AdminListProducts
// @Description Admin list all products
// @Tags AdminShop
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/shop/products [get]
func AdminListProducts(c *gin.Context) {
	page, pageSize := parsePagination(c)
	search := c.Query("search")
	companyID := parseUintQuery(c, "company_id")
	status := c.Query("status")
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Product{}).
		Preload("Company").Preload("GlobalCategory").Preload("Categories").Preload("Options").Preload("PricingTiers").Preload("Images")

	if search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies c ON c.id = products.company_id").
			Where("products.name LIKE ? OR products.sku LIKE ? OR c.name LIKE ?", like, like, like)
	}
	if companyID != nil {
		query = query.Where("products.company_id = ?", *companyID)
	}
	if status != "" {
		query = query.Where("products.status = ?", status)
	}

	var total int64
	query.Count(&total)

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

	response.Success(c, http.StatusOK, "Products retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// AdminGetProduct handles GET /api/v1/admin/shop/products/:product_id
// @Summary AdminGetProduct
// @Description Admin get product
// @Tags AdminShop
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/shop/products/{product_id} [get]
func AdminGetProduct(c *gin.Context) {
	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var product models.Product
	if err := database.DB.
		Preload("Company").Preload("GlobalCategory").Preload("Categories").Preload("Options").Preload("PricingTiers").Preload("Images").
		First(&product, productID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Product not found", nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product retrieved successfully", serializeProduct(&product, "b2c", true, baseURL))
}

// AdminCreateProduct handles POST /api/v1/admin/shop/products
// @Summary AdminCreateProduct
// @Description Admin create product for any company
// @Tags AdminShop
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param payload formData string true "JSON payload"
// @Param images formData file false "Product images"
// @Success 200 {object} response.APIResponse
// @Router /admin/shop/products [post]
func AdminCreateProduct(c *gin.Context) {
	payloadStr := c.PostForm("payload")
	var payload models.AdminProductCreateSchema
	if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	var existing models.Product
	product, err := saveProductFromPayload(c, payload.CompanyID, &existing)
	if err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product created successfully", serializeProduct(product, "b2c", true, baseURL))
}

// AdminUpdateProduct handles PUT /api/v1/admin/shop/products/:product_id
// @Summary AdminUpdateProduct
// @Description Admin update product
// @Tags AdminShop
// @Accept multipart/form-data
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Param payload formData string true "JSON payload"
// @Param images formData file false "Product images"
// @Success 200 {object} response.APIResponse
// @Router /admin/shop/products/{product_id} [put]
func AdminUpdateProduct(c *gin.Context) {
	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var existing models.Product
	if err := database.DB.First(&existing, productID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Product not found", nil)
		return
	}

	payloadStr := c.PostForm("payload")
	var payload models.AdminProductUpdateSchema
	if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	companyID := existing.CompanyID
	if payload.CompanyID != nil {
		companyID = payload.CompanyID
	}

	product, err := saveAdminProductFromPayload(c, companyID, &existing, payload)
	if err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	baseURL := c.GetString("baseURL")
	response.Success(c, http.StatusOK, "Product updated successfully", serializeProduct(product, "b2c", true, baseURL))
}

// AdminDeleteProduct handles DELETE /api/v1/admin/shop/products/:product_id
// @Summary AdminDeleteProduct
// @Description Admin delete product
// @Tags AdminShop
// @Produce json
// @Security Bearer
// @Param product_id path int true "product_id"
// @Success 200 {object} response.APIResponse
// @Router /admin/shop/products/{product_id} [delete]
func AdminDeleteProduct(c *gin.Context) {
	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid product ID", nil)
		return
	}

	var product models.Product
	if err := database.DB.First(&product, productID).Error; err != nil {
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

func saveAdminProductFromPayload(c *gin.Context, companyID *uint, existing *models.Product, payload models.AdminProductUpdateSchema) (*models.Product, error) {
	product := *existing

	if payload.Name != nil {
		product.Name = *payload.Name
	}
	if payload.SKU != nil {
		product.SKU = payload.SKU
	}
	if payload.GlobalCategoryID != nil {
		product.GlobalCategoryID = payload.GlobalCategoryID
	}
	if payload.Description != nil {
		product.Description = payload.Description
	}
	if payload.CostPrice != nil {
		product.CostPrice = *payload.CostPrice
	}
	if payload.RetailPrice != nil {
		product.RetailPrice = *payload.RetailPrice
	}
	if payload.WholesalePrice != nil {
		product.WholesalePrice = *payload.WholesalePrice
	}
	if payload.Discount != nil {
		product.Discount = *payload.Discount
	}
	if payload.StockQuantity != nil {
		product.StockQuantity = *payload.StockQuantity
	}
	if payload.MinStockAlert != nil {
		product.MinStockAlert = *payload.MinStockAlert
	}
	if payload.Status != nil {
		product.Status = *payload.Status
	}
	if payload.Specs != nil {
		specsBytes, _ := json.Marshal(payload.Specs)
		product.Specs = datatypes.JSON(specsBytes)
	}

	product.CompanyID = companyID

	if err := database.DB.Save(&product).Error; err != nil {
		return nil, err
	}

	if len(payload.CompanyCategoryIDs) > 0 {
		var cats []models.CompanyCategory
		database.DB.Where("id IN ?", payload.CompanyCategoryIDs).Find(&cats)
		database.DB.Model(&product).Association("Categories").Replace(cats)
	}

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

func parseUintQuery(c *gin.Context, key string) *uint {
	val := c.Query(key)
	if val == "" {
		return nil
	}
	if u, err := strconv.ParseUint(val, 10, 64); err == nil {
		uv := uint(u)
		return &uv
	}
	return nil
}
