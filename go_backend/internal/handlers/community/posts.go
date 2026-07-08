package community

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

// ListPosts handles GET /api/v1/community/posts/
func ListPosts(c *gin.Context) {
	page, pageSize := parsePagination(c)
	offset := (page - 1) * pageSize

	query := database.DB.Model(&models.Post{}).Preload("Author").Preload("Company").Order("created_at desc")
	if postType := c.Query("post_type"); postType != "" {
		query = query.Where("post_type = ?", postType)
	}
	if authorID := c.Query("author_id"); authorID != "" {
		query = query.Where("author_id = ?", authorID)
	}

	var total int64
	query.Count(&total)

	var posts []models.Post
	query.Limit(pageSize).Offset(offset).Find(&posts)

	items := make([]map[string]interface{}, 0, len(posts))
	for _, p := range posts {
		items = append(items, serializePost(&p))
	}

	response.Success(c, http.StatusOK, "Posts retrieved successfully.", paginatedResponse(page, pageSize, total, items))
}

// GetPost handles GET /api/v1/community/posts/:post_id
func GetPost(c *gin.Context) {
	postID, _ := strconv.Atoi(c.Param("post_id"))
	var post models.Post
	if err := database.DB.Preload("Author").Preload("Company").First(&post, postID).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Post not found", nil)
		return
	}

	response.Success(c, http.StatusOK, "Post retrieved successfully.", serializePost(&post))
}

// CreatePost handles POST /api/v1/community/posts/
func CreatePost(c *gin.Context) {
	user, ok := currentUser(c)
	if !ok {
		response.Error(c, http.StatusUnauthorized, "Unauthorized", nil)
		return
	}

	content := c.PostForm("content")
	postType := c.DefaultPostForm("post_type", "general")
	var companyID, systemID *uint
	if cid := c.PostForm("company_id"); cid != "" {
		id, _ := strconv.Atoi(cid)
		u := uint(id)
		companyID = &u
	}
	if sid := c.PostForm("system_id"); sid != "" {
		id, _ := strconv.Atoi(sid)
		u := uint(id)
		systemID = &u
	}

	if companyID != nil {
		var cObj models.Company
		if err := database.DB.First(&cObj, *companyID).Error; err != nil {
			response.Error(c, http.StatusNotFound, "Company not found", nil)
			return
		}
		if !isSuperuser(c) {
			var member models.CompanyMember
			if err := database.DB.Where("company_id = ? AND user_id = ?", *companyID, user.ID).First(&member).Error; err != nil {
				unauthorized(c)
				return
			}
		}
	}

	image, err := saveImage(c)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid image", nil)
		return
	}

	post := models.Post{
		AuthorID:  &user.ID,
		CompanyID: companyID,
		SystemID:  systemID,
		Content:   &content,
		Image:     image,
		PostType:  postType,
	}
	database.DB.Create(&post)
	database.DB.Preload("Author").Preload("Company").First(&post, post.ID)
	response.Success(c, http.StatusOK, "Post created successfully.", serializePost(&post))
}

// UpdatePost handles PUT /api/v1/community/posts/:post_id
func UpdatePost(c *gin.Context) {
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

	if post.AuthorID == nil || *post.AuthorID != user.ID {
		if !isSuperuser(c) {
			unauthorized(c)
			return
		}
	}

	var payload models.PostUpdateSchema
	if err := c.ShouldBindJSON(&payload); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid payload", nil)
		return
	}

	if payload.Content != nil {
		post.Content = payload.Content
	}
	if payload.PostType != nil {
		post.PostType = *payload.PostType
	}
	database.DB.Save(&post)
	database.DB.Preload("Author").Preload("Company").First(&post, post.ID)
	response.Success(c, http.StatusOK, "Post updated successfully.", serializePost(&post))
}

// DeletePost handles DELETE /api/v1/community/posts/:post_id
func DeletePost(c *gin.Context) {
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

	if post.AuthorID == nil || *post.AuthorID != user.ID {
		if !isSuperuser(c) {
			unauthorized(c)
			return
		}
	}

	database.DB.Delete(&post)
	response.Success(c, http.StatusOK, "Post deleted successfully.", nil)
}
