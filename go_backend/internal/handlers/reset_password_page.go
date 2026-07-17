package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services"
)

// ResetPasswordTemplate is the HTML form used by the email password reset link.
const ResetPasswordTemplate = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>إعادة تعيين كلمة المرور - Watt</title>
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      background: #f5f7fa;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      direction: rtl;
    }
    .card {
      background: #fff;
      padding: 2rem;
      border-radius: 12px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      width: 100%;
      max-width: 400px;
    }
    h1 {
      margin: 0 0 1rem;
      font-size: 1.4rem;
      color: #1a202c;
      text-align: center;
    }
    label {
      display: block;
      margin-bottom: 0.5rem;
      color: #4a5568;
      font-size: 0.95rem;
    }
    input {
      width: 100%;
      padding: 0.75rem;
      margin-bottom: 1rem;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 1rem;
    }
    button {
      width: 100%;
      padding: 0.75rem;
      background: #3182ce;
      color: #fff;
      border: none;
      border-radius: 8px;
      font-size: 1rem;
      cursor: pointer;
    }
    button:hover { background: #2b6cb0; }
    .message {
      margin-top: 1rem;
      padding: 0.75rem;
      border-radius: 8px;
      text-align: center;
      font-size: 0.95rem;
    }
    .success { background: #c6f6d5; color: #22543d; }
    .error { background: #fed7d7; color: #742a2a; }
  </style>
</head>
<body>
  <div class="card">
    <h1>إعادة تعيين كلمة المرور</h1>
    <form method="POST" action="/reset-password">
      <input type="hidden" name="token" value="{{.Token}}">
      <input type="hidden" name="email" value="{{.Email}}">
      <label for="password">كلمة المرور الجديدة</label>
      <input type="password" id="password" name="password" required minlength="6">
      <button type="submit">حفظ كلمة المرور</button>
    </form>
    {{if .Success}}
      <div class="message success">{{.Success}}</div>
    {{end}}
    {{if .Error}}
      <div class="message error">{{.Error}}</div>
    {{end}}
  </div>
</body>
</html>`

// ResetPasswordPage handles the web-based password reset form linked from emails.
func (h *UserHandler) ResetPasswordPage(c *gin.Context) {
	token := c.Query("token")
	email := c.Query("email")

	if c.Request.Method == http.MethodPost {
		token = c.PostForm("token")
		email = c.PostForm("email")
		password := c.PostForm("password")

		var reset models.PasswordReset
		if err := database.DB.Where("token = ? AND email = ?", token, email).First(&reset).Error; err != nil || !reset.IsValid() {
			c.HTML(http.StatusOK, "reset-password", gin.H{
				"Token": token,
				"Email": email,
				"Error": "الرمز غير صالح أو منتهي الصلاحية. اطلب رابطًا جديدًا.",
			})
			return
		}

		hashedPassword, err := services.GenerateDjangoPassword(password)
		if err != nil {
			c.HTML(http.StatusOK, "reset-password", gin.H{
				"Token": token,
				"Email": email,
				"Error": "حدث خطأ أثناء معالجة كلمة المرور.",
			})
			return
		}

		if err := database.DB.Model(&models.User{}).
			Where("email = ? AND is_deleted = ?", reset.Email, false).
			Update("password", hashedPassword).Error; err != nil {
			c.HTML(http.StatusOK, "reset-password", gin.H{
				"Token": token,
				"Email": email,
				"Error": "حدث خطأ أثناء تحديث كلمة المرور.",
			})
			return
		}

		now := time.Now()
		reset.UsedAt = &now
		database.DB.Save(&reset)

		c.HTML(http.StatusOK, "reset-password", gin.H{
			"Token": token,
			"Email": email,
			"Success": "تم تغيير كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول من التطبيق.",
		})
		return
	}

	c.HTML(http.StatusOK, "reset-password", gin.H{
		"Token": token,
		"Email": email,
	})
}
