package middleware

import (
	"fmt"
	"strings"

	"furniflow-backend/models"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	dbPkg "furniflow-backend/db"
)

func JWTProtected(secret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Missing authorization header"})
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid authorization format"})
		}

		tokenString := parts[1]
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method")
			}
			return []byte(secret), nil
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid or expired token"})
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Invalid token claims"})
		}

		// Check if token is revoked
		dbConn, dbErr := dbPkg.InitDB()
		if dbErr == nil {
			var revoked models.RevokedToken
			if err := dbConn.Where("token = ?", tokenString).First(&revoked).Error; err == nil {
				return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Token has been revoked"})
			}
		}

		// Set Context
		c.Locals("user_id", claims["user_id"])
		c.Locals("tenant_id", claims["tenant_id"])

		// Validate headers matching token
		reqTenant := c.Get("X-Tenant-ID")
		if reqTenant != "" && reqTenant != claims["tenant_id"] {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"success": false,
				"message": "Missing permissions to access this resource",
			})
		}

		return c.Next()
	}
}

// CheckPermission checks if the user has the required permission via context or database
func CheckPermission(requiredPermission string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		tenantID := c.Locals("tenant_id").(string)
		userID := c.Locals("user_id").(string)

		// Connect to DB directly for PoC purposes. In prod, inject repo or use redis.
		// Connect to DB via helper
		db, err := dbPkg.InitDB()
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Database connection failed"})
		}

		var user models.User
		if err := db.Preload("Roles.Permissions").Where("id = ? AND tenant_id = ?", userID, tenantID).First(&user).Error; err != nil {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Access denied"})
		}

		hasPermission := false
		for _, role := range user.Roles {
			if role.RoleCode == "PLATFORM_ADMIN" || role.RoleCode == "SYS_ADMIN" {
				hasPermission = true
				break
			}
			for _, p := range role.Permissions {
				if p.PermissionCode == requiredPermission {
					hasPermission = true
					break
				}
			}
		}

		if !hasPermission {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "Forbidden: missing " + requiredPermission})
		}

		return c.Next()
	}
}
