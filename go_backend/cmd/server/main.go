package main

import (
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	_ "watt/docs" // Import generated docs
	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/handlers/root"
	"watt/internal/routes"
	"watt/internal/services/fcm"
)

// @title SolarHub API
// @version 1.0
// @description SolarHub Backend API in Go
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

func main() {
	// Load configuration
	cfg := config.LoadConfig()

	// Connect to the database
	database.Connect(cfg)

	// Initialize Firebase Cloud Messaging
	if err := fcm.Initialize(cfg); err != nil {
		log.Fatal("Failed to initialize FCM: ", err)
	}

	// Set up Gin router
	router := gin.Default()
	router.RedirectTrailingSlash = false
	router.RedirectFixedPath = false

	// Create API grouping
	apiGroup := router.Group("/api")

	// App v1 grouping
	v1Group := apiGroup.Group("/v1")
	v1Group.Use(trailingSlashMiddleware())

	// Root (with and without trailing slash)
	v1Group.GET("", root.Welcome)
	v1Group.GET("/", root.Welcome)

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

	// Start server
	log.Printf("Starting server on port %s...\n", cfg.Port)
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatal("Failed to run server: ", err)
	}
}
