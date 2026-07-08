package offers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// ListAvailableRequests handles GET /api/v1/offers/available-requests
func ListAvailableRequests(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	var company models.Company
	database.DB.Preload("City").First(&company, member.CompanyID)

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.OfferRequest{}).Preload("User").Preload("City")
	if company.CityID != nil {
		query = query.Where("all_cities = ? OR city_id = ?", true, *company.CityID)
	}
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}

	var total int64
	query.Count(&total)

	var reqs []models.OfferRequest
	query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&reqs)

	items := make([]map[string]interface{}, 0, len(reqs))
	for _, r := range reqs {
		items = append(items, serializeOfferRequest(&r, ""))
	}

	response.Success(c, http.StatusOK, "Available requests retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// ReplyToRequest handles POST /api/v1/offers/requests/:id/reply
func ReplyToRequest(c *gin.Context) {
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
	var req models.OfferRequest
	if err := database.DB.First(&req, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}

	var existing int64
	database.DB.Model(&models.Offer{}).Where("offer_request_id = ? AND company_id = ?", id, member.CompanyID).Count(&existing)
	if existing > 0 {
		response.Error(c, http.StatusBadRequest, "You already sent an offer for this request", nil)
		return
	}

	var payload models.OfferCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	offer := models.Offer{
		UserID:          req.UserID,
		OfferRequestID:  req.ID,
		CompanyID:       &member.CompanyID,
		Price:           payload.Price,
		TotalPanelPower: payload.TotalPanelPower,
		PanelPower:      payload.PanelPower,
		PanelCount:      payload.PanelCount,
		PanelNote:       payload.PanelNote,
		BatterySize:     payload.BatterySize,
		BatteryCount:    payload.BatteryCount,
		BatteryNote:     payload.BatteryNote,
		BatteryType:     payload.BatteryType,
		InverterSize:    payload.InverterSize,
		InverterCount:   payload.InverterCount,
		InverterNote:    payload.InverterNote,
		InverterType:    payload.InverterType,
		Note:            payload.Note,
		Status:          "pending",
	}
	database.DB.Create(&offer)

	// Snapshot templates
	for _, item := range payload.TemplateInvolves {
		var template models.InvolvementTemplate
		if err := database.DB.Where("id = ? AND (company_id = ? OR company_id IS NULL)", item.TemplateID, member.CompanyID).First(&template).Error; err != nil {
			continue
		}
		inv := models.OfferInvolvement{
			Name:      template.Name,
			Quantity:  item.Quantity,
			Cost:      template.Cost,
			CompanyID: &member.CompanyID,
		}
		database.DB.Create(&inv)
		database.DB.Model(&offer).Association("Involves").Append(&inv)
	}

	// Create lead customer
	if req.UserID != nil {
		var existingCust models.Customer
		if err := database.DB.Where("company_id = ? AND buyer_profile_id = ?", member.CompanyID, *req.UserID).First(&existingCust).Error; err != nil {
			var user models.User
			name := ""
			if err := database.DB.First(&user, *req.UserID).Error; err == nil {
				name = user.FirstName
			}
			database.DB.Create(&models.Customer{
				CompanyID:    member.CompanyID,
				CustomerType: "lead",
				BuyerUserID:  req.UserID,
				FullName:     &name,
				PhoneNumber:  &user.Phone,
				Email:        &user.Email,
			})
		}
	}

	if req.Status == "open" {
		req.Status = "offered"
		database.DB.Save(&req)
	}

	database.DB.Preload("Company").Preload("Involves").First(&offer, offer.ID)
	notifsvc.SendNewOfferNotification(&offer)
	response.Success(c, http.StatusOK, "Offer sent successfully", serializeOffer(&offer))
}

// ListCompanyOffers handles GET /api/v1/offers/my-offers
func ListCompanyOffers(c *gin.Context) {
	_, member, ok := getUserMember(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}
	if member == nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Offer{}).Preload("Company").Preload("Involves").Where("company_id = ?", member.CompanyID)
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}

	var total int64
	query.Count(&total)

	var offers []models.Offer
	query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&offers)

	items := make([]map[string]interface{}, 0, len(offers))
	for _, o := range offers {
		items = append(items, serializeOffer(&o))
	}

	response.Success(c, http.StatusOK, "Company offers retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetCompanyOffer handles GET /api/v1/offers/my-offers/:id
func GetCompanyOffer(c *gin.Context) {
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
	var offer models.Offer
	if err := database.DB.Preload("Company").Preload("Involves").Where("id = ? AND company_id = ?", id, member.CompanyID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Offer retrieved successfully", serializeOffer(&offer))
}

// UpdateCompanyOffer handles PUT /api/v1/offers/my-offers/:id
func UpdateCompanyOffer(c *gin.Context) {
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
	var offer models.Offer
	if err := database.DB.Preload("Involves").Where("id = ? AND company_id = ?", id, member.CompanyID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}
	if offer.Status == "accepted" {
		response.Error(c, http.StatusForbidden, "Cannot edit an accepted offer", nil)
		return
	}

	var payload models.OfferCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	offer.Price = payload.Price
	offer.TotalPanelPower = payload.TotalPanelPower
	offer.PanelPower = payload.PanelPower
	offer.PanelCount = payload.PanelCount
	offer.PanelNote = payload.PanelNote
	offer.BatterySize = payload.BatterySize
	offer.BatteryCount = payload.BatteryCount
	offer.BatteryNote = payload.BatteryNote
	offer.BatteryType = payload.BatteryType
	offer.InverterSize = payload.InverterSize
	offer.InverterCount = payload.InverterCount
	offer.InverterNote = payload.InverterNote
	offer.InverterType = payload.InverterType
	offer.Note = payload.Note

	if len(payload.TemplateInvolves) > 0 {
		database.DB.Model(&offer).Association("Involves").Clear()
		for _, item := range payload.TemplateInvolves {
			var template models.InvolvementTemplate
			if err := database.DB.Where("id = ? AND (company_id = ? OR company_id IS NULL)", item.TemplateID, member.CompanyID).First(&template).Error; err != nil {
				continue
			}
			inv := models.OfferInvolvement{
				Name:      template.Name,
				Quantity:  item.Quantity,
				Cost:      template.Cost,
				CompanyID: &member.CompanyID,
			}
			database.DB.Create(&inv)
			database.DB.Model(&offer).Association("Involves").Append(&inv)
		}
	}

	database.DB.Save(&offer)
	database.DB.Preload("Company").Preload("Involves").First(&offer, offer.ID)
	notifsvc.SendUpdatedOfferNotification(&offer)
	response.Success(c, http.StatusOK, "Offer updated", serializeOffer(&offer))
}

// DeleteCompanyOffer handles DELETE /api/v1/offers/my-offers/:id
func DeleteCompanyOffer(c *gin.Context) {
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
	var offer models.Offer
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}
	if offer.Status == "accepted" {
		response.Error(c, http.StatusForbidden, "Cannot delete an accepted offer", nil)
		return
	}

	database.DB.Model(&offer).Association("Involves").Clear()
	database.DB.Delete(&offer)
	response.Success(c, http.StatusOK, "Offer deleted", nil)
}

// FinishCompanyOffer handles POST /api/v1/offers/my-offers/:id/finish
func FinishCompanyOffer(c *gin.Context) {
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
	var offer models.Offer
	if err := database.DB.Where("id = ? AND company_id = ?", id, member.CompanyID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}
	offer.Status = "pending"
	database.DB.Save(&offer)
	response.Success(c, http.StatusOK, "Offer submitted to user", nil)
}

// CompleteCompanyOffer handles POST /api/v1/offers/my-offers/:id/complete
func CompleteCompanyOffer(c *gin.Context) {
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
	var offer models.Offer
	if err := database.DB.Preload("OfferRequest").Where("id = ? AND company_id = ?", id, member.CompanyID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}
	if offer.Status != "accepted" {
		response.Error(c, http.StatusBadRequest, "Only accepted offers can be marked as completed", nil)
		return
	}

	offer.Status = "completed"
	database.DB.Save(&offer)
	if offer.OfferRequest != nil {
		offer.OfferRequest.Status = "closed"
		database.DB.Save(offer.OfferRequest)
	}
	response.Success(c, http.StatusOK, "Work marked as completed", nil)
}
