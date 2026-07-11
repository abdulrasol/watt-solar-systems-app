package shop

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	notifsvc "watt/internal/services/notifications"
)

// CreateCompanyOrder handles POST /api/v1/companies/:company_id/orders
// @Summary CreateCompanyOrder
// @Description Create an offline order for a seller company
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Param request body models.SellerOrderCreateSchema true "Order"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/orders [post]
func CreateCompanyOrder(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.SellerOrderCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	// Resolve optional customer/supplier and validate ownership
	var customer *models.Customer
	if payload.CustomerID != nil {
		var cust models.Customer
		if err := database.DB.Where("id = ? AND company_id = ?", *payload.CustomerID, company.ID).First(&cust).Error; err != nil {
			response.Error(c, http.StatusBadRequest, "Customer not found", nil)
			return
		}
		customer = &cust
	}
	var supplier *models.Supplier
	if payload.SupplierID != nil {
		var sup models.Supplier
		if err := database.DB.Where("id = ? AND company_id = ?", *payload.SupplierID, company.ID).First(&sup).Error; err != nil {
			response.Error(c, http.StatusBadRequest, "Supplier not found", nil)
			return
		}
		supplier = &sup
	}

	orderType := payload.OrderType
	if orderType == "" {
		orderType = "b2c"
	}

	// Generate next order number
	var lastOrder models.Order
	var nextNumber int64 = 1000
	database.DB.Where("seller_company_id = ?", company.ID).Order("order_number desc").First(&lastOrder)
	if lastOrder.OrderNumber != nil {
		nextNumber = *lastOrder.OrderNumber + 1
	}

	order := models.Order{
		SellerCompanyID:  &company.ID,
		OrderNumber:      &nextNumber,
		OrderType:        orderType,
		Status:           payload.Status,
		PaymentStatus:    payload.PaymentStatus,
		PaymentMethod:    payload.PaymentMethod,
		TotalAmount:      payload.TotalAmount,
		DiscountAmount:   payload.DiscountAmount,
		TaxAmount:        payload.TaxAmount,
		PaidAmount:       payload.PaidAmount,
		ShippingCost:     payload.ShippingCost,
		ShippingMethod:   payload.ShippingMethod,
		CurrencyCode:     payload.CurrencyCode,
		CurrencySymbol:   payload.CurrencySymbol,
		CustomerID:       payload.CustomerID,
		SupplierID:       payload.SupplierID,
		BuyerCompanyID:   payload.BuyerCompanyID,
		BuyerUserID:      payload.BuyerUserID,
		GuestCustomerName: payload.GuestCustomerName,
	}
	if order.Status == "" {
		order.Status = "pending"
	}
	if order.PaymentStatus == "" {
		order.PaymentStatus = "unpaid"
	}
	if order.PaymentMethod == "" {
		order.PaymentMethod = "cash"
	}
	if payload.ShippingAddress != nil {
		addrBytes, _ := json.Marshal(payload.ShippingAddress)
		order.ShippingAddress = addrBytes
	}

	if err := database.DB.Create(&order).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create order", nil)
		return
	}

	for _, item := range payload.Items {
		var product *models.Product
		if item.ProductID != 0 {
			var p models.Product
			if err := database.DB.Where("id = ? AND company_id = ?", item.ProductID, company.ID).First(&p).Error; err == nil {
				product = &p
			}
		}
		var pid *uint
		if product != nil {
			pid = &product.ID
		}
		name := ""
		if product != nil {
			name = product.Name
		}
		var optsBytes []byte
		if len(item.SelectedOptions) > 0 {
			optsBytes, _ = json.Marshal(item.SelectedOptions)
		}
		line := models.OrderItem{
			OrderID:             order.ID,
			ProductID:           pid,
			Quantity:            item.Quantity,
			UnitPrice:           0,
			TotalLinePrice:      0,
			ProductNameSnapshot: &name,
			SelectedOptions:     optsBytes,
		}
		database.DB.Create(&line)
	}

	// Update customer/supplier cached fields if linked
	if customer != nil || supplier != nil {
		// Best-effort: no-op for now
	}

	database.DB.Preload("Items.Product").Preload("BuyerCompany").Preload("BuyerUser").Preload("Customer").Preload("Supplier").First(&order, order.ID)

	notifsvc.SendSellerNewOrderNotification(&order)
	if order.PaymentStatus == "paid" {
		notifsvc.SendBuyerOrderPaymentStatusNotification(&order)
	}

	response.Success(c, http.StatusOK, "Order created successfully", serializeOrder(&order))
}

// ListCompanyOrders handles GET /api/v1/companies/:company_id/orders
// @Summary ListCompanyOrders
// @Description List orders for a seller company
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/orders [get]
func ListCompanyOrders(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Order{}).
		Preload("Items.Product").
		Preload("BuyerCompany").
		Preload("BuyerUser").
		Where("seller_company_id = ?", company.ID)

	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}
	if paymentStatus := c.Query("payment_status"); paymentStatus != "" {
		query = query.Where("payment_status = ?", paymentStatus)
	}
	if paymentMethod := c.Query("payment_method"); paymentMethod != "" {
		query = query.Where("payment_method = ?", paymentMethod)
	}
	if orderType := c.Query("order_type"); orderType != "" {
		query = query.Where("order_type = ?", orderType)
	}
	if search := c.Query("search"); search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies bc ON bc.id = orders.buyer_company_id").
			Joins("LEFT JOIN users bu ON bu.id = orders.buyer_user_id").
			Where("orders.order_number::text LIKE ? OR bc.name LIKE ? OR bu.username LIKE ?", like, like, like)
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

	response.Success(c, http.StatusOK, "Company orders retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetCompanyOrder handles GET /api/v1/companies/:company_id/orders/:order_id
// @Summary GetCompanyOrder
// @Description Get a company order
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/orders/{order_id} [get]
func GetCompanyOrder(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	orderID, err := strconv.Atoi(c.Param("order_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid order ID", nil)
		return
	}

	var order models.Order
	if err := database.DB.
		Preload("Items.Product").
		Preload("BuyerCompany").
		Preload("BuyerUser").
		Where("id = ? AND seller_company_id = ?", orderID, company.ID).First(&order).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Order not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Order retrieved successfully", serializeOrder(&order))
}

// UpdateCompanyOrder handles PUT /api/v1/companies/:company_id/orders/:order_id
// @Summary UpdateCompanyOrder
// @Description Update a company order (status, shipping, payment)
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param order_id path int true "order_id"
// @Param request body models.SellerOrderUpdateSchema true "Update"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/orders/{order_id} [put]
func UpdateCompanyOrder(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	orderID, err := strconv.Atoi(c.Param("order_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid order ID", nil)
		return
	}

	var order models.Order
	if err := database.DB.
		Preload("Items.Product").
		Where("id = ? AND seller_company_id = ?", orderID, company.ID).First(&order).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Order not found", nil)
		return
	}

	var payload models.SellerOrderUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	oldStatus := order.Status
	oldPaymentStatus := order.PaymentStatus

	if payload.Status != nil {
		if !isValidSellerStatusTransition(order.Status, *payload.Status) {
			response.Error(c, http.StatusBadRequest, "Invalid status transition", nil)
			return
		}
		now := time.Now()
		switch *payload.Status {
		case "processing":
			order.Status = "processing"
		case "shipped":
			order.Status = "shipped"
		case "delivered":
			order.Status = "delivered"
		case "completed":
			order.Status = "completed"
			if order.FulfilledAt == nil {
				order.FulfilledAt = &now
			}
		case "cancelled":
			order.Status = "cancelled"
			order.CancellationReason = payload.CancellationReason
		}
	}

	if payload.ShippingCost != nil {
		order.ShippingCost = *payload.ShippingCost
	}
	if payload.ShippingMethod != nil {
		order.ShippingMethod = payload.ShippingMethod
	}
	if payload.ShippingAddress != nil {
		addrBytes, _ := json.Marshal(payload.ShippingAddress)
		order.ShippingAddress = addrBytes
	}
	if payload.PaidAmount != nil {
		order.PaidAmount = *payload.PaidAmount
		if order.PaidAmount >= order.TotalAmount {
			order.PaymentStatus = "paid"
		} else if order.PaidAmount > 0 {
			order.PaymentStatus = "partial"
		}
	}

	// Recalculate total
	order.TotalAmount = subtotalFromOrder(&order) + order.ShippingCost + order.TaxAmount - order.DiscountAmount

	if err := database.DB.Save(&order).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update order", nil)
		return
	}

	if payload.Status != nil && *payload.Status != oldStatus {
		notifsvc.SendBuyerOrderStatusNotification(&order)
		if order.Status == "delivered" {
			notifsvc.SendOrderDeliveryPendingReceiptNotification(&order)
		}
		if order.Status == "completed" && order.OrderType == "b2b" {
			notifsvc.SendB2BOrderReceiptConfirmedNotification(&order)
		}
	}
	if order.PaymentStatus != oldPaymentStatus {
		notifsvc.SendBuyerOrderPaymentStatusNotification(&order)
	}

	response.Success(c, http.StatusOK, "Order updated successfully", serializeOrder(&order))
}

func isValidSellerStatusTransition(current, next string) bool {
	allowed := map[string][]string{
		"pending":   {"processing", "cancelled"},
		"processing": {"shipped", "cancelled"},
		"shipped":   {"delivered", "cancelled"},
		"delivered": {"completed"},
	}
	for _, s := range allowed[current] {
		if s == next {
			return true
		}
	}
	return false
}

func subtotalFromOrder(order *models.Order) float64 {
	var subtotal float64
	for _, item := range order.Items {
		subtotal += item.TotalLinePrice
	}
	return subtotal
}

// ListCompanyCustomers handles GET /api/v1/companies/:company_id/customers
// @Summary ListCompanyCustomers
// @Description List customers of a company
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/customers [get]
func ListCompanyCustomers(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	search := c.Query("search")
	offset := (page - 1) * pageSize

	query := database.DB.Where("company_id = ?", company.ID).Preload("BuyerCompany").Preload("BuyerUser")
	if search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies bc ON bc.id = customers.buyer_company_id").
			Joins("LEFT JOIN users bu ON bu.id = customers.buyer_profile_id").
			Where("customers.full_name LIKE ? OR bc.name LIKE ? OR bu.username LIKE ? OR customers.phone_number LIKE ?", like, like, like, like)
	}

	var total int64
	query.Model(&models.Customer{}).Count(&total)

	var customers []models.Customer
	if err := query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&customers).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch customers", nil)
		return
	}

	items := make([]map[string]interface{}, 0, len(customers))
	for _, cust := range customers {
		items = append(items, serializeCustomer(&cust))
	}

	response.Success(c, http.StatusOK, "Customers retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetCompanyCustomer handles GET /api/v1/companies/:company_id/customers/:customer_id
// @Summary GetCompanyCustomer
// @Description Get a customer
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param customer_id path int true "customer_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/customers/{customer_id} [get]
func GetCompanyCustomer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	customerID, err := strconv.Atoi(c.Param("customer_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid customer ID", nil)
		return
	}

	var customer models.Customer
	if err := database.DB.Preload("BuyerCompany").Preload("BuyerUser").Where("id = ? AND company_id = ?", customerID, company.ID).First(&customer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Customer not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Customer retrieved successfully", serializeCustomer(&customer))
}

// CreateCompanyCustomer handles POST /api/v1/companies/:company_id/customers
// @Summary CreateCompanyCustomer
// @Description Create a customer for a company
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.CustomerCreateSchema true "Customer"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/customers [post]
func CreateCompanyCustomer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.CustomerCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	customerType := strings.ToLower(payload.CustomerType)
	if customerType != "b2c" && customerType != "b2b" {
		response.Error(c, http.StatusBadRequest, "Invalid customer type", nil)
		return
	}

	customer := models.Customer{
		CompanyID:    company.ID,
		CustomerType: customerType,
		FullName:     payload.FullName,
		PhoneNumber:  payload.PhoneNumber,
		Email:        payload.Email,
		Address:      payload.Address,
	}

	if customerType == "b2b" {
		customer.BuyerCompanyID = payload.BuyerCompanyID
	} else {
		customer.BuyerUserID = payload.BuyerProfileID
	}

	if err := database.DB.Create(&customer).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create customer", nil)
		return
	}

	database.DB.Preload("BuyerCompany").Preload("BuyerUser").First(&customer, customer.ID)
	response.Success(c, http.StatusOK, "Customer created successfully", serializeCustomer(&customer))
}

// UpdateCompanyCustomer handles PUT /api/v1/companies/:company_id/customers/:customer_id
// @Summary UpdateCompanyCustomer
// @Description Update a customer
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param customer_id path int true "customer_id"
// @Param request body models.CustomerUpdateSchema true "Customer update"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/customers/{customer_id} [put]
func UpdateCompanyCustomer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	customerID, err := strconv.Atoi(c.Param("customer_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid customer ID", nil)
		return
	}

	var customer models.Customer
	if err := database.DB.Where("id = ? AND company_id = ?", customerID, company.ID).First(&customer).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Customer not found", nil)
		return
	}

	var payload models.CustomerUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if payload.FullName != nil {
		customer.FullName = payload.FullName
	}
	if payload.PhoneNumber != nil {
		customer.PhoneNumber = payload.PhoneNumber
	}
	if payload.Email != nil {
		customer.Email = payload.Email
	}
	if payload.Address != nil {
		customer.Address = payload.Address
	}

	if err := database.DB.Save(&customer).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update customer", nil)
		return
	}

	database.DB.Preload("BuyerCompany").Preload("BuyerUser").First(&customer, customer.ID)
	response.Success(c, http.StatusOK, "Customer updated successfully", serializeCustomer(&customer))
}

// DeleteCompanyCustomer handles DELETE /api/v1/companies/:company_id/customers/:customer_id
// @Summary DeleteCompanyCustomer
// @Description Delete a customer
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param customer_id path int true "customer_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/customers/{customer_id} [delete]
func DeleteCompanyCustomer(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	customerID, err := strconv.Atoi(c.Param("customer_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid customer ID", nil)
		return
	}

	if err := database.DB.Where("id = ? AND company_id = ?", customerID, company.ID).Delete(&models.Customer{}).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete customer", nil)
		return
	}

	response.Success(c, http.StatusOK, "Customer deleted successfully", nil)
}

// ListCompanySuppliers handles GET /api/v1/companies/:company_id/suppliers
// @Summary ListCompanySuppliers
// @Description List suppliers of a company
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/suppliers [get]
func ListCompanySuppliers(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	page, pageSize := parsePagination(c)
	search := c.Query("search")
	offset := (page - 1) * pageSize

	query := database.DB.Where("company_id = ?", company.ID).Preload("SellerCompany")
	if search != "" {
		like := "%" + search + "%"
		query = query.Joins("LEFT JOIN companies sc ON sc.id = suppliers.seller_company_id").
			Where("suppliers.name LIKE ? OR sc.name LIKE ? OR suppliers.phone_number LIKE ?", like, like, like)
	}

	var total int64
	query.Model(&models.Supplier{}).Count(&total)

	var suppliers []models.Supplier
	if err := query.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&suppliers).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to fetch suppliers", nil)
		return
	}

	items := make([]map[string]interface{}, 0, len(suppliers))
	for _, sup := range suppliers {
		items = append(items, serializeSupplier(&sup))
	}

	response.Success(c, http.StatusOK, "Suppliers retrieved successfully", paginationResponse(page, pageSize, total, items))
}

// GetCompanySupplier handles GET /api/v1/companies/:company_id/suppliers/:supplier_id
// @Summary GetCompanySupplier
// @Description Get a supplier
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param supplier_id path int true "supplier_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/suppliers/{supplier_id} [get]
func GetCompanySupplier(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	supplierID, err := strconv.Atoi(c.Param("supplier_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid supplier ID", nil)
		return
	}

	var supplier models.Supplier
	if err := database.DB.Preload("SellerCompany").Where("id = ? AND company_id = ?", supplierID, company.ID).First(&supplier).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Supplier not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Supplier retrieved successfully", serializeSupplier(&supplier))
}

// CreateCompanySupplier handles POST /api/v1/companies/:company_id/suppliers
// @Summary CreateCompanySupplier
// @Description Create a supplier for a company
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param request body models.SupplierCreateSchema true "Supplier"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/suppliers [post]
func CreateCompanySupplier(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	var payload models.SupplierCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	supplierType := strings.ToLower(payload.SupplierType)
	if supplierType == "" {
		supplierType = "external"
	}

	supplier := models.Supplier{
		CompanyID:       company.ID,
		SupplierType:    supplierType,
		SellerCompanyID: payload.SellerCompanyID,
		Name:            payload.Name,
		ContactName:     payload.ContactName,
		PhoneNumber:     payload.PhoneNumber,
		Email:           payload.Email,
		Address:         payload.Address,
		TaxID:           payload.TaxID,
	}

	if err := database.DB.Create(&supplier).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to create supplier", nil)
		return
	}

	database.DB.Preload("SellerCompany").First(&supplier, supplier.ID)
	response.Success(c, http.StatusOK, "Supplier created successfully", serializeSupplier(&supplier))
}

// UpdateCompanySupplier handles PUT /api/v1/companies/:company_id/suppliers/:supplier_id
// @Summary UpdateCompanySupplier
// @Description Update a supplier
// @Tags Shop
// @Accept json
// @Produce json
// @Security Bearer
// @Param supplier_id path int true "supplier_id"
// @Param request body models.SupplierUpdateSchema true "Supplier update"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/suppliers/{supplier_id} [put]
func UpdateCompanySupplier(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	supplierID, err := strconv.Atoi(c.Param("supplier_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid supplier ID", nil)
		return
	}

	var supplier models.Supplier
	if err := database.DB.Where("id = ? AND company_id = ?", supplierID, company.ID).First(&supplier).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Supplier not found", nil)
		return
	}

	var payload models.SupplierUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if payload.Name != nil {
		supplier.Name = *payload.Name
	}
	if payload.ContactName != nil {
		supplier.ContactName = payload.ContactName
	}
	if payload.PhoneNumber != nil {
		supplier.PhoneNumber = payload.PhoneNumber
	}
	if payload.Email != nil {
		supplier.Email = payload.Email
	}
	if payload.Address != nil {
		supplier.Address = payload.Address
	}
	if payload.TaxID != nil {
		supplier.TaxID = payload.TaxID
	}

	if err := database.DB.Save(&supplier).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to update supplier", nil)
		return
	}

	database.DB.Preload("SellerCompany").First(&supplier, supplier.ID)
	response.Success(c, http.StatusOK, "Supplier updated successfully", serializeSupplier(&supplier))
}

// DeleteCompanySupplier handles DELETE /api/v1/companies/:company_id/suppliers/:supplier_id
// @Summary DeleteCompanySupplier
// @Description Delete a supplier
// @Tags Shop
// @Produce json
// @Security Bearer
// @Param supplier_id path int true "supplier_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/suppliers/{supplier_id} [delete]
func DeleteCompanySupplier(c *gin.Context) {
	company, _, ok := companies.GetCompanyFromContext(c)
	if !ok {
		return
	}

	supplierID, err := strconv.Atoi(c.Param("supplier_id"))
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid supplier ID", nil)
		return
	}

	if err := database.DB.Where("id = ? AND company_id = ?", supplierID, company.ID).Delete(&models.Supplier{}).Error; err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to delete supplier", nil)
		return
	}

	response.Success(c, http.StatusOK, "Supplier deleted successfully", nil)
}

func serializeCustomer(cust *models.Customer) map[string]interface{} {
	buyer := map[string]interface{}(nil)
	if cust.CustomerType == "b2b" && cust.BuyerCompany != nil {
		buyer = map[string]interface{}{
			"id":   cust.BuyerCompany.ID,
			"name": cust.BuyerCompany.Name,
		}
	} else if cust.CustomerType == "b2c" && cust.BuyerUser != nil {
		buyer = map[string]interface{}{
			"id":       cust.BuyerUser.ID,
			"username": cust.BuyerUser.Username,
			"full_name": cust.BuyerUser.FirstName,
		}
	}

	return map[string]interface{}{
		"id":            cust.ID,
		"customer_type": cust.CustomerType,
		"buyer_party":   buyer,
		"full_name":     cust.FullName,
		"phone_number":  cust.PhoneNumber,
		"email":         cust.Email,
		"address":       cust.Address,
		"created_at":    cust.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":    cust.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}

func serializeSupplier(sup *models.Supplier) map[string]interface{} {
	seller := map[string]interface{}(nil)
	if sup.SellerCompany != nil {
		seller = map[string]interface{}{
			"id":   sup.SellerCompany.ID,
			"name": sup.SellerCompany.Name,
		}
	}

	return map[string]interface{}{
		"id":             sup.ID,
		"supplier_type":  sup.SupplierType,
		"seller_company": seller,
		"name":           sup.Name,
		"contact_name":   sup.ContactName,
		"phone_number":   sup.PhoneNumber,
		"email":          sup.Email,
		"address":        sup.Address,
		"tax_id":         sup.TaxID,
		"created_at":     sup.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at":     sup.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}
}
