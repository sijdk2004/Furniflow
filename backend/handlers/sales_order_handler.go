package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
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
	tenantID := c.Get("X-Tenant-ID")
	orders, err := h.service.GetAll(tenantID)
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
	tenantID := c.Get("X-Tenant-ID")

	order, err := h.service.GetByID(id, tenantID)
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
	tenantID := c.Get("X-Tenant-ID")
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userID := claims["user_id"].(string)

	var req dtos.SalesOrderUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
	}

	order, err := h.service.Update(id, tenantID, userID, req)
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
	tenantID := c.Get("X-Tenant-ID")
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userID := claims["user_id"].(string)

	var req dtos.SalesOrderStatusUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.service.UpdateStatus(id, tenantID, userID, req.Status); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "Sales order status updated successfully"})
}
