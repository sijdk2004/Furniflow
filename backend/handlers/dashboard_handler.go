package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
)

type DashboardHandler struct {
	service *services.DashboardService
}

func NewDashboardHandler(service *services.DashboardService) *DashboardHandler {
	return &DashboardHandler{service: service}
}

func (h *DashboardHandler) GetDashboardData(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID, _ := c.Locals("user_id").(string)

	var orgID *string
	if o := c.Locals("organization_id"); o != nil {
		if oStr, ok := o.(string); ok && oStr != "" {
			orgID = &oStr
		}
	}

	timeframe := c.Query("timeframe", "YTD")
	customerID := c.Query("customer_id")
	productID := c.Query("product_id")
	status := c.Query("status")

	filter := &models.DashboardFilterRequest{
		Timeframe:      timeframe,
		OrganizationID: orgID,
		UserID:         userID,
	}

	if customerID != "" {
		filter.CustomerID = &customerID
	}
	if productID != "" {
		filter.ProductID = &productID
	}
	if status != "" {
		filter.Status = &status
	}

	data, err := h.service.GetDashboardData(tenantID, filter)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    data,
	})
}
