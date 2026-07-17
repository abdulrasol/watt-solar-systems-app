package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
	"watt/internal/response"
)

// RateLimiter provides per-IP rate limiting using a token-bucket algorithm.
// It is safe for concurrent use.
type RateLimiter struct {
	limiters map[string]*rate.Limiter
	mu       sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter creates a limiter that allows `rps` requests per second
// with a burst of `burst`.
func NewRateLimiter(rps float64, burst int) *RateLimiter {
	return &RateLimiter{
		limiters: make(map[string]*rate.Limiter),
		rate:     rate.Limit(rps),
		burst:    burst,
	}
}

func (rl *RateLimiter) getLimiter(ip string) *rate.Limiter {
	rl.mu.RLock()
	l, ok := rl.limiters[ip]
	rl.mu.RUnlock()
	if ok {
		return l
	}

	rl.mu.Lock()
	defer rl.mu.Unlock()
	l, ok = rl.limiters[ip]
	if ok {
		return l
	}
	l = rate.NewLimiter(rl.rate, rl.burst)
	rl.limiters[ip] = l
	return l
}

// Middleware returns a gin middleware that rate-limits requests by client IP.
func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		if ip == "" {
			ip = "unknown"
		}
		if !rl.getLimiter(ip).Allow() {
			msgUser := "عدد الطلبات كبير جداً، يرجى المحاولة لاحقاً"
			response.Error(c, http.StatusTooManyRequests, "Rate limit exceeded", &msgUser)
			c.Abort()
			return
		}
		c.Next()
	}
}

// Cleanup periodically removes inactive limiters to prevent unbounded growth.
// For production with many unique IPs, switch to Redis-backed limiter.
func (rl *RateLimiter) Cleanup(interval time.Duration) {
	ticker := time.NewTicker(interval)
	go func() {
		for range ticker.C {
			rl.mu.Lock()
			// Simple cleanup: clear all limiters. In a real app, track last-seen time.
			// With a small burst window this is acceptable for moderate traffic.
			for k := range rl.limiters {
				delete(rl.limiters, k)
			}
			rl.mu.Unlock()
		}
	}()
}
