package repositories

import (
	"furniflow-backend/models"
	"gorm.io/gorm"
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
	return r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.Product{}).Error
}
