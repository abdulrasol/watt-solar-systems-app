package offers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// ListInvolvementTemplates handles GET /api/v1/involves/
func ListInvolvementTemplates(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	var templates []models.InvolvementTemplate
	database.DB.Where("company_id = ? AND is_active = ?", member.CompanyID, true).Find(&templates)

	items := make([]map[string]interface{}, 0, len(templates))
	for _, t := range templates {
		items = append(items, map[string]interface{}{
			"id":        t.ID,
			"name":      t.Name,
			"cost":      t.Cost,
			"is_active": t.IsActive,
		})
	}

	response.Success(c, http.StatusOK, "Involvement templates retrieved successfully", items)
}

// CreateInvolvementTemplate handles POST /api/v1/involves/
func CreateInvolvementTemplate(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	var payload models.InvolvementTemplateCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	t := models.InvolvementTemplate{
		Name:      payload.Name,
		Cost:      payload.Cost,
		CompanyID: &member.CompanyID,
		IsActive:  true,
	}
	database.DB.Create(&t)
	response.Success(c, http.StatusOK, "Involvement template created successfully", map[string]interface{}{
		"id":   t.ID,
		"name": t.Name,
		"cost": t.Cost,
	})
}

// UpdateInvolvementTemplate handles PUT /api/v1/involves/:id
func UpdateInvolvementTemplate(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var t models.InvolvementTemplate
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&t).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Template not found", nil)
		return
	}

	var payload models.InvolvementTemplateCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	t.Name = payload.Name
	t.Cost = payload.Cost
	database.DB.Save(&t)
	response.Success(c, http.StatusOK, "Involvement template updated successfully", map[string]interface{}{
		"id":   t.ID,
		"name": t.Name,
		"cost": t.Cost,
	})
}

// DeleteInvolvementTemplate handles DELETE /api/v1/involves/:id
func DeleteInvolvementTemplate(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var t models.InvolvementTemplate
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&t).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Template not found", nil)
		return
	}

	t.IsActive = false
	database.DB.Save(&t)
	response.Success(c, http.StatusOK, "Item removed from catalog", nil)
}
