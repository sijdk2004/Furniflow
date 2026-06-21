package repositories

import (
	"errors"
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type QuotationRepository struct {
	db *gorm.DB
}

func NewQuotationRepository(db *gorm.DB) *QuotationRepository {
	return &QuotationRepository{db: db}
}

func (r *QuotationRepository) Create(quotation *models.Quotation) error {
	return r.db.Create(quotation).Error
}

func (r *QuotationRepository) FindAll(tenantID string) ([]models.Quotation, error) {
	var quotations []models.Quotation
	err := r.db.Preload("Customer").Where("tenant_id = ? AND is_active = ?", tenantID, true).Order("date_created DESC").Find(&quotations).Error
	return quotations, err
}

func (r *QuotationRepository) FindByID(id, tenantID string) (*models.Quotation, error) {
	var quotation models.Quotation
	err := r.db.Preload("Customer").Preload("Items.Product").Where("id = ? AND tenant_id = ? AND is_active = ?", id, tenantID, true).First(&quotation).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("quotation not found")
		}
		return nil, err
	}
	return &quotation, nil
}

func (r *QuotationRepository) Update(quotation *models.Quotation) error {
	// First delete all existing items
	if err := r.db.Where("quotation_id = ?", quotation.ID).Delete(&models.QuotationItem{}).Error; err != nil {
		return err
	}
	// Then save the quotation (which will recreate items)
	return r.db.Save(quotation).Error
}

func (r *QuotationRepository) UpdateStatus(id, tenantID, status string) error {
	return r.db.Model(&models.Quotation{}).Where("id = ? AND tenant_id = ?", id, tenantID).Update("status", status).Error
}

func (r *QuotationRepository) Delete(id, tenantID string) error {
	return r.db.Model(&models.Quotation{}).Where("id = ? AND tenant_id = ?", id, tenantID).Update("is_active", false).Error
}

func (r *QuotationRepository) CreateSalesOrder(so *models.SalesOrder) error {
	return r.db.Create(so).Error
}
