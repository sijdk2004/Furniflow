package main

import (
	"fmt"
	"furniflow-backend/db"
	"furniflow-backend/models"
)

func main() {
	dbConn, err := db.InitDB()
	if err != nil {
		fmt.Println("Error connecting to DB:", err)
		return
	}

	tenantID := "SYSTEM_TENANT"

	updates := []struct {
		Code        string
		DisplayName string
		Description string
	}{
		{"CAT.CAT_CAT.VIEW", "View Categories", "Allows user to view product categories."},
		{"CAT.CAT_CAT.CREATE", "Create Categories", "Allows user to create product categories."},
		{"CAT.CAT_CAT.UPDATE", "Edit Categories", "Allows user to modify product categories."},
		{"CAT.CAT_CAT.DELETE", "Delete Categories", "Allows user to delete product categories."},
		{"MFG.PRD.DELETE", "Delete Production Orders", "Allows user to delete production orders."},
	}

	for _, u := range updates {
		res := dbConn.Model(&models.Permission{}).
			Where("permission_code = ? AND tenant_id = ?", u.Code, tenantID).
			Updates(map[string]interface{}{
				"display_name": u.DisplayName,
				"description":  u.Description,
			})
		if res.Error != nil {
			fmt.Println("Error updating", u.Code, res.Error)
		} else {
			fmt.Printf("Updated %s: %d rows affected\n", u.Code, res.RowsAffected)
		}
	}
}
