package community

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

func parsePagination(c *gin.Context) (page, pageSize int) {
	page, _ = strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ = strconv.Atoi(c.DefaultQuery("page_size", "10"))
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}
	return
}

func paginatedResponse(page, pageSize int, total int64, items interface{}) map[string]interface{} {
	totalPages := (int(total) + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}
	return map[string]interface{}{
		"items": items,
		"total": total,
		"page":  page,
		"pages": totalPages,
		"pagination": map[string]interface{}{
			"page":         page,
			"page_size":    pageSize,
			"total_items":  total,
			"total_pages":  totalPages,
			"has_next":     page < totalPages,
			"has_previous": page > 1,
		},
	}
}

func currentUser(c *gin.Context) (*models.User, bool) {
	userID, ok := companies.GetUserIDFromContext(c)
	if !ok {
		return nil, false
	}
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return nil, false
	}
	return &user, true
}

func isSuperuser(c *gin.Context) bool {
	v, exists := c.Get("is_superuser")
	if !exists {
		return false
	}
	b, ok := v.(bool)
	return ok && b
}

func serializeAuthor(user *models.User, company *models.Company, memberRole *string, baseURL string) models.CommunityAuthorInfo {
	if company != nil {
		info := models.CommunityAuthorInfo{
			ID:    strconv.Itoa(int(company.ID)),
			Name:  company.Name,
			Type:  "company",
			Image: utils.ResolveMediaPtr(baseURL, company.Logo),
			Phone: &company.Phone,
			Role:  memberRole,
		}
		if memberRole != nil {
			info.Role = memberRole
		}
		return info
	}
	if user != nil {
		return models.CommunityAuthorInfo{
			ID:    strconv.Itoa(int(user.ID)),
			Name:  user.Username,
			Type:  "user",
			Image: utils.ResolveMediaPtr(baseURL, user.Image),
		}
	}
	return models.CommunityAuthorInfo{ID: "0", Name: "System", Type: "system"}
}

func serializePost(post *models.Post, baseURL string) map[string]interface{} {
	var role *string
	var authorUser *models.User
	var authorCompany *models.Company
	if post.Author != nil {
		authorUser = post.Author
	}
	if post.Company != nil {
		authorCompany = post.Company
		if authorUser != nil {
			var member models.CompanyMember
			if err := database.DB.Where("company_id = ? AND user_id = ?", post.Company.ID, authorUser.ID).First(&member).Error; err == nil {
				role = &member.Role
			}
		}
	}
	image := post.Image
	return map[string]interface{}{
		"id":          post.ID,
		"content":     post.Content,
		"image_url":   utils.ResolveMediaPtr(baseURL, image),
		"post_type":   post.PostType,
		"likes_count": post.LikesCount,
		"created_at":  post.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"author_info": serializeAuthor(authorUser, authorCompany, role, baseURL),
	}
}

func serializeComment(comment *models.Comment, baseURL string) map[string]interface{} {
	return map[string]interface{}{
		"id":          comment.ID,
		"post_id":     comment.PostID,
		"content":     comment.Content,
		"created_at":  comment.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"author_info": serializeAuthor(comment.Author, nil, nil, baseURL),
	}
}

func unauthorized(c *gin.Context) {
	response.Error(c, http.StatusForbidden, "Not authorized", nil)
}

func saveImage(c *gin.Context) (*string, error) {
	file, err := c.FormFile("image")
	if err != nil {
		return nil, nil
	}
	return utils.SaveUploadedFileWithName(c, file, "community/posts")
}
