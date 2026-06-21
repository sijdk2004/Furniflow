package handlers

import (
	"furniflow-backend/dtos"
	"furniflow-backend/services"

	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	authService *services.AuthService
}

func NewAuthHandler(authService *services.AuthService) *AuthHandler {
	return &AuthHandler{authService: authService}
}

// Login godoc
// @Summary User Login
// @Description Authenticate user and return JWT tokens
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body dtos.LoginRequest true "Login credentials"
// @Success 200 {object} dtos.AuthResponse
// @Failure 401 {object} map[string]string
// @Router /v1/auth/login [post]
func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req dtos.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	res, err := h.authService.Authenticate(req)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"message": "Login successful",
		"data":    res,
	})
}

// Refresh godoc
// @Summary Refresh Token
// @Description Issue a new access token
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body dtos.RefreshRequest true "Refresh token payload"
// @Success 200 {object} dtos.AuthResponse
// @Router /v1/auth/refresh [post]
func (h *AuthHandler) Refresh(c *fiber.Ctx) error {
	var req dtos.RefreshRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	res, err := h.authService.RefreshTokens(req.RefreshToken)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"success": true,
		"message": "Token refreshed successfully",
		"data":    res,
	})
}

func (h *AuthHandler) GetProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	user, err := h.authService.GetUserByID(userID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
	}

	lastName := ""
	if user.LastName != nil {
		lastName = *user.LastName
	}

	mobile := ""
	if user.Mobile != nil {
		mobile = *user.Mobile
	}

	designation := ""
	if user.Designation != nil {
		designation = *user.Designation
	}

	department := ""
	if user.Department != nil {
		department = *user.Department
	}

	return c.JSON(fiber.Map{
		"success": true,
		"data": map[string]interface{}{
			"id":          user.ID.String(),
			"username":    user.Username,
			"first_name":  user.FirstName,
			"last_name":   lastName,
			"email":       user.Email,
			"mobile":      mobile,
			"designation": designation,
			"department":  department,
			"tenant_id":   user.TenantID,
		},
	})
}


func (h *AuthHandler) UpdateProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	var req struct {
		FirstName   string  `json:"first_name"`
		LastName    *string `json:"last_name"`
		Email       string  `json:"email"`
		Mobile      *string `json:"mobile"`
		Designation *string `json:"designation"`
		Department  *string `json:"department"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	err := h.authService.UpdateProfile(userID, req.FirstName, req.LastName, req.Email, req.Mobile, req.Designation, req.Department)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update profile"})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Profile updated successfully"})
}

func (h *AuthHandler) ChangePassword(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(string)
	var req struct {
		CurrentPassword string `json:"current_password"`
		NewPassword     string `json:"new_password"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	if len(req.NewPassword) < 8 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "New password must be at least 8 characters"})
	}

	err := h.authService.ChangePassword(userID, req.CurrentPassword, req.NewPassword)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"success": true, "message": "Password changed successfully"})
}
