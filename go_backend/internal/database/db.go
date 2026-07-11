package database

import (
	"log"
	"strings"

	"gorm.io/driver/mysql"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"watt/internal/config"
	"watt/internal/models"
)

var DB *gorm.DB

func Connect(cfg *config.Config) {
	var err error

	// Determine if SQLite or MySQL based on DatabaseURL
	if strings.HasSuffix(cfg.DatabaseURL, ".sqlite3") || strings.HasSuffix(cfg.DatabaseURL, ".db") {
		log.Println("Connecting to SQLite database:", cfg.DatabaseURL)
		DB, err = gorm.Open(sqlite.Open(cfg.DatabaseURL), &gorm.Config{})
	} else {
		log.Println("Connecting to MariaDB/MySQL database..")
		DB, err = gorm.Open(mysql.Open(cfg.DatabaseURL), &gorm.Config{})
	}

	if err != nil {
		log.Fatal("Failed to connect to the database! \n", err)
	}

	// Auto-migrate the new models
	if err := DB.AutoMigrate(
		&models.User{},
		&models.AppConfig{},
		&models.Currency{},
		&models.GlobalCategory{},
		&models.Notification{},
		&models.SubscriptionPlan{},
		&models.Feedback{},
		&models.Country{},
		&models.City{},
		// Company Models
		&models.ServiceType{},
		&models.CompanyType{},
		&models.CompanyCategory{},
		&models.Company{},
		&models.CompanyMember{},
		&models.DeliveryOption{},
		&models.Expense{},
		&models.FinancialTransaction{},
		&models.Contact{},
		&models.CompanyService{},
		&models.CompanyServiceCatalog{},
		&models.CompanyServiceSubscription{},
		&models.CompanyServiceRequest{},
		&models.CompanySubscriptionRequest{},
		&models.CompanyWork{},
		&models.CompanyWorkImage{},
		&models.Poster{},
		// Shop / Commerce / Accounting models
		&models.System{},
		&models.Product{},
		&models.ProductImage{},
		&models.ProductOption{},
		&models.ProductPricingTier{},
		&models.Order{},
		&models.OrderItem{},
		&models.Customer{},
		&models.Supplier{},
		&models.Invoice{},
		&models.Bill{},
		&models.Payment{},
		&models.Account{},
		&models.JournalEntry{},
		&models.JournalEntryLine{},
		&models.Payroll{},
		&models.TaxRecord{},
		// Offers
		&models.Offer{},
		&models.OfferRequest{},
		&models.OfferInvolvement{},
		&models.InvolvementTemplate{},
		// Community
		&models.Post{},
		&models.Comment{},
		// Notifications
		&models.PushDevice{},
		&models.NotificationRecord{},
	); err != nil {
		log.Fatal("Failed to auto-migrate database! \n", err)
	}

	log.Println("Database connection established")
}
