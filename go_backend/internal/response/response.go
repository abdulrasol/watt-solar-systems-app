package response

import (
	"github.com/gin-gonic/gin"
)

// APIResponse matches the exact structure required by the Flutter app
type APIResponse struct {
	Status      int         `json:"status"`
	Message     string      `json:"message"`
	Body        interface{} `json:"body"`
	Error       bool        `json:"error"`
	MessageUser *string     `json:"message_user"`
}

// Success sends a success response
func Success(c *gin.Context, status int, message string, body interface{}) {
	c.JSON(status, APIResponse{
		Status:      status,
		Message:     message,
		Body:        body,
		Error:       false,
		MessageUser: nil,
	})
}

// Error sends an error response
func Error(c *gin.Context, status int, message string, messageUser *string) {
	c.JSON(status, APIResponse{
		Status:      status,
		Message:     message,
		Body:        nil, // Body should typically be null or empty object for errors, depending on Django's exact behavior
		Error:       true,
		MessageUser: messageUser,
	})
}
