package main

import (
	"fmt"
	"furniflow-backend/models"
	"time"

	"github.com/google/uuid"
	dbPkg "furniflow-backend/db"
	"gorm.io/gorm"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	fmt.Println("Migrating database...")
	db.AutoMigrate(
		&models.MasterData{},
		&models.Country{},
		&models.State{},
		&models.City{},
		&models.Customer{},
		&models.Product{},
		&models.Quotation{},
		&models.QuotationItem{},
		&models.SalesOrder{},
		&models.SalesOrderItem{},
		&models.User{},
		&models.Role{},
	)

	tenantID := "SYSTEM_TENANT"

	// --- Seed Master Data ---
	fmt.Println("Seeding Master Data...")
	seedMasterData(db, tenantID, "wood_types", []models.MasterData{
		{Code: "OAK", Name: "Oak Wood", Description: "High quality oak wood", SortOrder: 10},
		{Code: "TEAK", Name: "Teak Wood", Description: "Premium teak wood", SortOrder: 20},
		{Code: "PINE", Name: "Pine Wood", Description: "Standard pine wood", SortOrder: 30},
	})
	seedMasterData(db, tenantID, "units_of_measure", []models.MasterData{
		{Code: "PCS", Name: "Pieces", Description: "Individual pieces", SortOrder: 10},
		{Code: "SET", Name: "Sets", Description: "Bundle of items", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "currencies", []models.MasterData{
		{Code: "USD", Name: "US Dollar", Description: "$", SortOrder: 10},
		{Code: "EUR", Name: "Euro", Description: "€", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "customer_types", []models.MasterData{
		{Code: "RETAIL", Name: "Retail Customer", Description: "Individual buyers", SortOrder: 10},
		{Code: "WHOLESALE", Name: "Wholesale Customer", Description: "Bulk buyers", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "product_categories", []models.MasterData{
		{Code: "CHAIRS", Name: "Chairs & Seating", Description: "Chairs, Sofas, Stools", SortOrder: 10},
		{Code: "TABLES", Name: "Tables & Desks", Description: "Dining tables, Coffee tables, Desks", SortOrder: 20},
		{Code: "STORAGE", Name: "Storage", Description: "Cabinets, Wardrobes, Shelves", SortOrder: 30},
	})
	seedMasterData(db, tenantID, "document_types", []models.MasterData{
		{Code: "INV", Name: "Invoice", Description: "Standard Invoice", SortOrder: 10},
		{Code: "PO", Name: "Purchase Order", Description: "Standard PO", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "branches", []models.MasterData{
		{Code: "HQ", Name: "Headquarters", Description: "Main Branch", SortOrder: 10},
		{Code: "EAST", Name: "East Coast Branch", Description: "Eastern region operations", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "departments", []models.MasterData{
		{Code: "SALES", Name: "Sales Dept", Description: "Sales and Marketing", SortOrder: 10},
		{Code: "PROD", Name: "Production Dept", Description: "Manufacturing", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "designations", []models.MasterData{
		{Code: "MGR", Name: "Manager", Description: "Department Manager", SortOrder: 10},
		{Code: "STAFF", Name: "Staff", Description: "Regular Staff", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "product_variants", []models.MasterData{
		{Code: "COLOR_RED", Name: "Red Polish", Description: "Red wood finish", SortOrder: 10},
		{Code: "COLOR_NATURAL", Name: "Natural Finish", Description: "Natural wood finish", SortOrder: 20},
	})
	seedMasterData(db, tenantID, "production_stages", []models.MasterData{
		{Code: "CUTTING", Name: "Wood Cutting", Description: "Initial cutting phase", SortOrder: 10},
		{Code: "ASSEMBLY", Name: "Assembly", Description: "Putting pieces together", SortOrder: 20},
		{Code: "FINISHING", Name: "Polishing & Finishing", Description: "Final touches", SortOrder: 30},
	})

	// Fetch IDs for references
	var customerType, uom, woodType, category models.MasterData
	db.Where("type = ? AND code = ?", "customer_types", "RETAIL").First(&customerType)
	db.Where("type = ? AND code = ?", "units_of_measure", "PCS").First(&uom)
	db.Where("type = ? AND code = ?", "wood_types", "OAK").First(&woodType)
	db.Where("type = ? AND code = ?", "product_categories", "TABLES").First(&category)

	// --- Seed Roles ---
	fmt.Println("Seeding Roles...")
	var count int64
	db.Model(&models.Role{}).Count(&count)
	if count == 0 {
		roles := []models.Role{
			{BaseModel: models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()}, RoleCode: "ADMIN", RoleName: "Administrator"},
			{BaseModel: models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()}, RoleCode: "SALES", RoleName: "Sales Rep"},
		}
		db.Create(&roles)
	}

	// --- Seed Customers ---
	fmt.Println("Seeding Customers...")
	db.Model(&models.Customer{}).Count(&count)
	if count == 0 {
		customers := []models.Customer{
			{
				BaseModel:      models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()},
				Name:           "John Doe",
				CustomerTypeID: &customerType.ID,
				Email:          strPtr("john.doe@example.com"),
				Phone:          strPtr("+1 555-0100"),
				AddressLine1:   strPtr("123 Furniture St"),
				CreditLimit:    5000.0,
			},
			{
				BaseModel:      models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()},
				Name:           "Acme Corp",
				CustomerTypeID: &customerType.ID,
				Email:          strPtr("contact@acme.com"),
				Phone:          strPtr("+1 555-0200"),
				AddressLine1:   strPtr("456 Corporate Blvd"),
				CreditLimit:    100000.0,
			},
		}
		db.Create(&customers)
	}

	// Fetch a customer for quotations
	var firstCustomer models.Customer
	db.First(&firstCustomer)

	// --- Seed Products ---
	fmt.Println("Seeding Products...")
	db.Model(&models.Product{}).Count(&count)
	if count == 0 {
		products := []models.Product{
			{
				BaseModel:   models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()},
				ProductCode: "TBL-001",
				ProductName: "Premium Oak Dining Table",
				CategoryID:  &category.ID,
				WoodTypeID:  &woodType.ID,
				UOMID:       &uom.ID,
				BasePrice:   1299.99,
				Description: strPtr("A beautiful 6-seater dining table made of premium oak wood."),
			},
			{
				BaseModel:   models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now()},
				ProductCode: "CHR-001",
				ProductName: "Classic Oak Chair",
				CategoryID:  &category.ID,
				WoodTypeID:  &woodType.ID,
				UOMID:       &uom.ID,
				BasePrice:   199.99,
				Description: strPtr("A classic, sturdy oak chair to match your dining table."),
			},
		}
		db.Create(&products)
	}

	var firstProduct models.Product
	db.First(&firstProduct)

	// --- Seed Quotations ---
	fmt.Println("Seeding Quotations...")
	db.Model(&models.Quotation{}).Count(&count)
	if count == 0 {
		quotation := models.Quotation{
			ID:          "QT-1001",
			TenantID:    tenantID,
			CustomerID:  firstCustomer.ID.String(),
			Status:      "Draft",
			DateCreated: time.Now(),
			ValidUntil:  time.Now().Add(30 * 24 * time.Hour),
			Subtotal:    1299.99,
			Tax:         130.00,
			Total:       1429.99,
			Notes:       strPtr("Valid for 30 days"),
			CreatedOn:   time.Now(),
			UpdatedOn:   time.Now(),
			Items: []models.QuotationItem{
				{
					ID:         uuid.New().String(),
					ProductID:  firstProduct.ID.String(),
					Quantity:   1,
					UnitPrice:  1299.99,
					TotalPrice: 1299.99,
				},
			},
		}
		db.Create(&quotation)
	}

	// --- Seed Sales Orders ---
	fmt.Println("Seeding Sales Orders...")
	db.Model(&models.SalesOrder{}).Count(&count)
	if count == 0 {
		so := models.SalesOrder{
			ID:          "SO-2001",
			TenantID:    tenantID,
			CustomerID:  firstCustomer.ID.String(),
			Status:      "Confirmed",
			OrderDate:   time.Now(),
			Subtotal:    1299.99,
			Tax:         130.00,
			TotalAmount: 1429.99,
			Remarks:     strPtr("Please deliver by next week"),
			CreatedOn:   time.Now(),
			UpdatedOn:   time.Now(),
			Items: []models.SalesOrderItem{
				{
					ID:         uuid.New().String(),
					ProductID:  firstProduct.ID.String(),
					Quantity:   1,
					UnitPrice:  1299.99,
					TotalPrice: 1299.99,
				},
			},
		}
		db.Create(&so)
	}

	fmt.Println("Seeding complete!")
}

func seedMasterData(db *gorm.DB, tenantID string, mType string, data []models.MasterData) {
	for _, d := range data {
		var count int64
		db.Model(&models.MasterData{}).Where("type = ? AND code = ?", mType, d.Code).Count(&count)
		if count == 0 {
			d.ID = uuid.New()
			d.Type = mType
			d.TenantID = tenantID
			d.IsActive = true
			d.CreatedOn = time.Now()
			db.Create(&d)
		}
	}
}

func strPtr(s string) *string {
	return &s
}
