package admin

import (
	"os"

	"github.com/gin-contrib/sessions"
	"github.com/gin-contrib/sessions/cookie"
	"github.com/gin-gonic/gin"
	handlers "watt/internal/admin/handlers"
	"watt/internal/config"
)

func RegisterRoutes(rg *gin.RouterGroup, cfg *config.Config) {
	store := cookie.NewStore([]byte(cfg.AdminCookieSecret))
	store.Options(sessions.Options{
		Path:     "/",
		MaxAge:   86400 * 30,
		HttpOnly: true,
		// Secure=true only in release mode so local HTTP dev works without HTTPS.
		Secure:   os.Getenv("GIN_MODE") == "release",
		SameSite: 0,
	})
	rg.Use(sessions.Sessions("admin_session", store))

	rg.GET("/admin/login", handlers.LoginHandler)
	rg.POST("/admin/login", handlers.LoginHandler)
	rg.GET("/admin/logout", handlers.LogoutHandler)

	adminGroup := rg.Group("/admin/config")
	adminGroup.Use(handlers.AdminAuthMiddleware())

	adminGroup.GET("", func(c *gin.Context) {
		c.Redirect(302, "/admin/config/section/overview")
	})

	adminGroup.GET("/section/:section", handlers.HandleSection)

	// Countries CRUD
	adminGroup.GET("/countries/create", handlers.CreateCountryForm)
	adminGroup.POST("/countries/create", handlers.CreateCountry)
	adminGroup.GET("/countries/:id/edit", handlers.EditCountryForm)
	adminGroup.PUT("/countries/:id/edit", handlers.EditCountry)
	adminGroup.DELETE("/countries/:id", handlers.DeleteCountry)

	// Cities CRUD
	adminGroup.GET("/cities/create", handlers.CreateCityForm)
	adminGroup.POST("/cities/create", handlers.CreateCity)
	adminGroup.GET("/cities/:id/edit", handlers.EditCityForm)
	adminGroup.PUT("/cities/:id/edit", handlers.EditCity)
	adminGroup.DELETE("/cities/:id", handlers.DeleteCity)

	// Currencies CRUD
	adminGroup.GET("/currencies/create", handlers.CreateCurrencyForm)
	adminGroup.POST("/currencies/create", handlers.CreateCurrency)
	adminGroup.GET("/currencies/:id/edit", handlers.EditCurrencyForm)
	adminGroup.PUT("/currencies/:id/edit", handlers.EditCurrency)
	adminGroup.DELETE("/currencies/:id", handlers.DeleteCurrency)

	// Subscriptions CRUD
	adminGroup.GET("/subscriptions/create", handlers.CreateSubscriptionForm)
	adminGroup.POST("/subscriptions/create", handlers.CreateSubscription)
	adminGroup.GET("/subscriptions/:id/edit", handlers.EditSubscriptionForm)
	adminGroup.PUT("/subscriptions/:id/edit", handlers.EditSubscription)
	adminGroup.DELETE("/subscriptions/:id", handlers.DeleteSubscription)

	// Company Types CRUD
	adminGroup.GET("/company-types/create", handlers.CreateCompanyTypeForm)
	adminGroup.POST("/company-types/create", handlers.CreateCompanyType)
	adminGroup.GET("/company-types/:id/edit", handlers.EditCompanyTypeForm)
	adminGroup.PUT("/company-types/:id/edit", handlers.EditCompanyType)
	adminGroup.DELETE("/company-types/:id", handlers.DeleteCompanyType)

	// Service Types CRUD
	adminGroup.GET("/service-types/create", handlers.CreateServiceTypeForm)
	adminGroup.POST("/service-types/create", handlers.CreateServiceType)
	adminGroup.GET("/service-types/:id/edit", handlers.EditServiceTypeForm)
	adminGroup.PUT("/service-types/:id/edit", handlers.EditServiceType)
	adminGroup.DELETE("/service-types/:id", handlers.DeleteServiceType)

	staticGroup := rg.Group("/admin/static")
	staticGroup.Static("/css", "internal/admin/static/css")
	staticGroup.Static("/js", "internal/admin/static/js")
}
