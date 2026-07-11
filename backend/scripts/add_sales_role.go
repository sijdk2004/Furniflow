package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
	"time"

	"github.com/google/uuid"
)

func main() {
	database, err := db.InitDB()
	if err != nil {
		panic(err)
	}

	tenantID := "SYSTEM_TENANT"

	// Create Role
	role := models.Role{
		BaseModel: models.BaseModel{
			ID:        uuid.New(),
			TenantID:  tenantID,
			IsActive:  true,
			CreatedOn: time.Now(),
		},
		RoleCode: "SALES_PERSON",
		RoleName: "Sales Person",
	}

	// Check if exists
	var existingRole models.Role
	err = database.Where("role_code = ?", role.RoleCode).First(&existingRole).Error
	if err == nil {
		fmt.Println("Role already exists!")
		role = existingRole
	} else {
		if err := database.Create(&role).Error; err != nil {
			panic(err)
		}
		fmt.Println("Created role:", role.RoleName)
	}

	// Fetch all permissions
	var allPerms []models.Permission
	database.Find(&allPerms)
	permMap := make(map[string]models.Permission)
	for _, p := range allPerms {
		permMap[p.PermissionCode] = p
	}

	// Permissions to assign (Real-world Sales Person)
	codesToAssign := []string{
		"DSH.SALES_DSH.VIEW",   // Access to sales dashboard
		"CUS.CUS_LIST.VIEW",    // Can view customers
		"CUS.CUS_LIST.CREATE",  // Can onboard new customers
		"CUS.CUS_LIST.UPDATE",  // Can update customer details
		"CAT.CAT_PROD.VIEW",    // Can view product catalog
		"CAT.CAT_CAT.VIEW",     // Can view categories
		"QTN.QTN_MGMT.VIEW",    // Can view quotations
		"QTN.QTN_MGMT.CREATE",  // Can create quotations
		"QTN.QTN_MGMT.UPDATE",  // Can edit draft quotations
		"SO.SO_LIST.VIEW",      // Can view sales orders
		"SO.SO_VIEW.VIEW",      // Can view sales order details
		"SO.SO_LIST.UPDATE",    // Can update order remarks/non-financial details
	}

	var rolePerms []models.Permission
	for _, code := range codesToAssign {
		if p, ok := permMap[code]; ok {
			rolePerms = append(rolePerms, p)
		} else {
			fmt.Println("Permission not found:", code)
		}
	}

	if len(rolePerms) > 0 {
		database.Exec("DELETE FROM role_permissions WHERE role_id = ?", role.ID)
		for _, p := range rolePerms {
			err = database.Exec("INSERT INTO role_permissions (tenant_id, role_id, permission_id) VALUES (?, ?, ?)",
				tenantID, role.ID, p.ID).Error
			if err != nil {
				panic(err)
			}
		}
		fmt.Println("Assigned", len(rolePerms), "permissions to Sales Person")
	} else {
		fmt.Println("No permissions assigned")
	}
}
