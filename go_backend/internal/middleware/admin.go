package middleware

import (
	"net/http"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"

	"github.com/gin-gonic/gin"
)

// SuperuserMiddleware ensures the user is a superuser
func SuperuserMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("user_id")
		if !exists {
			msgUser := "المستخدم غير مصادق عليه"
			response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
			c.Abort()
			return
		}

		var user models.User
		if err := database.DB.First(&user, userID).Error; err != nil {
			msgUser := "المستخدم غير موجود"
			response.Error(c, http.StatusUnauthorized, "User not found", &msgUser)
			c.Abort()
			return
		}

		if !user.IsSuperuser {
			msgUser := "لا تملك صلاحية الوصول"
			response.Error(c, http.StatusForbidden, "Forbidden: Superuser required", &msgUser)
			c.Abort()
			return
		}

		c.Set("is_superuser", true)
		c.Next()
	}
}
