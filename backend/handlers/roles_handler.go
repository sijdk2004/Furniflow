package handlers

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type RolesHandler struct{
	repo *repositories.RoleRepository
}

func NewRolesHandler(repo *repositories.RoleRepository) *RolesHandler {
	return &RolesHandler{repo: repo}
}

func (h *RolesHandler) GetRoles(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	roles, err := h.repo.GetAll(tenantID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": roles})
}

func (h *RolesHandler) CreateRole(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	var role models.Role
	if err := c.BodyParser(&role); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}
	role.TenantID = tenantID

	if err := h.repo.Create(&role); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": role})
}

func (h *RolesHandler) GetRole(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	role, err := h.repo.FindByID(c.Params("id"), tenantID)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Role not found"})
	}
	return c.JSON(fiber.Map{"success": true, "data": role})
}

func (h *RolesHandler) UpdateRole(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	role, err := h.repo.FindByID(c.Params("id"), tenantID)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Role not found"})
	}

	if err := c.BodyParser(role); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	if err := h.repo.Update(role); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": role})
}

func (h *RolesHandler) DeleteRole(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	if err := h.repo.Delete(c.Params("id"), tenantID); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "message": "Role deleted"})
}

func (h *RolesHandler) GetAllPermissions(c *fiber.Ctx) error {
	permissions, err := h.repo.GetAllPermissions()
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": permissions})
}

func (h *RolesHandler) GetRolePermissions(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	role, err := h.repo.FindByID(c.Params("id"), tenantID)
	if err != nil {
		return c.Status(404).JSON(fiber.Map{"error": "Role not found"})
	}
	return c.JSON(fiber.Map{"success": true, "data": role.Permissions})
}

func (h *RolesHandler) UpdateRolePermissions(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	roleID := c.Params("id")
	userIDStr, ok := c.Locals("user_id").(string)
	var updatedBy *uuid.UUID
	if ok && userIDStr != "" {
		id, err := uuid.Parse(userIDStr)
		if err == nil {
			updatedBy = &id
		}
	}
	
	var req struct {
		PermissionIDs []string `json:"permission_ids"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	if err := h.repo.UpdatePermissions(roleID, tenantID, req.PermissionIDs, updatedBy); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Permissions updated"})
}

func (h *RolesHandler) GetRoleUsers(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	users, err := h.repo.GetUsersByRole(c.Params("id"), tenantID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": users})
}

func (h *RolesHandler) UpdateRoleUsers(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	roleID := c.Params("id")
	userIDStr, ok := c.Locals("user_id").(string)
	var updatedBy *uuid.UUID
	if ok && userIDStr != "" {
		id, err := uuid.Parse(userIDStr)
		if err == nil {
			updatedBy = &id
		}
	}
	
	var req struct {
		UserIDs []string `json:"user_ids"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	}

	if err := h.repo.UpdateUsers(roleID, tenantID, req.UserIDs, updatedBy); err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Users updated"})
}

func (h *RolesHandler) GetRoleAuditHistory(c *fiber.Ctx) error {
	tenantID := c.Locals("tenant_id").(string)
	logs, err := h.repo.GetAuditLogs(c.Params("id"), tenantID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"success": true, "data": logs})
}
