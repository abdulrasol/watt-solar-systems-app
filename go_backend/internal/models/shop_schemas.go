package models

import "time"

// OrderItemCreateSchema schema
type OrderItemCreateSchema struct {
	ProductID        uint                   `json:"product_id" binding:"required"`
	Quantity         int                    `json:"quantity" binding:"required"`
	SelectedOptions  []uint `json:"selected_options"`
}

// B2COrderCreateSchema schema
type B2COrderCreateSchema struct {
	SellerCompanyID uint                   `json:"seller_company_id" binding:"required"`
	Items           []OrderItemCreateSchema `json:"items" binding:"required"`
	PaymentMethod   string                 `json:"payment_method" default:"cash"`
	ShippingCost    float64                `json:"shipping_cost" default:"0"`
	ShippingMethod  *string                `json:"shipping_method"`
	ShippingAddress interface{}            `json:"shipping_address"`
	DiscountAmount  float64                `json:"discount_amount" default:"0"`
	TaxAmount       float64                `json:"tax_amount" default:"0"`
	CurrencyCode    *string                `json:"currency_code"`
	CurrencySymbol  *string                `json:"currency_symbol"`
}

// B2BOrderCreateSchema schema
type B2BOrderCreateSchema struct {
	SellerCompanyID uint                    `json:"seller_company_id" binding:"required"`
	Items           []OrderItemCreateSchema `json:"items" binding:"required"`
	PaymentMethod   string                  `json:"payment_method" default:"credit"`
	ShippingCost    float64                 `json:"shipping_cost" default:"0"`
	ShippingMethod  *string                 `json:"shipping_method"`
	ShippingAddress interface{}             `json:"shipping_address"`
	DiscountAmount  float64                 `json:"discount_amount" default:"0"`
	TaxAmount       float64                 `json:"tax_amount" default:"0"`
	CurrencyCode    *string                 `json:"currency_code"`
	CurrencySymbol  *string                 `json:"currency_symbol"`
	DueDate         *time.Time              `json:"due_date"`
}

// SellerOrderCreateSchema schema
type SellerOrderCreateSchema struct {
	OrderType        string                  `json:"order_type" default:"b2c"`
	CustomerID       *uint                   `json:"customer_id"`
	GuestCustomerName *string                `json:"guest_customer_name"`
	BuyerCompanyID   *uint                   `json:"buyer_company_id"`
	BuyerUserID      *uint                   `json:"buyer_user_id"`
	SupplierID       *uint                   `json:"supplier_id"`
	Status           string                  `json:"status" default:"pending"`
	PaymentStatus    string                  `json:"payment_status" default:"unpaid"`
	PaymentMethod    string                  `json:"payment_method" default:"cash"`
	TotalAmount      float64                 `json:"total_amount" default:"0"`
	DiscountAmount   float64                 `json:"discount_amount" default:"0"`
	TaxAmount        float64                 `json:"tax_amount" default:"0"`
	PaidAmount       float64                 `json:"paid_amount" default:"0"`
	ShippingCost     float64                 `json:"shipping_cost" default:"0"`
	ShippingMethod   *string                 `json:"shipping_method"`
	ShippingAddress  interface{}             `json:"shipping_address"`
	CurrencyCode     *string                 `json:"currency_code"`
	CurrencySymbol   *string                 `json:"currency_symbol"`
	Notes            *string                 `json:"notes"`
	Items            []OrderItemCreateSchema `json:"items"`
}

// SellerOrderUpdateSchema schema
type SellerOrderUpdateSchema struct {
	Status             *string     `json:"status"`
	ShippingCost       *float64    `json:"shipping_cost"`
	ShippingMethod     *string     `json:"shipping_method"`
	ShippingAddress    interface{} `json:"shipping_address"`
	CancellationReason *string     `json:"cancellation_reason"`
	PaidAmount         *float64    `json:"paid_amount"`
}

// CustomerCreateSchema schema
type CustomerCreateSchema struct {
	CustomerType    string  `json:"customer_type" binding:"required"`
	BuyerCompanyID  *uint   `json:"buyer_company_id"`
	BuyerProfileID  *uint   `json:"buyer_profile_id"`
	FullName        *string `json:"full_name"`
	PhoneNumber     *string `json:"phone_number"`
	Email           *string `json:"email"`
	Address         *string `json:"address"`
}

// CustomerUpdateSchema schema
type CustomerUpdateSchema struct {
	FullName    *string `json:"full_name"`
	PhoneNumber *string `json:"phone_number"`
	Email       *string `json:"email"`
	Address     *string `json:"address"`
}

// SupplierCreateSchema schema
type SupplierCreateSchema struct {
	SupplierType    string  `json:"supplier_type" default:"external"`
	SellerCompanyID *uint   `json:"seller_company_id"`
	Name            string  `json:"name" binding:"required"`
	ContactName     *string `json:"contact_name"`
	PhoneNumber     *string `json:"phone_number"`
	Email           *string `json:"email"`
	Address         *string `json:"address"`
	TaxID           *string `json:"tax_id"`
}

// SupplierUpdateSchema schema
type SupplierUpdateSchema struct {
	Name        *string `json:"name"`
	ContactName *string `json:"contact_name"`
	PhoneNumber *string `json:"phone_number"`
	Email       *string `json:"email"`
	Address     *string `json:"address"`
	TaxID       *string `json:"tax_id"`
}

// ProductOptionInputSchema schema
type ProductOptionInputSchema struct {
	Name           string  `json:"name" binding:"required"`
	RetailPrice    float64 `json:"retail_price" default:"0"`
	Cost           float64 `json:"cost" default:"0"`
	WholesalePrice float64 `json:"wholesale_price" default:"0"`
	IsRequired     bool    `json:"is_required" default:"false"`
}

// ProductPricingTierInputSchema schema
type ProductPricingTierInputSchema struct {
	Quantity  int     `json:"quantity" binding:"required"`
	UnitPrice float64 `json:"unit_price" binding:"required"`
}

// ProductCreateSchema schema
type ProductCreateSchema struct {
	Name               string                          `json:"name" binding:"required"`
	SKU                *string                         `json:"sku"`
	GlobalCategoryID   *uint                           `json:"global_category_id"`
	CompanyCategoryIDs []uint                          `json:"company_category_ids"`
	Description        *string                         `json:"description"`
	CostPrice          float64                         `json:"cost_price" default:"0"`
	RetailPrice        float64                         `json:"retail_price" default:"0"`
	WholesalePrice     float64                         `json:"wholesale_price" default:"0"`
	Discount           float64                         `json:"discount" default:"0"`
	StockQuantity      int                             `json:"stock_quantity" default:"0"`
	MinStockAlert      int                             `json:"min_stock_alert" default:"5"`
	Specs              interface{}                     `json:"specs"`
	Status             string                          `json:"status" default:"active"`
	Options            []ProductOptionInputSchema      `json:"options"`
	PricingTiers       []ProductPricingTierInputSchema `json:"pricing_tiers"`
	ReplaceImages      bool                            `json:"replace_images" default:"false"`
}

// AdminProductCreateSchema schema
type AdminProductCreateSchema struct {
	ProductCreateSchema
	CompanyID uint `json:"company_id" binding:"required"`
}

// ProductUpdateSchema schema
type ProductUpdateSchema struct {
	Name               *string                         `json:"name"`
	SKU                *string                         `json:"sku"`
	GlobalCategoryID   *uint                           `json:"global_category_id"`
	CompanyCategoryIDs []uint                          `json:"company_category_ids"`
	Description        *string                         `json:"description"`
	CostPrice          *float64                        `json:"cost_price"`
	RetailPrice        *float64                        `json:"retail_price"`
	WholesalePrice     *float64                        `json:"wholesale_price"`
	Discount           *float64                        `json:"discount"`
	StockQuantity      *int                            `json:"stock_quantity"`
	MinStockAlert      *int                            `json:"min_stock_alert"`
	Specs              interface{}                     `json:"specs"`
	Status             *string                         `json:"status"`
	Options            []ProductOptionInputSchema      `json:"options"`
	PricingTiers       []ProductPricingTierInputSchema `json:"pricing_tiers"`
	ReplaceImages      bool                            `json:"replace_images" default:"false"`
}

// AdminProductUpdateSchema schema
type AdminProductUpdateSchema struct {
	ProductUpdateSchema
	CompanyID *uint `json:"company_id"`
}

// CartValidateRequest schema
type CartValidateRequest struct {
	SellerCompanyID  uint                    `json:"seller_company_id" binding:"required"`
	OrderType        string                  `json:"order_type" binding:"required"` // b2b or b2c
	Items            []OrderItemCreateSchema `json:"items" binding:"required"`
	DeliveryOptionID *uint                   `json:"delivery_option_id"`
}

// CartValidateResponse schema
type CartValidateResponse struct {
	Subtotal      float64  `json:"subtotal"`
	DeliveryCost  float64  `json:"delivery_cost"`
	Tax           float64  `json:"tax"`
	Total         float64  `json:"total"`
	Errors        []string `json:"errors"`
}
