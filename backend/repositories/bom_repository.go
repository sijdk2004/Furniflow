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
		// Deactivate all versions for this product
		if err := tx.Model(&models.BOM{}).
			Where("product_id = ? AND tenant_id = ?", productID, tenantID).
			Update("active_version", false).Error; err != nil {
			return err
		}
		// Activate the specified version
		if err := tx.Model(&models.BOM{}).
			Where("id = ? AND tenant_id = ?", id, tenantID).
			Update("active_version", true).Error; err != nil {
			return err
		}
		return nil
	})
}
