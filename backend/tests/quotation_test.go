package tests

import (
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"furniflow-backend/services"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	db.AutoMigrate(&models.Customer{}, &models.Product{}, &models.Quotation{}, &models.QuotationItem{}, &models.SalesOrder{})
	return db
}

func TestQuotationService_Create(t *testing.T) {
	t.Skip("Skipping DB tests on windows POC")
	db := setupTestDB()
	repo := repositories.NewQuotationRepository(db)
	service := services.NewQuotationService(repo)

	req := dtos.QuotationRequest{
		CustomerID: "CUST-1",
		ValidUntil: time.Now().Add(24 * time.Hour),
		Discount:   10,
		Tax:        5,
		Items: []dtos.QuotationItemRequest{
			{ProductID: "PROD-1", Quantity: 2, UnitPrice: 50},
			{ProductID: "PROD-2", Quantity: 1, UnitPrice: 100},
		},
	}

	q, err := service.Create("TENANT-1", "USER-1", req)
	assert.NoError(t, err)
	assert.NotNil(t, q)
	assert.Equal(t, "Draft", q.Status)
	assert.Equal(t, float64(200), q.Subtotal) // (2*50) + (1*100)
	assert.Equal(t, float64(195), q.Total)    // 200 - 10 + 5
	assert.Len(t, q.Items, 2)
}

func TestQuotationService_UpdateStatus_To_Converted(t *testing.T) {
	t.Skip("Skipping DB tests on windows POC")
	db := setupTestDB()
	repo := repositories.NewQuotationRepository(db)
	service := services.NewQuotationService(repo)

	// Create a Quotation directly via repo
	q := &models.Quotation{
		ID:         "QT-TEST",
		TenantID:   "TENANT-1",
		CustomerID: "CUST-1",
		Status:     "Approved",
		Total:      195,
	}
	err := repo.Create(q)
	assert.NoError(t, err)

	err = service.UpdateStatus("QT-TEST", "TENANT-1", "USER-1", "Converted")
	assert.NoError(t, err)

	// Verify Sales Order was created
	var so models.SalesOrder
	err = db.First(&so, "quotation_id = ?", "QT-TEST").Error
	assert.NoError(t, err)
	assert.Equal(t, "Draft", so.Status)
	assert.Equal(t, float64(195), so.TotalAmount)
	assert.Equal(t, "TENANT-1", so.TenantID)
}

func TestQuotationService_UpdateStatus_To_Converted_From_Draft(t *testing.T) {
	t.Skip("Skipping DB tests on windows POC")
	db := setupTestDB()
	repo := repositories.NewQuotationRepository(db)
	service := services.NewQuotationService(repo)

	// Create a Quotation directly via repo
	q := &models.Quotation{
		ID:         "QT-TEST",
		TenantID:   "TENANT-1",
		CustomerID: "CUST-1",
		Status:     "Draft",
	}
	err := repo.Create(q)
	assert.NoError(t, err)

	err = service.UpdateStatus("QT-TEST", "TENANT-1", "USER-1", "Converted")
	assert.Error(t, err)
	assert.Equal(t, "only Approved quotations can be converted", err.Error())
}
