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

	if entityType == "countries" {
		var countries []models.Country
		err := r.db.Where("tenant_id = ?", tenantID).Order("name ASC").Find(&countries).Error
		for _, c := range countries {
			records = append(records, models.MasterData{BaseModel: c.BaseModel, Type: "countries", Code: c.Code, Name: c.Name})
		}
		return records, err
	} else if entityType == "states" {
		var states []models.State
		err := r.db.Where("tenant_id = ?", tenantID).Order("name ASC").Find(&states).Error
		for _, s := range states {
			records = append(records, models.MasterData{BaseModel: s.BaseModel, Type: "states", Code: s.Code, Name: s.Name, Description: s.CountryID.String()})
		}
		return records, err
	} else if entityType == "cities" {
		var cities []models.City
		err := r.db.Where("tenant_id = ?", tenantID).Order("name ASC").Find(&cities).Error
		for _, c := range cities {
			records = append(records, models.MasterData{BaseModel: c.BaseModel, Type: "cities", Code: c.Code, Name: c.Name, Description: c.StateID.String()})
		}
		return records, err
	}

	err := r.db.Model(&models.MasterData{}).Where("type = ? AND tenant_id = ?", entityType, tenantID).Order("sort_order ASC, name ASC").Find(&records).Error
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
