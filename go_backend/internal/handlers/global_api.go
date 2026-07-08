package handlers

import (
	"net/http"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"

	"github.com/gin-gonic/gin"
)

// GetDefaultCurrency godoc
// @Summary      Get default currency
// @Description  Returns the default currency for the application
// @Tags         Global API
// @Produce      json
// @Success      200  {object}  response.APIResponse{body=models.CurrencyOut}
// @Router       /currency/default [get]
func GetDefaultCurrency(c *gin.Context) {
	var currency models.Currency

	// Try to find the default currency
	if err := database.DB.Where("is_default = ?", true).First(&currency).Error; err != nil {
		// Fallback to first available currency
		if err := database.DB.First(&currency).Error; err != nil {
			msgUser := "Default currency not configured."
			response.Error(c, http.StatusNotFound, "No currencies found in the system.", &msgUser)
			return
		}
	}

	response.Success(c, http.StatusOK, "Success", models.CurrencyOut{
		ID:        currency.ID,
		Name:      currency.Name,
		Code:      currency.Code,
		Symbol:    currency.Symbol,
		IsDefault: currency.IsDefault,
		CreatedAt: currency.CreatedAt,
	})
}
