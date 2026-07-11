package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ProductionTrackingHandler struct {
	service *services.ProductionTrackingService
}

func NewProductionTrackingHandler(service *services.ProductionTrackingService) *ProductionTrackingHandler {
	return &ProductionTrackingHandler{service: service}
}

func (h *ProductionTrackingHandler) GetBoardItems(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)

	items, err := h.service.GetBoardItems(tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": items})
}

func (h *ProductionTrackingHandler) EnsureTrackingExists(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	orderID := c.Params("orderId")
	userIDStr, ok := c.Locals("user_id").(string)

	var userID *uuid.UUID
	if ok && userIDStr != "" {
		uid, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &uid
		}
	}

	tracking, err := h.service.EnsureTrackingExists(orderID, tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": tracking})
}

func (h *ProductionTrackingHandler) GetTrackingByID(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	tracking, err := h.service.GetTrackingByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Tracking record not found"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": tracking})
}

func (h *ProductionTrackingHandler) UpdateStage(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userIDStr, ok := c.Locals("user_id").(string)
	id := c.Params("id")

	var userID *uuid.UUID
	if ok && userIDStr != "" {
		uid, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &uid
		}
	}

	var req models.UpdateTrackingStageRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	err := h.service.UpdateStage(id, &req, tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Stage updated successfully"})
}

func (h *ProductionTrackingHandler) StartStage(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	err := h.service.StartStage(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Stage started"})
}

func (h *ProductionTrackingHandler) ToggleHold(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userIDStr, ok := c.Locals("user_id").(string)
	id := c.Params("id")

	var userID *uuid.UUID
	if ok && userIDStr != "" {
		uid, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &uid
		}
	}

	var req models.ToggleHoldRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	err := h.service.ToggleHold(id, &req, tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Hold status updated successfully"})
}
