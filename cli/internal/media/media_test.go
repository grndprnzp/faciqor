package media_test

import (
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"testing"

	"faciqor/internal/media"
)

func createTestPNG(t *testing.T, dir string, filename string, width, height int) string {
	t.Helper()
	filePath := filepath.Join(dir, filename)
	img := image.NewRGBA(image.Rect(0, 0, width, height))
	for x := 0; x < width; x++ {
		for y := 0; y < height; y++ {
			img.Set(x, y, color.RGBA{R: 20, G: 30, B: 40, A: 255})
		}
	}

	f, err := os.Create(filePath)
	if err != nil {
		t.Fatalf("failed to create test image: %v", err)
	}
	defer f.Close()

	if err := png.Encode(f, img); err != nil {
		t.Fatalf("failed to encode PNG: %v", err)
	}

	return filePath
}

func TestValidateAndInspectImage(t *testing.T) {
	tempDir := t.TempDir()

	t.Run("accepts valid square 512x512 image", func(t *testing.T) {
		path := createTestPNG(t, tempDir, "valid_512.png", 512, 512)
		info, err := media.ValidateAndInspectImage(path)
		if err != nil {
			t.Fatalf("expected success, got error: %v", err)
		}
		if info.Width != 512 || info.Height != 512 {
			t.Errorf("expected 512x512, got %dx%d", info.Width, info.Height)
		}
		if info.ContentType != "image/png" {
			t.Errorf("expected image/png, got %s", info.ContentType)
		}
		if info.SHA256 == "" {
			t.Errorf("expected non-empty SHA256")
		}
	})

	t.Run("rejects non-square image", func(t *testing.T) {
		path := createTestPNG(t, tempDir, "non_square.png", 600, 400)
		_, err := media.ValidateAndInspectImage(path)
		if err == nil {
			t.Fatal("expected error for non-square image, got nil")
		}
	})

	t.Run("rejects square image smaller than 512px", func(t *testing.T) {
		path := createTestPNG(t, tempDir, "small.png", 256, 256)
		_, err := media.ValidateAndInspectImage(path)
		if err == nil {
			t.Fatal("expected error for image < 512px, got nil")
		}
	})

	t.Run("rejects non-existent file", func(t *testing.T) {
		_, err := media.ValidateAndInspectImage(filepath.Join(tempDir, "does_not_exist.png"))
		if err == nil {
			t.Fatal("expected error for non-existent file, got nil")
		}
	})
}
