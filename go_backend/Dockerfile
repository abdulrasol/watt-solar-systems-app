# Stage 1: Build
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git ca-certificates

# Copy dependency files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binaries
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o server ./cmd/server && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o createadmin ./cmd/createadmin

# Stage 2: Runtime
FROM alpine:latest

# Install ca-certificates for HTTPS requests (FCM, etc.)
RUN apk add --no-cache ca-certificates

WORKDIR /app

# Create non-root user for security
RUN adduser -D -u 1000 wattuser && \
    mkdir -p uploads data && \
    chown -R wattuser:wattuser /app

# Copy binaries and static assets from builder
COPY --from=builder /app/server .
COPY --from=builder /app/createadmin .
COPY --from=builder /app/internal/admin/static ./internal/admin/static

# Ensure directories are writable by non-root user
RUN chown -R wattuser:wattuser /app/uploads /app/data

USER wattuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/health || exit 1

CMD ["./server"]
