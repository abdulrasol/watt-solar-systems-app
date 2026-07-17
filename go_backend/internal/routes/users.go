package routes

import (
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers"
	"watt/internal/middleware"
)

// SetupUserRoutes registers the endpoints for the Users application.
func SetupUserRoutes(rg *gin.RouterGroup, cfg *config.Config) {
	usersGroup := rg.Group("/users")

	h := handlers.NewUserHandler(cfg)

	// Rate limiter for public auth endpoints: 10 requests per minute per IP.
	authLimiter := middleware.NewRateLimiter(10.0/60.0, 10)
	authLimiter.Cleanup(10 * time.Minute)
	publicAuth := usersGroup.Group("")
	publicAuth.Use(authLimiter.Middleware())

	// Public routes
	publicAuth.POST("/login", h.Login)
	publicAuth.POST("/register", h.Register)
	publicAuth.POST("/password-reset", h.PasswordResetRequest)
	publicAuth.POST("/password-reset/validate-token", h.ValidateResetToken)
	publicAuth.POST("/password-reset/confirm", h.ConfirmPasswordReset)

	// Public profile lookup (less sensitive, no strict rate limit)
	usersGroup.GET("/:username", h.GetUser)

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
