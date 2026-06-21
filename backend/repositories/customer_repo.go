package repositories

import (
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type CustomerRepository struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) *CustomerRepository {
	return &CustomerRepository{db: db}
}

func (r *CustomerRepository) FindAll(tenantID string) ([]models.Customer, error) {
	var records []models.Customer
	err := r.db.Where("tenant_id = ?", tenantID).
		Preload("CustomerType").
		Preload("Country").
		Preload("State").
		Preload("City").
		Find(&records).Error
	return records, err
}

func (r *CustomerRepository) FindByID(id, tenantID string) (*models.Customer, error) {
	var record models.Customer
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("CustomerType").
		Preload("Country").
		Preload("State").
		Preload("City").
		First(&record).Error
	return &record, err
}

func (r *CustomerRepository) Create(record *models.Customer) error {
	return r.db.Create(record).Error
}

func (r *CustomerRepository) Update(record *models.Customer) error {
	return r.db.Save(record).Error
}

func (r *CustomerRepository) Delete(id, tenantID string) error {
	return r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.Customer{}).Error
}
