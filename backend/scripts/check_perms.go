package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
)

func main() {
	dbConn, err := db.InitDB()
	if err != nil {
		fmt.Println("DB error:", err)
		return
	}

	var user models.User
	if err := dbConn.Preload("Roles.Permissions").Where("username = ?", "admin").First(&user).Error; err != nil {
		fmt.Println("User not found:", err)
		return
	}

	fmt.Printf("User: %s (Roles: %d)\n", user.Username, len(user.Roles))
	for _, role := range user.Roles {
		fmt.Printf("- Role: %s (Permissions: %d)\n", role.RoleCode, len(role.Permissions))
		for _, p := range role.Permissions {
			fmt.Printf("  * %s\n", p.PermissionCode)
		}
	}
}
