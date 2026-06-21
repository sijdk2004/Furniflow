package main

import (
	"time"
	
	"furniflow-backend/handlers"
	"furniflow-backend/middleware"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"furniflow-backend/services"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"furniflow-backend/db"
	zapLogger "furniflow-backend/logger"
	"go.uber.org/zap"
	"os"
)

func main() {
	zapLogger.InitLogger()
	defer zapLogger.Sync()

	app := fiber.New()
	app.Use(requestid.New())
	app.Use(logger.New(logger.Config{
		Format: "[${time}] ${locals:requestid} ${status} - ${latency} ${method} ${path}\n",
	}))
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, X-Tenant-ID, X-Organization-ID",
		AllowMethods: "GET, POST, PUT, DELETE, PATCH",
	}))

	// Connect Database via helper
	dbConn, err := db.InitDB()
	if err != nil {
		zapLogger.Log.Error("DB Connection Failed", zap.Error(err))
	}

	// Connection Pool Optimization
	sqlDB, sqlErr := dbConn.DB()
	if sqlErr == nil {
		sqlDB.SetMaxIdleConns(10)
		sqlDB.SetMaxOpenConns(100)
		sqlDB.SetConnMaxLifetime(time.Hour)
	}

	// Auto Migrate DB Models
	dbConn.AutoMigrate(
		&models.User{},
		&models.Role{},
		&models.Permission{},
		&models.Menu{},
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
		&models.BOM{},
		&models.BOMItem{},
		&models.ProductionOrder{},
		&models.ProductionTracking{},
		&models.Delivery{},
		&models.DeliveryTimelineHistory{},
		&models.AuditLog{},
		&models.RevokedToken{},
	)

	// Setup Dependencies
	roleRepo := repositories.NewRoleRepository(dbConn)
	userRepo := repositories.NewUserRepository(dbConn)
	menuRepo := repositories.NewMenuRepository(dbConn)
	masterRepo := repositories.NewMasterDataRepository(dbConn)
	customerRepo := repositories.NewCustomerRepository(dbConn)
	productRepo := repositories.NewProductRepository(dbConn)
	quotationRepo := repositories.NewQuotationRepository(dbConn)
	salesOrderRepo := repositories.NewSalesOrderRepository(dbConn)
	bomRepo := repositories.NewBOMRepository(dbConn)
	productionOrderRepo := repositories.NewProductionOrderRepository(dbConn)
	productionTrackingRepo := repositories.NewProductionTrackingRepository(dbConn)
	deliveryRepo := repositories.NewDeliveryRepository(dbConn)
	dashboardRepo := repositories.NewDashboardRepository(dbConn)
	salesDashboardRepo := repositories.NewSalesDashboardRepository(dbConn)
	mfgDashboardRepo := repositories.NewManufacturingDashboardRepository(dbConn)
	deliveryDashboardRepo := repositories.NewDeliveryDashboardRepository(dbConn)
	authService := services.NewAuthService(userRepo)
	masterService := services.NewMasterDataService(masterRepo)
	customerService := services.NewCustomerService(customerRepo)
	productService := services.NewProductService(productRepo)
	quotationService := services.NewQuotationService(quotationRepo)
	salesOrderService := services.NewSalesOrderService(salesOrderRepo)
	bomService := services.NewBOMService(bomRepo, productRepo)
	productionOrderService := services.NewProductionOrderService(productionOrderRepo, bomRepo)
	productionTrackingService := services.NewProductionTrackingService(productionTrackingRepo, productionOrderService)
	deliveryService := services.NewDeliveryService(deliveryRepo)
	dashboardService := services.NewDashboardService(dashboardRepo)
	salesDashboardService := services.NewSalesDashboardService(salesDashboardRepo)
	mfgDashboardService := services.NewManufacturingDashboardService(mfgDashboardRepo)
	deliveryDashboardService := services.NewDeliveryDashboardService(deliveryDashboardRepo)

	authHandler := handlers.NewAuthHandler(authService)
	usersHandler := handlers.NewUsersHandler(userRepo)
	rolesHandler := handlers.NewRolesHandler(roleRepo)
	menuHandler := handlers.NewMenuHandler(menuRepo)
	masterDataHandler := handlers.NewMasterDataHandler(masterService)
	customerHandler := handlers.NewCustomerHandler(customerService)
	productHandler := handlers.NewProductHandler(productService)
	quotationHandler := handlers.NewQuotationHandler(quotationService)
	salesOrderHandler := handlers.NewSalesOrderHandler(salesOrderService)
	bomHandler := handlers.NewBOMHandler(bomService)
	productionOrderHandler := handlers.NewProductionOrderHandler(productionOrderService)
	productionTrackingHandler := handlers.NewProductionTrackingHandler(productionTrackingService)
	deliveryHandler := handlers.NewDeliveryHandler(deliveryService)
	dashboardHandler := handlers.NewDashboardHandler(dashboardService)
	salesDashboardHandler := handlers.NewSalesDashboardHandler(salesDashboardService)
	mfgDashboardHandler := handlers.NewManufacturingDashboardHandler(mfgDashboardService)
	deliveryDashboardHandler := handlers.NewDeliveryDashboardHandler(deliveryDashboardService)
	uploadHandler := handlers.NewUploadHandler()

	// Static Files
	app.Static("/uploads", "./uploads")

	// API Routes
	api := app.Group("/v1")
	
	auth := api.Group("/auth")
	auth.Post("/login", authHandler.Login)
	auth.Post("/refresh", authHandler.Refresh)

	protectedAuth := api.Group("/auth", middleware.JWTProtected(string(services.JWTSecret)))
	protectedAuth.Get("/profile", authHandler.GetProfile)
	protectedAuth.Put("/profile", authHandler.UpdateProfile)
	protectedAuth.Post("/change-password", authHandler.ChangePassword)

	// Set JWT Secret for Auth Service
	jwtSecretEnv := os.Getenv("JWT_SECRET")
	if jwtSecretEnv != "" {
		services.JWTSecret = []byte(jwtSecretEnv)
	}

	// Protected Routes
	protected := api.Group("/system", middleware.JWTProtected(string(services.JWTSecret)))
	
	protected.Get("/dashboard/data", middleware.CheckPermission("DSH.DSH_HOME.VIEW"), dashboardHandler.GetDashboardData)
	protected.Get("/sales-dashboard/data", middleware.CheckPermission("DSH.DSH_HOME.VIEW"), salesDashboardHandler.GetSalesDashboardData)
	protected.Get("/sales_dashboard/data", middleware.CheckPermission("DSH.DSH_HOME.VIEW"), salesDashboardHandler.GetSalesDashboardData)
	protected.Get("/manufacturing-dashboard/data", middleware.CheckPermission("MFG.DSH.VIEW"), mfgDashboardHandler.GetManufacturingDashboardData)
	protected.Get("/delivery-dashboard/data", middleware.CheckPermission("DLV.DLV_LIST.VIEW"), deliveryDashboardHandler.GetDeliveryDashboardData)

	// Users CRUD
	users := protected.Group("/users")
	users.Get("/", middleware.CheckPermission("USR.USR_LIST.VIEW"), usersHandler.GetUsers)
	users.Post("/", middleware.CheckPermission("USR.USR_LIST.CREATE"), usersHandler.CreateUser)
	users.Get("/:id", middleware.CheckPermission("USR.USR_LIST.VIEW"), usersHandler.GetUser)
	users.Put("/:id", middleware.CheckPermission("USR.USR_LIST.UPDATE"), usersHandler.UpdateUser)
	users.Delete("/:id", middleware.CheckPermission("USR.USR_LIST.DELETE"), usersHandler.DeleteUser)

	// Roles CRUD
	roles := protected.Group("/roles")
	roles.Get("/", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetRoles)
	roles.Post("/", middleware.CheckPermission("ROL.ROL_LIST.CREATE"), rolesHandler.CreateRole)
	roles.Get("/permissions", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetAllPermissions)
	roles.Get("/:id", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetRole)
	roles.Put("/:id", middleware.CheckPermission("ROL.ROL_LIST.UPDATE"), rolesHandler.UpdateRole)
	roles.Delete("/:id", middleware.CheckPermission("ROL.ROL_LIST.DELETE"), rolesHandler.DeleteRole)
	roles.Get("/:id/permissions", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetRolePermissions)
	roles.Put("/:id/permissions", middleware.CheckPermission("ROL.ROL_LIST.UPDATE"), rolesHandler.UpdateRolePermissions)
	roles.Get("/:id/users", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetRoleUsers)
	roles.Put("/:id/users", middleware.CheckPermission("ROL.ROL_LIST.UPDATE"), rolesHandler.UpdateRoleUsers)
	roles.Get("/:id/audit-history", middleware.CheckPermission("ROL.ROL_LIST.VIEW"), rolesHandler.GetRoleAuditHistory)

	// Dynamic Menus
	protected.Get("/menus", menuHandler.GetMenus)

	// Master Data Generic CRUD
	masters := protected.Group("/masters")
	masters.Get("/:type", middleware.CheckPermission("SYS.MASTER_DATA.VIEW"), masterDataHandler.GetMasterData)
	masters.Post("/:type", middleware.CheckPermission("SYS.MASTER_DATA.CREATE"), masterDataHandler.CreateMasterData)
	masters.Put("/:type/:id", middleware.CheckPermission("SYS.MASTER_DATA.UPDATE"), masterDataHandler.UpdateMasterData)
	masters.Delete("/:type/:id", middleware.CheckPermission("SYS.MASTER_DATA.DELETE"), masterDataHandler.DeleteMasterData)

	// Customers CRUD
	customers := protected.Group("/customers")
	customers.Get("/", middleware.CheckPermission("CUS.CUS_LIST.VIEW"), customerHandler.GetCustomers)
	customers.Get("/:id", middleware.CheckPermission("CUS.CUS_LIST.VIEW"), customerHandler.GetCustomer)
	customers.Post("/", middleware.CheckPermission("CUS.CUS_LIST.CREATE"), customerHandler.CreateCustomer)
	customers.Put("/:id", middleware.CheckPermission("CUS.CUS_LIST.UPDATE"), customerHandler.UpdateCustomer)
	customers.Delete("/:id", middleware.CheckPermission("CUS.CUS_LIST.DELETE"), customerHandler.DeleteCustomer)

	// Products CRUD
	products := protected.Group("/products")
	products.Get("/", middleware.CheckPermission("CAT.CAT_PROD.VIEW"), productHandler.GetProducts)
	products.Get("/:id", middleware.CheckPermission("CAT.CAT_PROD.VIEW"), productHandler.GetProduct)
	products.Post("/", middleware.CheckPermission("CAT.CAT_PROD.CREATE"), productHandler.CreateProduct)
	products.Put("/:id", middleware.CheckPermission("CAT.CAT_PROD.UPDATE"), productHandler.UpdateProduct)
	products.Delete("/:id", middleware.CheckPermission("CAT.CAT_PROD.DELETE"), productHandler.DeleteProduct)

	// Quotations CRUD
	quotations := protected.Group("/quotations")
	quotations.Get("/", middleware.CheckPermission("QTN.QTN_MGMT.VIEW"), quotationHandler.GetQuotations)
	quotations.Get("/:id", middleware.CheckPermission("QTN.QTN_MGMT.VIEW"), quotationHandler.GetQuotation)
	quotations.Post("/", middleware.CheckPermission("QTN.QTN_MGMT.CREATE"), quotationHandler.CreateQuotation)
	quotations.Put("/:id", middleware.CheckPermission("QTN.QTN_MGMT.UPDATE"), quotationHandler.UpdateQuotation)
	quotations.Patch("/:id/status", middleware.CheckPermission("QTN.QTN_MGMT.UPDATE"), quotationHandler.UpdateQuotationStatus)
	quotations.Delete("/:id", middleware.CheckPermission("QTN.QTN_MGMT.DELETE"), quotationHandler.DeleteQuotation)

	// Sales Orders CRUD
	salesOrders := protected.Group("/sales-orders")
	salesOrders.Get("/", middleware.CheckPermission("SO.SO_LIST.VIEW"), salesOrderHandler.GetAll)
	salesOrders.Get("/:id", middleware.CheckPermission("SO.SO_VIEW.VIEW"), salesOrderHandler.GetByID)
	salesOrders.Put("/:id", middleware.CheckPermission("SO.SO_LIST.UPDATE"), salesOrderHandler.Update)
	salesOrders.Patch("/:id/status", middleware.CheckPermission("SO.SO_STATUS.UPDATE"), salesOrderHandler.UpdateStatus)

	// Manufacturing - BOM CRUD
	manufacturing := protected.Group("/manufacturing")
	boms := manufacturing.Group("/boms")
	boms.Get("/", middleware.CheckPermission("MFG.BOM.VIEW"), bomHandler.GetBOMs)
	boms.Post("/", middleware.CheckPermission("MFG.BOM.CREATE"), bomHandler.CreateBOM)
	boms.Get("/:id", middleware.CheckPermission("MFG.BOM.VIEW"), bomHandler.GetBOM)
	boms.Patch("/:id/status", middleware.CheckPermission("MFG.BOM.UPDATE"), bomHandler.UpdateStatus)

	prodOrders := manufacturing.Group("/production-orders")
	prodOrders.Get("/", middleware.CheckPermission("MFG.PRD.VIEW"), productionOrderHandler.GetProductionOrders)
	prodOrders.Post("/", middleware.CheckPermission("MFG.PRD.CREATE"), productionOrderHandler.CreateProductionOrder)
	prodOrders.Get("/:id", middleware.CheckPermission("MFG.PRD.VIEW"), productionOrderHandler.GetProductionOrderByID)
	prodOrders.Patch("/:id/status", middleware.CheckPermission("MFG.PRD.UPDATE"), productionOrderHandler.UpdateStatus)

	prodTracking := manufacturing.Group("/production-tracking")
	prodTracking.Get("/board", middleware.CheckPermission("MFG.TRK.VIEW_BOARD"), productionTrackingHandler.GetBoardItems)
	prodTracking.Post("/ensure/:orderId", middleware.CheckPermission("MFG.TRK.UPDATE"), productionTrackingHandler.EnsureTrackingExists)
	prodTracking.Get("/:id", middleware.CheckPermission("MFG.TRK.VIEW"), productionTrackingHandler.GetTrackingByID)
	prodTracking.Put("/:id/start", middleware.CheckPermission("MFG.TRK.UPDATE"), productionTrackingHandler.StartStage)
	prodTracking.Put("/:id/stage", middleware.CheckPermission("MFG.TRK.UPDATE"), productionTrackingHandler.UpdateStage)

	// Delivery CRUD
	delivery := protected.Group("/delivery")
	delivery.Get("/", middleware.CheckPermission("DLV.DLV_LIST.VIEW"), deliveryHandler.GetDeliveries)
	delivery.Post("/", middleware.CheckPermission("DLV.DLV_LIST.CREATE"), deliveryHandler.CreateDelivery)
	delivery.Get("/:id", middleware.CheckPermission("DLV.DLV_LIST.VIEW"), deliveryHandler.GetDeliveryByID)
	delivery.Put("/:id/status", middleware.CheckPermission("DLV.DLV_LIST.UPDATE"), deliveryHandler.UpdateDeliveryStatus)

	// Uploads
	uploads := protected.Group("/upload")
	uploads.Post("/image", uploadHandler.UploadImage)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}
	app.Listen(":" + port)
}
