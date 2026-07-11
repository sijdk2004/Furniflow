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
	if err := database.Preload("Roles.Permissions").Where("email = ?", "gokul@gmail.com").First(&user).Error; err != nil {
		fmt.Println("User not found:", err)
		return
	}

	fmt.Printf("User: %s, Roles count: %d\n", user.Username, len(user.Roles))
	for _, r := range user.Roles {
		fmt.Printf("- Role: %s\n", r.RoleCode)
		for _, p := range r.Permissions {
			fmt.Printf("  - Perm: %s\n", p.PermissionCode)
		}
	}
}
