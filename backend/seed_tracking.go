package main

import (
	"furniflow-backend/models"
	"log"
	"time"

	"github.com/google/uuid"
	dbPkg "furniflow-backend/db"
	"gorm.io/gorm"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	tenantID := "SYSTEM_TENANT"
	
	// Ensure categories exist
	categoryID := uuid.New()
	db.Create(&models.MasterData{
		BaseModel: models.BaseModel{ID: categoryID, TenantID: tenantID},
		Type: "CATEGORY",
		Code: "CAT01",
		Name: "Seating",
	})
	
	// Create sample products
	p1 := models.Product{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductCode: "CHAIR-" + uuid.New().String()[:4],
		ProductName: "Ergonomic Office Chair",
		CategoryID: &categoryID,
		BasePrice: 150.0,
	}
	p2 := models.Product{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductCode: "DESK-" + uuid.New().String()[:4],
		ProductName: "Standing Desk Pro",
		CategoryID: &categoryID,
		BasePrice: 350.0,
	}
	db.Create(&p1)
	db.Create(&p2)

	// Create sample BOM
	bomId := uuid.New()
	bom := models.BOM{
		BaseModel: models.BaseModel{ID: bomId, TenantID: tenantID},
		ProductID: p1.ID.String(),
		VersionNumber: 1,
		Status: "Approved",
	}
	db.Create(&bom)

	// Create sample Production Orders
	po1 := models.ProductionOrder{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductID: p1.ID.String(),
		BOMID: bomId.String(),
		BOMVersion: 1,
		Quantity: 50,
		Status: "In Progress",
	}
	po2 := models.ProductionOrder{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductID: p2.ID.String(),
		BOMID: bomId.String(),
		BOMVersion: 2,
		Quantity: 20,
		Status: "In Progress",
	}
	
	db.Create(&po1)
	db.Create(&po2)

	// Create Tracking instances
	team1 := "Assembly Team A"
	team2 := "Woodwork Team B"
	
	pt1 := models.ProductionTracking{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductionOrderID: po1.ID,
		CurrentStage: "Assembly",
		AssignedTeam: &team1,
		CompletionPercentage: 45,
	}
	
	pt2 := models.ProductionTracking{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		ProductionOrderID: po2.ID,
		CurrentStage: "Cutting",
		AssignedTeam: &team2,
		CompletionPercentage: 15,
	}

	db.Create(&pt1)
	db.Create(&pt2)
	
	// Create some histories
	db.Create(&models.ProductionStageHistory{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		TrackingID: pt1.ID,
		Stage: "Assembly",
		StageEnteredAt: time.Now().Add(-48 * time.Hour),
	})
	
	db.Create(&models.ProductionStageHistory{
		BaseModel: models.BaseModel{ID: uuid.New(), TenantID: tenantID},
		TrackingID: pt2.ID,
		Stage: "Cutting",
		StageEnteredAt: time.Now().Add(-24 * time.Hour),
	})

	log.Println("Sample data seeded successfully!")
}
