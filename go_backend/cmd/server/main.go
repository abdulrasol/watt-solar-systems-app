package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
	"strings"

	_ "watt/docs" // Import generated docs
	"watt/internal/admin"
	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/handlers"
	"watt/internal/handlers/root"
	"watt/internal/response"
	"watt/internal/routes"
	"watt/internal/seed"
	"watt/internal/services/fcm"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title Watt API
// @version 1.0
// @description Watt Backend API in Go
// @BasePath /api/v1
// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization
// trailingSlashMiddleware strips trailing slashes from API paths (except docs/static)
// so routes work with or without a trailing slash like Django.
func trailingSlashMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		path := c.Request.URL.Path
		if path != "/" && strings.HasSuffix(path, "/") && !strings.Contains(path, "/docs/") && !strings.Contains(path, "/uploads/") {
			c.Request.URL.Path = strings.TrimSuffix(path, "/")
		}
		c.Next()
	}
}

// securityHeadersMiddleware adds baseline security headers to every response.
func securityHeadersMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("X-Content-Type-Options", "nosniff")
		c.Header("X-Frame-Options", "DENY")
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		c.Header("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
		if os.Getenv("GIN_MODE") == "release" {
			c.Header("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload")
		}
		c.Next()
	}
}

// baseURLMiddleware injects the configured public base URL into the request
// context so response builders can construct full media URLs.
func baseURLMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Set("baseURL", cfg.BaseURL)
		c.Next()
	}
}

// healthHandler returns the service health, including a DB connectivity check.
func healthHandler(c *gin.Context) {
	sqlDB, err := database.DB.DB()
	if err != nil {
		response.Error(c, http.StatusServiceUnavailable, "Database connection unavailable", nil)
		return
	}
	if err := sqlDB.Ping(); err != nil {
		response.Error(c, http.StatusServiceUnavailable, "Database ping failed", nil)
		return
	}
	response.Success(c, http.StatusOK, "healthy", gin.H{"status": "up"})
}

func main() {
	// Load configuration
	cfg := config.LoadConfig()

	// Enforce release mode by default for production safety.
	if os.Getenv("GIN_MODE") == "" {
		os.Setenv("GIN_MODE", "release")
	}
	gin.SetMode(os.Getenv("GIN_MODE"))

	// Connect to the database
	database.Connect(cfg)

	// Seed a default admin user if the database is empty (first run only).
	seed.EnsureDefaultAdmin()

	// Initialize Firebase Cloud Messaging
	if err := fcm.Initialize(cfg); err != nil {
		log.Fatal("Failed to initialize FCM: ", err)
	}

	// Set up Gin router
	router := gin.Default()
	router.RedirectTrailingSlash = false
	router.RedirectFixedPath = false
	router.Use(securityHeadersMiddleware())
	router.Use(baseURLMiddleware(cfg))

	// Load the reset-password HTML template.
	router.SetHTMLTemplate(template.Must(template.New("reset-password").Parse(handlers.ResetPasswordTemplate)))

	// Configure CORS
	router.Use(cors.New(cors.Config{
		AllowOrigins:     cfg.CORSAllowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * 60 * 60,
	}))

	// Serve static files (uploads)
	router.Static("/uploads", "./uploads")

	// Create API grouping
	apiGroup := router.Group("/api")

	// App v1 grouping
	v1Group := apiGroup.Group("/v1")
	v1Group.Use(trailingSlashMiddleware())

	// Root (with and without trailing slash)
	v1Group.GET("", root.Welcome)
	v1Group.GET("/", root.Welcome)

	// Health check
	v1Group.GET("/health", healthHandler)

	// Swagger route under /api/v1/docs
	v1Group.GET("/docs", func(c *gin.Context) {
		c.Redirect(http.StatusMovedPermanently, "/api/v1/docs/index.html")
	})
	v1Group.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Setup App Routes
	routes.SetupUserRoutes(v1Group, cfg)
	routes.SetupAdminRoutes(v1Group, cfg)
	routes.SetupGlobalRoutes(v1Group)
	routes.SetupCompanyRoutes(v1Group, cfg)
	routes.SetupShopRoutes(v1Group, cfg)
	routes.SetupOffersRoutes(v1Group, cfg)
	routes.SetupSystemsRoutes(v1Group, cfg)
	routes.SetupAccountingRoutes(v1Group, cfg)
	routes.SetupCommunityRoutes(v1Group, cfg)
	routes.SetupNotificationsRoutes(v1Group, cfg)

	// Web-based password reset page linked from emails.
	userHandler := handlers.NewUserHandler(cfg)
	router.GET("/reset-password", userHandler.ResetPasswordPage)
	router.POST("/reset-password", userHandler.ResetPasswordPage)

	// Admin dashboard routes (under /admin/config)
	admin.RegisterRoutes(router.Group("/"), cfg)

	// Redirect root path to admin login for convenience
	router.GET("/", func(c *gin.Context) {
		c.Redirect(http.StatusTemporaryRedirect, "/admin/login")
	})

	// Start server
	log.Printf("Starting server on port %s...\n", cfg.Port)
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatal("Failed to run server: ", err)
	}
}
