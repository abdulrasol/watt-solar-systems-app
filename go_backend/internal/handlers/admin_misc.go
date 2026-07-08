package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
	"watt/internal/utils"
)

// --- Subscriptions ---

// GetSubscriptions godoc
// @Summary      Get all subscriptions
// @Description  Retrieves all subscription plans
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.SubscriptionPlanOut}
// @Router       /admin/subscriptions [get]
func (h *AdminHandler) GetSubscriptions(c *gin.Context) {
	var subs []models.SubscriptionPlan
	database.DB.Find(&subs)

	var result []models.SubscriptionPlanOut
	for _, sub := range subs {
		result = append(result, models.SubscriptionPlanOut{
			ID:           sub.ID,
			Name:         sub.Name,
			DurationDays: sub.DurationDays,
			Price:        sub.Price,
			Description:  sub.Description,
			IsActive:     sub.IsActive,
			CreatedAt:    sub.CreatedAt,
		})
	}
	c.JSON(http.StatusOK, map[string]interface{}{
		"items": result,
		"count": len(result),
	})
}

// CreateSubscription godoc
// @Summary      Create a subscription
// @Description  Creates a new subscription plan
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        subscription body models.SubscriptionPlanSchema true "Subscription data"
// @Success      200  {object}  response.APIResponse{body=models.SubscriptionPlanOut}
// @Router       /admin/subscriptions [post]
func (h *AdminHandler) CreateSubscription(c *gin.Context) {
	var req models.SubscriptionPlanSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	sub := models.SubscriptionPlan{
		Name:         req.Name,
		DurationDays: req.DurationDays,
		Price:        req.Price,
		Description:  req.Description,
		IsActive:     req.IsActive,
	}

	database.DB.Create(&sub)

	response.Success(c, http.StatusOK, "Subscription plan created successfully.", models.SubscriptionPlanOut{
		ID:           sub.ID,
		Name:         sub.Name,
		DurationDays: sub.DurationDays,
		Price:        sub.Price,
		Description:  sub.Description,
		IsActive:     sub.IsActive,
		CreatedAt:    sub.CreatedAt,
	})
}

// UpdateSubscription godoc
// @Summary      Update a subscription
// @Description  Updates an existing subscription plan by ID
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Subscription ID"
// @Param        subscription body models.SubscriptionPlanSchema true "Subscription update data"
// @Success      200  {object}  response.APIResponse{body=models.SubscriptionPlanOut}
// @Router       /admin/subscriptions/{id} [put]
func (h *AdminHandler) UpdateSubscription(c *gin.Context) {
	id := c.Param("id")
	var req models.SubscriptionPlanSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var sub models.SubscriptionPlan
	if err := database.DB.First(&sub, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Subscription not found.", nil)
		return
	}

	sub.Name = req.Name
	sub.DurationDays = req.DurationDays
	sub.Price = req.Price
	sub.Description = req.Description
	sub.IsActive = req.IsActive

	database.DB.Save(&sub)

	response.Success(c, http.StatusOK, "Subscription plan updated successfully.", models.SubscriptionPlanOut{
		ID:           sub.ID,
		Name:         sub.Name,
		DurationDays: sub.DurationDays,
		Price:        sub.Price,
		Description:  sub.Description,
		IsActive:     sub.IsActive,
		CreatedAt:    sub.CreatedAt,
	})
}

// DeleteSubscription godoc
// @Summary      Delete a subscription
// @Description  Deletes an existing subscription plan by ID
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Subscription ID"
// @Success      200  {object}  response.APIResponse
// @Router       /admin/subscriptions/{id} [delete]
func (h *AdminHandler) DeleteSubscription(c *gin.Context) {
	id := c.Param("id")
	var sub models.SubscriptionPlan
	if err := database.DB.First(&sub, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Subscription not found.", nil)
		return
	}

	database.DB.Delete(&sub)
	response.Success(c, http.StatusOK, "Subscription plan deleted successfully.", gin.H{})
}

// --- Categories ---

// GetCategories godoc
// @Summary      Get all categories
// @Description  Retrieves all global categories
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.GlobalCategoryOut}
// @Router       /admin/categories [get]
func (h *AdminHandler) GetCategories(c *gin.Context) {
	var cats []models.GlobalCategory
	database.DB.Find(&cats)

	var result []models.GlobalCategoryOut
	for _, cat := range cats {
		result = append(result, models.GlobalCategoryOut{
			ID:   cat.ID,
			Name: cat.Name,
			Icon: cat.Icon,
		})
	}
	c.JSON(http.StatusOK, map[string]interface{}{
		"items": result,
		"count": len(result),
	})
}

// CreateCategory godoc
// @Summary      Create a category
// @Description  Creates a new global category with optional icon
// @Tags         Admin API
// @Accept       multipart/form-data
// @Produce      json
// @Security     Bearer
// @Param        name formData string true "Category name"
// @Param        icon formData file false "Category icon"
// @Success      200  {object}  response.APIResponse{body=models.GlobalCategoryOut}
// @Router       /admin/categories [post]
func (h *AdminHandler) CreateCategory(c *gin.Context) {
	var req models.GlobalCategorySchema
	if err := c.ShouldBind(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	iconPath, err := utils.SaveUploadedFileOptional(c, "icon", "category_icons")
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to save icon", nil)
		return
	}

	cat := models.GlobalCategory{
		Name: req.Name,
		Icon: iconPath,
	}

	database.DB.Create(&cat)

	response.Success(c, http.StatusOK, "Global Category created successfully.", models.GlobalCategoryOut{
		ID:   cat.ID,
		Name: cat.Name,
		Icon: cat.Icon,
	})
}

// UpdateCategory godoc
// @Summary      Update a category
// @Description  Updates an existing global category by ID with optional icon
// @Tags         Admin API
// @Accept       multipart/form-data
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Category ID"
// @Param        name formData string false "Category name"
// @Param        icon formData file false "Category icon"
// @Success      200  {object}  response.APIResponse{body=models.GlobalCategoryOut}
// @Router       /admin/categories/{id} [put]
func (h *AdminHandler) UpdateCategory(c *gin.Context) {
	id := c.Param("id")
	var req models.GlobalCategorySchema
	if err := c.ShouldBind(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var cat models.GlobalCategory
	if err := database.DB.First(&cat, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Category not found.", nil)
		return
	}

	if req.Name != "" {
		cat.Name = req.Name
	}

	iconPath, err := utils.SaveUploadedFileOptional(c, "icon", "category_icons")
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "Failed to save icon", nil)
		return
	}
	if iconPath != nil {
		cat.Icon = iconPath
	}

	database.DB.Save(&cat)

	response.Success(c, http.StatusOK, "Global Category updated successfully.", models.GlobalCategoryOut{
		ID:   cat.ID,
		Name: cat.Name,
		Icon: cat.Icon,
	})
}

// DeleteCategory godoc
// @Summary      Delete a category
// @Description  Deletes an existing global category by ID
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Param        id path string true "Category ID"
// @Success      200  {object}  response.APIResponse
// @Router       /admin/categories/{id} [delete]
func (h *AdminHandler) DeleteCategory(c *gin.Context) {
	id := c.Param("id")
	var cat models.GlobalCategory
	if err := database.DB.First(&cat, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Category not found.", nil)
		return
	}

	database.DB.Delete(&cat)
	response.Success(c, http.StatusOK, "Global Category deleted successfully.", gin.H{})
}

// --- Notifications ---

// GetNotifications godoc
// @Summary      Get all notifications
// @Description  Retrieves all notifications (Admin view)
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.NotificationOut}
// @Router       /admin/notifications [get]
func (h *AdminHandler) GetNotifications(c *gin.Context) {
	var notifs []models.Notification
	database.DB.Order("created_at desc").Find(&notifs)

	var result []models.NotificationOut
	for _, n := range notifs {
		result = append(result, models.NotificationOut{
			ID:                n.ID,
			UserID:            n.UserID,
			Title:             n.Title,
			Body:              n.Body,
			NotificationType:  n.NotificationType,
			IsRead:            n.IsRead,
			RelatedEntityType: n.RelatedEntityType,
			RelatedEntityID:   n.RelatedEntityID,
			CreatedAt:         n.CreatedAt,
		})
	}
	response.Success(c, http.StatusOK, "Success", result)
}

// --- Feedbacks ---

// GetFeedbacks godoc
// @Summary      Get all feedbacks
// @Description  Retrieves all feedbacks
// @Tags         Admin API
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  response.APIResponse{body=[]models.FeedbackSchema}
// @Router       /admin/feedbacks [get]
func (h *AdminHandler) GetFeedbacks(c *gin.Context) {
	var feedbacks []models.Feedback
	database.DB.Find(&feedbacks)

	var result []models.FeedbackSchema
	for _, f := range feedbacks {
		result = append(result, models.FeedbackSchema{
			ID:          f.ID,
			Name:        f.Name,
			PhoneNumber: f.PhoneNumber,
			Message:     f.Message,
			Image:       f.Image,
			IsRead:      f.IsRead,
			CreatedAt:   f.CreatedAt,
		})
	}
	response.Success(c, http.StatusOK, "Success", result)
}

// CreateFeedback godoc
// @Summary      Create a feedback
// @Description  Creates a new feedback message
// @Tags         Admin API
// @Accept       multipart/form-data
// @Produce      json
// @Param        name formData string true "Name"
// @Param        phone_number formData int false "Phone Number"
// @Param        message formData string true "Message"
// @Param        image formData file false "Image file"
// @Success      200  {object}  response.APIResponse{body=models.FeedbackSchema}
// @Router       /api/admin/feedbacks [post]
func (h *AdminHandler) CreateFeedback(c *gin.Context) {
	var req struct {
		Name        string `form:"name" binding:"required"`
		PhoneNumber *int   `form:"phone_number"`
		Message     string `form:"message" binding:"required"`
	}

	if err := c.ShouldBind(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	fb := models.Feedback{
		Name:        req.Name,
		PhoneNumber: req.PhoneNumber,
		Message:     req.Message,
	}

	// Handle Image Upload (Placeholder for file handling if needed)
	file, err := c.FormFile("image")
	if err == nil {
		// Example: save file logic here
		// c.SaveUploadedFile(file, "uploads/" + file.Filename)
		imagePath := "/uploads/" + file.Filename
		fb.Image = &imagePath
	}

	database.DB.Create(&fb)

	response.Success(c, http.StatusOK, "Feedback created successfully.", models.FeedbackSchema{
		ID:          fb.ID,
		Name:        fb.Name,
		PhoneNumber: fb.PhoneNumber,
		Message:     fb.Message,
		Image:       fb.Image,
		IsRead:      fb.IsRead,
		CreatedAt:   fb.CreatedAt,
	})
}

// UpdateFeedback godoc
// @Summary      Update a feedback
// @Description  Updates an existing feedback (e.g. mark as read)
// @Tags         Admin API
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Feedback ID"
// @Param        feedback body models.FeedbackUpdateFormSchema true "Feedback update data"
// @Success      200  {object}  response.APIResponse{body=models.FeedbackSchema}
// @Router       /api/admin/feedback/s{id} [put]
func (h *AdminHandler) UpdateFeedback(c *gin.Context) {
	id := c.Param("id")
	var req models.FeedbackUpdateFormSchema
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, err.Error(), nil)
		return
	}

	var fb models.Feedback
	if err := database.DB.First(&fb, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Feedback not found.", nil)
		return
	}

	if req.IsRead != nil {
		fb.IsRead = *req.IsRead
	}
	database.DB.Save(&fb)

	response.Success(c, http.StatusOK, "Feedback updated successfully.", models.FeedbackSchema{
		ID:          fb.ID,
		Name:        fb.Name,
		PhoneNumber: fb.PhoneNumber,
		Message:     fb.Message,
		Image:       fb.Image,
		IsRead:      fb.IsRead,
		CreatedAt:   fb.CreatedAt,
	})
}

// DeleteFeedback godoc
// @Summary      Delete a feedback
// @Description  Deletes an existing feedback by ID
// @Tags         Admin API
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "Feedback ID"
// @Success      200  {object}  response.APIResponse
// @Router       /api/admin/feedback/{id} [delete]
func (h *AdminHandler) DeleteFeedback(c *gin.Context) {
	id := c.Param("id")
	var fb models.Feedback
	if err := database.DB.First(&fb, id).Error; err != nil {
		response.Error(c, http.StatusNotFound, "Feedback not found.", nil)
		return
	}

	database.DB.Delete(&fb)
	response.Success(c, http.StatusOK, "Feedback deleted successfully.", gin.H{})
}
