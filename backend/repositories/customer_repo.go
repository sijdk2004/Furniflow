package repositories

import (
	"errors"
	"furniflow-backend/models"
	"gorm.io/gorm"
	"strings"
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
		Order("name ASC").
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
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.Customer{}).Error
	if err != nil {
		if strings.Contains(err.Error(), "foreign key constraint") || strings.Contains(err.Error(), "SQLSTATE 23503") {
			return errors.New("cannot delete customer because it is referenced by other records (e.g., quotations or orders)")
		}
		return err
	}
	return nil
}

func (r *CustomerRepository) CreateCity(city *models.City) error {
	return r.db.Create(city).Error
}
