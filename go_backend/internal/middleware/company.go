package middleware

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// CompanyMemberMiddleware ensures the authenticated user is a member of the company
// specified by the "company_id" path parameter.
func CompanyMemberMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("user_id")
		if !exists {
			msgUser := "الرجاء تسجيل الدخول"
			response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
			c.Abort()
			return
		}

		companyID := c.Param("company_id")
		if companyID == "" {
			msgUser := "معرف الشركة غير موجود"
			response.Error(c, http.StatusBadRequest, "Missing Company ID", &msgUser)
			c.Abort()
			return
		}

		var member models.CompanyMember
		err := database.DB.Where("company_id = ? AND user_id = ?", companyID, userID).First(&member).Error
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				msgUser := "ليس لديك صلاحية للوصول إلى هذه الشركة"
				response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
			} else {
				msgUser := "خطأ في التحقق من الصلاحيات"
				response.Error(c, http.StatusInternalServerError, "Internal Server Error", &msgUser)
			}
			c.Abort()
			return
		}

		// Inject the member into context for handlers to check specific permissions
		c.Set("company_member", &member)
		c.Set("company_role", member.Role)
		c.Next()
	}
}

// CompanyAdminMiddleware ensures the user is an admin of the company
func CompanyAdminMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		role, exists := c.Get("company_role")
		if !exists || (role != "admin" && role != "manager") {
			msgUser := "تحتاج إلى صلاحيات مدير الشركة للقيام بهذا الإجراء"
			response.Error(c, http.StatusForbidden, "Forbidden: Admin only", &msgUser)
			c.Abort()
			return
		}
		c.Next()
	}
}
