package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
)

type SalesDashboardHandler struct {
	service *services.SalesDashboardService
}

func NewSalesDashboardHandler(service *services.SalesDashboardService) *SalesDashboardHandler {
	return &SalesDashboardHandler{service: service}
}

func (h *SalesDashboardHandler) GetSalesDashboardData(c *fiber.Ctx) error {
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
	salesRepID := c.Query("sales_rep_id")

	filter := &models.SalesDashboardFilterRequest{
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
	if salesRepID != "" {
		filter.SalesRepID = &salesRepID
	}

	data, err := h.service.GetSalesDashboardData(tenantID, filter)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data":    data,
	})
}
