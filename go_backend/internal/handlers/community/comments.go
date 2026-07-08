package community

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// ListComments handles GET /api/v1/community/posts/:post_id/comments
func ListComments(c *gin.Context) {
	postID, _ := strconv.Atoi(c.Param("post_id"))
	var post models.Post
	if err := database.DB.First(&post, postID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Post not found", nil)
		return
	}

	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	var total int64
	database.DB.Model(&models.Comment{}).Where("post_id = ?", postID).Count(&total)

	var comments []models.Comment
	database.DB.Preload("Author").Where("post_id = ?", postID).Order("created_at desc").Limit(pageSize).Offset(offset).Find(&comments)

	items := make([]map[string]interface{}, 0, len(comments))
	for _, comment := range comments {
		items = append(items, serializeComment(&comment))
	}

	response.Success(c, http.StatusOK, "Comments retrieved successfully.", paginatedResponse(page, pageSize, total, items))
}

// CreateComment handles POST /api/v1/community/posts/:post_id/comments
func CreateComment(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	postID, _ := strconv.Atoi(c.Param("post_id"))
	var post models.Post
	if err := database.DB.First(&post, postID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Post not found", nil)
		return
	}

	var payload models.CommentCreateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	comment := models.Comment{
		PostID:   post.ID,
		AuthorID: user.ID,
		Content:  payload.Content,
	}
	database.DB.Create(&comment)
	database.DB.Preload("Author").First(&comment, comment.ID)
	response.Success(c, http.StatusOK, "Comment added.", serializeComment(&comment))
}

// UpdateComment handles PUT /api/v1/community/comments/:comment_id
func UpdateComment(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	commentID, _ := strconv.Atoi(c.Param("comment_id"))
	var comment models.Comment
	if err := database.DB.First(&comment, commentID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Comment not found", nil)
		return
	}

	if comment.AuthorID != user.ID && !isSuperuser(c) {
		unauthorized(c)
		return
	}

	var payload models.CommentUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	comment.Content = payload.Content
	database.DB.Save(&comment)
	database.DB.Preload("Author").First(&comment, comment.ID)
	response.Success(c, http.StatusOK, "Comment updated.", serializeComment(&comment))
}

// DeleteComment handles DELETE /api/v1/community/comments/:comment_id
func DeleteComment(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	commentID, _ := strconv.Atoi(c.Param("comment_id"))
	var comment models.Comment
	if err := database.DB.First(&comment, commentID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Comment not found", nil)
		return
	}

	if comment.AuthorID != user.ID && !isSuperuser(c) {
		unauthorized(c)
		return
	}

	database.DB.Delete(&comment)
	response.Success(c, http.StatusOK, "Comment deleted.", nil)
}
