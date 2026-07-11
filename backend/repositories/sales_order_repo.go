package repositories

import (
	"errors"
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type SalesOrderRepository struct {
	db *gorm.DB
}

func NewSalesOrderRepository(db *gorm.DB) *SalesOrderRepository {
	return &SalesOrderRepository{db: db}
}

func (r *SalesOrderRepository) FindAll(tenantID string, isRestricted bool, userID string) ([]models.SalesOrder, error) {
	var orders []models.SalesOrder
	query := r.db.Preload("Customer").Where("tenant_id = ? AND is_active = ?", tenantID, true)
	if isRestricted {
		query = query.Where("created_by = ?", userID)
	}
	err := query.Order("created_on desc").Find(&orders).Error
	return orders, err
}

func (r *SalesOrderRepository) FindByID(id string, tenantID string, isRestricted bool, userID string) (*models.SalesOrder, error) {
	var order models.SalesOrder
	query := r.db.Preload("Customer").Preload("Items").Preload("Items.Product").Where("id = ? AND tenant_id = ? AND is_active = ?", id, tenantID, true)
	if isRestricted {
		query = query.Where("created_by = ?", userID)
	}
	err := query.First(&order).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("sales order not found")
		}
		return nil, err
	}
	return &order, nil
}

func (r *SalesOrderRepository) Update(order *models.SalesOrder) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// First delete existing items
		if err := tx.Where("sales_order_id = ?", order.ID).Delete(&models.SalesOrderItem{}).Error; err != nil {
			return err
		}
		
		// Then save order (which will save the new items)
		if err := tx.Save(order).Error; err != nil {
			return err
		}
		return nil
	})
}

func (r *SalesOrderRepository) UpdateStatus(id string, tenantID string, status string, isRestricted bool, userID string) error {
	query := r.db.Model(&models.SalesOrder{}).Where("id = ? AND tenant_id = ?", id, tenantID)
	if isRestricted {
		query = query.Where("created_by = ?", userID)
	}
	return query.Update("status", status).Error
}
