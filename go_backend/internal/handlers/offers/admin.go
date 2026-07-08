package offers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// AdminListOffers handles GET /api/v1/offers/admin/offers
func AdminListOffers(c *gin.Context) {
	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Offer{}).Preload("Company").Preload("Involves")
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

	response.Success(c, http.StatusOK, "Admin offers retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// AdminListRequests handles GET /api/v1/offers/admin/requests
func AdminListRequests(c *gin.Context) {
	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.OfferRequest{}).Preload("User").Preload("City")
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

	response.Success(c, http.StatusOK, "Admin requests retrieved successfully", paginationResponse(page, pageSize, total, items))
}
