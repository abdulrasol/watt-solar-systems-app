package shop

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/models"
	"watt/internal/response"
)

func getUserID(c *gin.Context) (uint, bool) {
	userID, exists := c.Get("user_id")
	if !exists {
		msgUser := "الرجاء تسجيل الدخول"
		response.Error(c, http.StatusUnauthorized, "Unauthorized", &msgUser)
		return 0, false
	}
	return userID.(uint), true
}

func parsePagination(c *gin.Context) (page, pageSize int) {
	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("page_size", "12")
	page, _ = strconv.Atoi(pageStr)
	if page < 1 {
		page = 1
	}
	pageSize, _ = strconv.Atoi(pageSizeStr)
	if pageSize < 1 || pageSize > 100 {
		pageSize = 12
	}
	return
}

func parseFloatQuery(c *gin.Context, key string) *float64 {
	val := c.Query(key)
	if val == "" {
		return nil
	}
	if f, err := strconv.ParseFloat(val, 64); err == nil {
		return &f
	}
	return nil
}

func parseBoolQuery(c *gin.Context, key string) *bool {
	val := c.Query(key)
	if val == "" {
		return nil
	}
	if b, err := strconv.ParseBool(val); err == nil {
		return &b
	}
	return nil
}

func serializeMinimalCompany(company *models.Company) map[string]interface{} {
	if company == nil {
		return nil
	}
	return map[string]interface{}{
		"id":     company.ID,
		"name":   company.Name,
		"logo":   company.Logo,
		"phone":  company.Phone,
	}
}

func serializeFullCompany(company *models.Company) map[string]interface{} {
	if company == nil {
		return nil
	}

	var categories []map[string]interface{}
	for _, cat := range company.Categories {
		categories = append(categories, map[string]interface{}{
			"id":      cat.ID,
			"name":    cat.Name,
			"company": serializeMinimalCompany(&cat.Company),
			"created_at": cat.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}

	var city map[string]interface{}
	if company.City != nil {
		city = map[string]interface{}{
			"id":   company.City.ID,
			"name": company.City.Name,
			"code": company.City.Code,
			"country": map[string]interface{}{
				"id":   company.City.Country.ID,
				"name": company.City.Country.Name,
				"code": company.City.Country.Code,
			},
		}
	}

	var currency map[string]interface{}
	if company.Currency != nil {
		currency = map[string]interface{}{
			"id":         company.Currency.ID,
			"name":       company.Currency.Name,
			"code":       company.Currency.Code,
			"symbol":     company.Currency.Symbol,
			"is_default": company.Currency.IsDefault,
			"created_at": company.Currency.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		}
	}

	var ctype map[string]interface{}
	if company.CompanyType != nil {
		ctype = map[string]interface{}{
			"id":   company.CompanyType.ID,
			"code": company.CompanyType.CType,
			"name": company.CompanyType.Name,
		}
	}

	return map[string]interface{}{
		"id":                     company.ID,
		"name":                   company.Name,
		"phone":                  company.Phone,
		"company_type":           ctype,
		"city":                   city,
		"currency":               currency,
		"allows_b2b":             company.AllowsB2B,
		"allows_b2c":             company.AllowsB2C,
		"subscription_is_valid":  company.HasValidSubscription(),
		"company_categories":     categories,
	}
}

func serializeProduct(product *models.Product, channel string, includeCost bool) map[string]interface{} {
	if product == nil {
		return nil
	}

	displayPrice := product.RetailPrice
	if channel == "b2b" {
		displayPrice = product.WholesalePrice
	}

	var globalCategory map[string]interface{}
	if product.GlobalCategory != nil {
		globalCategory = map[string]interface{}{
			"id":   product.GlobalCategory.ID,
			"name": product.GlobalCategory.Name,
		}
	}

	var companyCategories []map[string]interface{}
	for _, cat := range product.Categories {
		companyCategories = append(companyCategories, map[string]interface{}{
			"id":   cat.ID,
			"name": cat.Name,
		})
	}

	var images []string
	for _, img := range product.Images {
		images = append(images, img.Image)
	}

	var options []map[string]interface{}
	for _, opt := range product.Options {
		options = append(options, map[string]interface{}{
			"id":              opt.ID,
			"name":            opt.Name,
			"cost":            opt.Cost,
			"retail_price":    opt.RetailPrice,
			"wholesale_price": opt.WholesalePrice,
			"is_required":     opt.IsRequired,
		})
	}

	var tiers []map[string]interface{}
	for _, t := range product.PricingTiers {
		tiers = append(tiers, map[string]interface{}{
			"id":        t.ID,
			"quantity":  t.Quantity,
			"unit_price": t.UnitPrice,
		})
	}

	result := map[string]interface{}{
		"id":               product.ID,
		"company":          serializeFullCompany(product.Company),
		"name":             product.Name,
		"sku":              product.SKU,
		"description":      product.Description,
		"global_category":  globalCategory,
		"company_categories": companyCategories,
		"retail_price":     product.RetailPrice,
		"wholesale_price":  product.WholesalePrice,
		"display_price":    displayPrice,
		"discount":         product.Discount,
		"stock_quantity":   product.StockQuantity,
		"min_stock_alert":  product.MinStockAlert,
		"is_available":     product.Status == "active" && product.StockQuantity > 0,
		"status":           product.Status,
		"specs":            product.Specs,
		"options":          options,
		"pricing_tiers":    tiers,
		"images":           images,
		"created_at":       product.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":       product.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}

	if includeCost {
		result["cost_price"] = product.CostPrice
	}

	return result
}

func serializeOrder(order *models.Order) map[string]interface{} {
	if order == nil {
		return nil
	}

	var items []map[string]interface{}
	for _, item := range order.Items {
		items = append(items, map[string]interface{}{
			"id":                item.ID,
			"product_id":        item.ProductID,
			"product_name":      item.ProductNameSnapshot,
			"quantity":          item.Quantity,
			"unit_price":        item.UnitPrice,
			"total_line_price":  item.TotalLinePrice,
			"selected_options":  item.SelectedOptions,
		})
	}

	sellerParty := map[string]interface{}(nil)
	if order.SellerCompany != nil {
		sellerParty = map[string]interface{}{
			"type":    "company",
			"id":      order.SellerCompany.ID,
			"name":    order.SellerCompany.Name,
			"phone":   order.SellerCompany.Phone,
			"email":   nil,
			"city":    serializeCity(order.SellerCompany.City),
			"address": order.SellerCompany.Address,
		}
	}

	buyerParty := map[string]interface{}(nil)
	if order.OrderType == "b2b" && order.BuyerCompany != nil {
		buyerParty = map[string]interface{}{
			"type":    "company",
			"id":      order.BuyerCompany.ID,
			"name":    order.BuyerCompany.Name,
			"phone":   order.BuyerCompany.Phone,
			"email":   nil,
			"city":    serializeCity(order.BuyerCompany.City),
			"address": order.BuyerCompany.Address,
		}
	}

	return map[string]interface{}{
		"id":                        order.ID,
		"order_number":              order.OrderNumber,
		"order_type":                order.OrderType,
		"status":                    order.Status,
		"payment_status":            order.PaymentStatus,
		"payment_method":            order.PaymentMethod,
		"seller_party":              sellerParty,
		"buyer_party":               buyerParty,
		"total_amount":              order.TotalAmount,
		"discount_amount":           order.DiscountAmount,
		"tax_amount":                order.TaxAmount,
		"paid_amount":               order.PaidAmount,
		"shipping_cost":             order.ShippingCost,
		"shipping_method":           order.ShippingMethod,
		"shipping_address":          order.ShippingAddress,
		"cancellation_reason":       order.CancellationReason,
		"currency_code":             order.CurrencyCode,
		"currency_symbol":           order.CurrencySymbol,
		"buyer_receipt_confirmed":   order.BuyerReceiptConfirmed,
		"buyer_receipt_confirmed_at": formatTime(order.BuyerReceiptConfirmedAt),
		"fulfilled_at":              formatTime(order.FulfilledAt),
		"stock_transferred_at":      formatTime(order.StockTransferredAt),
		"items":                     items,
		"created_at":                order.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":                order.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func formatTime(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format("2006-01-02T15:04:05Z07:00")
	return &s
}

func serializeCity(city *models.City) map[string]interface{} {
	if city == nil {
		return nil
	}
	return map[string]interface{}{
		"id":   city.ID,
		"name": city.Name,
		"code": city.Code,
		"country": map[string]interface{}{
			"id":   city.Country.ID,
			"name": city.Country.Name,
			"code": city.Country.Code,
		},
	}
}

func paginationResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	return map[string]interface{}{
		"items": items,
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

func searchTerms(search string) []string {
	var terms []string
	for _, part := range strings.Split(search, " ") {
		part = strings.TrimSpace(part)
		if part != "" {
			terms = append(terms, part)
		}
	}
	return terms
}
