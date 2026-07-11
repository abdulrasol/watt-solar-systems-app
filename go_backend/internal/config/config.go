package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	FCMProjectID          string
	FCMServiceAccountFile string
	EmailHostUser         string
	EmailHostPassword     string
	Port                  string
	DatabaseURL           string
	JWTSecret             string
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
		dbUrl = "solarhub_go.sqlite3"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		// Default to the same fallback Django uses so JWTs are interchangeable in dev.
		jwtSecret = "django-insecure-x)8hqn4ff$+!(z@(57be8y5t!c239=2$3i8cctpplkpiz18%d9"
	}

	return &Config{
		FCMProjectID:          os.Getenv("FCM_PROJECT_ID"),
		FCMServiceAccountFile: os.Getenv("FCM_SERVICE_ACCOUNT_FILE"),
		EmailHostUser:         os.Getenv("EMAIL_HOST_USER"),
		EmailHostPassword:     os.Getenv("EMAIL_HOST_PASSWORD"),
		Port:                  port,
		DatabaseURL:           dbUrl,
		JWTSecret:             jwtSecret,
	}
}
