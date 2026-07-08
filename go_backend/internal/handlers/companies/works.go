package companies

import (
	"fmt"
	"math"
	"net/http"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/response"
)

func getCompanyFromContext(c *gin.Context) (*models.CompanyMember, bool) {
	memberInterface, exists := c.Get("company_member")
	if !exists {
		return nil, false
	}
	return memberInterface.(*models.CompanyMember), true
}

// GetCompanyWorks handles GET /api/company/{company_id}/works
// @Security Bearer
// @Summary GetCompanyWorks
// @Description GetCompanyWorks
// @Tags Companies Works
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/works [get]
func GetCompanyWorks(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	pageStr := c.DefaultQuery("page", "1")
	pageSizeStr := c.DefaultQuery("page_size", "12")
	page, _ := strconv.Atoi(pageStr)
	pageSize, _ := strconv.Atoi(pageSizeStr)

	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 12
	} else if pageSize > 100 {
		pageSize = 100
	}

	var totalItems int64
	database.DB.Model(&models.CompanyWork{}).Where("company_id = ?", member.CompanyID).Count(&totalItems)

	totalPages := int(math.Ceil(float64(totalItems) / float64(pageSize)))
	offset := (page - 1) * pageSize

	var works []models.CompanyWork
	database.DB.Where("company_id = ?", member.CompanyID).
		Preload("Images").
		Order("created_at desc").
		Offset(offset).
		Limit(pageSize).
		Find(&works)

	var items []map[string]interface{}
	for _, w := range works {
		var images []map[string]interface{}
		for _, img := range w.Images {
			images = append(images, map[string]interface{}{
				"id":         img.ID,
				"image_url":  img.Image,
				"created_at": img.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			})
		}

		items = append(items, map[string]interface{}{
			"id":         w.ID,
			"title":      w.Title,
			"body":       w.Body,
			"created_at": w.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"updated_at": w.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
			"images":     images,
		})
	}

	pagination := map[string]interface{}{
		"page":         page,
		"page_size":    pageSize,
		"total_items":  totalItems,
		"total_pages":  totalPages,
		"has_next":     page < totalPages,
		"has_previous": page > 1,
	}

	payload := map[string]interface{}{
		"items":      items,
		"pagination": pagination,
	}

	response.Success(c, http.StatusOK, "Company works retrieved successfully.", payload)
}

// CreateCompanyWork handles POST /api/company/{company_id}/works
// @Accept multipart/form-data
// @Produce json
// @Param title formData string false "Title"
// @Param body formData string false "Body"
// @Param images formData file false "Images (multiple allowed)"
// @Security Bearer
// @Summary CreateCompanyWork
// @Description CreateCompanyWork
// @Tags Companies Works
// @Param company_id path int true "company_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/works [post]
func CreateCompanyWork(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	title := c.PostForm("title")
	body := c.PostForm("body")

	var titlePtr, bodyPtr *string
	if title != "" {
		titlePtr = &title
	}
	if body != "" {
		bodyPtr = &body
	}

	work := models.CompanyWork{
		CompanyID: member.CompanyID,
		Title:     titlePtr,
		Body:      bodyPtr,
	}

	tx := database.DB.Begin()
	if err := tx.Create(&work).Error; err != nil {
		tx.Rollback()
		msgUser := "حدث خطأ أثناء إضافة العمل"
		response.Error(c, http.StatusInternalServerError, "Failed to create work", &msgUser)
		return
	}

	form, _ := c.MultipartForm()
	var imagesList []map[string]interface{}
	if form != nil {
		files := form.File["images"]
		for _, file := range files {
			filename := fmt.Sprintf("%s%s", uuid.New().String(), filepath.Ext(file.Filename))
			savePath := filepath.Join("uploads", "company_works", filename)
			if err := c.SaveUploadedFile(file, savePath); err == nil {
				imgObj := models.CompanyWorkImage{
					WorkID: work.ID,
					Image:  "/" + savePath,
				}
				tx.Create(&imgObj)
				imagesList = append(imagesList, map[string]interface{}{
					"id":         imgObj.ID,
					"image_url":  imgObj.Image,
					"created_at": time.Now().Format("2006-01-02T15:04:05Z07:00"), // close enough for response
				})
			}
		}
	}
	tx.Commit()

	payload := map[string]interface{}{
		"id":         work.ID,
		"title":      work.Title,
		"body":       work.Body,
		"created_at": work.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at": work.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"images":     imagesList,
	}
	if imagesList == nil {
		payload["images"] = []interface{}{}
	}

	response.Success(c, http.StatusOK, "Work created successfully.", payload)
}

// UpdateCompanyWork handles PUT /api/company/{company_id}/works/{work_id}
// @Accept json
// @Produce json
// @Param request body models.CompanyWorkUpdateSchema true "Work details"
// @Security Bearer
// @Summary UpdateCompanyWork
// @Description UpdateCompanyWork
// @Tags Companies Works
// @Param company_id path int true "company_id"
// @Param work_id path int true "work_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/works/{work_id} [put]
func UpdateCompanyWork(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	workIDStr := c.Param("work_id")
	workID, err := strconv.Atoi(workIDStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Work ID", nil)
		return
	}

	var work models.CompanyWork
	if err := database.DB.Preload("Images").Where("id = ? AND company_id = ?", workID, member.CompanyID).First(&work).Error; err != nil {
		msgUser := "العمل غير موجود"
		response.Error(c, http.StatusNotFound, "Work not found", &msgUser)
		return
	}

	title := c.PostForm("title")
	body := c.PostForm("body")

	if title != "" {
		work.Title = &title
	}
	if body != "" {
		work.Body = &body
	}

	tx := database.DB.Begin()
	if err := tx.Save(&work).Error; err != nil {
		tx.Rollback()
		msgUser := "حدث خطأ أثناء تعديل العمل"
		response.Error(c, http.StatusInternalServerError, "Failed to update work", &msgUser)
		return
	}

	form, _ := c.MultipartForm()
	if form != nil {
		files := form.File["images"]
		for _, file := range files {
			filename := fmt.Sprintf("%s%s", uuid.New().String(), filepath.Ext(file.Filename))
			savePath := filepath.Join("uploads", "company_works", filename)
			if err := c.SaveUploadedFile(file, savePath); err == nil {
				imgObj := models.CompanyWorkImage{
					WorkID: work.ID,
					Image:  "/" + savePath,
				}
				tx.Create(&imgObj)
				work.Images = append(work.Images, imgObj)
			}
		}
	}
	tx.Commit()

	var imagesList []map[string]interface{}
	for _, img := range work.Images {
		imagesList = append(imagesList, map[string]interface{}{
			"id":         img.ID,
			"image_url":  img.Image,
			"created_at": img.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	if imagesList == nil {
		imagesList = []map[string]interface{}{}
	}

	payload := map[string]interface{}{
		"id":         work.ID,
		"title":      work.Title,
		"body":       work.Body,
		"created_at": work.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at": work.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"images":     imagesList,
	}

	response.Success(c, http.StatusOK, "Work updated successfully.", payload)
}

// DeleteCompanyWork handles DELETE /api/company/{company_id}/works/{work_id}
// @Security Bearer
// @Summary DeleteCompanyWork
// @Description DeleteCompanyWork
// @Tags Companies Works
// @Param company_id path int true "company_id"
// @Param work_id path int true "work_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/works/{work_id} [delete]
func DeleteCompanyWork(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	workIDStr := c.Param("work_id")
	workID, err := strconv.Atoi(workIDStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Work ID", nil)
		return
	}

	var work models.CompanyWork
	if err := database.DB.Where("id = ? AND company_id = ?", workID, member.CompanyID).First(&work).Error; err != nil {
		msgUser := "العمل غير موجود"
		response.Error(c, http.StatusNotFound, "Work not found", &msgUser)
		return
	}

	database.DB.Delete(&work)

	response.Success(c, http.StatusOK, "Work deleted successfully.", map[string]interface{}{})
}

// DeleteCompanyWorkImage handles DELETE /api/company/{company_id}/works/images/{image_id}
// @Security Bearer
// @Summary DeleteCompanyWorkImage
// @Description DeleteCompanyWorkImage
// @Tags Companies Works
// @Param company_id path int true "company_id"
// @Param image_id path int true "image_id"
// @Success 200 {object} response.APIResponse
// @Router /companies/{company_id}/works/images/{image_id} [delete]
func DeleteCompanyWorkImage(c *gin.Context) {
	member, ok := getCompanyFromContext(c)
	if !ok {
		msgUser := "خطأ في الصلاحيات"
		response.Error(c, http.StatusForbidden, "Forbidden", &msgUser)
		return
	}

	imageIDStr := c.Param("image_id")
	imageID, err := strconv.Atoi(imageIDStr)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid Image ID", nil)
		return
	}

	var img models.CompanyWorkImage
	if err := database.DB.Preload("Work").Where("id = ?", imageID).First(&img).Error; err != nil {
		msgUser := "الصورة غير موجودة"
		response.Error(c, http.StatusNotFound, "Image not found", &msgUser)
		return
	}

	if img.Work.CompanyID != member.CompanyID {
		msgUser := "الصورة غير موجودة"
		response.Error(c, http.StatusNotFound, "Image not found", &msgUser)
		return
	}

	database.DB.Delete(&img)

	response.Success(c, http.StatusOK, "Work image deleted successfully.", map[string]interface{}{})
}
