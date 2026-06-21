package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ProductionOrderHandler struct {
	service *services.ProductionOrderService
}

func NewProductionOrderHandler(service *services.ProductionOrderService) *ProductionOrderHandler {
	return &ProductionOrderHandler{service: service}
}

func (h *ProductionOrderHandler) CreateProductionOrder(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userIDStr, ok := c.Locals("user_id").(string)
	
	var userID *uuid.UUID
	if ok && userIDStr != "" {
		id, err := uuid.Parse(userIDStr)
		if err == nil {
			userID = &id
		}
	}

	var req models.CreateProductionOrderRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	order, err := h.service.CreateProductionOrder(&req, tenantID, userID, nil)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"data": order})
}

func (h *ProductionOrderHandler) GetProductionOrders(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	
	orders, err := h.service.GetProductionOrders(tenantID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": orders})
}

func (h *ProductionOrderHandler) GetProductionOrderByID(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	order, err := h.service.GetProductionOrderByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Production Order not found"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"data": order})
}

func (h *ProductionOrderHandler) UpdateStatus(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	id := c.Params("id")

	var req models.UpdateProductionOrderStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	err := h.service.UpdateStatus(id, tenantID, req.Status)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Status updated successfully"})
}
