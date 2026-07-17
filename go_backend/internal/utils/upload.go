package utils

import (
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const maxUploadSize = 5 * 1024 * 1024 // 5 MB

var allowedImageExts = map[string]bool{
	".jpg":  true,
	".jpeg": true,
	".png":  true,
	".gif":  true,
	".webp": true,
}

var allowedImageTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/gif":  true,
	"image/webp": true,
}

func validateUpload(file *multipart.FileHeader) error {
	if file.Size > maxUploadSize {
		return fmt.Errorf("file too large: maximum allowed size is %d MB", maxUploadSize/(1024*1024))
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if !allowedImageExts[ext] {
		return fmt.Errorf("file extension not allowed: %s", ext)
	}

	opened, err := file.Open()
	if err != nil {
		return fmt.Errorf("failed to open uploaded file")
	}
	defer opened.Close()

	buffer := make([]byte, 512)
	n, err := opened.Read(buffer)
	if err != nil && err != io.EOF {
		return fmt.Errorf("failed to read uploaded file")
	}
	contentType := http.DetectContentType(buffer[:n])
	if !allowedImageTypes[contentType] {
		return fmt.Errorf("file type not allowed: %s", contentType)
	}

	return nil
}

// SaveUploadedFile saves a multipart file to the uploads directory and returns the public path.
// baseDir is the sub-directory under uploads (e.g. "company_logos", "user_images").
func SaveUploadedFile(c *gin.Context, fieldName string, baseDir string) (*string, error) {
	file, err := c.FormFile(fieldName)
	if err != nil {
		return nil, err
	}

	if err := validateUpload(file); err != nil {
		return nil, err
	}

	dir := filepath.Join("uploads", baseDir)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, err
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	savePath := filepath.Join(dir, filename)

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		return nil, err
	}

	publicPath := "/" + savePath
	return &publicPath, nil
}

// SaveUploadedFileOptional is like SaveUploadedFile but returns nil without error when the field is missing.
func SaveUploadedFileOptional(c *gin.Context, fieldName string, baseDir string) (*string, error) {
	if _, err := c.FormFile(fieldName); err != nil {
		return nil, nil
	}
	return SaveUploadedFile(c, fieldName, baseDir)
}

// SaveUploadedFileWithName saves a provided *multipart.FileHeader to the uploads directory and returns the public path.
func SaveUploadedFileWithName(c *gin.Context, file *multipart.FileHeader, baseDir string) (*string, error) {
	if err := validateUpload(file); err != nil {
		return nil, err
	}

	dir := filepath.Join("uploads", baseDir)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return nil, err
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	savePath := filepath.Join(dir, filename)

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		return nil, err
	}

	publicPath := "/" + savePath
	return &publicPath, nil
}
