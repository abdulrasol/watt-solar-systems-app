package offers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
)

// CompanyListOfferRequests handles GET /api/v1/companies/:company_id/offers/requests
func CompanyListOfferRequests(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

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

	response.Success(c, http.StatusOK, "Company offer requests retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// CompanyListOffers handles GET /api/v1/companies/:company_id/offers
func CompanyListOffers(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Offer{}).Preload("Involves").Where("company_id = ?", company.ID)
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

// CompanyReplyToOfferRequest handles POST /api/v1/companies/:company_id/offers/requests/:request_id/reply
func CompanyReplyToOfferRequest(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	requestID, _ := strconv.Atoi(c.Param("request_id"))
	var req models.OfferRequest
	if err := database.DB.First(&req, requestID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}

	var existing int64
	database.DB.Model(&models.Offer{}).Where("offer_request_id = ? AND company_id = ?", requestID, company.ID).Count(&existing)
	if existing > 0 {
		response.Error(c, http.StatusBadRequest, "You already sent an offer for this request", nil)
		return
	}

	var payload models.OfferCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	companyID := company.ID
	offer := models.Offer{
		UserID:          req.UserID,
		OfferRequestID:  req.ID,
		CompanyID:       &companyID,
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

	for _, item := range payload.TemplateInvolves {
		var template models.InvolvementTemplate
		if err := database.DB.Where("id = ? AND (company_id = ? OR company_id IS NULL)", item.TemplateID, company.ID).First(&template).Error; err != nil {
			continue
		}
		inv := models.OfferInvolvement{
			Name:      template.Name,
			Quantity:  item.Quantity,
			Cost:      template.Cost,
			CompanyID: &companyID,
		}
		database.DB.Create(&inv)
		database.DB.Model(&offer).Association("Involves").Append(&inv)
	}

	if req.Status == "open" {
		req.Status = "offered"
		database.DB.Save(&req)
	}

	database.DB.Preload("Company").Preload("Involves").First(&offer, offer.ID)
	response.Success(c, http.StatusOK, "Offer reply created successfully", serializeOffer(&offer))
}

// CompanyUpdateOffer handles PUT /api/v1/companies/:company_id/offers/:offer_id
func CompanyUpdateOffer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	offerID, _ := strconv.Atoi(c.Param("offer_id"))
	var offer models.Offer
	if err := database.DB.Preload("Involves").Where("id = ? AND company_id = ?", offerID, company.ID).First(&offer).Error; err != nil {
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
			if err := database.DB.Where("id = ? AND (company_id = ? OR company_id IS NULL)", item.TemplateID, company.ID).First(&template).Error; err != nil {
				continue
			}
			inv := models.OfferInvolvement{
				Name:      template.Name,
				Quantity:  item.Quantity,
				Cost:      template.Cost,
				CompanyID: &company.ID,
			}
			database.DB.Create(&inv)
			database.DB.Model(&offer).Association("Involves").Append(&inv)
		}
	}

	database.DB.Save(&offer)
	database.DB.Preload("Company").Preload("Involves").First(&offer, offer.ID)
	response.Success(c, http.StatusOK, "Offer updated successfully", serializeOffer(&offer))
}

// CompanyDeleteOffer handles DELETE /api/v1/companies/:company_id/offers/:offer_id
func CompanyDeleteOffer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	offerID, _ := strconv.Atoi(c.Param("offer_id"))
	var offer models.Offer
	if err := database.DB.Where("id = ? AND company_id = ?", offerID, company.ID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}
	if offer.Status == "accepted" {
		response.Error(c, http.StatusForbidden, "Cannot delete an accepted offer", nil)
		return
	}

	database.DB.Model(&offer).Association("Involves").Clear()
	database.DB.Delete(&offer)
	response.Success(c, http.StatusOK, "Offer deleted successfully", nil)
}
