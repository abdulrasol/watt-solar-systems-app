package notifications

import (
	"fmt"
	"strings"
	"time"

	"watt/internal/database"
	"watt/internal/models"
)

// SendCompanyInviteNotification notifies a user when added/invited to a company.
func SendCompanyInviteNotification(member *models.CompanyMember) {
	go func() {
		if member == nil || member.UserID == 0 {
			return
		}
		var m models.CompanyMember
		if err := database.DB.Preload("Company").Preload("User").First(&m, member.ID).Error; err != nil {
			return
		}
		if m.CompanyID == 0 || m.UserID == 0 {
			return
		}
		lang := userLanguage(m.User.Language)
		role := roleName(m.Role, lang)
		bodyArgs := map[string]interface{}{
			"company_name": m.Company.Name,
			"role":         role,
		}
		data := map[string]interface{}{
			"content": serializeCompanyMember(&m),
			"type":    "invite",
		}
		notifyUser(m.UserID, "invite", bodyArgs, data, "invite", "Company", &m.CompanyID)
	}()
}

// SendMemberRemovedNotification notifies a user when removed from a company.
func SendMemberRemovedNotification(company *models.Company, userID uint) {
	go func() {
		if company == nil || userID == 0 {
			return
		}
		data := map[string]interface{}{
			"content": map[string]interface{}{
				"company_id":   company.ID,
				"company_name": company.Name,
			},
			"type": "member-remove",
		}
		notifyUser(userID, "member_removed", map[string]interface{}{"company_name": company.Name}, data, "member-remove", "Company", &company.ID)
	}()
}

// SendCompanySubscriptionNotification notifies admins/managers of a company about subscription changes.
func SendCompanySubscriptionNotification(subscription *models.CompanyServiceSubscription) {
	go func() {
		if subscription == nil {
			return
		}
		var sub models.CompanyServiceSubscription
		if err := database.DB.Preload("Company").Preload("Service").First(&sub, subscription.ID).Error; err != nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"service_name": sub.Service.Name,
			"state":        sub.Status,
		}
		data := map[string]interface{}{
			"content": serializeSubscription(&sub),
			"type":    "service",
		}
		notifyCompanyMembersByLanguage(sub.CompanyID, []string{"admin", "manager"}, "subscription_update", bodyArgs, data, "service", "CompanyServiceSubscription", &sub.ID)
	}()
}

// SendNewCompanyRegistrationNotification notifies superusers about a new company registration.
func SendNewCompanyRegistrationNotification(company *models.Company) {
	go func() {
		if company == nil {
			return
		}
		var c models.Company
		if err := database.DB.First(&c, company.ID).Error; err != nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"company_name": c.Name,
		}
		data := map[string]interface{}{
			"content": serializeCompany(&c),
			"type":    "company_registration",
		}
		superuserIDs := getSuperuserIDs()
		notifyUserIDsByLanguage(superuserIDs, "new_company_registration", bodyArgs, data, "info", "Company", &c.ID)
	}()
}

// SendCompanyUpdateNotification notifies superusers when a company's profile is updated.
func SendCompanyUpdateNotification(company *models.Company) {
	go func() {
		if company == nil {
			return
		}
		var c models.Company
		if err := database.DB.First(&c, company.ID).Error; err != nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"company_name": c.Name,
		}
		data := map[string]interface{}{
			"content": serializeCompany(&c),
			"type":    "company_updated",
		}
		superuserIDs := getSuperuserIDs()
		notifyUserIDsByLanguage(superuserIDs, "company_updated", bodyArgs, data, "info", "Company", &c.ID)
	}()
}

// SendNewCompanySubscriptionRequestNotification notifies superusers about a new subscription request.
func SendNewCompanySubscriptionRequestNotification(req *models.CompanySubscriptionRequest) {
	go func() {
		if req == nil {
			return
		}
		var r models.CompanySubscriptionRequest
		if err := database.DB.Preload("Company").Preload("SubscriptionPlan").First(&r, req.ID).Error; err != nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"company_name": r.Company.Name,
			"plan_name":    r.SubscriptionPlan.Name,
		}
		data := map[string]interface{}{
			"content": serializeCompanySubscriptionRequest(&r),
			"type":    "subscription_request",
		}
		superuserIDs := getSuperuserIDs()
		notifyUserIDsByLanguage(superuserIDs, "new_subscription_request", bodyArgs, data, "subscription_request", "CompanySubscriptionRequest", &r.ID)
	}()
}

// SendCompanySubscriptionRequestReviewNotification notifies company admins/managers when their subscription request is reviewed.
func SendCompanySubscriptionRequestReviewNotification(company *models.Company, plan *models.SubscriptionPlan, status, notes string, effectiveStart, resultingExpiry *time.Time) {
	go func() {
		if company == nil || plan == nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"plan_name":    plan.Name,
			"status":       status,
			"company_name": company.Name,
		}
		content := map[string]interface{}{
			"company_id":            company.ID,
			"company_name":          company.Name,
			"subscription_plan_id":  plan.ID,
			"subscription_plan_name": plan.Name,
			"status":                status,
			"notes":                 notes,
			"effective_start":       formatTime(effectiveStart),
			"resulting_expiry":      formatTime(resultingExpiry),
		}
		data := map[string]interface{}{
			"content": content,
			"type":    "subscription_request",
		}
		notifyCompanyMembersByLanguage(company.ID, []string{"admin", "manager"}, "subscription_review", bodyArgs, data, "subscription_request", "CompanySubscriptionRequest", &plan.ID)
	}()
}

// SendCompanyActivationReminderNotification notifies superusers about a pending company activation.
func SendCompanyActivationReminderNotification(company *models.Company, requestedBy *models.User) {
	go func() {
		if company == nil {
			return
		}
		var c models.Company
		if err := database.DB.Preload("CompanyType").First(&c, company.ID).Error; err != nil {
			return
		}
		var requestedByUsername string
		if requestedBy != nil {
			requestedByUsername = requestedBy.Username
		}
		content := map[string]interface{}{
			"company_id":               c.ID,
			"company_name":             c.Name,
			"company_type":             nil,
			"status":                   c.Status,
			"created_at":               c.CreatedAt.Format(time.RFC3339),
			"registered_for_hours":     int(time.Since(c.CreatedAt).Hours()),
			"requested_by":             requestedByUsername,
			"last_activation_reminder_at": formatTime(c.LastActivationReminderAt),
		}
		if c.CompanyType != nil {
			content["company_type"] = c.CompanyType.Name
		}
		data := map[string]interface{}{
			"content": content,
			"type":    "company_activation_reminder",
		}
		superuserIDs := getSuperuserIDs()
		notifyUserIDsByLanguage(superuserIDs, "activation_reminder", map[string]interface{}{"company_name": c.Name}, data, "company_activation_reminder", "Company", &c.ID)
	}()
}

// SendUpdatedSolarRequestNotification notifies matching companies when a solar request is updated.
func SendUpdatedSolarRequestNotification(req *models.OfferRequest) {
	go func() {
		if req == nil {
			return
		}
		var r models.OfferRequest
		if err := database.DB.Preload("User").Preload("City").First(&r, req.ID).Error; err != nil {
			return
		}
		notifySolarRequest(&r, "solar_request_updated", "updated")
	}()
}

// SendNewSolarRequestNotification notifies matching companies when a new solar request is created.
func SendNewSolarRequestNotification(req *models.OfferRequest) {
	go func() {
		if req == nil {
			return
		}
		var r models.OfferRequest
		if err := database.DB.Preload("User").Preload("City").First(&r, req.ID).Error; err != nil {
			return
		}
		notifySolarRequest(&r, "new_solar_request", "")
	}()
}

func notifySolarRequest(req *models.OfferRequest, translationKey, action string) {
	profile := req.User
	if profile == nil || profile.ID == 0 {
		return
	}
	userName := userDisplayName(profile)
	capacity := fmt.Sprintf("%dW", req.TotalPanelPower)

	var cityID, countryID *uint
	if !req.AllCities {
		if req.CityID != nil {
			cityID = req.CityID
		}
	} else if profile.CityID != nil {
		var city models.City
		if err := database.DB.First(&city, *profile.CityID).Error; err == nil {
			countryID = &city.CountryID
		}
	}

	members := membersForService("offers", []string{"admin", "manager", "sales"}, cityID, countryID)
	if len(members) == 0 {
		return
	}
	userIDs := companyMembersUserIDs(members)
	if len(userIDs) == 0 {
		return
	}

	bodyArgs := map[string]interface{}{
		"user_name": userName,
		"capacity":  capacity,
	}
	data := map[string]interface{}{
		"content": serializeOfferRequest(req),
		"type":    "offer_request",
	}
	if action != "" {
		data["action"] = action
	}
	notifyUserIDsByLanguage(userIDs, translationKey, bodyArgs, data, "offer_request", "OfferRequest", &req.ID)
}

// SendNewOfferNotification notifies the request owner when a company sends an offer.
func SendNewOfferNotification(offer *models.Offer) {
	go func() {
		if offer == nil {
			return
		}
		var o models.Offer
		if err := database.DB.Preload("User").Preload("Company").First(&o, offer.ID).Error; err != nil {
			return
		}
		if o.UserID == nil || *o.UserID == 0 {
			return
		}
		companyName := "A company"
		if o.Company != nil {
			companyName = o.Company.Name
		}
		data := map[string]interface{}{
			"content": serializeOffer(&o),
			"type":    "offer",
		}
		notifyUser(*o.UserID, "new_offer", map[string]interface{}{"company_name": companyName}, data, "offer", "Offer", &o.ID)
	}()
}

// SendUpdatedOfferNotification notifies the request owner when a company updates an offer.
func SendUpdatedOfferNotification(offer *models.Offer) {
	go func() {
		if offer == nil {
			return
		}
		var o models.Offer
		if err := database.DB.Preload("User").Preload("Company").First(&o, offer.ID).Error; err != nil {
			return
		}
		if o.UserID == nil || *o.UserID == 0 {
			return
		}
		companyName := "A company"
		if o.Company != nil {
			companyName = o.Company.Name
		}
		data := map[string]interface{}{
			"content": serializeOffer(&o),
			"type":    "offer",
			"action":  "updated",
		}
		notifyUser(*o.UserID, "offer_updated", map[string]interface{}{"company_name": companyName}, data, "offer", "Offer", &o.ID)
	}()
}

// SendSellerNewOrderNotification notifies seller company members of a new order.
func SendSellerNewOrderNotification(order *models.Order) {
	go func() {
		if order == nil || order.SellerCompanyID == nil {
			return
		}
		var o models.Order
		if err := database.DB.Preload("SellerCompany").Preload("BuyerCompany").Preload("BuyerUser").First(&o, order.ID).Error; err != nil {
			return
		}
		if o.SellerCompanyID == nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"order_number": orderNumber(o),
			"buyer_name":   buyerNameForOrder(&o),
			"company_name": o.SellerCompany.Name,
		}
		data := map[string]interface{}{
			"content": serializeOrder(&o),
			"type":    "order",
		}
		notifyCompanyMembersByLanguage(*o.SellerCompanyID, []string{"admin", "manager", "sales"}, "order_new", bodyArgs, data, "order", "Order", &o.ID)
	}()
}

// SendBuyerOrderStatusNotification notifies the buyer about an order status change.
func SendBuyerOrderStatusNotification(order *models.Order) {
	go func() {
		if order == nil {
			return
		}
		var o models.Order
		if err := database.DB.Preload("SellerCompany").Preload("BuyerCompany").Preload("BuyerUser").First(&o, order.ID).Error; err != nil {
			return
		}
		key := "order_status"
		if o.Status == "cancelled" {
			key = "order_cancelled"
		}
		bodyArgs := map[string]interface{}{
			"order_number":   orderNumber(o),
			"status":         o.Status,
			"payment_status": o.PaymentStatus,
		}
		data := map[string]interface{}{
			"content": serializeOrder(&o),
			"type":    "order",
			"action":  "status-updated",
		}
		if o.OrderType == "b2b" && o.BuyerCompanyID != nil {
			notifyCompanyMembersByLanguage(*o.BuyerCompanyID, []string{"admin", "manager", "sales"}, key, bodyArgs, data, "order", "Order", &o.ID)
		} else if o.BuyerUserID != nil {
			notifyUser(*o.BuyerUserID, key, bodyArgs, data, "order", "Order", &o.ID)
		}
	}()
}

// SendBuyerOrderPaymentStatusNotification notifies the buyer about a payment status change.
func SendBuyerOrderPaymentStatusNotification(order *models.Order) {
	go func() {
		if order == nil {
			return
		}
		var o models.Order
		if err := database.DB.Preload("SellerCompany").Preload("BuyerCompany").Preload("BuyerUser").First(&o, order.ID).Error; err != nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"order_number":   orderNumber(o),
			"payment_status": o.PaymentStatus,
		}
		data := map[string]interface{}{
			"content": serializeOrder(&o),
			"type":    "order",
			"action":  "payment-updated",
		}
		if o.OrderType == "b2b" && o.BuyerCompanyID != nil {
			notifyCompanyMembersByLanguage(*o.BuyerCompanyID, []string{"admin", "manager", "sales"}, "order_payment_status", bodyArgs, data, "order", "Order", &o.ID)
		} else if o.BuyerUserID != nil {
			notifyUser(*o.BuyerUserID, "order_payment_status", bodyArgs, data, "order", "Order", &o.ID)
		}
	}()
}

// SendOrderDeliveryPendingReceiptNotification asks the buyer to confirm receipt.
func SendOrderDeliveryPendingReceiptNotification(order *models.Order) {
	go func() {
		if order == nil || order.BuyerCompanyID == nil {
			return
		}
		var o models.Order
		if err := database.DB.Preload("SellerCompany").Preload("BuyerCompany").First(&o, order.ID).Error; err != nil {
			return
		}
		if o.BuyerCompanyID == nil || o.SellerCompany == nil {
			return
		}
		bodyArgs := map[string]interface{}{
			"order_number": orderNumber(o),
			"company_name": o.SellerCompany.Name,
		}
		data := map[string]interface{}{
			"content": serializeOrder(&o),
			"type":    "order",
			"action":  "confirm-receipt",
		}
		notifyCompanyMembersByLanguage(*o.BuyerCompanyID, []string{"admin", "manager", "sales"}, "order_delivery_pending_receipt", bodyArgs, data, "order", "Order", &o.ID)
	}()
}

// SendB2BOrderReceiptConfirmedNotification notifies the seller that the buyer confirmed receipt.
func SendB2BOrderReceiptConfirmedNotification(order *models.Order) {
	go func() {
		if order == nil || order.SellerCompanyID == nil {
			return
		}
		var o models.Order
		if err := database.DB.Preload("SellerCompany").Preload("BuyerCompany").First(&o, order.ID).Error; err != nil {
			return
		}
		buyerName := "Buyer"
		if o.BuyerCompany != nil {
			buyerName = o.BuyerCompany.Name
		}
		bodyArgs := map[string]interface{}{
			"order_number": orderNumber(o),
			"buyer_name":   buyerName,
		}
		data := map[string]interface{}{
			"content": serializeOrder(&o),
			"type":    "order",
			"action":  "receipt-confirmed",
		}
		notifyCompanyMembersByLanguage(*o.SellerCompanyID, []string{"admin", "manager", "sales"}, "order_receipt_confirmed", bodyArgs, data, "order", "Order", &o.ID)
	}()
}

// SendPosterCreatedNotification notifies superusers when a poster is created.
func SendPosterCreatedNotification(poster *models.Poster) {
	go func() {
		if poster == nil {
			return
		}
		var p models.Poster
		if err := database.DB.Preload("Company").First(&p, poster.ID).Error; err != nil {
			return
		}
		data := map[string]interface{}{
			"content": serializePoster(&p),
			"type":    "poster",
		}
		superuserIDs := getSuperuserIDs()
		notifyUserIDsByLanguage(superuserIDs, "poster_created", map[string]interface{}{"company_name": p.Company.Name}, data, "poster", "Poster", &p.ID)
	}()
}

// SendPosterApprovedNotification notifies company admins/managers when a poster is approved.
func SendPosterApprovedNotification(poster *models.Poster) {
	go func() {
		if poster == nil {
			return
		}
		var p models.Poster
		if err := database.DB.Preload("Company").First(&p, poster.ID).Error; err != nil {
			return
		}
		data := map[string]interface{}{
			"content": serializePoster(&p),
			"type":    "poster",
		}
		notifyCompanyMembersByLanguage(p.CompanyID, []string{"admin", "manager"}, "poster_approved", nil, data, "poster", "Poster", &p.ID)
	}()
}

func getSuperuserIDs() []uint {
	var ids []uint
	database.DB.Model(&models.User{}).Where("is_superuser = ?", true).Pluck("id", &ids)
	return ids
}

func userDisplayName(u *models.User) string {
	name := strings.TrimSpace(u.FirstName + " " + u.LastName)
	if name != "" {
		return name
	}
	return u.Username
}

func orderNumber(o models.Order) string {
	if o.OrderNumber != nil {
		return fmt.Sprintf("%d", *o.OrderNumber)
	}
	return fmt.Sprintf("%d", o.ID)
}

func formatTime(t *time.Time) interface{} {
	if t == nil {
		return nil
	}
	return t.Format(time.RFC3339)
}
