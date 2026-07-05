package repositories

import (
	"furniflow-backend/models"

	"gorm.io/gorm"
)

type BOMRepository struct {
	db *gorm.DB
}

func NewBOMRepository(db *gorm.DB) *BOMRepository {
	return &BOMRepository{db: db}
}

func (r *BOMRepository) Create(bom *models.BOM) error {
	return r.db.Create(bom).Error
}

func (r *BOMRepository) GetByID(id string, tenantID string) (*models.BOM, error) {
	var bom models.BOM
	err := r.db.Preload("Items.Component").
		Preload("Items.Uom").
		Preload("Product").
		Where("id = ? AND tenant_id = ?", id, tenantID).
		First(&bom).Error
	if err != nil {
		return nil, err
	}
	return &bom, nil
}

func (r *BOMRepository) GetAll(tenantID string) ([]models.BOM, error) {
	var boms []models.BOM
	err := r.db.Preload("Product").
		Where("tenant_id = ?", tenantID).
		Order("created_on desc").
		Find(&boms).Error
	return boms, err
}

func (r *BOMRepository) GetByProductID(productID string, tenantID string) ([]models.BOM, error) {
	var boms []models.BOM
	err := r.db.Preload("Product").
		Where("product_id = ? AND tenant_id = ?", productID, tenantID).
		Order("version_number desc").
		Find(&boms).Error
	return boms, err
}

func (r *BOMRepository) GetActiveBOMByProduct(productID string, tenantID string) (*models.BOM, error) {
	var bom models.BOM
	err := r.db.Preload("Items.Component").
		Preload("Items.Uom").
		Preload("Product").
		Where("product_id = ? AND tenant_id = ? AND active_version = ? AND status = ?", productID, tenantID, true, "Active").
		First(&bom).Error
	if err != nil {
		return nil, err
	}
	return &bom, nil
}

func (r *BOMRepository) UpdateStatus(id string, tenantID string, status string) error {
	return r.db.Model(&models.BOM{}).
		Where("id = ? AND tenant_id = ?", id, tenantID).
		Update("status", status).Error
}

func (r *BOMRepository) SetActiveVersion(id string, productID string, tenantID string) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// Deactivate and archive all versions for this product
		if err := tx.Model(&models.BOM{}).
			Where("product_id = ? AND tenant_id = ?", productID, tenantID).
			Updates(map[string]interface{}{
				"active_version": false,
				"status":         "Archived",
			}).Error; err != nil {
			return err
		}
		// Activate the specified version
		if err := tx.Model(&models.BOM{}).
			Where("id = ? AND tenant_id = ?", id, tenantID).
			Updates(map[string]interface{}{
				"active_version": true,
				"status":         "Active",
			}).Error; err != nil {
			return err
		}
		return nil
	})
}

func (r *BOMRepository) Revise(bomID string, tenantID string) (*models.BOM, error) {
	var newBOM *models.BOM

	err := r.db.Transaction(func(tx *gorm.DB) error {
		// 1. Fetch original BOM
		var originalBOM models.BOM
		if err := tx.Preload("Items").Where("id = ? AND tenant_id = ?", bomID, tenantID).First(&originalBOM).Error; err != nil {
			return err
		}

		// 2. Find highest version number for this product
		var highestVersion int
		tx.Model(&models.BOM{}).Where("product_id = ? AND tenant_id = ?", originalBOM.ProductID, tenantID).Select("COALESCE(MAX(version_number), 0)").Row().Scan(&highestVersion)

		// 3. Create new BOM
		newBOM = &models.BOM{
			ProductID:     originalBOM.ProductID,
			VersionNumber: highestVersion + 1,
			ActiveVersion: false,
			Status:        "Draft",
			MaterialCost:  originalBOM.MaterialCost,
			LaborCost:     originalBOM.LaborCost,
			OverheadCost:  originalBOM.OverheadCost,
			TotalCost:     originalBOM.TotalCost,
			BaseModel: models.BaseModel{
				TenantID: tenantID,
			},
		}

		if err := tx.Create(newBOM).Error; err != nil {
			return err
		}

		// 4. Duplicate items
		for _, item := range originalBOM.Items {
			newItem := models.BOMItem{
				BOMID:       newBOM.ID.String(),
				ComponentID: item.ComponentID,
				Quantity:    item.Quantity,
				UomID:       item.UomID,
				UnitCost:    item.UnitCost,
				TotalCost:   item.TotalCost,
			}
			if err := tx.Create(&newItem).Error; err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	return r.GetByID(newBOM.ID.String(), tenantID)
}
