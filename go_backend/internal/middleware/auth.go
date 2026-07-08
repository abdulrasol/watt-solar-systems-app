package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"watt/internal/config"
	"watt/internal/response"
)

func AuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			msgUser := "الرجاء تسجيل الدخول"
			response.Error(c, http.StatusUnauthorized, "Missing Authorization Header", &msgUser)
			c.Abort()
			return
		}

		tokenString := authHeader
		parts := strings.Split(authHeader, " ")
		if len(parts) == 2 && parts[0] == "Bearer" {
			tokenString = parts[1]
		} else if len(parts) > 1 {
			msgUser := "تنسيق الرمز غير صحيح"
			response.Error(c, http.StatusUnauthorized, "Invalid Authorization Header", &msgUser)
			c.Abort()
			return
		}
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(cfg.JWTSecret), nil
		})

		if err != nil || !token.Valid {
			msgUser := "الرمز غير صالح أو منتهي الصلاحية"
			response.Error(c, http.StatusUnauthorized, "Invalid Token", &msgUser)
			c.Abort()
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			// Extract user_id
			userID := uint(claims["user_id"].(float64))
			c.Set("user_id", userID)
			c.Set("username", claims["username"])
			c.Next()
		} else {
			msgUser := "تنسيق الرمز غير مدعوم"
			response.Error(c, http.StatusUnauthorized, "Invalid Token Claims", &msgUser)
			c.Abort()
		}
	}
}
