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

	var perms []models.Permission
	database.Find(&perms)

	for _, p := range perms {
		fmt.Printf("%s - %s\n", p.PermissionCode, p.Description)
	}
}
