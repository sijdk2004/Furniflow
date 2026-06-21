package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type DeliveryHandler struct {
	service *services.DeliveryService
}

func NewDeliveryHandler(service *services.DeliveryService) *DeliveryHandler {
	return &DeliveryHandler{service: service}
}

func (h *DeliveryHandler) GetDeliveries(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)

	deliveries, err := h.service.GetDeliveries(tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": deliveries})
}

func (h *DeliveryHandler) GetDeliveryByID(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	delivery, err := h.service.GetDeliveryByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": delivery})
}

func (h *DeliveryHandler) CreateDelivery(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userIDStr, ok := c.Locals("user_id").(string)

	var userID *uuid.UUID
	if ok && userIDStr != "" {
		uid, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &uid
		}
	}

	var req models.CreateDeliveryRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	delivery, err := h.service.CreateDelivery(&req, tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": delivery})
}

func (h *DeliveryHandler) UpdateDeliveryStatus(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")
	userIDStr, ok := c.Locals("user_id").(string)

	var userID *uuid.UUID
	if ok && userIDStr != "" {
		uid, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &uid
		}
	}

	var req models.UpdateDeliveryStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	err := h.service.UpdateDeliveryStatus(id, &req, tenantID, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Delivery status updated successfully"})
}
