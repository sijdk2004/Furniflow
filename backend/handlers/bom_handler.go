package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type BOMHandler struct {
	service *services.BOMService
}

func NewBOMHandler(service *services.BOMService) *BOMHandler {
	return &BOMHandler{service: service}
}

func (h *BOMHandler) CreateBOM(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userIDStr := c.Locals("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)
	
	// Optional org ID
	var orgID *string
	if val := c.Locals("organization_id"); val != nil {
		strVal := val.(string)
		if strVal != "" {
			orgID = &strVal
		}
	}

	var req models.CreateBOMRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request payload", "details": err.Error()})
	}

	bom, err := h.service.CreateBOM(&req, tenantID, &userID, orgID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create BOM", "details": err.Error()})
	}

	// Example audit log
	// s.auditService.Log(..., "BOM_CREATE")

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"success": true, "data": bom})
}

func (h *BOMHandler) GetBOMs(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)

	boms, err := h.service.GetBOMs(tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch BOMs"})
	}

	return c.JSON(fiber.Map{"success": true, "data": boms})
}

func (h *BOMHandler) GetBOM(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	bom, err := h.service.GetBOMByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "BOM not found"})
	}

	return c.JSON(fiber.Map{"success": true, "data": bom})
}

func (h *BOMHandler) UpdateStatus(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	var req models.UpdateBOMStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request payload"})
	}

	err := h.service.UpdateStatus(id, tenantID, req.Status)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Failed to update status", "details": err.Error()})
	}

	// Example audit log
	// s.auditService.Log(..., "BOM_STATUS_UPDATE")

	return c.JSON(fiber.Map{"success": true, "message": "Status updated successfully"})
}
