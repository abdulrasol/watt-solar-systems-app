package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers"
	"watt/internal/middleware"
)

// SetupUserRoutes registers the endpoints for the Users application.
func SetupUserRoutes(rg *gin.RouterGroup, cfg *config.Config) {
	usersGroup := rg.Group("/users")

	h := handlers.NewUserHandler(cfg)

	// Public routes
	usersGroup.POST("/login", h.Login)
	usersGroup.POST("/register", h.Register)
	usersGroup.GET("/:username", h.GetUser)
	usersGroup.POST("/password-reset", h.PasswordResetRequest)
	usersGroup.POST("/password-reset/validate-token", h.ValidateResetToken)
	usersGroup.POST("/password-reset/confirm", h.ConfirmPasswordReset)

	// Protected routes
	authGroup := usersGroup.Group("")
	authGroup.Use(middleware.AuthMiddleware(cfg))
	{
		authGroup.GET("/profile", h.GetProfile)
		authGroup.PUT("/profile", h.UpdateProfile)
		authGroup.POST("/delete-account", h.DeleteAccount)
		authGroup.PUT("/language", h.UpdateLanguage)

		// Admin only routes
		adminGroup := authGroup.Group("")
		adminGroup.Use(middleware.SuperuserMiddleware())
		{
			adminGroup.GET("", h.GetUsers)
			adminGroup.POST("/promote/:username", h.PromoteUser)
		}
	}
}
