package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/systems"
	"watt/internal/middleware"
)

// SetupSystemsRoutes registers /systems and /admin/systems routes
func SetupSystemsRoutes(router *gin.RouterGroup, cfg *config.Config) {
	group := router.Group("/systems")
	group.Use(middleware.AuthMiddleware(cfg))
	{
		group.GET("/", systems.ListMySystems)
		group.POST("/", systems.CreateMySystem)
		group.GET("/:sys_id", systems.GetMySystem)
		group.PUT("/:sys_id", systems.UpdateMySystem)
		group.DELETE("/:sys_id", systems.DeleteMySystem)
	}

	admin := router.Group("/admin/systems")
	admin.Use(middleware.AuthMiddleware(cfg))
	admin.Use(middleware.SuperuserMiddleware())
	{
		admin.GET("/", systems.AdminListSystems)
		admin.PUT("/:sys_id/status", systems.AdminUpdateSystemStatus)
	}
}
