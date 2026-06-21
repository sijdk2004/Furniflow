package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
)

type CustomerHandler struct {
	service *services.CustomerService
}

func NewCustomerHandler(service *services.CustomerService) *CustomerHandler {
	return &CustomerHandler{service: service}
}

// GetCustomers godoc
// @Summary Get Customer List
// @Description Retrieve a list of customers
// @Tags Customers
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/customers [get]
func (h *CustomerHandler) GetCustomers(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)

	records, err := h.service.GetAll(tenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}

// GetCustomer godoc
// @Summary Get Customer details
// @Description Retrieve specific customer
// @Tags Customers
// @Accept json
// @Produce json
// @Param id path string true "Customer ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/customers/{id} [get]
func (h *CustomerHandler) GetCustomer(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)

	record, err := h.service.GetByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"success": false, "error": "Customer not found"})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// CreateCustomer godoc
// @Summary Create Customer
// @Description Create a new customer
// @Tags Customers
// @Accept json
// @Produce json
// @Param request body dtos.CustomerRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/customers [post]
func (h *CustomerHandler) CreateCustomer(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.CustomerRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Create(tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// UpdateCustomer godoc
// @Summary Update Customer
// @Description Update an existing customer
// @Tags Customers
// @Accept json
// @Produce json
// @Param id path string true "Customer ID"
// @Param request body dtos.CustomerRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/customers/{id} [put]
func (h *CustomerHandler) UpdateCustomer(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.CustomerRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Update(id, tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// DeleteCustomer godoc
// @Summary Delete Customer
// @Description Remove a customer record
// @Tags Customers
// @Accept json
// @Produce json
// @Param id path string true "Customer ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/customers/{id} [delete]
func (h *CustomerHandler) DeleteCustomer(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)

	if err := h.service.Delete(id, tenantID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Customer deleted successfully"})
}
