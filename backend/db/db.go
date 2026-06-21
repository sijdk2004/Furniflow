package db

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func InitDB() (*gorm.DB, error) {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	dbHost := os.Getenv("DB_HOST")
	if dbHost == "" { dbHost = "localhost" }
	dbUser := os.Getenv("DB_USER")
	if dbUser == "" { dbUser = "postgres" }
	dbPassword := os.Getenv("DB_PASSWORD")
	if dbPassword == "" { dbPassword = "master" }
	dbName := os.Getenv("DB_NAME")
	if dbName == "" { dbName = "furniflow" }
	dbPort := os.Getenv("DB_PORT")
	if dbPort == "" { dbPort = "5432" }
	dbSSLMode := os.Getenv("DB_SSLMODE")
	if dbSSLMode == "" { dbSSLMode = "disable" }
	dbTimeZone := os.Getenv("DB_TIMEZONE")
	if dbTimeZone == "" { dbTimeZone = "UTC" }

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s TimeZone=%s", dbHost, dbUser, dbPassword, dbName, dbPort, dbSSLMode, dbTimeZone)
	dbConn, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	// Register Global Tenant Plugin
	err = dbConn.Use(&TenantPlugin{})
	if err != nil {
		log.Println("Failed to initialize TenantPlugin: " + err.Error())
	}

	return dbConn, nil
}
