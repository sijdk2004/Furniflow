package main

import (
	"fmt"
	"log"
	"strings"

	"furniflow-backend/db"
	"furniflow-backend/models"
	"github.com/joho/godotenv"
	"github.com/xuri/excelize/v2"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

func main() {
	if err := godotenv.Load(".env"); err != nil {
		log.Println("No .env file found or failed to load, falling back to environment variables.")
	}

	database, err := db.InitDB()
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	f, err := excelize.OpenFile("../docs/District_Masters.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		log.Fatal("No sheets found")
	}

	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	// 1. Get CountryID for India
	// We know Tamil Nadu is in India, so let's find Tamil Nadu to get its CountryID
	var tn models.State
	if err := database.Where("name = ?", "Tamil Nadu").First(&tn).Error; err != nil {
		log.Fatal("Could not find Tamil Nadu to get India's CountryID. Error:", err)
	}
	indiaCountryID := tn.CountryID
	tenantID := tn.TenantID

	// 2. Load all existing states
	var states []models.State
	if err := database.Find(&states).Error; err != nil {
		log.Fatal("Failed to load states:", err)
	}

	stateMap := make(map[string]models.State)
	for _, s := range states {
		stateMap[strings.ToLower(s.Name)] = s
	}

	caser := cases.Title(language.English)
	insertedStates := 0
	insertedCities := 0

	for i, row := range rows {
		if i == 0 || len(row) < 4 {
			continue
		}

		stateCode := strings.TrimSpace(row[0])
		stateName := strings.TrimSpace(row[1])
		districtCode := strings.TrimSpace(row[2])
		districtName := strings.TrimSpace(row[3])
		
		districtNameCased := caser.String(strings.ToLower(districtName))
		stateNameCased := caser.String(strings.ToLower(stateName))

		// 3. Find or Create State
		state, ok := stateMap[strings.ToLower(stateName)]
		if !ok {
			if strings.ToLower(stateName) == "andaman & nicobar islands" {
				state, ok = stateMap["andaman and nicobar islands"]
			} else if strings.ToLower(stateName) == "delhi" {
				state, ok = stateMap["delhi"]
			}
		}

		if !ok {
			// Create State
			state = models.State{
				CountryID: indiaCountryID,
				Code:      stateCode,
				Name:      stateNameCased,
			}
			state.TenantID = tenantID
			if err := database.Create(&state).Error; err != nil {
				log.Printf("Failed to create state %s: %v", stateNameCased, err)
				continue
			}
			stateMap[strings.ToLower(stateName)] = state
			insertedStates++
		}

		// 4. Find or Create City (District)
		var count int64
		database.Model(&models.City{}).Where("code = ?", districtCode).Count(&count)
		if count == 0 {
			city := models.City{
				StateID: state.ID,
				Code:    districtCode,
				Name:    districtNameCased,
			}
			city.TenantID = tenantID
			if err := database.Create(&city).Error; err != nil {
				log.Printf("Failed to create district %s: %v", districtNameCased, err)
			} else {
				insertedCities++
			}
		}
	}

	fmt.Printf("Successfully inserted %d new states and %d new districts/cities.\n", insertedStates, insertedCities)
}
