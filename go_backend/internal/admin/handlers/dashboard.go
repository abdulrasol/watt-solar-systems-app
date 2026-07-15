package admin

import (
	"embed"
	"html/template"
	"net/http"
	"strings"
	"time"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services"
)

//go:embed base.html login.html
var templateFS embed.FS

var baseTemplate = template.Must(template.ParseFS(templateFS, "base.html"))
var loginTemplate = template.Must(template.ParseFS(templateFS, "login.html"))

type LoginPageData struct {
	Error string
}

type NavItem struct {
	Key   string
	Label string
	Icon  string
	Badge int
}

type NavGroup struct {
	Title string
	Items []NavItem
}

var navGroups = []NavGroup{
	{
		Title: "مساحة العمل",
		Items: []NavItem{{Key: "overview", Label: "نظرة عامة", Icon: "grid"}},
	},
	{
		Title: "الإدارة الأساسية",
		Items: []NavItem{
			{Key: "configs", Label: "الإعدادات", Icon: "toggle"},
			{Key: "users", Label: "المستخدمون", Icon: "users"},
			{Key: "countries", Label: "الدول", Icon: "globe"},
			{Key: "cities", Label: "المدن", Icon: "map"},
			{Key: "currencies", Label: "العملات", Icon: "coins"},
			{Key: "subscriptions", Label: "باقات الاشتراك", Icon: "badge"},
			{Key: "categories", Label: "التصنيفات العامة", Icon: "layers"},
		},
	},
	{
		Title: "إدارة الشركات",
		Items: []NavItem{
			{Key: "companies", Label: "الشركات", Icon: "building"},
			{Key: "company-types", Label: "أنواع الشركات", Icon: "layers"},
			{Key: "subscription-requests", Label: "طلبات الاشتراك", Icon: "clipboard"},
			{Key: "service-types", Label: "أنواع الخدمات", Icon: "spark"},
			{Key: "posters", Label: "البوسترات", Icon: "image"},
		},
	},
	{
		Title: "العمليات",
		Items: []NavItem{
			{Key: "systems", Label: "الأنظمة", Icon: "bolt"},
			{Key: "notifications", Label: "الإشعارات", Icon: "bell"},
			{Key: "feedbacks", Label: "الملاحظات", Icon: "message"},
			{Key: "offers", Label: "العروض والطلبات", Icon: "megaphone"},
			{Key: "products", Label: "المنتجات", Icon: "package"},
		},
	},
}

type DashboardContext struct {
	NavGroups     []NavGroup
	ActiveSection string
	SectionHTML   template.HTML
	Username      string
}

func GetSessionUsername(c *gin.Context) string {
	session := sessions.Default(c)
	username, _ := session.Get("username").(string)
	return username
}

func AdminAuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		session := sessions.Default(c)
		userID := session.Get("user_id")
		if userID == nil {
			c.Redirect(http.StatusFound, "/admin/login")
			c.Abort()
			return
		}
		c.Next()
	}
}

func LoginHandler(c *gin.Context) {
	if c.Request.Method == "GET" {
		session := sessions.Default(c)
		if session.Get("user_id") != nil {
			c.Redirect(http.StatusFound, "/admin/config/section/overview")
			return
		}
		c.Header("Content-Type", "text/html; charset=utf-8")
		loginTemplate.Execute(c.Writer, LoginPageData{})
		return
	}

	username := c.PostForm("username")
	password := c.PostForm("password")

	if username == "" || password == "" {
		c.Header("Content-Type", "text/html; charset=utf-8")
		loginTemplate.Execute(c.Writer, LoginPageData{Error: "يرجى إدخال اسم المستخدم وكلمة المرور"})
		return
	}

	var user models.User
	if err := database.DB.Where("username = ? AND is_deleted = ?", username, false).First(&user).Error; err != nil {
		c.Header("Content-Type", "text/html; charset=utf-8")
		loginTemplate.Execute(c.Writer, LoginPageData{Error: "اسم المستخدم أو كلمة المرور غير صحيحة"})
		return
	}

	if !services.VerifyDjangoPassword(password, user.Password) {
		c.Header("Content-Type", "text/html; charset=utf-8")
		loginTemplate.Execute(c.Writer, LoginPageData{Error: "اسم المستخدم أو كلمة المرور غير صحيحة"})
		return
	}

	if !user.IsSuperuser {
		c.Header("Content-Type", "text/html; charset=utf-8")
		loginTemplate.Execute(c.Writer, LoginPageData{Error: "ليس لديك صلاحية الوصول إلى لوحة التحكم"})
		return
	}

	session := sessions.Default(c)
	session.Set("user_id", user.ID)
	session.Set("username", user.Username)
	session.Save()

	c.Redirect(http.StatusFound, "/admin/config/section/overview")
}

func LogoutHandler(c *gin.Context) {
	session := sessions.Default(c)
	session.Clear()
	session.Save()
	c.Redirect(http.StatusFound, "/admin/login")
}

func RenderDashboard(c *gin.Context, section string, sectionHTML template.HTML) {
	username := GetSessionUsername(c)
	ctx := DashboardContext{
		NavGroups:     navGroups,
		ActiveSection: section,
		SectionHTML:   sectionHTML,
		Username:      username,
	}
	c.Header("Content-Type", "text/html; charset=utf-8")
	if err := baseTemplate.Execute(c.Writer, ctx); err != nil {
		c.String(http.StatusInternalServerError, "خطأ في عرض الصفحة")
	}
}

func renderSection(c *gin.Context, html string) {
	section := c.Param("section")
	if section == "" {
		section = "overview"
	}
	if strings.HasPrefix(c.GetHeader("HX-Request"), "true") {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusOK, html)
		return
	}
	RenderDashboard(c, section, template.HTML(html))
}

func formatTime(t time.Time) string {
	return t.Format("2006-01-02 15:04")
}

func formatDate(t time.Time) string {
	return t.Format("2006-01-02")
}

func safeStr(s *string) string {
	if s == nil {
		return "—"
	}
	return *s
}

func boolToActive(b bool) string {
	if b {
		return "active"
	}
	return "inactive"
}

func countQuery(model interface{}, condition string, args ...interface{}) int64 {
	var count int64
	database.DB.Model(model).Where(condition, args...).Count(&count)
	return count
}
