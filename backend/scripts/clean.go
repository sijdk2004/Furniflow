package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
)

func main() {
	dbConn, err := db.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	fmt.Println("Removing old currencies (USD, EUR)...")
	dbConn.Where("type = ? AND code IN ?", "currencies", []string{"USD", "EUR"}).Delete(&models.MasterData{})

	fmt.Println("Running seed again to add INR...")
	// We'll let seed_data.go handle the actual seeding.
}
