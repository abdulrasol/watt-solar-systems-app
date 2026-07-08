package offers

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
)

func parsePagination(c *gin.Context) (page, pageSize int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ = strconv.Atoi(c.DefaultQuery("page_size", "12"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}
	return
}

func paginationResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	return map[string]interface{}{
		"items": items,
		"count": total,
		"pagination": map[string]interface{}{
			"page":         page,
			"page_size":    pageSize,
			"total_items":  total,
			"total_pages":  totalPages,
			"has_next":     page < totalPages,
			"has_previous": page > 1,
		},
	}
}

func getUserMember(c *gin.Context) (*models.User, *models.CompanyMember, bool) {
	userIDVal, exists := c.Get("user_id")
	if !exists {
		return nil, nil, false
	}
	userID := userIDVal.(uint)
	var user models.User
	database.DB.First(&user, userID)

	var member models.CompanyMember
	if err := database.DB.Where("user_id = ?", userID).First(&member).Error; err != nil {
		return &user, nil, true
	}
	return &user, &member, true
}

func serializeOfferRequest(req *models.OfferRequest, username string) map[string]interface{} {
	var city map[string]interface{}
	if req.City != nil {
		city = map[string]interface{}{
			"id":   req.City.ID,
			"name": req.City.Name,
			"code": req.City.Code,
		}
	}
	authorName := username
	if authorName == "" && req.User != nil {
		authorName = req.User.Username
	}
	return map[string]interface{}{
		"id":                    req.ID,
		"user":                  map[string]interface{}{"name": authorName},
		"city":                  city,
		"all_cities":            req.AllCities,
		"total_panel_power":     req.TotalPanelPower,
		"panel_power":           req.PanelPower,
		"panel_count":           req.PanelCount,
		"panel_note":            req.PanelNote,
		"total_battery_power":   req.TotalBatteryPower,
		"battery_size":          req.BatterySize,
		"battery_count":         req.BatteryCount,
		"battery_note":          req.BatteryNote,
		"battery_type":          req.BatteryType,
		"total_inverters_power": req.TotalInvertersPower,
		"inverter_size":         req.InverterSize,
		"inverter_count":        req.InverterCount,
		"inverter_note":         req.InverterNote,
		"inverter_type":         req.InverterType,
		"note":                  req.Note,
		"status":                req.Status,
		"offers_count":          len(req.Offers),
		"created_at":            req.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeOffer(offer *models.Offer) map[string]interface{} {
	var company map[string]interface{}
	if offer.Company != nil {
		company = map[string]interface{}{
			"id":   offer.Company.ID,
			"name": offer.Company.Name,
		}
	}

	involves := make([]map[string]interface{}, 0, len(offer.Involves))
	for _, inv := range offer.Involves {
		involves = append(involves, map[string]interface{}{
			"id":         inv.ID,
			"name":       inv.Name,
			"quantity":   inv.Quantity,
			"cost":       inv.Cost,
			"total_cost": inv.Cost * float64(inv.Quantity),
		})
	}

	total := offer.Price
	for _, inv := range involves {
		total += inv["total_cost"].(float64)
	}

	return map[string]interface{}{
		"id":                offer.ID,
		"offer_request_id":  offer.OfferRequestID,
		"company":           company,
		"price":             offer.Price,
		"total_price":       total,
		"involves":          involves,
		"total_panel_power": offer.TotalPanelPower,
		"panel_power":       offer.PanelPower,
		"panel_count":       offer.PanelCount,
		"panel_note":        offer.PanelNote,
		"battery_size":      offer.BatterySize,
		"battery_count":     offer.BatteryCount,
		"battery_note":      offer.BatteryNote,
		"battery_type":      offer.BatteryType,
		"inverter_size":     offer.InverterSize,
		"inverter_count":    offer.InverterCount,
		"inverter_note":     offer.InverterNote,
		"inverter_type":     offer.InverterType,
		"note":              offer.Note,
		"status":            offer.Status,
		"created_at":        offer.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}
