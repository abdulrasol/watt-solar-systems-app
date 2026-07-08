package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

// AdminCreateCompanyType handles POST /api/v1/admin/companies/types
// @Summary AdminCreateCompanyType
// @Description AdminCreateCompanyType
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param request body models.AdminCompanyTypeCreateSchema true "Payload"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/types [post]
func AdminCreateCompanyType(c *gin.Context) {
	var payload models.AdminCompanyTypeCreateSchema

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	ctype := models.CompanyType{
		CType: payload.CType,
		Name:  payload.Name,
	}

	if err := database.DB.Create(&ctype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create company type", nil)
		return
	}

	response.Success(c, http.StatusCreated, "Company type created successfully", ctype)
}

// AdminUpdateCompanyType handles PUT /api/v1/admin/companies/types/{id}
// @Summary AdminUpdateCompanyType
// @Description AdminUpdateCompanyType
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param request body models.AdminCompanyTypeUpdateSchema true "Payload"
// @Param id path int true "id"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/types/{id} [put]
func AdminUpdateCompanyType(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.Atoi(idStr)

	var payload models.AdminCompanyTypeUpdateSchema

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	var ctype models.CompanyType
	if err := database.DB.First(&ctype, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Company type not found", nil)
		return
	}

	if payload.CType != "" {
		ctype.CType = payload.CType
	}
	if payload.Name != "" {
		ctype.Name = payload.Name
	}

	if err := database.DB.Save(&ctype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update company type", nil)
		return
	}

	response.Success(c, http.StatusOK, "Company type updated successfully", ctype)
}

// AdminDeleteCompanyType handles DELETE /api/v1/admin/companies/types/{id}
// @Summary AdminDeleteCompanyType
// @Description AdminDeleteCompanyType
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param id path int true "id"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/types/{id} [delete]
func AdminDeleteCompanyType(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.Atoi(idStr)

	var ctype models.CompanyType
	if err := database.DB.First(&ctype, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Company type not found", nil)
		return
	}

	if err := database.DB.Delete(&ctype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete company type", nil)
		return
	}

	response.Success(c, http.StatusOK, "Company type deleted successfully", nil)
}

// AdminCreateServiceType handles POST /api/v1/admin/companies/service-types
// @Summary AdminCreateServiceType
// @Description AdminCreateServiceType
// @Tags Admin Companies API
// @Accept multipart/form-data
// @Produce json
// @Param name formData string true "Name"
// @Param description formData string false "Description"
// @Param image formData file false "Image"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/service-types [post]
func AdminCreateServiceType(c *gin.Context) {
	var payload models.ServiceTypeCreateSchema

	if err := c.ShouldBind(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	imagePath, err := utils.SaveUploadedFileOptional(c, "image", "service_type_images")
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to save image", nil)
		return
	}

	stype := models.ServiceType{
		Name:        payload.Name,
		Description: payload.Description,
		Image:       imagePath,
	}

	if err := database.DB.Create(&stype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create service type", nil)
		return
	}

	response.Success(c, http.StatusCreated, "Service type created successfully", SerializeServiceType(&stype, nil))
}

// AdminUpdateServiceType handles PUT /api/v1/admin/companies/service-types/{id}
// @Summary AdminUpdateServiceType
// @Description AdminUpdateServiceType
// @Tags Admin Companies API
// @Accept multipart/form-data
// @Produce json
// @Param name formData string false "Name"
// @Param description formData string false "Description"
// @Param image formData file false "Image"
// @Param id path int true "id"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/service-types/{id} [put]
func AdminUpdateServiceType(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.Atoi(idStr)

	var payload models.ServiceTypeUpdateSchema

	if err := c.ShouldBind(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	var stype models.ServiceType
	if err := database.DB.First(&stype, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Service type not found", nil)
		return
	}

	if payload.Name != nil {
		stype.Name = *payload.Name
	}
	if payload.Description != nil {
		stype.Description = payload.Description
	}

	imagePath, err := utils.SaveUploadedFileOptional(c, "image", "service_type_images")
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to save image", nil)
		return
	}
	if imagePath != nil {
		stype.Image = imagePath
	}

	if err := database.DB.Save(&stype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update service type", nil)
		return
	}

	response.Success(c, http.StatusOK, "Service type updated successfully", SerializeServiceType(&stype, nil))
}

// AdminDeleteServiceType handles DELETE /api/v1/admin/companies/service-types/{id}
// @Summary AdminDeleteServiceType
// @Description AdminDeleteServiceType
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param id path int true "id"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/service-types/{id} [delete]
func AdminDeleteServiceType(c *gin.Context) {
	idStr := c.Param("id")
	id, _ := strconv.Atoi(idStr)

	var stype models.ServiceType
	if err := database.DB.First(&stype, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Service type not found", nil)
		return
	}

	if err := database.DB.Delete(&stype).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete service type", nil)
		return
	}

	response.Success(c, http.StatusOK, "Service type deleted successfully", nil)
}

// AdminCreateCatalogService handles POST /api/v1/admin/companies/catalog/services
// @Summary AdminCreateCatalogService
// @Description AdminCreateCatalogService
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param request body models.CompanyServiceCatalogCreateSchema true "Payload"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/catalog/services [post]
func AdminCreateCatalogService(c *gin.Context) {
	var payload models.CompanyServiceCatalogCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	desc := ""
	if payload.Description != nil {
		desc = *payload.Description
	}

	service := models.CompanyServiceCatalog{
		Code:        payload.Code,
		Name:        payload.Name,
		Description: desc,
		Category:    payload.Category,
		IsActive:    payload.IsActive,
		SortOrder:   payload.SortOrder,
		Route:       payload.Route,
		Icon:        payload.Icon,
	}

	if err := database.DB.Create(&service).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create catalog service", nil)
		return
	}

	response.Success(c, http.StatusCreated, "Catalog service created successfully", service)
}

// AdminUpdateCatalogService handles PUT /api/v1/admin/companies/catalog/services/{service_code}
// @Summary AdminUpdateCatalogService
// @Description AdminUpdateCatalogService
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param request body models.CompanyServiceCatalogUpdateSchema true "Payload"
// @Param service_code path string true "service_code"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/catalog/services/{service_code} [put]
func AdminUpdateCatalogService(c *gin.Context) {
	code := c.Param("service_code")

	var payload models.CompanyServiceCatalogUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	var service models.CompanyServiceCatalog
	if err := database.DB.Where("code = ?", code).First(&service).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Catalog service not found", nil)
		return
	}

	if payload.Name != nil {
		service.Name = *payload.Name
	}
	if payload.Description != nil {
		service.Description = *payload.Description
	}
	if payload.Category != nil {
		service.Category = *payload.Category
	}
	if payload.IsActive != nil {
		service.IsActive = *payload.IsActive
	}
	if payload.SortOrder != nil {
		service.SortOrder = *payload.SortOrder
	}
	if payload.Route != nil {
		service.Route = payload.Route
	}
	if payload.Icon != nil {
		service.Icon = payload.Icon
	}

	if err := database.DB.Save(&service).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update catalog service", nil)
		return
	}

	response.Success(c, http.StatusOK, "Catalog service updated successfully", service)
}

// AdminDeleteCatalogService handles DELETE /api/v1/admin/companies/catalog/services/{service_code}
// @Summary AdminDeleteCatalogService
// @Description AdminDeleteCatalogService
// @Tags Admin Companies API
// @Accept json
// @Produce json
// @Param service_code path string true "service_code"
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /admin/companies/catalog/services/{service_code} [delete]
func AdminDeleteCatalogService(c *gin.Context) {
	code := c.Param("service_code")

	var service models.CompanyServiceCatalog
	if err := database.DB.Where("code = ?", code).First(&service).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Catalog service not found", nil)
		return
	}

	if err := database.DB.Delete(&service).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete catalog service", nil)
		return
	}

	response.Success(c, http.StatusOK, "Catalog service deleted successfully", nil)
}
