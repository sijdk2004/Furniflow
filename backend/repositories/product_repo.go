package repositories

import (
	"errors"
	"furniflow-backend/models"
	"gorm.io/gorm"
	"strings"
)

type ProductRepository struct {
	db *gorm.DB
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{db: db}
}

func (r *ProductRepository) FindAll(tenantID string) ([]models.Product, error) {
	var records []models.Product
	err := r.db.Where("tenant_id = ?", tenantID).
		Preload("Category").
		Preload("WoodType").
		Preload("UOM").
		Order("product_name ASC").
		Find(&records).Error
	return records, err
}

func (r *ProductRepository) FindByID(id, tenantID string) (*models.Product, error) {
	var record models.Product
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Category").
		Preload("WoodType").
		Preload("UOM").
		First(&record).Error
	return &record, err
}

func (r *ProductRepository) Create(record *models.Product) error {
	return r.db.Create(record).Error
}

func (r *ProductRepository) Update(record *models.Product) error {
	return r.db.Save(record).Error
}

func (r *ProductRepository) Delete(id, tenantID string) error {
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.Product{}).Error
	if err != nil {
		if strings.Contains(err.Error(), "foreign key constraint") || strings.Contains(err.Error(), "SQLSTATE 23503") {
			return errors.New("cannot delete product because it is referenced by other records")
		}
		return err
	}
	return nil
}
