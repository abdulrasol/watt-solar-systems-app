package shop

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// CreateStoreOrder handles POST /api/v1/shop/store/orders
// @Summary CreateStoreOrder
// @Description Create a B2C order
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.B2COrderCreateSchema true "Order"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/orders [post]
func CreateStoreOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}

	var payload models.B2COrderCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if err := createOrder(c, userID, "b2c", payload.SellerCompanyID, payload.Items, payload.PaymentMethod, payload.ShippingCost, payload.ShippingMethod, payload.ShippingAddress, payload.DiscountAmount, payload.TaxAmount, payload.CurrencyCode, payload.CurrencySymbol, nil); err != nil {
		return
	}
}

// CreateB2BOrder handles POST /api/v1/shop/b2b/orders
// @Summary CreateB2BOrder
// @Description Create a B2B order
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.B2BOrderCreateSchema true "Order"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/orders [post]
func CreateB2BOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}

	var payload models.B2BOrderCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if err := createOrder(c, userID, "b2b", payload.SellerCompanyID, payload.Items, payload.PaymentMethod, payload.ShippingCost, payload.ShippingMethod, payload.ShippingAddress, payload.DiscountAmount, payload.TaxAmount, payload.CurrencyCode, payload.CurrencySymbol, payload.DueDate); err != nil {
		return
	}
}

func createOrder(c *gin.Context, buyerUserID uint, orderType string, sellerCompanyID uint, items []models.OrderItemCreateSchema, paymentMethod string, shippingCost float64, shippingMethod *string, shippingAddress interface{}, discountAmount, taxAmount float64, currencyCode, currencySymbol *string, dueDate *time.Time) error {
	var seller models.Company
	if err := database.DB.Preload("CompanyType").Preload("CompanyType.AllowedServices").First(&seller, sellerCompanyID).Error; err != nil {
		response.Error(c, http.StatusBadRequest, "Seller company not found", nil)
		return err
	}

	channel := "b2c"
	if orderType == "b2b" {
		channel = "b2b"
	}
	if !companies.IsCompanyPubliclyVisible(&seller, channel) {
		response.Error(c, http.StatusBadRequest, "Seller not eligible for this channel", nil)
		return fmt.Errorf("seller not eligible")
	}

	var buyerUser models.User
	if err := database.DB.First(&buyerUser, buyerUserID).Error; err != nil {
		response.Error(c, http.StatusBadRequest, "Buyer not found", nil)
		return err
	}

	var buyerCompany *models.Company
	if orderType == "b2b" {
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", buyerUserID).Preload("Company").First(&member).Error; err != nil {
			response.Error(c, http.StatusBadRequest, "Buyer company not found", nil)
			return err
		}
		buyerCompany = &member.Company
		if buyerCompany.ID == seller.ID {
			response.Error(c, http.StatusBadRequest, "Cannot order from own company", nil)
			return fmt.Errorf("same company")
		}
	}

	now := time.Now()
	order := models.Order{
		SellerCompanyID: &seller.ID,
		OrderType:       orderType,
		Status:          "pending",
		PaymentStatus:   "unpaid",
		PaymentMethod:   paymentMethod,
		ShippingCost:    shippingCost,
		ShippingMethod:  shippingMethod,
		DiscountAmount:  discountAmount,
		TaxAmount:       taxAmount,
		CurrencyCode:    currencyCode,
		CurrencySymbol:  currencySymbol,
		CreatedAt:       now,
		UpdatedAt:       now,
	}

	if orderType == "b2c" {
		order.BuyerUserID = &buyerUserID
	} else {
		order.BuyerCompanyID = &buyerCompany.ID
	}

	if dueDate != nil {
		order.DueDate = dueDate
	} else if paymentMethod == "cash" {
		d := now
		order.DueDate = &d
	} else {
		d := now.AddDate(0, 0, 30)
		order.DueDate = &d
	}

	// Validate items and calculate total
	var subtotal float64
	for _, item := range items {
		var product models.Product
		if err := database.DB.First(&product, item.ProductID).Error; err != nil {
			response.Error(c, http.StatusBadRequest, "Product not found", nil)
			return err
		}
		if product.CompanyID == nil || *product.CompanyID != seller.ID {
			response.Error(c, http.StatusBadRequest, "Product does not belong to seller", nil)
			return fmt.Errorf("product seller mismatch")
		}
		if product.Status != "active" || product.StockQuantity < item.Quantity {
			response.Error(c, http.StatusBadRequest, "Product not available", nil)
			return fmt.Errorf("product unavailable")
		}

		unitPrice := product.RetailPrice
		if orderType == "b2b" {
			unitPrice = product.WholesalePrice
		}
		totalLinePrice := unitPrice * float64(item.Quantity)
		subtotal += totalLinePrice

		order.Items = append(order.Items, models.OrderItem{
			ProductID:           &product.ID,
			Quantity:            item.Quantity,
			UnitPrice:           unitPrice,
			TotalLinePrice:      totalLinePrice,
			ProductNameSnapshot: &product.Name,
		})
	}

	order.TotalAmount = subtotal + shippingCost + taxAmount - discountAmount
	if paymentMethod == "cash" {
		order.PaymentStatus = "paid"
		order.PaidAmount = order.TotalAmount
	}

	if err := database.DB.Create(&order).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create order", nil)
		return err
	}

	// Create invoice
	invoice := models.Invoice{
		CompanyID:     seller.ID,
		OrderID:       &order.ID,
		InvoiceNumber: fmt.Sprintf("INV-%d", order.ID),
		IssueDate:     now,
		DueDate:       *order.DueDate,
		TotalAmount:   order.TotalAmount,
		PaidAmount:    order.PaidAmount,
		Status:        "draft",
	}
	if order.PaymentStatus == "paid" {
		invoice.Status = "paid"
	} else {
		invoice.Status = "sent"
	}
	database.DB.Create(&invoice)

	if paymentMethod == "cash" {
		payment := models.Payment{
			CompanyID:     seller.ID,
			InvoiceID:     &invoice.ID,
			PaymentType:   "incoming",
			Amount:        order.TotalAmount,
			PaymentDate:   now,
			PaymentMethod: paymentMethod,
		}
		database.DB.Create(&payment)
	}

	if orderType == "b2b" {
		bill := models.Bill{
			CompanyID:    buyerCompany.ID,
			OrderID:      &order.ID,
			BillNumber:   fmt.Sprintf("BILL-%d", order.ID),
			IssueDate:    &now,
			DueDate:      *order.DueDate,
			TotalAmount:  order.TotalAmount,
			PaidAmount:   0,
			Status:       "received",
		}
		database.DB.Create(&bill)
	}

	// Auto-create customer/supplier
	if orderType == "b2c" {
		createB2CCustomer(&seller, buyerUserID)
	} else {
		createB2BCustomer(&seller, buyerCompany.ID)
		createB2BSupplier(buyerCompany, seller.ID)
	}

	notifsvc.SendSellerNewOrderNotification(&order)
	if order.PaymentStatus == "paid" {
		notifsvc.SendBuyerOrderPaymentStatusNotification(&order)
	}

	response.Success(c, http.StatusOK, "Order created successfully", serializeOrder(&order))
	return nil
}

func createB2CCustomer(seller *models.Company, buyerUserID uint) {
	var existing models.Customer
	if err := database.DB.Where("company_id = ? AND buyer_profile_id = ? AND customer_type = ?", seller.ID, buyerUserID, "b2c").First(&existing).Error; err == nil {
		return
	}
	var user models.User
	if err := database.DB.First(&user, buyerUserID).Error; err != nil {
		return
	}
	customer := models.Customer{
		CompanyID:    seller.ID,
		CustomerType: "b2c",
		BuyerUserID:  &buyerUserID,
		FullName:     &user.FirstName,
	}
	database.DB.Create(&customer)
}

func createB2BCustomer(seller *models.Company, buyerCompanyID uint) {
	var existing models.Customer
	if err := database.DB.Where("company_id = ? AND buyer_company_id = ? AND customer_type = ?", seller.ID, buyerCompanyID, "b2b").First(&existing).Error; err == nil {
		return
	}
	customer := models.Customer{
		CompanyID:       seller.ID,
		CustomerType:    "b2b",
		BuyerCompanyID:  &buyerCompanyID,
	}
	database.DB.Create(&customer)
}

func createB2BSupplier(buyerCompany *models.Company, sellerCompanyID uint) {
	var existing models.Supplier
	if err := database.DB.Where("company_id = ? AND seller_company_id = ? AND supplier_type = ?", buyerCompany.ID, sellerCompanyID, "b2b").First(&existing).Error; err == nil {
		return
	}
	var seller models.Company
	if err := database.DB.First(&seller, sellerCompanyID).Error; err != nil {
		return
	}
	supplier := models.Supplier{
		CompanyID:        buyerCompany.ID,
		SupplierType:     "b2b",
		SellerCompanyID:  &sellerCompanyID,
		Name:             seller.Name,
	}
	database.DB.Create(&supplier)
}

// ListMyStoreOrders handles GET /api/v1/shop/store/my-orders
// @Summary ListMyStoreOrders
// @Description List authenticated user's B2C orders
// @Tags Shop
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /shop/store/my-orders [get]
func ListMyStoreOrders(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	listMyOrders(c, userID, "b2c")
}

// GetMyStoreOrder handles GET /api/v1/shop/store/my-orders/:order_id
// @Summary GetMyStoreOrder
// @Description Get authenticated user's B2C order
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/my-orders/{order_id} [get]
func GetMyStoreOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	getMyOrder(c, userID, "b2c")
}

// CancelMyStoreOrder handles POST /api/v1/shop/store/my-orders/:order_id/cancel
// @Summary CancelMyStoreOrder
// @Description Cancel user's B2C order
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/store/my-orders/{order_id}/cancel [post]
func CancelMyStoreOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	cancelMyOrder(c, userID, "b2c")
}

// ListMyB2BOrders handles GET /api/v1/shop/b2b/my-orders
// @Summary ListMyB2BOrders
// @Description List authenticated company's B2B orders
// @Tags Shop
// @Produce json
// @Security Bearer
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/my-orders [get]
func ListMyB2BOrders(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	listMyOrders(c, userID, "b2b")
}

// GetMyB2BOrder handles GET /api/v1/shop/b2b/my-orders/:order_id
// @Summary GetMyB2BOrder
// @Description Get authenticated company's B2B order
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/my-orders/{order_id} [get]
func GetMyB2BOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	getMyOrder(c, userID, "b2b")
}

// CancelMyB2BOrder handles POST /api/v1/shop/b2b/my-orders/:order_id/cancel
// @Summary CancelMyB2BOrder
// @Description Cancel company's B2B order
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/my-orders/{order_id}/cancel [post]
func CancelMyB2BOrder(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}
	cancelMyOrder(c, userID, "b2b")
}

// ConfirmB2BReceipt handles POST /api/v1/shop/b2b/my-orders/:order_id/confirm-receipt
// @Summary ConfirmB2BReceipt
// @Description Confirm receipt of B2B order and transfer stock
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /shop/b2b/my-orders/{order_id}/confirm-receipt [post]
func ConfirmB2BReceipt(c *gin.Context) {
	userID, ok := getUserID(c)
	if !ok {
		return
	}

	orderID, err := strconv.Atoi(c.Param("order_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid order ID", nil)
		return
	}

	var member models.CompanyMember
	if err := database.DB.Where("user_id = ?", userID).First(&member).Error; err != nil {
		response.Error(c, http.StatusForbidden, "Not a company member", nil)
		return
	}

	var order models.Order
	if err := database.DB.Preload("Items").First(&order, orderID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Order not found", nil)
		return
	}

	if order.OrderType != "b2b" || order.BuyerCompanyID == nil || *order.BuyerCompanyID != member.CompanyID {
		response.Error(c, http.StatusForbidden, "Forbidden", nil)
		return
	}

	if order.Status != "delivered" {
		response.Error(c, http.StatusBadRequest, "Order must be delivered to confirm receipt", nil)
		return
	}

	now := time.Now()
	order.BuyerReceiptConfirmed = true
	order.BuyerReceiptConfirmedAt = &now
	order.Status = "completed"
	order.StockTransferredAt = &now

	// Transfer stock from seller to buyer
	for _, item := range order.Items {
		if item.ProductID == nil {
			continue
		}
		var sellerProduct models.Product
		if err := database.DB.First(&sellerProduct, *item.ProductID).Error; err != nil {
			continue
		}
		if sellerProduct.StockQuantity < item.Quantity {
			continue
		}
		sellerProduct.StockQuantity -= item.Quantity
		database.DB.Save(&sellerProduct)

		// Find or create buyer product
		var buyerProduct models.Product
		if err := database.DB.Where("company_id = ? AND name = ?", member.CompanyID, sellerProduct.Name).First(&buyerProduct).Error; err != nil {
			buyerProduct = models.Product{
				CompanyID:        &member.CompanyID,
				Name:             sellerProduct.Name,
				SKU:              sellerProduct.SKU,
				GlobalCategoryID: sellerProduct.GlobalCategoryID,
				Description:      sellerProduct.Description,
				CostPrice:        sellerProduct.CostPrice,
				RetailPrice:      sellerProduct.RetailPrice,
				WholesalePrice:   sellerProduct.WholesalePrice,
				StockQuantity:    item.Quantity,
				MinStockAlert:    sellerProduct.MinStockAlert,
				Specs:            sellerProduct.Specs,
				Status:           "active",
				SourceProductID:  &sellerProduct.ID,
			}
			database.DB.Create(&buyerProduct)
		} else {
			buyerProduct.StockQuantity += item.Quantity
			database.DB.Save(&buyerProduct)
		}
	}

	if err := database.DB.Save(&order).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to confirm receipt", nil)
		return
	}

	notifsvc.SendB2BOrderReceiptConfirmedNotification(&order)
	notifsvc.SendBuyerOrderStatusNotification(&order)

	response.Success(c, http.StatusOK, "Receipt confirmed and stock transferred", serializeOrder(&order))
}

func listMyOrders(c *gin.Context, userID uint, orderType string) {
	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var companyID *uint
	if orderType == "b2b" {
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", userID).First(&member).Error; err == nil {
			companyID = &member.CompanyID
		}
	}

	query := database.DB.Model(&models.Order{}).Preload("Items.Product").Preload("SellerCompany").Where("order_type = ?", orderType)
	if orderType == "b2c" {
		query = query.Where("buyer_user_id = ?", userID)
	} else {
		query = query.Where("buyer_company_id = ?", *companyID)
	}

	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}
	if paymentStatus := c.Query("payment_status"); paymentStatus != "" {
		query = query.Where("payment_status = ?", paymentStatus)
	}
	if paymentMethod := c.Query("payment_method"); paymentMethod != "" {
		query = query.Where("payment_method = ?", paymentMethod)
	}
	if search := c.Query("search"); search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies ocomp ON ocomp.id = orders.seller_company_id").
			Where("orders.order_number::text ILIKE ? OR ocomp.name ILIKE ?", like, like)
	}

	var total int64
	query.Count(&total)

	var orders []models.Order
	if err := query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&orders).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch orders", nil)
		return
	}

	items := make([]map[string]interface{}, 0, len(orders))
	for _, o := range orders {
		items = append(items, serializeOrder(&o))
	}

	response.Success(c, http.StatusOK, "Orders retrieved successfully", paginationResponse(page, pageSize, total, items))
}

func getMyOrder(c *gin.Context, userID uint, orderType string) {
	orderID, err := strconv.Atoi(c.Param("order_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid order ID", nil)
		return
	}

	var companyID *uint
	if orderType == "b2b" {
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", userID).First(&member).Error; err == nil {
			companyID = &member.CompanyID
		}
	}

	query := database.DB.Preload("Items.Product").Preload("SellerCompany").Where("id = ? AND order_type = ?", orderID, orderType)
	if orderType == "b2c" {
		query = query.Where("buyer_user_id = ?", userID)
	} else {
		query = query.Where("buyer_company_id = ?", *companyID)
	}

	var order models.Order
	if err := query.First(&order).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Order not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Order retrieved successfully", serializeOrder(&order))
}

func cancelMyOrder(c *gin.Context, userID uint, orderType string) {
	orderID, err := strconv.Atoi(c.Param("order_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid order ID", nil)
		return
	}

	var companyID *uint
	if orderType == "b2b" {
		var member models.CompanyMember
		if err := database.DB.Where("user_id = ?", userID).First(&member).Error; err == nil {
			companyID = &member.CompanyID
		}
	}

	query := database.DB.Where("id = ? AND order_type = ?", orderID, orderType)
	if orderType == "b2c" {
		query = query.Where("buyer_user_id = ?", userID)
	} else {
		query = query.Where("buyer_company_id = ?", *companyID)
	}

	var order models.Order
	if err := query.First(&order).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Order not found", nil)
		return
	}

	if order.Status != "pending" && order.Status != "processing" {
		response.Error(c, http.StatusBadRequest, "Order cannot be cancelled", nil)
		return
	}

	order.Status = "cancelled"
	if err := database.DB.Save(&order).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to cancel order", nil)
		return
	}

	notifsvc.SendBuyerOrderStatusNotification(&order)

	response.Success(c, http.StatusOK, "Order cancelled successfully", serializeOrder(&order))
}

