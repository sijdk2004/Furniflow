package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"github.com/gofiber/fiber/v2"
)

type UsersHandler struct{
	repo *repositories.UserRepository
}

func NewUsersHandler(repo *repositories.UserRepository) *UsersHandler {
	return &UsersHandler{repo: repo}
}

func (h *UsersHandler) GetUsers(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	users, err := h.repo.GetAll(tenantID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": users})
}

func (h *UsersHandler) CreateUser(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	var user models.User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}
	user.TenantID = tenantID
	
	if err := h.repo.Create(&user); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": user})
}

func (h *UsersHandler) GetUser(c *fiber.Ctx) error {
	user, err := h.repo.FindByID(c.Params("id"))
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "User not found"})
	}
	return c.JSON(fiber.Map{"success": true, "data": user})
}

func (h *UsersHandler) UpdateUser(c *fiber.Ctx) error {
	user, err := h.repo.FindByID(c.Params("id"))
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "User not found"})
	}

	if err := c.BodyParser(user); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	if err := h.repo.Update(user); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": user})
}

func (h *UsersHandler) DeleteUser(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	if err := h.repo.Delete(c.Params("id"), tenantID); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "message": "User deleted"})
}
