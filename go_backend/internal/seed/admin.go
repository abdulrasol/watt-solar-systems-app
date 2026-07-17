package seed

import (
	"log"
	"os"

	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services"
)

// EnsureDefaultAdmin creates a default superuser if no users exist in the database.
// Credentials are read from environment variables with safe fallbacks for first run.
func EnsureDefaultAdmin() {
	var count int64
	if err := database.DB.Model(&models.User{}).Count(&count).Error; err != nil {
		log.Printf("Warning: failed to count users during seed: %v", err)
		return
	}

	if count > 0 {
		return
	}

	username := os.Getenv("DEFAULT_ADMIN_USERNAME")
	if username == "" {
		username = "admin"
	}
	email := os.Getenv("DEFAULT_ADMIN_EMAIL")
	if email == "" {
		email = "admin@watt.local"
	}
	password := os.Getenv("DEFAULT_ADMIN_PASSWORD")
	if password == "" {
		password = "admin123"
	}

	hashedPassword, err := services.GenerateDjangoPassword(password)
	if err != nil {
		log.Printf("Warning: failed to hash default admin password: %v", err)
		return
	}

	admin := models.User{
		Username:    username,
		Email:       email,
		Password:    hashedPassword,
		IsActive:    true,
		IsStaff:     true,
		IsSuperuser: true,
	}

	if err := database.DB.Create(&admin).Error; err != nil {
		log.Printf("Warning: failed to create default admin user: %v", err)
		return
	}

	log.Printf("Default admin user created: username=%s, email=%s", username, email)
	log.Println("IMPORTANT: Change the default password after first login!")
}
