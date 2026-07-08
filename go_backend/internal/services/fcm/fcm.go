package fcm

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/models"
)

var (
	app        *firebase.App
	client     *messaging.Client
	configured bool
)

// Initialize sets up the Firebase Admin SDK for FCM.
// It logs a warning and returns nil if credentials are missing, so the server can still start.
func Initialize(cfg *config.Config) error {
	projectID := strings.TrimSpace(cfg.FCMProjectID)
	serviceAccountFile := strings.TrimSpace(cfg.FCMServiceAccountFile)
	if serviceAccountFile == "" {
		serviceAccountFile = strings.TrimSpace(os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"))
	}

	if projectID == "" || serviceAccountFile == "" {
		log.Println("⚠️ FCM not configured; push notifications will be disabled. Set FCM_PROJECT_ID and FCM_SERVICE_ACCOUNT_FILE.")
		return nil
	}

	if _, err := os.Stat(serviceAccountFile); err != nil {
		log.Printf("⚠️ FCM service account file not found (%s): %v; push notifications disabled.", serviceAccountFile, err)
		return nil
	}

	ctx := context.Background()
	opts := []option.ClientOption{option.WithCredentialsFile(serviceAccountFile)}
	var err error
	app, err = firebase.NewApp(ctx, &firebase.Config{ProjectID: projectID}, opts...)
	if err != nil {
		return fmt.Errorf("failed to initialize firebase app: %w", err)
	}

	client, err = app.Messaging(ctx)
	if err != nil {
		return fmt.Errorf("failed to initialize firebase messaging client: %w", err)
	}

	configured = true
	log.Println("✅ FCM initialized successfully")
	return nil
}

// IsConfigured reports whether FCM is ready to send notifications.
func IsConfigured() bool {
	return configured
}

// SendMulticast sends a notification to up to 500 tokens per batch.
// It returns the number of successful and failed deliveries and deactivates invalid tokens.
func SendMulticast(tokens []string, title, body string, data map[string]interface{}) (successCount, failureCount int, err error) {
	if !configured {
		return 0, 0, fmt.Errorf("FCM not configured")
	}

	ctx := context.Background()
	uniqueTokens := uniqueStrings(tokens)
	if len(uniqueTokens) == 0 {
		return 0, 0, nil
	}

	const batchSize = 500
	stringData := stringifyData(data)

	for i := 0; i < len(uniqueTokens); i += batchSize {
		end := i + batchSize
		if end > len(uniqueTokens) {
			end = len(uniqueTokens)
		}
		batch := uniqueTokens[i:end]

		msg := &messaging.MulticastMessage{
			Tokens:       batch,
			Notification: &messaging.Notification{Title: title, Body: body},
			Data:         stringData,
		}

		resp, sendErr := client.SendMulticast(ctx, msg)
		if sendErr != nil {
			return successCount, failureCount, fmt.Errorf("fcm multicast send failed: %w", sendErr)
		}

		for idx, r := range resp.Responses {
			if r.Success {
				successCount++
			} else {
				failureCount++
				deactivateIfInvalid(batch[idx], r.Error)
			}
		}
	}

	return successCount, failureCount, nil
}

// SendTopic sends a notification to an FCM topic.
func SendTopic(topic, title, body string, data map[string]interface{}) (string, error) {
	if !configured {
		return "", fmt.Errorf("FCM not configured")
	}

	ctx := context.Background()
	msg := &messaging.Message{
		Notification: &messaging.Notification{Title: title, Body: body},
		Data:         stringifyData(data),
		Topic:        topic,
	}

	return client.Send(ctx, msg)
}

func stringifyData(data map[string]interface{}) map[string]string {
	if len(data) == 0 {
		return nil
	}
	out := make(map[string]string, len(data))
	for k, v := range data {
		switch s := v.(type) {
		case string:
			out[k] = s
		case nil:
			out[k] = ""
		default:
			if b, err := json.Marshal(v); err == nil {
				out[k] = string(b)
			} else {
				out[k] = fmt.Sprintf("%v", v)
			}
		}
	}
	return out
}

func uniqueStrings(input []string) []string {
	seen := make(map[string]struct{}, len(input))
	out := make([]string, 0, len(input))
	for _, s := range input {
		s := strings.TrimSpace(s)
		if s == "" {
			continue
		}
		if _, ok := seen[s]; ok {
			continue
		}
		seen[s] = struct{}{}
		out = append(out, s)
	}
	return out
}

func deactivateIfInvalid(token string, err error) {
	if err == nil || token == "" {
		return
	}
	msg := strings.ToLower(err.Error())
	if strings.Contains(msg, "registration-token-not-registered") ||
		strings.Contains(msg, "invalid-registration-token") ||
		strings.Contains(msg, "sender-id-mismatch") ||
		strings.Contains(msg, "mismatched-credential") {
		if err := database.DB.Model(&models.PushDevice{}).
			Where("registration_id = ?", token).
			Update("is_active", false).Error; err != nil {
			log.Printf("⚠️ Failed to deactivate invalid FCM token: %v", err)
		}
	}
}
