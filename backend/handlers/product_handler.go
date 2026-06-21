package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
)

type ProductHandler struct {
	service *services.ProductService
}

func NewProductHandler(service *services.ProductService) *ProductHandler {
	return &ProductHandler{service: service}
}

// GetProducts godoc
// @Summary Get Product List
// @Description Retrieve a list of products
// @Tags Products
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/products [get]
func (h *ProductHandler) GetProducts(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)

	records, err := h.service.GetAll(tenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}

// GetProduct godoc
// @Summary Get Product details
// @Description Retrieve specific product
// @Tags Products
// @Accept json
// @Produce json
// @Param id path string true "Product ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/products/{id} [get]
func (h *ProductHandler) GetProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)

	record, err := h.service.GetByID(id, tenantID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"success": false, "error": "Product not found"})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// CreateProduct godoc
// @Summary Create Product
// @Description Create a new product
// @Tags Products
// @Accept json
// @Produce json
// @Param request body dtos.ProductRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/products [post]
func (h *ProductHandler) CreateProduct(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.ProductRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Create(tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// UpdateProduct godoc
// @Summary Update Product
// @Description Update an existing product
// @Tags Products
// @Accept json
// @Produce json
// @Param id path string true "Product ID"
// @Param request body dtos.ProductRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/products/{id} [put]
func (h *ProductHandler) UpdateProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.ProductRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Update(id, tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// DeleteProduct godoc
// @Summary Delete Product
// @Description Remove a product record
// @Tags Products
// @Accept json
// @Produce json
// @Param id path string true "Product ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/products/{id} [delete]
func (h *ProductHandler) DeleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)

	if err := h.service.Delete(id, tenantID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Product deleted successfully"})
}
