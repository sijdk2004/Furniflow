package main

import (
	"fmt"
	"math/rand"
	"time"

	"furniflow-backend/models"

	"github.com/google/uuid"
	dbPkg "furniflow-backend/db"
	"gorm.io/gorm"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	tenantID := "SYSTEM_TENANT"
	rand.Seed(time.Now().UnixNano())

	fmt.Println("Starting Demo Data Generation...")

	// 1. Fetch Required Master Data
	var customerTypes []models.MasterData
	db.Where("type = ?", "customer_types").Find(&customerTypes)
	var categories []models.MasterData
	db.Where("type = ?", "product_categories").Find(&categories)
	var woodTypes []models.MasterData
	db.Where("type = ?", "wood_types").Find(&woodTypes)
	var uoms []models.MasterData
	db.Where("type = ?", "units_of_measure").Find(&uoms)

	if len(customerTypes) == 0 || len(categories) == 0 || len(woodTypes) == 0 {
		fmt.Println("Error: Master Data not seeded. Please run seed_data.go first.")
		return
	}

	// 2. Generate Customers
	fmt.Println("Generating Customers...")
	customerNames := []string{
		"Global Tech Offices", "Grand Hotel Suites", "Urban Dine Restaurant", "Vertex Corp",
		"Apex Interior Designs", "Starlight Cafe", "Oasis Resorts", "Crestwood Designs",
		"Lumina Spaces", "John Smith", "Emma Johnson", "Michael Williams", "Sarah Brown",
		"David Jones", "Lisa Garcia", "Robert Martinez", "Mary Rodriguez", "James Lee",
		"Patricia Walker", "Creative Hub Coworking",
	}
	var customers []models.Customer
	for i, name := range customerNames {
		createdOn := time.Now().AddDate(0, -rand.Intn(6), -rand.Intn(30))
		ct := customerTypes[rand.Intn(len(customerTypes))]
		c := models.Customer{
			BaseModel:      models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: createdOn, UpdatedOn: createdOn},
			Name:           name,
			CustomerTypeID: &ct.ID,
			Email:          strPtr(fmt.Sprintf("contact_%d@example.com", i)),
			Phone:          strPtr(fmt.Sprintf("+1-555-%04d", 1000+i)),
			AddressLine1:   strPtr(fmt.Sprintf("%d Main St, Suite %d", 100+i*10, i+1)),
			CreditLimit:    float64(5000 + rand.Intn(45000)),
		}
		db.Create(&c)
		customers = append(customers, c)
	}

	// 3. Generate Products
	fmt.Println("Generating Products...")
	productTypes := []string{"Dining Table", "Office Table", "Study Table", "Wardrobe", "TV Unit", "Bed", "Office Chair", "Executive Chair", "Sofa", "Cabinet"}
	adjectives := []string{"Premium", "Modern", "Classic", "Minimalist", "Rustic", "Luxury", "Ergonomic"}
	var products []models.Product
	for i := 0; i < 50; i++ {
		pType := productTypes[rand.Intn(len(productTypes))]
		adj := adjectives[rand.Intn(len(adjectives))]
		cat := categories[rand.Intn(len(categories))]
		wood := woodTypes[rand.Intn(len(woodTypes))]
		uom := uoms[0]

		p := models.Product{
			BaseModel:   models.BaseModel{TenantID: tenantID, IsActive: true, CreatedOn: time.Now().AddDate(0, -6, 0)},
			ProductCode: fmt.Sprintf("PRD-%04d", 1001+i),
			ProductName: fmt.Sprintf("%s %s", adj, pType),
			CategoryID:  &cat.ID,
			WoodTypeID:  &wood.ID,
			UOMID:       &uom.ID,
			BasePrice:   float64(100 + rand.Intn(1900)),
			Description: strPtr(fmt.Sprintf("A high-quality %s made for modern spaces.", pType)),
		}
		db.Create(&p)
		products = append(products, p)
	}

	// 4. Generate Quotations
	fmt.Println("Generating Quotations...")
	var quotations []models.Quotation
	qStatuses := []string{
		"Approved", "Approved", "Approved", "Approved", "Approved",
		"Approved", "Approved", "Approved", "Approved", "Approved",
		"Approved", "Approved", "Approved", "Approved", "Approved",
		"Draft", "Draft", "Draft", "Rejected", "Expired",
	}
	rand.Shuffle(len(qStatuses), func(i, j int) { qStatuses[i], qStatuses[j] = qStatuses[j], qStatuses[i] })
	for i := 0; i < 20; i++ {
		cust := customers[rand.Intn(len(customers))]
		createdOn := time.Now().AddDate(0, -rand.Intn(5), -rand.Intn(28))
		status := qStatuses[i]

		q := models.Quotation{
			ID:          fmt.Sprintf("QT-%05d", 20000+i),
			TenantID:    tenantID,
			CustomerID:  cust.ID.String(),
			Status:      status,
			DateCreated: createdOn,
			ValidUntil:  createdOn.AddDate(0, 1, 0),
			CreatedOn:   createdOn,
			UpdatedOn:   createdOn.AddDate(0, 0, rand.Intn(5)),
			Notes:       strPtr("Demo Quote"),
		}
		
		subtotal := 0.0
		numItems := 1 + rand.Intn(4)
		for j := 0; j < numItems; j++ {
			prod := products[rand.Intn(len(products))]
			qty := 1 + rand.Intn(10)
			itemTotal := prod.BasePrice * float64(qty)
			subtotal += itemTotal
			
			db.Create(&models.QuotationItem{
				ID:         uuid.New().String(),
				QuotationID: q.ID,
				ProductID:  prod.ID.String(),
				Quantity:   qty,
				UnitPrice:  prod.BasePrice,
				TotalPrice: itemTotal,
			})
		}
		q.Subtotal = subtotal
		q.Tax = subtotal * 0.10
		q.Total = subtotal + q.Tax
		db.Create(&q)
		
		if status == "Approved" {
			quotations = append(quotations, q)
		}
	}

	// 5. Generate Sales Orders
	fmt.Println("Generating Sales Orders...")
	var salesOrders []models.SalesOrder
	soStatuses := []string{"Confirmed", "In Production", "Ready for Delivery", "Delivered"}
	
	rand.Shuffle(len(quotations), func(i, j int) { quotations[i], quotations[j] = quotations[j], quotations[i] })
	limitSO := 15
	if len(quotations) < limitSO { limitSO = len(quotations) }

	for i := 0; i < limitSO; i++ {
		q := quotations[i]
		soDate := q.UpdatedOn.AddDate(0, 0, 1+rand.Intn(3))
		status := soStatuses[rand.Intn(len(soStatuses))]
		
		so := models.SalesOrder{
			ID:          fmt.Sprintf("SO-%05d", 30000+i),
			TenantID:    tenantID,
			QuotationID: &q.ID,
			CustomerID:  q.CustomerID,
			Status:      status,
			OrderDate:   soDate,
			Subtotal:    q.Subtotal,
			Tax:         q.Tax,
			TotalAmount: q.Total,
			CreatedOn:   soDate,
			UpdatedOn:   soDate.AddDate(0, 0, rand.Intn(10)),
		}
		db.Create(&so)
		salesOrders = append(salesOrders, so)
		
		var qItems []models.QuotationItem
		db.Where("quotation_id = ?", q.ID).Find(&qItems)
		for _, qi := range qItems {
			db.Create(&models.SalesOrderItem{
				ID:           uuid.New().String(),
				SalesOrderID: so.ID,
				ProductID:    qi.ProductID,
				Quantity:     qi.Quantity,
				UnitPrice:    qi.UnitPrice,
				TotalPrice:   qi.TotalPrice,
			})
		}
	}

	// 6. Generate BOMs
	fmt.Println("Generating BOMs...")
	var boms []models.BOM
	for i := 0; i < 15; i++ {
		prod := products[rand.Intn(len(products))]
		createdOn := time.Now().AddDate(0, -rand.Intn(6), 0)
		bom := models.BOM{
			BaseModel:     models.BaseModel{ID: uuid.New(), TenantID: tenantID, CreatedOn: createdOn, UpdatedOn: createdOn},
			ProductID:     prod.ID.String(),
			VersionNumber: 1,
			ActiveVersion: true,
			Status:        "Active",
			TotalCost:     prod.BasePrice * 0.4,
		}
		db.Create(&bom)
		boms = append(boms, bom)
	}

	// 7. Generate Production Orders & Tracking
	fmt.Println("Generating Production Orders and Tracking...")
	var productionOrders []models.ProductionOrder
	stages := []string{"Cutting", "Assembly", "Finishing", "QA"}
	poStatuses := []string{"Released", "In Progress", "Completed", "Ready for Delivery"}
	
	limitPO := 10
	if len(salesOrders) < limitPO { limitPO = len(salesOrders) }

	for i := 0; i < limitPO; i++ {
		so := salesOrders[i]
		bom := boms[rand.Intn(len(boms))]
		poDate := so.OrderDate.AddDate(0, 0, 1+rand.Intn(3))
		status := poStatuses[rand.Intn(len(poStatuses))]
		
		var soItems []models.SalesOrderItem
		db.Where("sales_order_id = ?", so.ID).Find(&soItems)
		if len(soItems) == 0 { continue }
		
		plannedStart := poDate
		plannedEnd := poDate.AddDate(0, 0, 5+rand.Intn(14))
		
		po := models.ProductionOrder{
			BaseModel:          models.BaseModel{ID: uuid.New(), TenantID: tenantID, CreatedOn: poDate, UpdatedOn: poDate.AddDate(0, 0, rand.Intn(5))},
			SalesOrderID:       strPtr(so.ID),
			ProductID:          soItems[0].ProductID,
			BOMID:              bom.ID.String(),
			BOMVersion:         1,
			Quantity:           soItems[0].Quantity,
			Status:             status,
			PlannedStartDate:   &plannedStart,
			PlannedEndDate:     &plannedEnd,
		}
		db.Create(&po)
		productionOrders = append(productionOrders, po)

		// Create tracking
		tracking := models.ProductionTracking{
			BaseModel:            models.BaseModel{ID: uuid.New(), TenantID: tenantID, CreatedOn: poDate},
			ProductionOrderID:    po.ID,
			CurrentStage:         stages[rand.Intn(len(stages))],
			CompletionPercentage: rand.Intn(100),
			StageStartDate:       &poDate,
		}
		db.Create(&tracking)

		// Generate tracking history
		trackTime := poDate
		for j := 0; j < 4; j++ { 
			trackTime = trackTime.Add(time.Duration(rand.Intn(24)) * time.Hour)
			history := models.ProductionStageHistory{
				BaseModel:        models.BaseModel{ID: uuid.New(), TenantID: tenantID, CreatedOn: trackTime},
				TrackingID:       tracking.ID,
				Stage:            stages[j],
				StageEnteredAt:   trackTime,
				StageStartedAt:   &trackTime,
				StageCompletedAt: &trackTime,
			}
			db.Create(&history)
			if tracking.CurrentStage == stages[j] { break }
		}
	}

	// 8. Generate Deliveries
	fmt.Println("Generating Deliveries...")
	dlvStatuses := []string{"Scheduled", "In Transit", "Delivered"}
	
	limitDlv := 5
	if len(productionOrders) < limitDlv { limitDlv = len(productionOrders) }

	for i := 0; i < limitDlv; i++ {
		po := productionOrders[i]
		var so models.SalesOrder
		db.First(&so, "id = ?", *po.SalesOrderID)
		
		dlvDate := po.UpdatedOn.AddDate(0, 0, 1+rand.Intn(3))
		status := dlvStatuses[rand.Intn(len(dlvStatuses))]
		
		dlv := models.Delivery{
			BaseModel:              models.BaseModel{ID: uuid.New(), TenantID: tenantID, CreatedOn: dlvDate, UpdatedOn: dlvDate},
			DeliveryNumber:         fmt.Sprintf("DLV-%05d", 60000+i),
			SalesOrderID:           strPtr(so.ID),
			ProductionOrderID:      po.ID,
			CustomerID:             uuid.MustParse(so.CustomerID),
			Status:                 status,
			ExpectedDeliveryDate:   dlvDate.AddDate(0, 0, rand.Intn(7)),
		}
		if status == "Delivered" {
			realDlv := dlvDate.AddDate(0, 0, 1)
			dlv.DeliveryDate = &realDlv
			dlv.CustomerAcknowledgement = true
		}
		db.Create(&dlv)
	}

	fmt.Println("Demo Data Generation Complete!")
}

func strPtr(s string) *string {
	return &s
}
