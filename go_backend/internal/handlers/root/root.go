package root

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Welcome handles GET /api/v1/
func Welcome(c *gin.Context) {
	c.JSON(http.StatusOK, map[string]interface{}{
		"status":        "active",
		"message":       "Welcome to Watt App API",
		"version":       "1.0",
		"documentation": "/api/v1/docs",
	})
}
