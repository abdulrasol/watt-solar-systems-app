package notifications

import (
	"time"

	"watt/internal/models"
)

func serializeSubscription(s *models.CompanyServiceSubscription) map[string]interface{} {
	return map[string]interface{}{
		"id":            s.ID,
		"company_id":    s.CompanyID,
		"company_name":  nil,
		"service_id":    s.ServiceID,
		"service_name":  nil,
		"status":        s.Status,
		"activated_at":  formatTime(s.ActivatedAt),
		"starts_at":     formatTime(s.StartsAt),
		"ends_at":       formatTime(s.EndsAt),
	}
}

func serializeCompanySubscriptionRequest(r *models.CompanySubscriptionRequest) map[string]interface{} {
	requestedBy := ""
	if r.RequestedBy != nil {
		requestedBy = r.RequestedBy.Username
	}
	return map[string]interface{}{
		"id":                      r.ID,
		"company_id":              r.CompanyID,
		"company_name":            nil,
		"subscription_plan_id":    r.SubscriptionPlanID,
		"subscription_plan_name":  nil,
		"requested_by":            requestedBy,
		"status":                  r.Status,
		"requested_at":            formatTime(r.RequestedAt),
		"notes":                   r.Notes,
		"image":                   r.Image,
	}
}

func serializeOfferRequest(req *models.OfferRequest) map[string]interface{} {
	cityName := "your area"
	if req.City != nil {
		cityName = req.City.Name
	}
	userName := ""
	if req.User != nil {
		userName = userDisplayName(req.User)
	}
	return map[string]interface{}{
		"id":                  req.ID,
		"user_id":             req.UserID,
		"user_name":           userName,
		"city_id":             req.CityID,
		"city_name":           cityName,
		"total_panel_power":   req.TotalPanelPower,
		"status":              req.Status,
		"created_at":          req.CreatedAt.Format(time.RFC3339),
	}
}

func serializeOffer(o *models.Offer) map[string]interface{} {
	companyName := "Unknown"
	if o.Company != nil {
		companyName = o.Company.Name
	}
	return map[string]interface{}{
		"id":              o.ID,
		"company_id":      o.CompanyID,
		"company_name":    companyName,
		"price":           o.Price,
		"total_price":     o.TotalPanelPower,
		"status":          o.Status,
		"created_at":      o.CreatedAt.Format(time.RFC3339),
	}
}

func serializeCompanyMember(m *models.CompanyMember) map[string]interface{} {
	return map[string]interface{}{
		"id":          m.ID,
		"company_id":  m.CompanyID,
		"company_name": nil,
		"role":        m.Role,
		"joined_at":   m.JoinedAt.Format(time.RFC3339),
	}
}

func serializeOrder(o *models.Order) map[string]interface{} {
	buyerName := buyerNameForOrder(o)
	sellerName := ""
	if o.SellerCompany != nil {
		sellerName = o.SellerCompany.Name
	}
	return map[string]interface{}{
		"id":                o.ID,
		"order_number":      orderNumber(*o),
		"order_type":        o.OrderType,
		"status":            o.Status,
		"payment_status":    o.PaymentStatus,
		"payment_method":    o.PaymentMethod,
		"seller_company_id": o.SellerCompanyID,
		"seller_company_name": sellerName,
		"buyer_company_id":  o.BuyerCompanyID,
		"buyer_company_name": nil,
		"buyer_user_id":     o.BuyerUserID,
		"buyer_user_name":   buyerName,
		"total_amount":      o.TotalAmount,
		"created_at":        o.CreatedAt.Format(time.RFC3339),
		"updated_at":        o.UpdatedAt.Format(time.RFC3339),
	}
}

func serializePoster(p *models.Poster) map[string]interface{} {
	return map[string]interface{}{
		"id":          p.ID,
		"company_id":  p.CompanyID,
		"company_name": nil,
		"action_type": p.ActionType,
		"status":      p.Status,
	}
}
