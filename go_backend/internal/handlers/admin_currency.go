package handlers

import (
	"net/http"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"

	"github.com/gin-gonic/gin"
)

// GetCurrencies godoc
// @Summary      Get all currencies
// @Description  Retrieves all currencies
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.CurrencyOut}
// @Router       /admin/currencies [get]
func (h *AdminHandler) GetCurrencies(c *gin.Context) {
	var currencies []models.Currency
	database.DB.Find(&currencies)

	var result []models.CurrencyOut
	for _, curr := range currencies {
		result = append(result, models.CurrencyOut{
			ID:        curr.ID,
			Name:      curr.Name,
			Code:      curr.Code,
			Symbol:    curr.Symbol,
			IsDefault: curr.IsDefault,
			CreatedAt: curr.CreatedAt,
		})
	}

	response.Success(c, http.StatusOK, "Success", result)
}

// CreateCurrency godoc
// @Summary      Create a currency
// @Description  Creates a new currency
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        currency body models.CurrencySchema true "Currency data"
// @Success      200  {object}  response.APIResponse{body=models.CurrencyOut}
// @Router       /admin/currencies [post]
func (h *AdminHandler) CreateCurrency(c *gin.Context) {
	var req models.CurrencySchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	currency := models.Currency{
		Name:      req.Name,
		Code:      req.Code,
		Symbol:    req.Symbol,
		IsDefault: req.IsDefault,
	}

	database.DB.Create(&currency)

	response.Success(c, http.StatusOK, "Currency created successfully.", models.CurrencyOut{
		ID:        currency.ID,
		Name:      currency.Name,
		Code:      currency.Code,
		Symbol:    currency.Symbol,
		IsDefault: currency.IsDefault,
		CreatedAt: currency.CreatedAt,
	})
}

// UpdateCurrency godoc
// @Summary      Update a currency
// @Description  Updates an existing currency by ID
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Currency ID"
// @Param        currency body models.CurrencySchema true "Currency update data"
// @Success      200  {object}  response.APIResponse{body=models.CurrencyOut}
// @Router       /admin/currencies/{id} [put]
func (h *AdminHandler) UpdateCurrency(c *gin.Context) {
	id := c.Param("id")
	var req models.CurrencySchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var currency models.Currency
	if err := database.DB.First(&currency, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Currency not found.", nil)
		return
	}

	currency.Name = req.Name
	currency.Code = req.Code
	currency.Symbol = req.Symbol
	currency.IsDefault = req.IsDefault

	database.DB.Save(&currency)

	response.Success(c, http.StatusOK, "Currency updated successfully.", models.CurrencyOut{
		ID:        currency.ID,
		Name:      currency.Name,
		Code:      currency.Code,
		Symbol:    currency.Symbol,
		IsDefault: currency.IsDefault,
		CreatedAt: currency.CreatedAt,
	})
}

// DeleteCurrency godoc
// @Summary      Delete a currency
// @Description  Deletes an existing currency by ID
// @Tags         Admin API
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Currency ID"
// @Success      200  {object}  response.APIResponse
// @Router       /api/admin/currencies/{id} [delete]
func (h *AdminHandler) DeleteCurrency(c *gin.Context) {
	id := c.Param("id")

	var currency models.Currency
	if err := database.DB.First(&currency, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Currency not found.", nil)
		return
	}

	database.DB.Delete(&currency)
	response.Success(c, http.StatusOK, "Currency deleted successfully.", gin.H{})
}
