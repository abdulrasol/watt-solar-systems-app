package notifications

import (
	"encoding/json"
	"log"
	"strings"
	"time"

	"gorm.io/datatypes"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services/fcm"
)

const (
	maxBatchTokens = 500
)

// createInAppNotifications inserts rows into the in-app Notification table.
func createInAppNotifications(userIDs []uint, title, body, notificationType, relatedEntityType string, relatedEntityID *uint) {
	if len(userIDs) == 0 {
		return
	}
	// dedupe
	seen := make(map[uint]struct{}, len(userIDs))
	uniq := make([]uint, 0, len(userIDs))
	for _, id := range userIDs {
		if id == 0 {
			continue
		}
		if _, ok := seen[id]; ok {
			continue
		}
		seen[id] = struct{}{}
		uniq = append(uniq, id)
	}
	if len(uniq) == 0 {
		return
	}
	for _, uid := range uniq {
		n := models.Notification{
			UserID:            uid,
			Title:             title,
			Body:              body,
			NotificationType:  notificationType,
			RelatedEntityType: nil,
			RelatedEntityID:   nil,
		}
		if relatedEntityType != "" {
			t := relatedEntityType
			n.RelatedEntityType = &t
		}
		if relatedEntityID != nil && *relatedEntityID != 0 {
			v := *relatedEntityID
			n.RelatedEntityID = &v
		}
		database.DB.Create(&n)
	}
}

// createPushRecord inserts a NotificationRecord for analytics/history.
func createPushRecord(title, body, ntype string, targetUserID *uint, topic *string, data map[string]interface{}, success, failure int) {
	now := time.Now()
	rec := models.NotificationRecord{
		Title:        title,
		Body:         body,
		Type:         ntype,
		Status:       "sent",
		TargetUserID: targetUserID,
		Topic:        topic,
		DevicesCount: success + failure,
		SuccessCount: success,
		FailureCount: failure,
		SentAt:       &now,
	}
	if len(data) > 0 {
		b, _ := json.Marshal(data)
		rec.Data = datatypes.JSON(b)
	}
	database.DB.Create(&rec)
}

// sendPushToTokens fetches active tokens for the given user IDs and sends one multicast.
func sendPushToTokens(userIDs []uint, title, body string, data map[string]interface{}) (int, int) {
	if len(userIDs) == 0 {
		return 0, 0
	}
	var devices []models.PushDevice
	database.DB.Where("user_id IN ? AND is_active = ?", userIDs, true).Find(&devices)
	if len(devices) == 0 {
		return 0, 0
	}
	tokens := make([]string, 0, len(devices))
	for _, d := range devices {
		tokens = append(tokens, d.RegistrationID)
	}
	success, failure, err := fcm.SendMulticast(tokens, title, body, data)
	if err != nil {
		log.Printf("⚠️ FCM send failed: %v", err)
		return 0, len(tokens)
	}
	return success, failure
}

// notifyUser sends a localized push + in-app notification to a single user.
func notifyUser(userID uint, translationKey string, bodyArgs map[string]interface{}, data map[string]interface{}, notificationType, relatedEntityType string, relatedEntityID *uint) {
	if userID == 0 {
		return
	}
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return
	}
	lang := userLanguage(user.Language)
	title := translatedText(translationKey, "title", lang, bodyArgs)
	body := translatedText(translationKey, "body", lang, bodyArgs)
	if title == "" && body == "" {
		return
	}
	success, failure := sendPushToTokens([]uint{userID}, title, body, data)
	createInAppNotifications([]uint{userID}, title, body, notificationType, relatedEntityType, relatedEntityID)
	createPushRecord(title, body, notificationType, &userID, nil, data, success, failure)
}

// notifyUserIDsByLanguage groups users by language and sends one push per language.
func notifyUserIDsByLanguage(userIDs []uint, translationKey string, bodyArgs map[string]interface{}, data map[string]interface{}, notificationType, relatedEntityType string, relatedEntityID *uint) {
	if len(userIDs) == 0 {
		return
	}
	users := []models.User{}
	database.DB.Where("id IN ?", userIDs).Find(&users)
	byLang := groupUsersByLanguage(users)
	for lang, ids := range byLang {
		if len(ids) == 0 {
			continue
		}
		title := translatedText(translationKey, "title", lang, bodyArgs)
		body := translatedText(translationKey, "body", lang, bodyArgs)
		if title == "" && body == "" {
			continue
		}
		success, failure := sendPushToTokens(ids, title, body, data)
		createInAppNotifications(ids, title, body, notificationType, relatedEntityType, relatedEntityID)
		createPushRecord(title, body, notificationType, nil, nil, data, success, failure)
	}
}

// notifyCompanyMembersByLanguage sends a localized push to members of a company with given roles.
func notifyCompanyMembersByLanguage(companyID uint, roles []string, translationKey string, bodyArgs map[string]interface{}, data map[string]interface{}, notificationType, relatedEntityType string, relatedEntityID *uint) {
	var members []models.CompanyMember
	database.DB.Where("company_id = ? AND role IN ?", companyID, roles).Preload("User").Find(&members)
	if len(members) == 0 {
		return
	}
	userIDs := make([]uint, 0, len(members))
	for _, m := range members {
		if m.UserID != 0 {
			userIDs = append(userIDs, m.UserID)
		}
	}
	notifyUserIDsByLanguage(userIDs, translationKey, bodyArgs, data, notificationType, relatedEntityType, relatedEntityID)
}

// membersForService finds company members whose company type allows a given service code.
func membersForService(serviceCode string, roles []string, cityID, countryID *uint) []models.CompanyMember {
	query := database.DB.
		Select("company_members.*").
		Joins("JOIN companies ON companies.id = company_members.company_id").
		Joins("JOIN company_type_services ON company_type_services.company_type_id = companies.company_type_id").
		Joins("JOIN company_service_catalogs ON company_service_catalogs.id = company_type_services.company_service_catalog_id").
		Where("company_members.role IN ?", roles).
		Where("companies.status = ?", "active").
		Where("company_service_catalogs.code = ?", serviceCode).
		Where("company_service_catalogs.is_active = ?", true)

	if cityID != nil {
		query = query.Where("companies.city_id = ?", *cityID)
	} else if countryID != nil {
		query = query.Joins("JOIN cities ON cities.id = companies.city_id").
			Where("cities.country_id = ?", *countryID)
	}

	var members []models.CompanyMember
	query.Preload("User").Find(&members)
	return members
}

func groupUsersByLanguage(users []models.User) map[string][]uint {
	res := make(map[string][]uint)
	for _, u := range users {
		lang := userLanguage(u.Language)
		res[lang] = append(res[lang], u.ID)
	}
	return res
}

func companyMembersUserIDs(members []models.CompanyMember) []uint {
	seen := make(map[uint]struct{})
	out := make([]uint, 0, len(members))
	for _, m := range members {
		if m.UserID == 0 {
			continue
		}
		if _, ok := seen[m.UserID]; ok {
			continue
		}
		seen[m.UserID] = struct{}{}
		out = append(out, m.UserID)
	}
	return out
}

func ptrUint(v uint) *uint {
	return &v
}

// buyerNameForOrder returns a display name for the order buyer.
func buyerNameForOrder(order *models.Order) string {
	if order.BuyerCompany != nil && order.BuyerCompanyID != nil {
		return order.BuyerCompany.Name
	}
	if order.BuyerUser != nil && order.BuyerUserID != nil {
		name := strings.TrimSpace(order.BuyerUser.FirstName + " " + order.BuyerUser.LastName)
		if name != "" {
			return name
		}
		return order.BuyerUser.Username
	}
	return "Customer"
}
