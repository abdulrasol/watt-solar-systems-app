package services

import (
	"encoding/base64"
	"fmt"
	"log"
	"net/smtp"
	"os"

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

// loadLogoBase64 reads the embedded logo and returns a base64 data URI.
func loadLogoBase64() string {
	data, err := os.ReadFile("internal/assets/logo.png")
	if err != nil {
		log.Printf("Warning: failed to load logo for email: %v", err)
		return ""
	}
	return "data:image/png;base64," + base64.StdEncoding.EncodeToString(data)
}

// SendPasswordResetEmail sends a professional HTML password reset email.
func (s *EmailService) SendPasswordResetEmail(toEmail, token string) error {
	if !s.IsConfigured() {
		return fmt.Errorf("email service is not configured")
	}

	logoURI := loadLogoBase64()
	resetURL := fmt.Sprintf("%s/reset-password?token=%s&email=%s", s.cfg.FrontendURL, token, toEmail)

	subject := "=?UTF-8?B?" + base64.StdEncoding.EncodeToString([]byte("إعادة تعيين كلمة المرور - Watt")) + "?="

	htmlBody := fmt.Sprintf(`<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>إعادة تعيين كلمة المرور</title>
  <style>
    body { margin: 0; padding: 0; background-color: #f4f6f8; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; direction: rtl; }
    .container { max-width: 600px; margin: 40px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
    .header { background: linear-gradient(135deg, #0ea5e9 0%%, #0284c7 100%%); padding: 40px 30px; text-align: center; }
    .header img { width: 100px; height: 100px; margin-bottom: 16px; }
    .header h1 { color: #ffffff; margin: 0; font-size: 26px; font-weight: 600; }
    .content { padding: 40px 30px; color: #334155; line-height: 1.8; }
    .content p { margin: 0 0 18px; font-size: 16px; }
    .btn { display: inline-block; background: #0ea5e9; color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-size: 16px; font-weight: 600; margin: 20px 0; }
    .code-box { background: #f1f5f9; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 16px; text-align: center; font-family: 'Courier New', monospace; font-size: 18px; letter-spacing: 2px; color: #0f172a; margin: 20px 0; }
    .footer { background: #f8fafc; padding: 24px 30px; text-align: center; color: #64748b; font-size: 13px; border-top: 1px solid #e2e8f0; }
    .footer a { color: #0ea5e9; text-decoration: none; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      %s
      <h1>إعادة تعيين كلمة المرور</h1>
    </div>
    <div class="content">
      <p>مرحبًا،</p>
      <p>لقد تلقينا طلبًا لإعادة تعيين كلمة المرور لحسابك في <strong>Watt</strong>. اضغط على الزر أدناه لإكمال العملية.</p>
      <div style="text-align: center;">
        <a href="%s" class="btn">إعادة تعيين كلمة المرور</a>
      </div>
      <p>إذا لم يعمل الزر، انسخ الرابط التالي والصقه في المتصفح:</p>
      <p style="word-break: break-all; font-size: 13px; color: #475569;">%s</p>
      <p>أو يمكنك استخدام رمز التعيين التالي:</p>
      <div class="code-box">%s</div>
      <p>الرمز صالح لمدة <strong>1 ساعة</strong>. إذا لم تطلب إعادة تعيين كلمة المرور، يمكنك تجاهل هذا البريد بأمان.</p>
    </div>
    <div class="footer">
      <p>© 2026 Watt. جميع الحقوق محفوظة.</p>
      <p>للدعم: <a href="mailto:%s">%s</a></p>
    </div>
  </div>
</body>
</html>`, logoTag(logoURI), resetURL, resetURL, token, s.cfg.EmailHostUser, s.cfg.EmailHostUser)

	plainBody := fmt.Sprintf(`مرحبًا،

لقد تلقينا طلبًا لإعادة تعيين كلمة المرور لحسابك في Watt.

رمز إعادة التعيين: %s

الرابط:
%s

الرمز صالح لمدة 1 ساعة.

إذا لم تطلب إعادة تعيين كلمة المرور، يمكنك تجاهل هذا البريد.

Watt
`, token, resetURL)

	boundary := "watt-reset-boundary-" + token[:16]

	msg := []byte("To: " + toEmail + "\r\n" +
		"From: " + s.cfg.EmailHostUser + "\r\n" +
		"Subject: " + subject + "\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: multipart/alternative; boundary=\"" + boundary + "\"\r\n" +
		"\r\n" +
		"--" + boundary + "\r\n" +
		"Content-Type: text/plain; charset=\"UTF-8\"\r\n" +
		"\r\n" +
		plainBody + "\r\n" +
		"--" + boundary + "\r\n" +
		"Content-Type: text/html; charset=\"UTF-8\"\r\n" +
		"\r\n" +
		htmlBody + "\r\n" +
		"--" + boundary + "--\r\n")

	auth := smtp.PlainAuth("", s.cfg.EmailHostUser, s.cfg.EmailHostPassword, "smtp.gmail.com")

	err := smtp.SendMail("smtp.gmail.com:587", auth, s.cfg.EmailHostUser, []string{toEmail}, msg)
	if err != nil {
		log.Printf("Failed to send password reset email to %s: %v", toEmail, err)
		return err
	}

	log.Printf("Password reset email sent to %s", toEmail)
	return nil
}

func logoTag(uri string) string {
	if uri == "" {
		return ""
	}
	return fmt.Sprintf(`<img src="%s" alt="Watt Logo">`, uri)
}
