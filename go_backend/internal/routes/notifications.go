package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/notifications"
	"watt/internal/middleware"
)

// SetupNotificationsRoutes registers /api/v1/notification/* routes
func SetupNotificationsRoutes(router *gin.RouterGroup, cfg *config.Config) {
	// Inject config into context for handlers that need it
	cfgMiddleware := func(c *gin.Context) {
		c.Set("cfg", cfg)
		c.Next()
	}

	// Public subscribe
	router.POST("/notification/subscribe", cfgMiddleware, notifications.Subscribe)

	// Authenticated
	auth := router.Group("/notification")
	auth.Use(cfgMiddleware)
	auth.Use(middleware.AuthMiddleware(cfg))
	{
		auth.POST("/unsubscribe", notifications.Unsubscribe)
		auth.GET("/devices", notifications.ListDevices)
		auth.POST("/tokens/:token_id/deactivate", notifications.DeactivateDevice)
		auth.GET("/history", notifications.History)
	}

	// In-app notifications (authenticated)
	inbox := router.Group("/notifications")
	inbox.Use(cfgMiddleware)
	inbox.Use(middleware.AuthMiddleware(cfg))
	{
		inbox.GET("", notifications.GetMyNotifications)
		inbox.POST("/:id/read", notifications.MarkNotificationRead)
	}

	// Admin
	admin := router.Group("/notification")
	admin.Use(cfgMiddleware)
	admin.Use(middleware.AuthMiddleware(cfg))
	admin.Use(middleware.SuperuserMiddleware())
	{
		admin.POST("/send-broadcast", notifications.SendBroadcast)
		admin.POST("/send-group", notifications.SendGroup)
		admin.POST("/send-user", notifications.SendUser)
		admin.POST("/send-topic/:topic", notifications.SendTopic)
		admin.GET("/statistics", notifications.Statistics)
	}
}
