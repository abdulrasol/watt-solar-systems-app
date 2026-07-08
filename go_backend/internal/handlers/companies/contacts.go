package companies

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// GetContacts handles GET /api/company/{company_id}/contacts
// @Security Bearer
// @Summary GetContacts
// @Description GetContacts
// @Tags Companies Contacts
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/contacts [get]
func GetContacts(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var contacts []models.Contact
	if err := database.DB.Where("company_id = ?", member.CompanyID).Find(&contacts).Error; err != nil {
		msgUser := "حدث خطأ أثناء جلب جهات الاتصال"
		response.Error(c, http.StatusInternalServerError, "Failed to fetch contacts", &msgUser)
		return
	}

	data := make([]map[string]interface{}, 0, len(contacts))
	for _, contact := range contacts {
		data = append(data, map[string]interface{}{
			"id":         contact.ID,
			"name":       contact.Name,
			"email":      contact.Email,
			"phone":      contact.Phone,
			"notes":      contact.Notes,
			"company":    contact.CompanyID,
			"created_at": contact.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	c.JSON(http.StatusOK, map[string]interface{}{
		"items": data,
		"count": len(data),
	})
}

// CreateContact handles POST /api/company/{company_id}/contacts
// @Accept json
// @Produce json
// @Param request body models.ContactSchema true "Contact details"
// @Security Bearer
// @Summary CreateContact
// @Description CreateContact
// @Tags Companies Contacts
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/contacts [post]
func CreateContact(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	var payload struct {
		Name  string  `json:"name" binding:"required"`
		Email *string `json:"email"`
		Phone string  `json:"phone"`
		Notes *string `json:"notes"`
	}

	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid JSON payload", nil)
		return
	}

	contact := models.Contact{
		CompanyID: member.CompanyID,
		Name:      payload.Name,
		Email:     payload.Email,
		Phone:     payload.Phone,
		Notes:     payload.Notes,
	}

	if err := database.DB.Create(&contact).Error; err != nil {
		msgUser := "حدث خطأ أثناء إضافة جهة الاتصال"
		response.Error(c, http.StatusInternalServerError, "Failed to create contact", &msgUser)
		return
	}

	response.Success(c, http.StatusOK, "Contact created successfully.", map[string]interface{}{
		"id":         contact.ID,
		"name":       contact.Name,
		"email":      contact.Email,
		"phone":      contact.Phone,
		"notes":      contact.Notes,
		"company":    contact.CompanyID,
		"created_at": contact.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

// DeleteContact handles DELETE /api/company/{company_id}/contacts/{contact_id}
// @Security Bearer
// @Summary DeleteContact
// @Description DeleteContact
// @Tags Companies Contacts
// @Param company_id path int true "company_id"
// @Param contact_id path int true "contact_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/contacts/{contact_id} [delete]
func DeleteContact(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		return
	}

	idStr := c.Param("contact_id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Contact ID", nil)
		return
	}

	var contact models.Contact
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&contact).Error; err != nil {
		msgUser := "جهة الاتصال غير موجودة"
		response.Error(c, http.StatusNotFound, "Contact not found", &msgUser)
		return
	}

	database.DB.Delete(&contact)

	response.Success(c, http.StatusOK, "Contact deleted successfully.", map[string]interface{}{})
}
