package handlers

import (
	"furniflow-backend/repositories"
	"github.com/gofiber/fiber/v2"
)

type MenuHandler struct{
	repo *repositories.MenuRepository
}

func NewMenuHandler(repo *repositories.MenuRepository) *MenuHandler {
	return &MenuHandler{repo: repo}
}

func (h *MenuHandler) GetMenus(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	
	menus, err := h.repo.FindAllActiveByTenant(tenantID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "data": menus})
}
