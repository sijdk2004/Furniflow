package main

import (
	"fmt"
	"furniflow-backend/models"
	dbPkg "furniflow-backend/db"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	db.AutoMigrate(&models.User{}, &models.Role{}, &models.Permission{})

	hash, _ := bcrypt.GenerateFromPassword([]byte("password"), bcrypt.DefaultCost)
	lastName := "Admin"

	var count int64
	db.Model(&models.User{}).Where("username = ?", "admin").Count(&count)
	if count > 0 {
		fmt.Println("Admin already exists, updating password and tenant ID...")
		db.Model(&models.User{}).Where("username = ?", "admin").Updates(map[string]interface{}{
			"password_hash": string(hash),
			"tenant_id":     "SYSTEM_TENANT",
		})
		return
	}

	admin := models.User{
		BaseModel: models.BaseModel{
			TenantID: "SYSTEM_TENANT",
		},
		Username:     "admin",
		PasswordHash: string(hash),
		Email:        "admin@furniflow.com",
		FirstName:    "System",
		LastName:     &lastName,
	}

	db.Create(&admin)

	fmt.Println("Admin user seeded successfully!")
}
