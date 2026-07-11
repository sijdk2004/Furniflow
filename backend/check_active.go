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

	fmt.Printf("User: %s, IsActive: %t, TenantID: %s, LastName is nil: %t\n", user.Username, user.IsActive, user.TenantID, user.LastName == nil)
}
