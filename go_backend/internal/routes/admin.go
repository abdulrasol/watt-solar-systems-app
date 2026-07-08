package routes

import (
	"watt/internal/config"
	"watt/internal/handlers"
	"watt/internal/middleware"

	"github.com/gin-gonic/gin"
)

// SetupAdminRoutes configures the admin routes
func SetupAdminRoutes(rg *gin.RouterGroup, cfg *config.Config) {
	adminHandler := handlers.NewAdminHandler()

	// Public admin routes
	rg.GET("/admin/config", adminHandler.GetConfigs)
	rg.GET("/admin/countries", adminHandler.GetCountries)
	rg.GET("/admin/cities", adminHandler.GetCities)
	rg.POST("/admin/feedbacks", adminHandler.CreateFeedback) // Actually public in Django

	adminGroup := rg.Group("/admin")
	// Protect admin routes with both AuthMiddleware (to get user_id) and SuperuserMiddleware (to check privileges)
	adminGroup.Use(middleware.AuthMiddleware(cfg), middleware.SuperuserMiddleware())
	{
		// Config
		adminGroup.POST("/config", adminHandler.CreateConfig)
		adminGroup.PUT("/config/:key", adminHandler.UpdateConfig)
		adminGroup.DELETE("/config/:key", adminHandler.DeleteConfig)

		// Currencies
		adminGroup.GET("/currencies", adminHandler.GetCurrencies)
		adminGroup.POST("/currencies", adminHandler.CreateCurrency)
		adminGroup.PUT("/currencies/:id", adminHandler.UpdateCurrency)
		adminGroup.DELETE("/currencies/:id", adminHandler.DeleteCurrency)

		// Countries (Write operations)
		adminGroup.POST("/countries", adminHandler.CreateCountry)
		adminGroup.PUT("/countries/:id", adminHandler.UpdateCountry)
		adminGroup.DELETE("/countries/:id", adminHandler.DeleteCountry)

		// Cities (Write operations)
		adminGroup.POST("/cities", adminHandler.CreateCity)
		adminGroup.PUT("/cities/:id", adminHandler.UpdateCity)
		adminGroup.DELETE("/cities/:id", adminHandler.DeleteCity)

		// Subscriptions
		adminGroup.GET("/subscriptions", adminHandler.GetSubscriptions)
		adminGroup.POST("/subscriptions", adminHandler.CreateSubscription)
		adminGroup.PUT("/subscriptions/:id", adminHandler.UpdateSubscription)
		adminGroup.DELETE("/subscriptions/:id", adminHandler.DeleteSubscription)

		// Categories
		adminGroup.GET("/categories", adminHandler.GetCategories)
		adminGroup.POST("/categories", adminHandler.CreateCategory)
		adminGroup.PUT("/categories/:id", adminHandler.UpdateCategory)
		adminGroup.DELETE("/categories/:id", adminHandler.DeleteCategory)

		// Notifications
		adminGroup.GET("/notifications", adminHandler.GetNotifications)

		// Feedbacks (Read and Update/Delete)
		adminGroup.GET("/feedbacks", adminHandler.GetFeedbacks)
		adminGroup.PUT("/feedback/s:id", adminHandler.UpdateFeedback) // Note: Django has /feedback/s{id} which is a typo, we match it.
		adminGroup.DELETE("/feedback/:id", adminHandler.DeleteFeedback)
	}
}
