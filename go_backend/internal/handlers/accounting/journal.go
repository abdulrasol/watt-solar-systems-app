package accounting

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// ListJournalEntries handles GET /api/v1/accounting/:company_id/journal
func ListJournalEntries(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize
	ordering := c.DefaultQuery("ordering", "-date")

	query := database.DB.Model(&models.JournalEntry{}).Preload("Lines.Account").Where("company_id = ?", company.ID)
	if from := c.Query("date_from"); from != "" {
		query = query.Where("date >= ?", from)
	}
	if to := c.Query("date_to"); to != "" {
		query = query.Where("date <= ?", to)
	}
	if search := c.Query("search"); search != "" {
		query = query.Where("description LIKE ? OR reference LIKE ?", "%"+search+"%", "%"+search+"%")
	}

	orderCol := "date desc"
	switch ordering {
	case "date":
		orderCol = "date"
	case "created_at":
		orderCol = "created_at"
	case "-created_at":
		orderCol = "created_at desc"
	}

	var total int64
	query.Count(&total)

	var entries []models.JournalEntry
	query.Order(orderCol).Limit(pageSize).Offset(offset).Find(&entries)

	items := make([]map[string]interface{}, 0, len(entries))
	for _, e := range entries {
		items = append(items, serializeJournalEntry(&e))
	}

	response.Success(c, http.StatusOK, "Journal entries retrieved successfully.", paginationResponse(page, pageSize, total, items))
}

// GetJournalEntry handles GET /api/v1/accounting/:company_id/journal/:entry_id
func GetJournalEntry(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	entryID, _ := strconv.Atoi(c.Param("entry_id"))
	var entry models.JournalEntry
	if err := database.DB.Preload("Lines.Account").Where("id = ? AND company_id = ?", entryID, company.ID).First(&entry).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Journal entry not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Journal entry retrieved successfully.", serializeJournalEntry(&entry))
}
