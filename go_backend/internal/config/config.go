package config

import (
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

func parseStringSlice(raw string) []string {
	if raw == "" {
		return nil
	}
	parts := strings.Split(raw, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			result = append(result, p)
		}
	}
	return result
}

type Config struct {
	FCMProjectID          string
	FCMServiceAccountFile string
	EmailHostUser         string
	EmailHostPassword     string
	Port                  string
	DatabaseURL           string
	JWTSecret             string
	AdminCookieSecret     string
	CORSAllowedOrigins    []string
}

func LoadConfig() *Config {
	// Try loading from .env file, ignore if not found
	err := godotenv.Load(".env")
	if err != nil {
		log.Println("Warning: No .env file found or error loading it, using system environment variables")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		dbUrl = "watt.sqlite3"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("FATAL: JWT_SECRET environment variable is required. Set a strong secret (at least 32 characters) in your .env file.")
	}
	if len(jwtSecret) < 32 {
		log.Fatalf("FATAL: JWT_SECRET must be at least 32 characters long, got %d characters.", len(jwtSecret))
	}

	adminCookieSecret := os.Getenv("ADMIN_COOKIE_SECRET")
	if adminCookieSecret == "" {
		log.Fatal("FATAL: ADMIN_COOKIE_SECRET environment variable is required. Set a strong secret (at least 32 characters) in your .env file.")
	}
	if len(adminCookieSecret) < 32 {
		log.Fatalf("FATAL: ADMIN_COOKIE_SECRET must be at least 32 characters long, got %d characters.", len(adminCookieSecret))
	}

	corsOrigins := parseStringSlice(os.Getenv("CORS_ALLOWED_ORIGINS"))
	if len(corsOrigins) == 0 {
		if os.Getenv("GIN_MODE") == "release" {
			log.Fatal("FATAL: CORS_ALLOWED_ORIGINS environment variable is required in release mode. Example: https://watt.example.com,https://admin.watt.example.com")
		}
		corsOrigins = []string{"http://localhost:*", "http://127.0.0.1:*"}
	}

	return &Config{
		FCMProjectID:          os.Getenv("FCM_PROJECT_ID"),
		FCMServiceAccountFile: os.Getenv("FCM_SERVICE_ACCOUNT_FILE"),
		EmailHostUser:         os.Getenv("EMAIL_HOST_USER"),
		EmailHostPassword:     os.Getenv("EMAIL_HOST_PASSWORD"),
		Port:                  port,
		DatabaseURL:           dbUrl,
		JWTSecret:             jwtSecret,
		AdminCookieSecret:     adminCookieSecret,
		CORSAllowedOrigins:    corsOrigins,
	}
}
