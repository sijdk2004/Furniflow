package main

import (
	"encoding/json"
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
	"log"
)

func main() {
	dbConn, err := db.InitDB()
	if err != nil {
		log.Fatal(err)
	}
	gormDB, _ := dbConn.DB()
	defer gormDB.Close()

	var states []models.State
	dbConn.Find(&states)
	
	var records []models.MasterData
	for _, s := range states {
		records = append(records, models.MasterData{BaseModel: s.BaseModel, Type: "states", Code: s.Code, Name: s.Name, Description: s.CountryID.String()})
	}
	
	b, _ := json.MarshalIndent(records, "", "  ")
	fmt.Println("MASTERDATA STATES:", string(b))
}
