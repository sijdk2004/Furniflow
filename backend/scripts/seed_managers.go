package main

import (
	"fmt"
	"furniflow-backend/models"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	dbPkg "furniflow-backend/db"
	"gorm.io/gorm"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	hash, _ := bcrypt.GenerateFromPassword([]byte("password"), bcrypt.DefaultCost)
	tenantID := "SYSTEM_TENANT"

	roles := []struct {
		Code string
		Name string
	}{
		{"PLATFORM_ADMIN", "Platform Admin"},
		{"SALES_MANAGER", "Sales Manager"},
		{"PRODUCTION_MANAGER", "Production Manager"},
		{"DELIVERY_MANAGER", "Delivery Manager"},
	}

	for _, r := range roles {
		var role models.Role
		if err := db.Where("role_code = ?", r.Code).First(&role).Error; err != nil {
			role = models.Role{
				BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
				RoleCode:  r.Code,
				RoleName:  r.Name,
			}
			db.Create(&role)
		}
	}

	users := []struct {
		Username  string
		Email     string
		FirstName string
		LastName  string
		RoleCode  string
	}{
		{"admin", "admin@furniflow.com", "System", "Admin", "PLATFORM_ADMIN"},
		{"sales_manager", "sales@furniflow.com", "Alice", "Sales", "SALES_MANAGER"},
		{"prod_manager", "production@furniflow.com", "Bob", "Production", "PRODUCTION_MANAGER"},
		{"dlv_manager", "delivery@furniflow.com", "Charlie", "Delivery", "DELIVERY_MANAGER"},
	}

	for _, u := range users {
		var user models.User
		if err := db.Where("username = ?", u.Username).First(&user).Error; err != nil {
			user = models.User{
				BaseModel:    models.BaseModel{ID: uuid.New(), TenantID: tenantID},
				Username:     u.Username,
				Email:        u.Email,
				PasswordHash: string(hash),
				FirstName:    u.FirstName,
				LastName:     &u.LastName,
			}
			db.Create(&user)
		} else {
			db.Model(&user).Updates(map[string]interface{}{
				"password_hash": string(hash),
			})
		}

		var role models.Role
		db.Where("role_code = ?", u.RoleCode).First(&role)

		// Create many-to-many relationship explicitly if needed, but Gorm handles it
		db.Model(&user).Association("Roles").Append(&role)
	}

	fmt.Println("Manager users seeded successfully!")
}
