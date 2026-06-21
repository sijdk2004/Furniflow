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
	
	err = dbConn.AutoMigrate(&models.AuditLog{}, &models.RevokedToken{})
	if err != nil {
		log.Fatal("AutoMigrate failed:", err)
	}
	log.Println("Successfully migrated AuditLog and RevokedToken")
}
