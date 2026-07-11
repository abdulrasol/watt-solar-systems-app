package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/shop"
	"watt/internal/middleware"
)

// SetupShopRoutes registers the /shop routes
func SetupShopRoutes(router *gin.RouterGroup, cfg *config.Config) {
	shopGroup := router.Group("/shop")
	{
		shopGroup.GET("/catalog/meta", shop.StoreCatalogMeta)

		storeGroup := shopGroup.Group("/store")
		{
			storeGroup.GET("/companies", shop.ListStoreCompanies)
			storeGroup.GET("/companies/:id/company-categories", shop.ListStoreCompanyCategories)
			storeGroup.GET("/products", shop.ListStoreProducts)
			storeGroup.GET("/products/:id", shop.GetStoreProduct)
			storeGroup.GET("/companies/:id/products", shop.ListStoreCompanyProducts)
			storeGroup.GET("/categories/:type/:id/products", shop.ListStoreCategoryProducts)
			storeGroup.GET("/search", shop.ListStoreSearch)
		}

		b2bGroup := shopGroup.Group("/b2b")
		{
			b2bGroup.GET("/products", shop.ListB2BProducts)
			b2bGroup.GET("/products/:id", shop.GetB2BProduct)
			b2bGroup.GET("/companies/:id/products", shop.ListB2BCompanyProducts)
			b2bGroup.GET("/categories/:type/:id/products", shop.ListB2BCategoryProducts)
			b2bGroup.GET("/search", shop.ListB2BSearch)
		}

		// Authenticated order endpoints
		authShop := shopGroup.Group("")
		authShop.Use(middleware.AuthMiddleware(cfg))
		{
			authShop.POST("/store/orders", shop.CreateStoreOrder)
			authShop.POST("/b2b/orders", shop.CreateB2BOrder)
			authShop.GET("/store/my-orders", shop.ListMyStoreOrders)
			authShop.GET("/store/my-orders/:order_id", shop.GetMyStoreOrder)
			authShop.POST("/store/my-orders/:order_id/cancel", shop.CancelMyStoreOrder)
			authShop.GET("/b2b/my-orders", shop.ListMyB2BOrders)
			authShop.GET("/b2b/my-orders/:order_id", shop.GetMyB2BOrder)
			authShop.POST("/b2b/my-orders/:order_id/cancel", shop.CancelMyB2BOrder)
			authShop.POST("/b2b/my-orders/:order_id/confirm-receipt", shop.ConfirmB2BReceipt)
			authShop.POST("/cart/validate", shop.ValidateCart)
		}
	}

	// Company commerce routes
	companyShop := router.Group("/companies/:company_id")
	companyShop.Use(middleware.AuthMiddleware(cfg))
	companyShop.Use(middleware.CompanyMemberMiddleware())
	{
		companyShop.GET("/products", shop.ListCompanyProducts)
		companyShop.GET("/products/filter-options", shop.GetCompanyProductFilterOptions)
		companyShop.GET("/products/:product_id", shop.GetCompanyProduct)
		companyShop.POST("/products", shop.CreateCompanyProduct)
		companyShop.PUT("/products/:product_id", shop.UpdateCompanyProduct)
		companyShop.DELETE("/products/:product_id", shop.DeleteCompanyProduct)

		companyShop.GET("/orders", shop.ListCompanyOrders)
		companyShop.POST("/orders", shop.CreateCompanyOrder)
		companyShop.GET("/orders/:order_id", shop.GetCompanyOrder)
		companyShop.PUT("/orders/:order_id", shop.UpdateCompanyOrder)

		companyShop.GET("/customers", shop.ListCompanyCustomers)
		companyShop.GET("/customers/:customer_id", shop.GetCompanyCustomer)
		companyShop.POST("/customers", shop.CreateCompanyCustomer)
		companyShop.PUT("/customers/:customer_id", shop.UpdateCompanyCustomer)
		companyShop.DELETE("/customers/:customer_id", shop.DeleteCompanyCustomer)

		companyShop.GET("/suppliers", shop.ListCompanySuppliers)
		companyShop.GET("/suppliers/:supplier_id", shop.GetCompanySupplier)
		companyShop.POST("/suppliers", shop.CreateCompanySupplier)
		companyShop.PUT("/suppliers/:supplier_id", shop.UpdateCompanySupplier)
		companyShop.DELETE("/suppliers/:supplier_id", shop.DeleteCompanySupplier)
	}

	// Admin shop routes
	adminShop := router.Group("/admin/shop")
	adminShop.Use(middleware.AuthMiddleware(cfg))
	adminShop.Use(middleware.SuperuserMiddleware())
	{
		adminShop.GET("/products", shop.AdminListProducts)
		adminShop.GET("/products/:product_id", shop.AdminGetProduct)
		adminShop.POST("/products", shop.AdminCreateProduct)
		adminShop.PUT("/products/:product_id", shop.AdminUpdateProduct)
		adminShop.DELETE("/products/:product_id", shop.AdminDeleteProduct)
	}
}
