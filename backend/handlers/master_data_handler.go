package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
)

type MasterDataHandler struct {
	service *services.MasterDataService
}

func NewMasterDataHandler(service *services.MasterDataService) *MasterDataHandler {
	return &MasterDataHandler{service: service}
}

// GetMasterData godoc
// @Summary Get Master Data List
// @Description Retrieve reference list for a specific master data type
// @Tags MasterData
// @Accept json
// @Produce json
// @Param type path string true "Entity Type (e.g. units_of_measure)"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/masters/{type} [get]
func (h *MasterDataHandler) GetMasterData(c *fiber.Ctx) error {
	entityType := c.Params("type")
	tenantID := c.Locals("tenant_id").(string)

	records, err := h.service.GetAll(entityType, tenantID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": records})
}

// CreateMasterData godoc
// @Summary Create Master Data
// @Description Create a new record in a master data table
// @Tags MasterData
// @Accept json
// @Produce json
// @Param type path string true "Entity Type"
// @Param request body dtos.MasterDataRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/masters/{type} [post]
func (h *MasterDataHandler) CreateMasterData(c *fiber.Ctx) error {
	entityType := c.Params("type")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.MasterDataRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Create(entityType, tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// UpdateMasterData godoc
// @Summary Update Master Data
// @Description Update an existing master data record
// @Tags MasterData
// @Accept json
// @Produce json
// @Param type path string true "Entity Type"
// @Param id path string true "Record ID"
// @Param request body dtos.MasterDataRequest true "Payload"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/masters/{type}/{id} [put]
func (h *MasterDataHandler) UpdateMasterData(c *fiber.Ctx) error {
	entityType := c.Params("type")
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)
	userID := c.Locals("user_id").(string)

	var req dtos.MasterDataRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": "Invalid JSON"})
	}

	record, err := h.service.Update(entityType, id, tenantID, userID, req)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": record})
}

// DeleteMasterData godoc
// @Summary Delete Master Data
// @Description Remove a master data record
// @Tags MasterData
// @Accept json
// @Produce json
// @Param type path string true "Entity Type"
// @Param id path string true "Record ID"
// @Success 200 {object} map[string]interface{}
// @Router /v1/system/masters/{type}/{id} [delete]
func (h *MasterDataHandler) DeleteMasterData(c *fiber.Ctx) error {
	entityType := c.Params("type")
	id := c.Params("id")
	tenantID := c.Locals("tenant_id").(string)

	if err := h.service.Delete(entityType, id, tenantID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Record deleted successfully"})
}
