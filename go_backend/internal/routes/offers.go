package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/offers"
	"watt/internal/middleware"
)

// SetupOffersRoutes registers /offers, /involves, and /companies/:company_id/offers routes
func SetupOffersRoutes(router *gin.RouterGroup, cfg *config.Config) {
	// User/company offers
	offersGroup := router.Group("/offers")
	offersGroup.Use(middleware.AuthMiddleware(cfg))
	{
		offersGroup.POST("/requests", offers.CreateRequest)
		offersGroup.GET("/requests", offers.ListMyRequests)
		offersGroup.GET("/requests/:id", offers.GetRequest)
		offersGroup.PUT("/requests/:id", offers.UpdateRequest)
		offersGroup.DELETE("/requests/:id", offers.DeleteRequest)
		offersGroup.GET("/requests/:id/offers", offers.ListRequestOffers)
		offersGroup.POST("/:id/response", offers.RespondToOffer)

		offersGroup.GET("/available-requests", offers.ListAvailableRequests)
		offersGroup.POST("/requests/:id/reply", offers.ReplyToRequest)
		offersGroup.GET("/my-offers", offers.ListCompanyOffers)
		offersGroup.GET("/my-offers/:id", offers.GetCompanyOffer)
		offersGroup.PUT("/my-offers/:id", offers.UpdateCompanyOffer)
		offersGroup.DELETE("/my-offers/:id", offers.DeleteCompanyOffer)
		offersGroup.POST("/my-offers/:id/finish", offers.FinishCompanyOffer)
		offersGroup.POST("/my-offers/:id/complete", offers.CompleteCompanyOffer)

		// Admin
		offersGroup.GET("/admin/offers", offers.AdminListOffers)
		offersGroup.GET("/admin/requests", offers.AdminListRequests)
	}

	// Involvement templates
	involvesGroup := router.Group("/involves")
	involvesGroup.Use(middleware.AuthMiddleware(cfg))
	{
		involvesGroup.GET("/", offers.ListInvolvementTemplates)
		involvesGroup.POST("/", offers.CreateInvolvementTemplate)
		involvesGroup.PUT("/:id", offers.UpdateInvolvementTemplate)
		involvesGroup.DELETE("/:id", offers.DeleteInvolvementTemplate)
	}

	// Company-scoped offers
	companyOffers := router.Group("/companies/:company_id/offers")
	companyOffers.Use(middleware.AuthMiddleware(cfg))
	companyOffers.Use(middleware.CompanyMemberMiddleware())
	{
		companyOffers.GET("/requests", offers.CompanyListOfferRequests)
		companyOffers.GET("/", offers.CompanyListOffers)
		companyOffers.POST("/requests/:request_id/reply", offers.CompanyReplyToOfferRequest)
		companyOffers.PUT("/:offer_id", offers.CompanyUpdateOffer)
		companyOffers.DELETE("/:offer_id", offers.CompanyDeleteOffer)
	}
}
