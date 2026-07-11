package admin

import (
	"embed"
	"html/template"
	"math"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

//go:embed crud_section.html form_template.html
var crudTemplateFS embed.FS

var crudSectionTemplate = template.Must(template.New("crud_section.html").Funcs(template.FuncMap{
	"add": func(a, b int) int { return a + b },
	"sub": func(a, b int) int { return a - b },
	"seq": func(n int) []int { r := make([]int, n); for i := 0; i < n; i++ { r[i] = i + 1 }; return r },
}).ParseFS(crudTemplateFS, "crud_section.html"))

var formTemplate = template.Must(template.New("form_template.html").ParseFS(crudTemplateFS, "form_template.html"))

type SelectOption struct {
	Value string
	Label string
}

type FieldDef struct {
	Key      string
	Label    string
	Type     string // "text", "number", "bool", "select", "textarea", "json", "password"
	Required bool
	Options  []SelectOption
}

type RowData struct {
	ID    string
	Cells []string
}

type FormData struct {
	Action string
	Method string // "post" or "put"
	Fields []FieldDef
	Data   map[string]string
	Error  string
}

func renderForm(c *gin.Context, form FormData) {
	c.Header("Content-Type", "text/html; charset=utf-8")
	formTemplate.Execute(c.Writer, form)
}

func renderFormError(c *gin.Context, form FormData, errMsg string) {
	form.Error = errMsg
	c.Header("Content-Type", "text/html; charset=utf-8")
	c.Status(http.StatusUnprocessableEntity)
	formTemplate.Execute(c.Writer, form)
}

type CRUDPageData struct {
	Title       string
	Description string
	Section     string
	Columns     []FieldDef
	Labels      []string // column labels for responsive table
	HasActions  bool
	AllowCreate bool
	AllowEdit   bool
	AllowDelete bool
	Rows        []RowData
	Total       int
	Page        int
	PerPage     int
	TotalPages  int
	Filters     map[string]string
}

type Pagination struct {
	Page       int
	PerPage    int
	Total      int
	TotalPages int
}

func parsePagination(c *gin.Context) Pagination {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	if page < 1 {
		page = 1
	}
	perPage := 15
	return Pagination{
		Page:    page,
		PerPage: perPage,
	}
}

func (p Pagination) CalcTotal(total int) Pagination {
	p.Total = total
	p.TotalPages = int(math.Ceil(float64(total) / float64(p.PerPage)))
	if p.TotalPages < 1 {
		p.TotalPages = 1
	}
	return p
}

func (p Pagination) Offset() int {
	return (p.Page - 1) * p.PerPage
}

func parseFilters(c *gin.Context, columns []FieldDef) map[string]string {
	filters := map[string]string{}
	for _, col := range columns {
		if q := c.Query("q_" + col.Key); q != "" {
			filters[col.Key] = q
		}
	}
	return filters
}

func applyFilter(c *gin.Context, query *gorm.DB, colName, clause string) *gorm.DB {
	if q := c.Query("q_" + colName); q != "" {
		return query.Where(clause, "%"+q+"%")
	}
	return query
}

func applyFilterCountry(c *gin.Context, query *gorm.DB, colName string) *gorm.DB {
	if q := c.Query("q_" + colName); q != "" {
		return query.Where("country_id IN (SELECT id FROM countries WHERE name LIKE ?)", "%"+q+"%")
	}
	return query
}

func renderCRUDTable(c *gin.Context, data CRUDPageData) {
	s := c.Param("section")
	if s == "" {
		s = data.Section
	}
	data.Section = s
	data.HasActions = data.AllowCreate || data.AllowEdit || data.AllowDelete
	if data.Filters == nil {
		data.Filters = map[string]string{}
	}
	if len(data.Labels) == 0 {
		for _, col := range data.Columns {
			data.Labels = append(data.Labels, col.Label)
		}
	}
	renderSection(c, execCRUDTemplate(data))
}

func execCRUDTemplate(data CRUDPageData) string {
	var buf strings.Builder
	if err := crudSectionTemplate.Execute(&buf, data); err != nil {
		return "<p>خطأ في عرض القسم</p>"
	}
	return buf.String()
}

// Bool helpers for template rendering
func boolYesNo(b bool) string {
	if b {
		return "نعم"
	}
	return "لا"
}

func boolActiveInactive(b bool) string {
	if b {
		return `<span class="badge badge-active">مفعل</span>`
	}
	return `<span class="badge badge-inactive">غير مفعل</span>`
}

func boolBadge(b bool, activeLabel, inactiveLabel string) string {
	if b {
		return `<span class="badge badge-active">` + activeLabel + `</span>`
	}
	return `<span class="badge badge-inactive">` + inactiveLabel + `</span>`
}

func statusBadge(status string) string {
	switch status {
	case "active":
		return `<span class="badge badge-active">نشط</span>`
	case "pending":
		return `<span class="badge badge-warning">معلق</span>`
	case "inactive":
		return `<span class="badge badge-inactive">غير نشط</span>`
	default:
		return `<span class="badge badge-inactive">` + status + `</span>`
	}
}

func badgeHTML(label, class string) string {
	return `<span class="badge badge-` + class + `">` + label + `</span>`
}
