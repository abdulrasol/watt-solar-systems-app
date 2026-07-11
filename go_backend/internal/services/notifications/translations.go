package notifications

import (
	"fmt"
	"strings"
)

// translationMap mirrors Django notifier.TRANSLATIONS.
var translationMap = map[string]map[string]map[string]string{
	"new_company_registration": {
		"title": {"en": "New Company Registration", "ar": "تسجيل شركة جديدة"},
		"body":  {"en": "Company '{company_name}' has registered and is pending approval.", "ar": "قامت شركة '{company_name}' بالتسجيل وهي بانتظار الموافقة."},
	},
	"company_updated": {
		"title": {"en": "Company Profile Updated", "ar": "تحديث بيانات شركة"},
		"body":  {"en": "Company '{company_name}' updated its profile.", "ar": "قامت شركة '{company_name}' بتحديث بياناتها."},
	},
	"invite": {
		"title": {"en": "Company Invitation", "ar": "دعوة للانضمام إلى شركة"},
		"body":  {"en": "You have been added to '{company_name}' as a {role}.", "ar": "تمت إضافتك إلى '{company_name}' بصفتك {role}."},
	},
	"member_removed": {
		"title": {"en": "Company Membership Removed", "ar": "تمت إزالة العضوية من الشركة"},
		"body":  {"en": "Your membership with '{company_name}' has been terminated.", "ar": "تم إنهاء عضويتك في '{company_name}'."},
	},
	"subscription_update": {
		"title": {"en": "Subscription {state}", "ar": "الاشتراك {state}"},
		"body":  {"en": "{service_name} has been updated to {state}", "ar": "تم تحديث {service_name} إلى {state}"},
	},
	"new_subscription_request": {
		"title": {"en": "new subscription request", "ar": "طلب اشتراك جديد"},
		"body":  {"en": "{company_name} requested {plan_name}", "ar": "{company_name} طلب {plan_name}"},
	},
	"subscription_review": {
		"title": {"en": "subscription request {status}", "ar": "طلب الاشتراك {status}"},
		"body":  {"en": "{plan_name} request was {status} for {company_name}", "ar": "تم {status} طلب {plan_name} لـ {company_name}"},
	},
	"activation_reminder": {
		"title": {"en": "company activation reminder", "ar": "تذكير بتنشيط الشركة"},
		"body":  {"en": "{company_name} is still pending approval", "ar": "لا يزال {company_name} في انتظار الموافقة"},
	},
	"solar_request_updated": {
		"title": {"en": "solar system request updated", "ar": "تم تحديث طلب نظام الطاقة الشمسية"},
		"body":  {"en": "{user_name} updated the request for a {capacity} system", "ar": "حدث {user_name} الطلب لنظام {capacity}"},
	},
	"new_solar_request": {
		"title": {"en": "new solar system request", "ar": "طلب نظام طاقة شمسية جديد"},
		"body":  {"en": "offer a {capacity} system to {user_name}", "ar": "قدم عرضاً لنظام {capacity} لـ {user_name}"},
	},
	"new_offer": {
		"title": {"en": "You get Offer", "ar": "لقد حصلت على عرض"},
		"body":  {"en": "Company {company_name} sent you an offer for your solar request.", "ar": "أرسلت شركة {company_name} عرضاً لطلب الطاقة الشمسية الخاص بك."},
	},
	"offer_updated": {
		"title": {"en": "Offer updated", "ar": "تم تحديث العرض"},
		"body":  {"en": "Company {company_name} updated its offer for your solar request.", "ar": "حدثت شركة {company_name} عرضها لطلب الطاقة الشمسية الخاص بك."},
	},
	"order_new": {
		"title": {"en": "New order received", "ar": "تم استلام طلب جديد"},
		"body":  {"en": "Order #{order_number} from {buyer_name} for {company_name}.", "ar": "تم استلام الطلب #{order_number} من {buyer_name} لصالح {company_name}."},
	},
	"order_status": {
		"title": {"en": "Order status updated", "ar": "تم تحديث حالة الطلب"},
		"body":  {"en": "Order #{order_number} is now {status}.", "ar": "أصبح الطلب #{order_number} بالحالة {status}."},
	},
	"order_delivery_pending_receipt": {
		"title": {"en": "Confirm order receipt", "ar": "أكد استلام الطلب"},
		"body":  {"en": "Order #{order_number} from {company_name} was marked delivered. Please confirm receipt.", "ar": "تم تعليم الطلب #{order_number} من {company_name} كمسلّم. يرجى تأكيد الاستلام."},
	},
	"order_receipt_confirmed": {
		"title": {"en": "Buyer confirmed receipt", "ar": "أكد المشتري الاستلام"},
		"body":  {"en": "Order #{order_number} was received by {buyer_name}.", "ar": "تم استلام الطلب #{order_number} من قبل {buyer_name}."},
	},
	"order_cancelled": {
		"title": {"en": "Order cancelled", "ar": "تم إلغاء الطلب"},
		"body":  {"en": "Order #{order_number} has been cancelled.", "ar": "تم إلغاء الطلب #{order_number}."},
	},
	"order_payment_status": {
		"title": {"en": "Order payment updated", "ar": "تم تحديث دفع الطلب"},
		"body":  {"en": "Payment for order #{order_number} is now {payment_status}.", "ar": "أصبحت حالة دفع الطلب #{order_number} هي {payment_status}."},
	},
	"poster_created": {
		"title": {"en": "New Poster Requested", "ar": "طلب بوستر جديد"},
		"body":  {"en": "{company_name} requested to publish a poster.", "ar": "طلبت شركة {company_name} نشر بوستر."},
	},
	"poster_approved": {
		"title": {"en": "Poster Approved", "ar": "تمت الموافقة على البوستر"},
		"body":  {"en": "Your poster has been approved and is now active.", "ar": "تمت الموافقة على البوستر الخاص بك وهو نشط الآن."},
	},
	"roles": {
		"admin":   {"en": "Admin", "ar": "مدير"},
		"manager": {"en": "Manager", "ar": "مسؤول"},
		"sales":   {"en": "Sales", "ar": "مبيعات"},
		"staff":   {"en": "Staff", "ar": "موظف"},
	},
}

func userLanguage(lang string) string {
	lang = strings.ToLower(strings.TrimSpace(lang))
	if lang == "en" {
		return "en"
	}
	return "ar"
}

func translatedText(category, key, lang string, args ...map[string]interface{}) string {
	l := userLanguage(lang)
	text := ""
	if cat, ok := translationMap[category]; ok {
		if k, ok := cat[key]; ok {
			if t, ok := k[l]; ok && t != "" {
				text = t
			} else if t, ok := k["ar"]; ok {
				text = t
			}
		}
	}
	if text == "" {
		return ""
	}
	if len(args) > 0 {
		for k, v := range args[0] {
			text = strings.ReplaceAll(text, "{"+k+"}", toString(v))
		}
	}
	return text
}

func roleName(role, lang string) string {
	return translatedText("roles", role, lang)
}

func toString(v interface{}) string {
	switch val := v.(type) {
	case string:
		return val
	case nil:
		return ""
	default:
		// Use a simple Sprintf for numbers, booleans, etc.
		return fmt.Sprintf("%v", val)
	}
}
