package handlers

import (
	"net/http"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct{}

func NewAdminHandler() *AdminHandler {
	return &AdminHandler{}
}

// GetConfigs godoc
// @Summary      Get all app configs
// @Description  Retrieves all global app configurations
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Success      200  {object}  response.APIResponse{body=[]models.ConfigOut}
// @Router       /admin/config [get]
func (h *AdminHandler) GetConfigs(c *gin.Context) {
	var configs []models.AppConfig
	database.DB.Find(&configs)

	var result []models.ConfigOut
	for _, conf := range configs {
		result = append(result, models.ConfigOut{
			Key:         conf.Key,
			Value:       conf.Value,
			Description: conf.Description,
			UpdatedAt:   conf.UpdatedAt,
		})
	}

	response.Success(c, http.StatusOK, "Success", result)
}

// CreateConfig godoc
// @Summary      Create a new app config
// @Description  Creates a new global app configuration
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        config body models.ConfigCreateSchema true "Config data"
// @Success      200  {object}  response.APIResponse{body=models.ConfigOut}
// @Router       /admin/config [post]
func (h *AdminHandler) CreateConfig(c *gin.Context) {
	var req models.ConfigCreateSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var existing models.AppConfig
	if err := database.DB.Where("key = ?", req.Key).First(&existing).Error; err == nil {
		response.Error(c, http.StatusBadRequest, "Configuration key already exists.", nil)
		return
	}

	config := models.AppConfig{
		Key:         req.Key,
		Value:       req.Value,
		Description: req.Description,
	}

	database.DB.Create(&config)

	response.Success(c, http.StatusOK, "Configuration created successfully.", models.ConfigOut{
		Key:         config.Key,
		Value:       config.Value,
		Description: config.Description,
		UpdatedAt:   config.UpdatedAt,
	})
}

// UpdateConfig godoc
// @Summary      Update an app config
// @Description  Updates an existing global app configuration by key
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        key path string true "Config Key"
// @Param        config body models.ConfigUpdateSchema true "Config update data"
// @Success      200  {object}  response.APIResponse{body=models.ConfigOut}
// @Router       /admin/config/{key} [put]
func (h *AdminHandler) UpdateConfig(c *gin.Context) {
	key := c.Param("key")
	var req models.ConfigUpdateSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var config models.AppConfig
	if err := database.DB.Where("key = ?", key).First(&config).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Configuration not found.", nil)
		return
	}

	if req.Value != nil {
		config.Value = *req.Value
	}
	if req.Description != nil {
		config.Description = req.Description
	}

	database.DB.Save(&config)

	response.Success(c, http.StatusOK, "Configuration updated successfully.", models.ConfigOut{
		Key:         config.Key,
		Value:       config.Value,
		Description: config.Description,
		UpdatedAt:   config.UpdatedAt,
	})
}

// DeleteConfig godoc
// @Summary      Delete an app config
// @Description  Deletes an existing global app configuration by key
// @Tags         Admin API
// @Produce      json
// @Security     BearerAuth
// @Param        key path string true "Config Key"
// @Success      200  {object}  response.APIResponse
// @Router       /api/admin/config/{key} [delete]
func (h *AdminHandler) DeleteConfig(c *gin.Context) {
	key := c.Param("key")

	var config models.AppConfig
	if err := database.DB.Where("key = ?", key).First(&config).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Configuration not found.", nil)
		return
	}

	database.DB.Delete(&config)
	response.Success(c, http.StatusOK, "Configuration deleted successfully.", gin.H{})
}
