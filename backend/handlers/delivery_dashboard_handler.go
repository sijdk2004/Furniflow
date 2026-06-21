package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
)

type DeliveryDashboardHandler struct {
	service *services.DeliveryDashboardService
}

func NewDeliveryDashboardHandler(service *services.DeliveryDashboardService) *DeliveryDashboardHandler {
	return &DeliveryDashboardHandler{service: service}
}

func (h *DeliveryDashboardHandler) GetDeliveryDashboardData(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	userID, _ := c.Locals("user_id").(string)

	var orgID *string
	if o := c.Locals("organization_id"); o != nil {
		if oStr, ok := o.(string); ok && oStr != "" {
			orgID = &oStr
		}
	}

	timeframe := c.Query("timeframe", "1M")
	customerID := c.Query("customer_id")
	status := c.Query("status")
	driver := c.Query("driver")
	vehicle := c.Query("vehicle")
	salesOrderID := c.Query("sales_order_id")

	filter := &models.DeliveryDashboardFilterRequest{
		Timeframe:      timeframe,
		OrganizationID: orgID,
		UserID:         userID,
	}

	if customerID != "" { filter.CustomerID = &customerID }
	if status != "" { filter.Status = &status }
	if driver != "" { filter.Driver = &driver }
	if vehicle != "" { filter.Vehicle = &vehicle }
	if salesOrderID != "" { filter.SalesOrderID = &salesOrderID }

	data, err := h.service.GetDashboardData(tenantID, *filter)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    data,
	})
}
