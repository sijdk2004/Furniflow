package handlers

import (
	"fmt"
	"strings"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"path/filepath"
)

type UploadHandler struct{}

func NewUploadHandler() *UploadHandler {
	return &UploadHandler{}
}

// UploadImage godoc
// @Summary Upload Image
// @Description Upload an image and get URL
// @Tags Uploads
// @Accept multipart/form-data
// @Produce json
// @Param file formData file true "Image File"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/upload/image [post]
func (h *UploadHandler) UploadImage(c *fiber.Ctx) error {
	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Failed to get file"})
	}

	if file.Size > 5*1024*1024 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "File size exceeds 5MB limit"})
	}

	contentType := file.Header.Get("Content-Type")
	if contentType != "image/jpeg" && contentType != "image/png" && contentType != "image/webp" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid file type. Only JPEG, PNG, and WebP are allowed"})
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".webp" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid file extension. Only jpg, jpeg, png, and webp are allowed"})
	}

	filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
	savePath := fmt.Sprintf("./uploads/%s", filename)

	if err := c.SaveFile(file, savePath); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"success": false, "error": "Failed to save file"})
	}

	// For POC, assuming the backend runs on localhost:3000
	url := fmt.Sprintf("http://localhost:3000/uploads/%s", filename)
	return c.JSON(fiber.Map{"success": true, "url": url})
}
