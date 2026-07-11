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

	fmt.Println("User:", user.Username)
	fmt.Println("Roles:")
	for _, r := range user.Roles {
		fmt.Println(" -", r.RoleName)
		for _, p := range r.Permissions {
			fmt.Println("   *", p.PermissionCode)
		}
	}
	if len(user.Roles) == 0 {
		fmt.Println("No roles assigned to user")
	}
}
