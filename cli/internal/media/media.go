package media

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"net/http"
	"os"

	_ "golang.org/x/image/webp"
)

const (
	MaxFileSize  = 5 * 1024 * 1024 // 5MB
	MinDimension = 512             // 512px
)

// ImageInfo contains inspected metadata about a validated image file.
type ImageInfo struct {
	Path        string
	Width       int
	Height      int
	Size        int64
	ContentType string
	SHA256      string
}

// ValidateAndInspectImage inspects a local image file and verifies:
// 1. File size <= 5MB
// 2. Aspect ratio is strictly 1:1 (square)
// 3. Dimensions are at least 512x512px
func ValidateAndInspectImage(filePath string) (*ImageInfo, error) {
	stat, err := os.Stat(filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read image file: %w", err)
	}

	if stat.Size() > MaxFileSize {
		return nil, fmt.Errorf("file size (%d bytes / %.2f MB) exceeds maximum allowed size of 5MB", stat.Size(), float64(stat.Size())/(1024*1024))
	}

	file, err := os.Open(filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to open image file: %w", err)
	}
	defer file.Close()

	cfg, format, err := image.DecodeConfig(file)
	if err != nil {
		return nil, fmt.Errorf("invalid or unsupported image format (allowed: PNG, JPEG, WebP): %w", err)
	}

	if cfg.Width != cfg.Height {
		return nil, fmt.Errorf("image must be square (1:1 aspect ratio), got %dx%dpx", cfg.Width, cfg.Height)
	}

	if cfg.Width < MinDimension || cfg.Height < MinDimension {
		return nil, fmt.Errorf("image dimensions must be at least %dx%dpx, got %dx%dpx", MinDimension, MinDimension, cfg.Width, cfg.Height)
	}

	var contentType string
	switch format {
	case "jpeg":
		contentType = "image/jpeg"
	case "png":
		contentType = "image/png"
	case "webp":
		contentType = "image/webp"
	default:
		return nil, fmt.Errorf("unsupported image format '%s'. Allowed: PNG, JPEG, WebP", format)
	}

	// Compute SHA-256
	if _, err := file.Seek(0, io.SeekStart); err != nil {
		return nil, fmt.Errorf("failed to rewind file: %w", err)
	}

	hasher := sha256.New()
	if _, err := io.Copy(hasher, file); err != nil {
		return nil, fmt.Errorf("failed to calculate SHA-256: %w", err)
	}
	sha256Hex := hex.EncodeToString(hasher.Sum(nil))

	return &ImageInfo{
		Path:        filePath,
		Width:       cfg.Width,
		Height:      cfg.Height,
		Size:        stat.Size(),
		ContentType: contentType,
		SHA256:      sha256Hex,
	}, nil
}

// UploadToS3 uploads a local file to a pre-signed S3 PUT URL.
func UploadToS3(ctx context.Context, uploadURL string, filePath string, contentType string, headers map[string]string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file for upload: %w", err)
	}
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return fmt.Errorf("failed to stat file for upload: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPut, uploadURL, file)
	if err != nil {
		return fmt.Errorf("failed to create HTTP PUT request: %w", err)
	}

	req.ContentLength = stat.Size()
	req.Header.Set("Content-Type", contentType)

	for k, v := range headers {
		req.Header.Set(k, v)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("HTTP PUT upload to S3 failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("S3 upload returned HTTP %d: %s", resp.StatusCode, string(body))
	}

	return nil
}
