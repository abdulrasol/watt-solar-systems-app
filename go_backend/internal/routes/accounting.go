package routes

import (
	"github.com/gin-gonic/gin"
	"watt/internal/config"
	"watt/internal/handlers/accounting"
	"watt/internal/middleware"
)

// SetupAccountingRoutes registers /api/v1/accounting/:company_id/* routes
func SetupAccountingRoutes(router *gin.RouterGroup, cfg *config.Config) {
	group := router.Group("/accounting/:company_id")
	group.Use(middleware.AuthMiddleware(cfg))
	group.Use(middleware.CompanyMemberMiddleware())
	{
		group.GET("/overview", accounting.Overview)

		group.GET("/accounts", accounting.ListAccounts)
		group.POST("/accounts", accounting.CreateAccount)
		group.PUT("/accounts/:account_id", accounting.UpdateAccount)
		group.DELETE("/accounts/:account_id", accounting.DeleteAccount)

		group.GET("/journal", accounting.ListJournalEntries)
		group.GET("/journal/:entry_id", accounting.GetJournalEntry)

		group.GET("/invoices", accounting.ListInvoices)
		group.GET("/invoices/:invoice_id", accounting.GetInvoice)

		group.GET("/bills", accounting.ListBills)
		group.GET("/bills/:bill_id", accounting.GetBill)

		group.GET("/payments", accounting.ListPayments)
		group.POST("/payments", accounting.CreatePayment)

		group.GET("/ledger", accounting.LedgerSummary)
		group.GET("/receivables", accounting.Receivables)
		group.GET("/payables", accounting.Payables)
		group.GET("/transactions", accounting.Transactions)
	}
}
