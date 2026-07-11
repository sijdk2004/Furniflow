package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
)

func main() {
	database, err := db.InitDB()
	if err != nil {
		panic(err)
	}

	var user models.User
	if err := database.Where("email = ?", "gokul@gmail.com").First(&user).Error; err != nil {
		fmt.Println("User not found:", err)
		return
	}

	var role models.Role
	if err := database.Where("role_code = ?", "SALES_PERSON").First(&role).Error; err != nil {
		fmt.Println("Role not found:", err)
		return
	}

	// Insert into user_roles
	err = database.Exec("INSERT INTO user_roles (tenant_id, user_id, role_id) VALUES (?, ?, ?) ON CONFLICT DO NOTHING", "SYSTEM_TENANT", user.ID, role.ID).Error
	if err != nil {
		fmt.Println("Failed to assign role:", err)
		return
	}

	fmt.Println("Successfully assigned SALES_PERSON role to Gokul")
}
