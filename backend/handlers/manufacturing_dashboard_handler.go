package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
)

type ManufacturingDashboardHandler struct {
	service *services.ManufacturingDashboardService
}

func NewManufacturingDashboardHandler(service *services.ManufacturingDashboardService) *ManufacturingDashboardHandler {
	return &ManufacturingDashboardHandler{service: service}
}

func (h *ManufacturingDashboardHandler) GetManufacturingDashboardData(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID, _ := c.Locals("user_id").(string)

	var orgID *string
	if o := c.Locals("organization_id"); o != nil {
		if oStr, ok := o.(string); ok && oStr != "" {
			orgID = &oStr
		}
	}

	timeframe := c.Query("timeframe", "YTD")
	productID := c.Query("product_id")
	status := c.Query("status")
	stage := c.Query("stage")
	teamID := c.Query("assigned_team")
	empID := c.Query("assigned_employee")

	filter := &models.ManufacturingDashboardFilterRequest{
		Timeframe:      timeframe,
		OrganizationID: orgID,
		UserID:         userID,
	}

	if productID != "" { filter.ProductID = &productID }
	if status != "" { filter.Status = &status }
	if stage != "" { filter.Stage = &stage }
	if teamID != "" { filter.AssignedTeam = &teamID }
	if empID != "" { filter.AssignedEmp = &empID }

	data, err := h.service.GetManufacturingDashboardData(tenantID, filter)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    data,
	})
}
