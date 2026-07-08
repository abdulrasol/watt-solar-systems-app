package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetCompanyCategories handles GET /api/v1/companies/:company_id/categories
// @Summary GetCompanyCategories
// @Description Get categories for a company
// @Tags Company Operations
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/categories [get]
func GetCompanyCategories(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var categories []models.CompanyCategory
	if err := database.DB.Where("company_id = ?", company.ID).Order("created_at desc").Find(&categories).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب التصنيفات"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch categories", &msgUser)
		return
	}

	items := make([]map[string]interface{}, 0, len(categories))
	for _, cat := range categories {
		items = append(items, map[string]interface{}{
			"id":         cat.ID,
			"name":       cat.Name,
			"company":    cat.CompanyID,
			"created_at": cat.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	response.Success(c, http.StatusOK, "Categories retrieved successfully", map[string]interface{}{
		"items": items,
		"count": len(items),
	})
}

// CreateCompanyCategory handles POST /api/v1/companies/:company_id/categories
// @Summary CreateCompanyCategory
// @Description Create a category for a company
// @Tags Company Operations
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.CompanyCategorySchema true "Category"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/categories [post]
func CreateCompanyCategory(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.CompanyCategorySchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		msgUser := "بيانات غير صالحة"
		response.Error(c, http.StatusBadRequest, "Invalid payload", &msgUser)
		return
	}

	category := models.CompanyCategory{
		CompanyID: company.ID,
		Name:      payload.Name,
	}

	if err := database.DB.Create(&category).Error; err != nil {
		msgUser := "فشل في إنشاء التصنيف"
		response.Error(c, http.StatusInternalServerError, "Failed to create category", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Category created successfully", category)
}

// DeleteCompanyCategory handles DELETE /api/v1/companies/:company_id/categories/:category_id
// @Summary DeleteCompanyCategory
// @Description Delete a company category
// @Tags Company Operations
// @Security Bearer
// @Param category_id path int true "category_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/categories/{category_id} [delete]
func DeleteCompanyCategory(c *gin.Context) {
	company, _, ok := GetCompanyFromContext(c)
	if !ok {
		return
	}

	categoryID, err := strconv.Atoi(c.Param("category_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid category ID", nil)
		return
	}

	var category models.CompanyCategory
	if err := database.DB.Where("id = ? AND company_id = ?", categoryID, company.ID).First(&category).Error; err != nil {
		msgUser := "التصنيف غير موجود"
		response.Error(c, http.StatusNotFound, "Category not found", &msgUser)
		return
	}

	if err := database.DB.Delete(&category).Error; err != nil {
		msgUser := "فشل في حذف التصنيف"
		response.Error(c, http.StatusInternalServerError, "Failed to delete category", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Category deleted successfully", nil)
}
