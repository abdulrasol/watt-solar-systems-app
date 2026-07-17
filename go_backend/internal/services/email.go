package services

import (
	"encoding/base64"
	"fmt"
	"log"
	"net/smtp"

	"watt/internal/config"
)

// EmailService handles sending emails via SMTP.
type EmailService struct {
	cfg *config.Config
}

// NewEmailService creates a new EmailService.
func NewEmailService(cfg *config.Config) *EmailService {
	return &EmailService{cfg: cfg}
}

// IsConfigured returns true if the required SMTP credentials are set.
func (s *EmailService) IsConfigured() bool {
	return s.cfg.EmailHostUser != "" && s.cfg.EmailHostPassword != ""
}

// SendPasswordResetEmail sends the password reset email with token and link.
func (s *EmailService) SendPasswordResetEmail(toEmail, token string) error {
	if !s.IsConfigured() {
		return fmt.Errorf("email service is not configured")
	}

	subject := "=?UTF-8?B?" + base64.StdEncoding.EncodeToString([]byte("إعادة تعيين كلمة المرور - Watt")) + "?="

	resetURL := fmt.Sprintf("%s/reset-password?token=%s&email=%s", s.cfg.FrontendURL, token, toEmail)

	body := fmt.Sprintf(`مرحبًا،

لقد تلقينا طلبًا لإعادة تعيين كلمة المرور لحسابك في Watt.

رمز إعادة التعيين: %s

أو يمكنك استخدام الرابط التالي:
%s

الرمز صالح لمدة 1 ساعة.

إذا لم تطلب إعادة تعيين كلمة المرور، يمكنك تجاهل هذا البريد.

فريق Watt
`, token, resetURL)

	msg := []byte("To: " + toEmail + "\r\n" +
		"From: " + s.cfg.EmailHostUser + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/plain; charset=\"UTF-8\"\r\n" +
		"\r\n" +
		body + "\r\n")

	// Gmail app passwords may contain spaces; net/smtp works fine with them.
	auth := smtp.PlainAuth("", s.cfg.EmailHostUser, s.cfg.EmailHostPassword, "smtp.gmail.com")

	err := smtp.SendMail("smtp.gmail.com:587", auth, s.cfg.EmailHostUser, []string{toEmail}, msg)
	if err != nil {
		log.Printf("Failed to send password reset email to %s: %v", toEmail, err)
		return err
	}

	log.Printf("Password reset email sent to %s", toEmail)
	return nil
}
