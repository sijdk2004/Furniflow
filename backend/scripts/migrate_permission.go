package main

import (
	"log"
	"furniflow-backend/db"
	"furniflow-backend/models"
)

func main() {
	dbConn, err := db.InitDB()
	if err != nil {
		log.Fatal(err)
	}
	
	err = dbConn.AutoMigrate(&models.Permission{})
	if err != nil {
		log.Println("Permission Migration error:", err)
	} else {
		log.Println("Permission migrated successfully!")
	}
}
