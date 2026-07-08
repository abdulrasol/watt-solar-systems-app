package routes

import (
	"watt/internal/handlers"

	"github.com/gin-gonic/gin"
)

// SetupGlobalRoutes configures the global public routes
func SetupGlobalRoutes(rg *gin.RouterGroup) {
	globalGroup := rg.Group("/global/currency")
	{
		globalGroup.GET("/default", handlers.GetDefaultCurrency)
	}
}
