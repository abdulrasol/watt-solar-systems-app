package routes

import (
	"github.com/gin-gonic/gin"

	"watt/internal/config"
	"watt/internal/handlers/companies"
	"watt/internal/middleware"
)

// SetupCompanyRoutes registers the /companies and /company routes
func SetupCompanyRoutes(router *gin.RouterGroup, cfg *config.Config) {
	// Public service types
	serviceTypesPublicGroup := router.Group("/service-types")
	{
		serviceTypesPublicGroup.GET("/", companies.ListServiceTypes)
		serviceTypesPublicGroup.GET("/public", companies.ListServiceTypes)
	}

	// Public APIs
	publicGroup := router.Group("/public/companies")
	{
		publicGroup.GET("/", companies.PublicListCompanies)
		publicGroup.GET("/posters", companies.PublicListPosters)
		publicGroup.GET("/:company_id", companies.PublicGetCompany)
		publicGroup.GET("/:company_id/works", companies.PublicListCompanyWorks)
		publicGroup.GET("/:company_id/services", companies.PublicGetCompanyServices)
	}

	// Superuser Admin APIs
	superAdminGroup := router.Group("/admin/companies")
	superAdminGroup.Use(middleware.AuthMiddleware(cfg))
	superAdminGroup.Use(middleware.SuperuserMiddleware())
	{
		superAdminGroup.GET("", companies.AdminListCompanies)
		superAdminGroup.POST("/:company_id/status", companies.AdminUpdateCompanyStatus)
		superAdminGroup.GET("/:company_id", companies.AdminGetCompany)
		superAdminGroup.GET("/:company_id/services", companies.AdminGetCompanyServices)
		superAdminGroup.GET("/:company_id/members", companies.AdminGetCompanyMembers)
		superAdminGroup.GET("/:company_id/posters", companies.AdminGetCompanyPosters)
		superAdminGroup.POST("/posters/:poster_id/review", companies.AdminReviewPoster)
		superAdminGroup.POST("/posters/:poster_id/extend", companies.AdminExtendPoster)

		// Company Types
		superAdminGroup.POST("/types", companies.AdminCreateCompanyType)
		superAdminGroup.PUT("/types/:id", companies.AdminUpdateCompanyType)
		superAdminGroup.DELETE("/types/:id", companies.AdminDeleteCompanyType)

		// Service Types
		superAdminGroup.POST("/service-types", companies.AdminCreateServiceType)
		superAdminGroup.PUT("/service-types/:id", companies.AdminUpdateServiceType)
		superAdminGroup.DELETE("/service-types/:id", companies.AdminDeleteServiceType)

		// Catalog Services (use service_code in path)
		superAdminGroup.GET("/catalog/services", companies.AdminListCatalogServices)
		superAdminGroup.POST("/catalog/services", companies.AdminCreateCatalogService)
		superAdminGroup.PUT("/catalog/services/:service_code", companies.AdminUpdateCatalogService)
		superAdminGroup.DELETE("/catalog/services/:service_code", companies.AdminDeleteCatalogService)

		superAdminGroup.GET("/:company_id/details", companies.AdminGetCompanyDetails)
		superAdminGroup.GET("/posters", companies.AdminListAdminPosters)
		superAdminGroup.POST("/:company_id/subscription-requests/:request_id/review", companies.AdminReviewSubscriptionRequest)
	}

	// Companies APIs
	companiesGroup := router.Group("/companies")
	{
		companiesGroup.GET("/types", companies.GetCompanyTypes)
		companiesGroup.GET("/service-types", companies.GetServiceTypes)

		// Authenticated Routes
		authCompanies := companiesGroup.Group("")
		authCompanies.Use(middleware.AuthMiddleware(cfg))
		{
			authCompanies.POST("/register", companies.RegisterCompany)
			authCompanies.GET("/catalog/services", companies.GetServiceCatalog)
			authCompanies.GET("/subscriptions", companies.GetSubscriptionPlans)
			authCompanies.GET("/service-types/:id", companies.GetServiceTypeByID)
			authCompanies.POST("/service-types/:id/toggle", companies.ToggleCompanyServiceType)
			authCompanies.PUT("/:company_id", companies.UpdateCompany)
		}
	}

	// Specific Company operations
	companyGroup := router.Group("/companies/:company_id")
	companyGroup.Use(middleware.AuthMiddleware(cfg))
	companyGroup.Use(middleware.CompanyMemberMiddleware())
	{
		companyGroup.GET("/summary", companies.GetCompanySummary)
		companyGroup.POST("/subscription-request", companies.RequestSubscription)
		companyGroup.POST("/activation-reminder", companies.ActivationReminder)
		companyGroup.POST("/toggle-active", companies.ToggleCompanyActive)
		companyGroup.GET("/services", companies.GetCompanyServices)
		companyGroup.GET("/systems", companies.GetCompanySystems)
		companyGroup.GET("/analytics", companies.GetCompanyAnalytics)
		companyGroup.GET("/public-services", companies.GetPublicServices)
		companyGroup.POST("/public-services", companies.CreatePublicService)
		companyGroup.PUT("/public-services/:service_id", companies.UpdatePublicService)
		companyGroup.DELETE("/public-services/:service_id", companies.DeletePublicService)
		companyGroup.GET("/categories", companies.GetCompanyCategories)
		companyGroup.POST("/categories", companies.CreateCompanyCategory)
		companyGroup.DELETE("/categories/:category_id", companies.DeleteCompanyCategory)
		companyGroup.POST("/posters", companies.CreatePoster)
		companyGroup.GET("/posters", companies.GetCompanyPosters)
		companyGroup.PUT("/posters/:poster_id", companies.UpdatePoster)
		companyGroup.DELETE("/posters/:poster_id", companies.DeletePoster)
		companyGroup.PATCH("/posters/:poster_id/toggle-active", companies.TogglePosterActive)

		// Works APIs
		companyGroup.GET("/works", companies.GetCompanyWorks)
		companyGroup.POST("/works", companies.CreateCompanyWork)
		companyGroup.PUT("/works/:work_id", companies.UpdateCompanyWork)
		companyGroup.DELETE("/works/:work_id", companies.DeleteCompanyWork)
		companyGroup.DELETE("/works/images/:image_id", companies.DeleteCompanyWorkImage)

		// Members APIs
		companyGroup.GET("/members", companies.GetCompanyMembers)

		// Finance & Expenses APIs
		companyGroup.GET("/expense", companies.GetExpenses)
		companyGroup.POST("/expense", companies.CreateExpense)
		companyGroup.DELETE("/expense/:expense_id", companies.DeleteExpense)

		companyGroup.GET("/finance", companies.GetFinancialTransactions)
		companyGroup.POST("/finance", companies.CreateFinancialTransaction)
		companyGroup.DELETE("/finance/:tx_id", companies.DeleteFinancialTransaction)

		// Delivery APIs
		companyGroup.GET("/delivery", companies.GetDeliveryOptions)
		companyGroup.POST("/delivery", companies.CreateDeliveryOption)
		companyGroup.DELETE("/delivery/:option_id", companies.DeleteDeliveryOption)

		// Contacts APIs
		companyGroup.GET("/contacts", companies.GetContacts)
		companyGroup.POST("/contacts", companies.CreateContact)
		companyGroup.DELETE("/contacts/:contact_id", companies.DeleteContact)

		adminGroup := companyGroup.Group("")
		adminGroup.Use(middleware.CompanyAdminMiddleware())
		{
			adminGroup.POST("/members/invite", companies.InviteMember)
			adminGroup.POST("/members/create", companies.CreateNewMember)
			adminGroup.DELETE("/members/:member_id", companies.RemoveMember)
		}
	}
}
