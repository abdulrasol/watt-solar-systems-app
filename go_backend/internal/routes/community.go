package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/community"
	"watt/internal/middleware"
)

// SetupCommunityRoutes registers /api/v1/community/* routes
func SetupCommunityRoutes(router *gin.RouterGroup, cfg *config.Config) {
	// Public posts
	router.GET("/community/posts/", community.ListPosts)
	router.GET("/community/posts/:post_id", community.GetPost)

	// Auth-required posts
	auth := router.Group("/community")
	auth.Use(middleware.AuthMiddleware(cfg))
	{
		auth.POST("/posts/", community.CreatePost)
		auth.PUT("/posts/:post_id", community.UpdatePost)
		auth.DELETE("/posts/:post_id", community.DeletePost)

		auth.GET("/posts/:post_id/comments", community.ListComments)
		auth.POST("/posts/:post_id/comments", community.CreateComment)
		auth.PUT("/comments/:comment_id", community.UpdateComment)
		auth.DELETE("/comments/:comment_id", community.DeleteComment)
	}
}
