package offers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// CreateRequest handles POST /api/v1/offers/requests
func CreateRequest(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	var payload models.OfferRequestCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	var user models.User
	database.DB.First(&user, userID)

	req := models.OfferRequest{
		UserID:              &userID,
		CityID:              payload.CityID,
		AllCities:           payload.AllCities,
		TotalPanelPower:     payload.TotalPanelPower,
		PanelPower:          payload.PanelPower,
		PanelCount:          payload.PanelCount,
		PanelNote:           payload.PanelNote,
		TotalBatteryPower:   payload.TotalBatteryPower,
		BatterySize:         payload.BatterySize,
		BatteryCount:        payload.BatteryCount,
		BatteryNote:         payload.BatteryNote,
		BatteryType:         payload.BatteryType,
		TotalInvertersPower: payload.TotalInvertersPower,
		InverterSize:        payload.InverterSize,
		InverterCount:       payload.InverterCount,
		InverterNote:        payload.InverterNote,
		InverterType:        payload.InverterType,
		Note:                payload.Note,
		Status:              "open",
	}
	if req.BatteryType == "" {
		req.BatteryType = "gel"
	}
	if req.InverterType == "" {
		req.InverterType = "hybrid"
	}

	database.DB.Create(&req)
	notifsvc.SendNewSolarRequestNotification(&req)
	response.Success(c, http.StatusOK, "Request created successfully", serializeOfferRequest(&req, user.Username))
}

// ListMyRequests handles GET /api/v1/offers/requests
func ListMyRequests(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Where("user_id = ?", userID).Order("created_at desc")
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}

	var total int64
	query.Model(&models.OfferRequest{}).Count(&total)

	var reqs []models.OfferRequest
	query.Preload("Offers").Limit(pageSize).Offset(offset).Find(&reqs)

	items := make([]map[string]interface{}, 0, len(reqs))
	for _, r := range reqs {
		items = append(items, serializeOfferRequest(&r, ""))
	}

	response.Success(c, http.StatusOK, "Requests retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetRequest handles GET /api/v1/offers/requests/:id
func GetRequest(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var req models.OfferRequest
	if err := database.DB.Preload("Offers").Where("id = ? AND user_id = ?", id, userID).First(&req).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Request retrieved successfully", serializeOfferRequest(&req, ""))
}

// UpdateRequest handles PUT /api/v1/offers/requests/:id
func UpdateRequest(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var req models.OfferRequest
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&req).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}

	if req.Status == "fulfilled" {
		response.Error(c, http.StatusForbidden, "Cannot update a fulfilled request", nil)
		return
	}

	var payload models.OfferRequestUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	applyOfferRequestPayload(&req, &payload)
	database.DB.Save(&req)
	notifsvc.SendUpdatedSolarRequestNotification(&req)
	response.Success(c, http.StatusOK, "Request updated", serializeOfferRequest(&req, ""))
}

// DeleteRequest handles DELETE /api/v1/offers/requests/:id
func DeleteRequest(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var req models.OfferRequest
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&req).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}
	if req.Status == "fulfilled" {
		response.Error(c, http.StatusForbidden, "Cannot delete a fulfilled request", nil)
		return
	}
	database.DB.Delete(&req)
	response.Success(c, http.StatusOK, "Request deleted", nil)
}

// ListRequestOffers handles GET /api/v1/offers/requests/:id/offers
func ListRequestOffers(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var req models.OfferRequest
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&req).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Request not found", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.Offer{}).Where("offer_request_id = ?", req.ID).Count(&total)

	var offers []models.Offer
	database.DB.Preload("Company").Preload("Involves").Where("offer_request_id = ?", req.ID).Order("created_at desc").Limit(pageSize).Offset(offset).Find(&offers)

	items := make([]map[string]interface{}, 0, len(offers))
	for _, o := range offers {
		items = append(items, serializeOffer(&o))
	}

	response.Success(c, http.StatusOK, "Request offers retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// RespondToOffer handles POST /api/v1/offers/:id/response
func RespondToOffer(c *gin.Context) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	id, _ := strconv.Atoi(c.Param("id"))
	var offer models.Offer
	if err := database.DB.Preload("OfferRequest").Where("id = ? AND user_id = ?", id, userID).First(&offer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Offer not found", nil)
		return
	}

	var payload models.OfferResponseSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	offer.Status = payload.State
	database.DB.Save(&offer)

	if payload.State == "accepted" && offer.OfferRequest != nil {
		offer.OfferRequest.Status = "accepted"
		database.DB.Save(offer.OfferRequest)
		database.DB.Model(&models.Offer{}).Where("offer_request_id = ? AND id != ?", offer.OfferRequestID, offer.ID).Update("status", "rejected")
	}

	response.Success(c, http.StatusOK, "Offer marked as "+payload.State, nil)
}

func applyOfferRequestPayload(req *models.OfferRequest, payload *models.OfferRequestUpdateSchema) {
	if payload.CityID != nil {
		req.CityID = payload.CityID
	}
	req.AllCities = payload.AllCities
	req.TotalPanelPower = payload.TotalPanelPower
	if payload.PanelPower != nil {
		req.PanelPower = payload.PanelPower
	}
	if payload.PanelCount != nil {
		req.PanelCount = payload.PanelCount
	}
	if payload.PanelNote != nil {
		req.PanelNote = payload.PanelNote
	}
	req.TotalBatteryPower = payload.TotalBatteryPower
	if payload.BatterySize != nil {
		req.BatterySize = payload.BatterySize
	}
	if payload.BatteryCount != nil {
		req.BatteryCount = payload.BatteryCount
	}
	if payload.BatteryNote != nil {
		req.BatteryNote = payload.BatteryNote
	}
	if payload.BatteryType != "" {
		req.BatteryType = payload.BatteryType
	}
	req.TotalInvertersPower = payload.TotalInvertersPower
	if payload.InverterSize != nil {
		req.InverterSize = payload.InverterSize
	}
	if payload.InverterCount != nil {
		req.InverterCount = payload.InverterCount
	}
	if payload.InverterNote != nil {
		req.InverterNote = payload.InverterNote
	}
	if payload.InverterType != "" {
		req.InverterType = payload.InverterType
	}
	if payload.Note != nil {
		req.Note = payload.Note
	}
}
