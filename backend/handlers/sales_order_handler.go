package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
)

type SalesOrderHandler struct {
	service *services.SalesOrderService
}

func NewSalesOrderHandler(service *services.SalesOrderService) *SalesOrderHandler {
	return &SalesOrderHandler{service: service}
}

// @Summary Get all sales orders
// @Tags sales-orders
// @Accept json
// @Produce json
// @Security Bearer
// @Router /v1/sales-orders [get]
func (h *SalesOrderHandler) GetAll(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}
	orders, err := h.service.GetAll(tenantID, isRestricted, userID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"data": orders})
}

// @Summary Get sales order by ID
// @Tags sales-orders
// @Accept json
// @Produce json
// @Security Bearer
// @Param id path string true "Sales Order ID"
// @Router /v1/sales-orders/{id} [get]
func (h *SalesOrderHandler) GetByID(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	order, err := h.service.GetByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"data": order})
}

// @Summary Update draft sales order
// @Tags sales-orders
// @Accept json
// @Produce json
// @Security Bearer
// @Param id path string true "Sales Order ID"
// @Param body body dtos.SalesOrderUpdateRequest true "Update Request"
// @Router /v1/sales-orders/{id} [put]
func (h *SalesOrderHandler) Update(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	var req dtos.SalesOrderUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
	}

	order, err := h.service.Update(id, tenantID, userID, req, isRestricted)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"data": order, "message": "Sales order updated successfully"})
}

// @Summary Update sales order status
// @Tags sales-orders
// @Accept json
// @Produce json
// @Security Bearer
// @Param id path string true "Sales Order ID"
// @Param body body dtos.SalesOrderStatusUpdateRequest true "Status Update Request"
// @Router /v1/sales-orders/{id}/status [patch]
func (h *SalesOrderHandler) UpdateStatus(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	var req dtos.SalesOrderStatusUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.service.UpdateStatus(id, tenantID, userID, req.Status, isRestricted); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "Sales order status updated successfully"})
}
