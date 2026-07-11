package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
)

type QuotationHandler struct {
	service *services.QuotationService
}

func NewQuotationHandler(service *services.QuotationService) *QuotationHandler {
	return &QuotationHandler{service: service}
}

// GetQuotations godoc
// @Summary Get Quotation List
// @Description Retrieve a list of quotations
// @Tags Quotations
// @Accept json
// @Produce json
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations [get]
func (h *QuotationHandler) GetQuotations(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	records, err := h.service.GetAll(tenantID, isRestricted, userID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}

// GetQuotation godoc
// @Summary Get Quotation details
// @Description Retrieve specific quotation
// @Tags Quotations
// @Accept json
// @Produce json
// @Param id path string true "Quotation ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations/{id} [get]
func (h *QuotationHandler) GetQuotation(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	record, err := h.service.GetByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"success": false, "error": "Quotation not found"})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// CreateQuotation godoc
// @Summary Create Quotation
// @Description Create a new quotation
// @Tags Quotations
// @Accept json
// @Produce json
// @Param request body dtos.QuotationRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations [post]
func (h *QuotationHandler) CreateQuotation(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.QuotationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Create(tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// UpdateQuotation godoc
// @Summary Update Quotation
// @Description Update an existing quotation
// @Tags Quotations
// @Accept json
// @Produce json
// @Param id path string true "Quotation ID"
// @Param request body dtos.QuotationRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations/{id} [put]
func (h *QuotationHandler) UpdateQuotation(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	var req dtos.QuotationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Update(id, tenantID, userID, req, isRestricted)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// UpdateQuotationStatus godoc
// @Summary Update Quotation Status
// @Description Transition a quotation to a new status (e.g. Approved, Converted)
// @Tags Quotations
// @Accept json
// @Produce json
// @Param id path string true "Quotation ID"
// @Param request body dtos.QuotationStatusUpdateRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations/{id}/status [patch]
func (h *QuotationHandler) UpdateQuotationStatus(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	var req dtos.QuotationStatusUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	if err := h.service.UpdateStatus(id, tenantID, userID, req.Status, isRestricted); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Status updated successfully"})
}

// DeleteQuotation godoc
// @Summary Delete Quotation
// @Description Remove a quotation record
// @Tags Quotations
// @Accept json
// @Produce json
// @Param id path string true "Quotation ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/quotations/{id} [delete]
func (h *QuotationHandler) DeleteQuotation(c *fiber.Ctx) error {
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)
	isRestricted := false
	if val := c.Locals("is_restricted_sales"); val != nil {
		isRestricted = val.(bool)
	}

	if err := h.service.Delete(id, tenantID, isRestricted, userID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Quotation deleted successfully"})
}
