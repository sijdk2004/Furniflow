package repositories

import (
	"furniflow-backend/models"

	"gorm.io/gorm"
)

type ProductionOrderRepository struct {
	db *gorm.DB
}

func NewProductionOrderRepository(db *gorm.DB) *ProductionOrderRepository {
	return &ProductionOrderRepository{db: db}
}

func (r *ProductionOrderRepository) Create(order *models.ProductionOrder) error {
	return r.db.Create(order).Error
}

func (r *ProductionOrderRepository) GetByID(id string, tenantID string) (*models.ProductionOrder, error) {
	var order models.ProductionOrder
	err := r.db.Preload("Product").
		Where("id = ? AND tenant_id = ?", id, tenantID).
		First(&order).Error
	if err != nil {
		return nil, err
	}
	return &order, nil
}

func (r *ProductionOrderRepository) GetAll(tenantID string, status string) ([]models.ProductionOrder, error) {
	var orders []models.ProductionOrder
	query := r.db.Preload("Product").Where("tenant_id = ?", tenantID)
	if status != "" {
		query = query.Where("status = ?", status)
	}
	err := query.Order("created_on desc").Find(&orders).Error
	return orders, err
}

func (r *ProductionOrderRepository) UpdateStatus(id string, tenantID string, status string) error {
	return r.db.Model(&models.ProductionOrder{}).
		Where("id = ? AND tenant_id = ?", id, tenantID).
		Update("status", status).Error
}
