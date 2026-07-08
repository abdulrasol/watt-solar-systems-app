package utils

import (
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// SaveUploadedFile saves a multipart file to the uploads directory and returns the public path.
// baseDir is the sub-directory under uploads (e.g. "company_logos", "user_images").
func SaveUploadedFile(c *gin.Context, fieldName string, baseDir string) (*string, error) {
	file, err := c.FormFile(fieldName)
	if err != nil {
		return nil, err
	}

	dir := filepath.Join("uploads", baseDir)
	if err := os.MkdirAll(dir, os.ModePerm); err != nil {
		return nil, err
	}

	ext := filepath.Ext(file.Filename)
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
	dir := filepath.Join("uploads", baseDir)
	if err := os.MkdirAll(dir, os.ModePerm); err != nil {
		return nil, err
	}

	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	savePath := filepath.Join(dir, filename)

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		return nil, err
	}

	publicPath := "/" + savePath
	return &publicPath, nil
}
