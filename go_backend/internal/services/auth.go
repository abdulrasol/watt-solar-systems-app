package services

import (
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"golang.org/x/crypto/pbkdf2"
	"watt/internal/config"
	"watt/internal/models"
)

// VerifyDjangoPassword verifies a plain password against a Django pbkdf2_sha256 hash.
// Django hash format: pbkdf2_sha256$iterations$salt$hash_in_base64
func VerifyDjangoPassword(plainPassword, djangoHash string) bool {
	// If it's a bcrypt hash (used by Go createsuperuser), verify with bcrypt
	if strings.HasPrefix(djangoHash, "$2a$") || strings.HasPrefix(djangoHash, "$2b$") {
		err := bcrypt.CompareHashAndPassword([]byte(djangoHash), []byte(plainPassword))
		return err == nil
	}

	parts := strings.Split(djangoHash, "$")
	if len(parts) != 4 || parts[0] != "pbkdf2_sha256" {
		return false // Not a standard Django pbkdf2_sha256 hash or bcrypt
	}

	iterations, err := strconv.Atoi(parts[1])
	if err != nil {
		return false
	}

	salt := parts[2]
	encodedHash := parts[3]

	decodedHash, err := base64.StdEncoding.DecodeString(encodedHash)
	if err != nil {
		return false
	}

	// Django uses SHA256, 32 bytes for the derived key length
	computedHash := pbkdf2.Key([]byte(plainPassword), []byte(salt), iterations, 32, sha256.New)

	// Constant time compare to prevent timing attacks
	return subtle.ConstantTimeCompare(decodedHash, computedHash) == 1
}

// GenerateDjangoPassword creates a new Django-compatible password hash
func GenerateDjangoPassword(plainPassword string) (string, error) {
	iterations := 260000 // Django standard iterations (varies by version, 260000 is common for Django 3.2+)

	// Generate random 12-character salt (base64 encoded random bytes or random string)
	saltBytes := make([]byte, 12)
	_, err := rand.Read(saltBytes)
	if err != nil {
		return "", err
	}
	salt := base64.RawStdEncoding.EncodeToString(saltBytes)[:12]

	computedHash := pbkdf2.Key([]byte(plainPassword), []byte(salt), iterations, 32, sha256.New)
	encodedHash := base64.StdEncoding.EncodeToString(computedHash)

	return fmt.Sprintf("pbkdf2_sha256$%d$%s$%s", iterations, salt, encodedHash), nil
}

// GenerateJWT creates a JWT token matching Django Ninja-JWT output structure.
// Usually ninja-jwt returns access and refresh tokens.
func GenerateJWT(user *models.User, cfg *config.Config) (string, string, error) {
	// Access Token
	accessClaims := jwt.MapClaims{
		"token_type": "access",
		"user_id":    user.ID,
		"username":   user.Username,
		"exp":        time.Now().Add(time.Hour * 24).Unix(), // 1 day
		"iat":        time.Now().Unix(),
		"jti":        generateJTI(),
	}
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessString, err := accessToken.SignedString([]byte(cfg.JWTSecret))
	if err != nil {
		return "", "", err
	}

	// Refresh Token
	refreshClaims := jwt.MapClaims{
		"token_type": "refresh",
		"user_id":    user.ID,
		"exp":        time.Now().Add(time.Hour * 24 * 7).Unix(), // 7 days
		"iat":        time.Now().Unix(),
		"jti":        generateJTI(),
	}
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshString, err := refreshToken.SignedString([]byte(cfg.JWTSecret))
	if err != nil {
		return "", "", err
	}

	return accessString, refreshString, nil
}

func generateJTI() string {
	b := make([]byte, 16)
	rand.Read(b)
	return fmt.Sprintf("%x", b)
}
