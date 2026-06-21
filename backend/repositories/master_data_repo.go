package repositories

import (
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type MasterDataRepository struct {
	db *gorm.DB
}

func NewMasterDataRepository(db *gorm.DB) *MasterDataRepository {
	return &MasterDataRepository{db: db}
}

func (r *MasterDataRepository) FindAll(entityType, tenantID string) ([]models.MasterData, error) {
	var records []models.MasterData
	err := r.db.Model(&models.MasterData{}).Where("type = ? AND tenant_id = ?", entityType, tenantID).Order("sort_order ASC").Find(&records).Error
	return records, err
}

func (r *MasterDataRepository) FindByID(entityType, id, tenantID string) (*models.MasterData, error) {
	var record models.MasterData
	err := r.db.Model(&models.MasterData{}).Where("type = ? AND id = ? AND tenant_id = ?", entityType, id, tenantID).First(&record).Error
	return &record, err
}

func (r *MasterDataRepository) Create(entityType string, record *models.MasterData) error {
	record.Type = entityType
	return r.db.Create(record).Error
}

func (r *MasterDataRepository) Update(entityType string, record *models.MasterData) error {
	record.Type = entityType
	return r.db.Save(record).Error
}

func (r *MasterDataRepository) Delete(entityType, id, tenantID string) error {
	return r.db.Model(&models.MasterData{}).Where("type = ? AND id = ? AND tenant_id = ?", entityType, id, tenantID).Delete(&models.MasterData{}).Error
}
