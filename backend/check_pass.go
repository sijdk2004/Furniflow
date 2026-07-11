package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
	"golang.org/x/crypto/bcrypt"
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

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte("password"))
	if err != nil {
		fmt.Println("Password 'password' does NOT match:", err)
	} else {
		fmt.Println("Password 'password' matches!")
	}
	
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte("password123"))
	if err != nil {
		fmt.Println("Password 'password123' does NOT match:", err)
	} else {
		fmt.Println("Password 'password123' matches!")
	}
}
