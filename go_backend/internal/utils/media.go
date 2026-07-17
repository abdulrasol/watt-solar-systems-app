package utils

import (
	"strings"

	"github.com/gin-gonic/gin"
)

// ResolveMediaURL converts a stored relative media path (e.g. /uploads/...)
// into a full URL by prepending the configured base URL. If the path is already
// an absolute URL or empty, it is returned unchanged. This keeps database values
// portable (relative paths) while API consumers receive usable URLs.
func ResolveMediaURL(baseURL, path string) string {
	if path == "" {
		return ""
	}
	if strings.HasPrefix(path, "http://") || strings.HasPrefix(path, "https://") {
		return path
	}
	if !strings.HasPrefix(path, "/") {
		path = "/" + path
	}
	return baseURL + path
}

// ResolveMediaPtr is a convenience wrapper for nullable media paths.
func ResolveMediaPtr(baseURL string, path *string) *string {
	if path == nil {
		return nil
	}
	resolved := ResolveMediaURL(baseURL, *path)
	return &resolved
}

// ResolveMediaURLFromContext reads the base URL stored by baseURLMiddleware
// and resolves the given media path. Falls back to the raw path if no base URL
// is available.
func ResolveMediaURLFromContext(c *gin.Context, path string) string {
	baseURL := c.GetString("baseURL")
	return ResolveMediaURL(baseURL, path)
}

// mediaURLKeys are JSON keys whose string values should be converted to full URLs.
var mediaURLKeys = map[string]bool{
	"image":     true,
	"image_url": true,
	"logo":      true,
	"logo_url":  true,
}

// ResolveMediaURLsInMap recursively walks a map and resolves any string values
// whose key is a known media URL key. Useful for notification content that was
// serialized before BASE_URL was available.
func ResolveMediaURLsInMap(baseURL string, m map[string]interface{}) {
	if m == nil {
		return
	}
	for k, v := range m {
		switch val := v.(type) {
		case string:
			if mediaURLKeys[k] {
				m[k] = ResolveMediaURL(baseURL, val)
			}
		case map[string]interface{}:
			ResolveMediaURLsInMap(baseURL, val)
		case []interface{}:
			for _, item := range val {
				if subMap, ok := item.(map[string]interface{}); ok {
					ResolveMediaURLsInMap(baseURL, subMap)
				}
			}
		}
	}
}
