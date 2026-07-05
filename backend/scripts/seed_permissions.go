package main

import (
	"fmt"
	"furniflow-backend/models"

	"github.com/google/uuid"
	dbPkg "furniflow-backend/db"
)

func main() {
	db, err := dbPkg.InitDB()
	if err != nil {
		panic("failed to connect database")
	}

	tenantID := "SYSTEM_TENANT"

	permissionsData := []struct {
		Code        string
		Module      string
		Screen      string
		Action      string
		DisplayName string
		Description string
	}{
		{"DSH.DSH_HOME.VIEW", "DSH", "DSH_HOME", "VIEW", "View Executive Dashboard", "Allows user to view the executive dashboard."},
		{"MFG.DSH.VIEW", "MFG", "DSH", "VIEW", "View Manufacturing Dashboard", "Allows user to view the manufacturing dashboard."},
		{"USR.USR_LIST.VIEW", "USR", "USR_LIST", "VIEW", "View Users", "Allows user to view user records."},
		{"USR.USR_LIST.CREATE", "USR", "USR_LIST", "CREATE", "Create Users", "Allows user to create user records."},
		{"USR.USR_LIST.UPDATE", "USR", "USR_LIST", "UPDATE", "Edit Users", "Allows user to modify user records."},
		{"USR.USR_LIST.DELETE", "USR", "USR_LIST", "DELETE", "Delete Users", "Allows user to delete user records."},
		{"ROL.ROL_LIST.VIEW", "ROL", "ROL_LIST", "VIEW", "View Roles", "Allows user to view roles and permissions."},
		{"ROL.ROL_LIST.CREATE", "ROL", "ROL_LIST", "CREATE", "Create Roles", "Allows user to create new roles."},
		{"ROL.ROL_LIST.UPDATE", "ROL", "ROL_LIST", "UPDATE", "Edit Roles", "Allows user to modify role permissions."},
		{"ROL.ROL_LIST.DELETE", "ROL", "ROL_LIST", "DELETE", "Delete Roles", "Allows user to delete roles."},
		{"SYS.MASTER_DATA.VIEW", "SYS", "MASTER_DATA", "VIEW", "View Master Data", "Allows user to view master data."},
		{"SYS.MASTER_DATA.CREATE", "SYS", "MASTER_DATA", "CREATE", "Create Master Data", "Allows user to create master data."},
		{"SYS.MASTER_DATA.UPDATE", "SYS", "MASTER_DATA", "UPDATE", "Edit Master Data", "Allows user to update master data."},
		{"SYS.MASTER_DATA.DELETE", "SYS", "MASTER_DATA", "DELETE", "Delete Master Data", "Allows user to delete master data."},
		{"CUS.CUS_LIST.VIEW", "CUS", "CUS_LIST", "VIEW", "View Customers", "Allows user to view customer records."},
		{"CUS.CUS_LIST.CREATE", "CUS", "CUS_LIST", "CREATE", "Create Customers", "Allows user to create customer records."},
		{"CUS.CUS_LIST.UPDATE", "CUS", "CUS_LIST", "UPDATE", "Edit Customers", "Allows user to modify customer records."},
		{"CUS.CUS_LIST.DELETE", "CUS", "CUS_LIST", "DELETE", "Delete Customers", "Allows user to delete customer records."},
		{"CAT.CAT_PROD.VIEW", "CAT", "CAT_PROD", "VIEW", "View Catalog", "Allows user to view product catalog."},
		{"CAT.CAT_PROD.CREATE", "CAT", "CAT_PROD", "CREATE", "Create Products", "Allows user to create products."},
		{"CAT.CAT_PROD.UPDATE", "CAT", "CAT_PROD", "UPDATE", "Edit Products", "Allows user to modify products."},
		{"CAT.CAT_PROD.DELETE", "CAT", "CAT_PROD", "DELETE", "Delete Products", "Allows user to delete products."},
		{"QTN.QTN_MGMT.VIEW", "QTN", "QTN_MGMT", "VIEW", "View Quotations", "Allows user to view quotations."},
		{"QTN.QTN_MGMT.CREATE", "QTN", "QTN_MGMT", "CREATE", "Create Quotations", "Allows user to create quotations."},
		{"QTN.QTN_MGMT.UPDATE", "QTN", "QTN_MGMT", "UPDATE", "Edit Quotations", "Allows user to modify quotations."},
		{"QTN.QTN_MGMT.DELETE", "QTN", "QTN_MGMT", "DELETE", "Delete Quotations", "Allows user to delete quotations."},
		{"SO.SO_LIST.VIEW", "SO", "SO_LIST", "VIEW", "View Sales Orders", "Allows user to view sales orders."},
		{"SO.SO_LIST.UPDATE", "SO", "SO_LIST", "UPDATE", "Edit Sales Orders", "Allows user to modify sales orders."},
		{"SO.SO_VIEW.VIEW", "SO", "SO_VIEW", "VIEW", "View Order Details", "Allows user to view sales order details."},
		{"SO.SO_STATUS.UPDATE", "SO", "SO_STATUS", "UPDATE", "Update Order Status", "Allows user to update sales order status."},
		{"MFG.BOM.VIEW", "MFG", "BOM", "VIEW", "View BOM", "Allows user to view Bill of Materials."},
		{"MFG.BOM.CREATE", "MFG", "BOM", "CREATE", "Create BOM", "Allows user to create Bill of Materials."},
		{"MFG.BOM.UPDATE", "MFG", "BOM", "UPDATE", "Edit BOM", "Allows user to modify Bill of Materials."},
		{"MFG.PRD.VIEW", "MFG", "PRD", "VIEW", "View Production Orders", "Allows user to view production orders."},
		{"MFG.PRD.CREATE", "MFG", "PRD", "CREATE", "Create Production Orders", "Allows user to create production orders."},
		{"MFG.PRD.UPDATE", "MFG", "PRD", "UPDATE", "Edit Production Orders", "Allows user to update production orders."},
		{"MFG.TRK.VIEW_BOARD", "MFG", "TRK", "VIEW_BOARD", "View Production Board", "Allows user to view the production Kanban board."},
		{"MFG.TRK.VIEW", "MFG", "TRK", "VIEW", "View Production Tracking", "Allows user to view production tracking details."},
		{"MFG.TRK.UPDATE", "MFG", "TRK", "UPDATE", "Update Production Tracking", "Allows user to start and complete production stages."},
		{"DLV.DLV_LIST.VIEW", "DLV", "DLV_LIST", "VIEW", "View Deliveries", "Allows user to view delivery management."},
		{"DLV.DLV_LIST.CREATE", "DLV", "DLV_LIST", "CREATE", "Create Deliveries", "Allows user to create delivery schedules."},
		{"DLV.DLV_LIST.UPDATE", "DLV", "DLV_LIST", "UPDATE", "Update Delivery Status", "Allows user to update delivery status."},
	}

	for _, p := range permissionsData {
		db.Exec(`
			INSERT INTO permissions (id, tenant_id, permission_code, module_code, screen_code, action_type, display_name, description, is_active, created_on, updated_on)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, true, NOW(), NOW())
			ON CONFLICT (permission_code) DO UPDATE SET 
				display_name = EXCLUDED.display_name,
				description = EXCLUDED.description
		`, uuid.New(), tenantID, p.Code, p.Module, p.Screen, p.Action, p.DisplayName, p.Description)
	}

	roleMappings := map[string][]string{
		"PLATFORM_ADMIN": {
			"DSH.DSH_HOME.VIEW", "MFG.DSH.VIEW", "DLV.DLV_LIST.VIEW",
			"USR.USR_LIST.VIEW", "USR.USR_LIST.CREATE", "USR.USR_LIST.UPDATE", "USR.USR_LIST.DELETE",
			"ROL.ROL_LIST.VIEW", "ROL.ROL_LIST.CREATE", "ROL.ROL_LIST.UPDATE", "ROL.ROL_LIST.DELETE",
			"SYS.MASTER_DATA.VIEW", "SYS.MASTER_DATA.CREATE", "SYS.MASTER_DATA.UPDATE", "SYS.MASTER_DATA.DELETE",
			"CUS.CUS_LIST.VIEW", "CUS.CUS_LIST.CREATE", "CUS.CUS_LIST.UPDATE", "CUS.CUS_LIST.DELETE",
			"CAT.CAT_PROD.VIEW", "CAT.CAT_PROD.CREATE", "CAT.CAT_PROD.UPDATE", "CAT.CAT_PROD.DELETE",
			"QTN.QTN_MGMT.VIEW", "QTN.QTN_MGMT.CREATE", "QTN.QTN_MGMT.UPDATE", "QTN.QTN_MGMT.DELETE",
			"SO.SO_LIST.VIEW", "SO.SO_LIST.UPDATE", "SO.SO_VIEW.VIEW", "SO.SO_STATUS.UPDATE",
			"MFG.BOM.VIEW", "MFG.BOM.CREATE", "MFG.BOM.UPDATE",
			"MFG.PRD.VIEW", "MFG.PRD.CREATE", "MFG.PRD.UPDATE",
			"MFG.TRK.VIEW_BOARD", "MFG.TRK.VIEW", "MFG.TRK.UPDATE",
			"DLV.DLV_LIST.VIEW", "DLV.DLV_LIST.CREATE", "DLV.DLV_LIST.UPDATE",
		},
		"SALES_MANAGER": {
			"DSH.DSH_HOME.VIEW",
			"CUS.CUS_LIST.VIEW", "CUS.CUS_LIST.CREATE", "CUS.CUS_LIST.UPDATE",
			"CAT.CAT_PROD.VIEW",
			"QTN.QTN_MGMT.VIEW", "QTN.QTN_MGMT.CREATE", "QTN.QTN_MGMT.UPDATE",
			"SO.SO_LIST.VIEW", "SO.SO_LIST.UPDATE", "SO.SO_VIEW.VIEW", "SO.SO_STATUS.UPDATE",
		},
		"PRODUCTION_MANAGER": {
			"MFG.DSH.VIEW",
			"MFG.BOM.VIEW", "MFG.BOM.CREATE", "MFG.BOM.UPDATE",
			"MFG.PRD.VIEW", "MFG.PRD.CREATE", "MFG.PRD.UPDATE",
			"MFG.TRK.VIEW_BOARD", "MFG.TRK.VIEW", "MFG.TRK.UPDATE",
			"CAT.CAT_PROD.VIEW",
		},
		"DELIVERY_MANAGER": {
			"DLV.DLV_LIST.VIEW", "DLV.DLV_LIST.CREATE", "DLV.DLV_LIST.UPDATE",
			"SO.SO_LIST.VIEW", "SO.SO_VIEW.VIEW",
		},
	}

	for roleCode, perms := range roleMappings {
		var role models.Role
		if err := db.Where("role_code = ?", roleCode).First(&role).Error; err == nil {
			var dbPerms []models.Permission
			db.Where("permission_code IN ?", perms).Find(&dbPerms)
			
			for _, p := range dbPerms {
				db.Exec(`
					INSERT INTO role_permissions (role_id, permission_id, tenant_id) 
					VALUES (?, ?, ?) 
					ON CONFLICT DO NOTHING
				`, role.ID, p.ID, tenantID)
			}
		}
	}

	fmt.Println("Role Permissions seeded via raw SQL successfully!")
}
