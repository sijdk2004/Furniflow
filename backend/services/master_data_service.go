package services

import (
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"furniflow-backend/validators"
	"github.com/google/uuid"
	"time"
)

type MasterDataService struct {
	repo *repositories.MasterDataRepository
}

func NewMasterDataService(repo *repositories.MasterDataRepository) *MasterDataService {
	return &MasterDataService{repo: repo}
}

func (s *MasterDataService) GetAll(entityType, tenantID string) ([]models.MasterData, error) {
	return s.repo.FindAll(entityType, tenantID)
}

func (s *MasterDataService) Create(entityType, tenantID, userID string, req dtos.MasterDataRequest) (*models.MasterData, error) {


	if err := validators.ValidateMasterDataRequest(&req); err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)
	
	record := &models.MasterData{
		BaseModel: models.BaseModel{
			TenantID:  tenantID,
			IsActive:  req.IsActive,
			CreatedBy: &uid,
			CreatedOn: time.Now(),
		},
		Code:        req.Code,
		Name:        req.Name,
		Description: req.Description,
		SortOrder:   req.SortOrder,
	}

	err := s.repo.Create(entityType, record)
	return record, err
}

func (s *MasterDataService) Update(entityType, id, tenantID, userID string, req dtos.MasterDataRequest) (*models.MasterData, error) {


	if err := validators.ValidateMasterDataRequest(&req); err != nil {
		return nil, err
	}

	record, err := s.repo.FindByID(entityType, id, tenantID)
	if err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)

	record.Code = req.Code
	record.Name = req.Name
	record.Description = req.Description
	record.SortOrder = req.SortOrder
	record.IsActive = req.IsActive
	record.UpdatedBy = &uid
	record.UpdatedOn = time.Now()

	err = s.repo.Update(entityType, record)
	return record, err
}

func (s *MasterDataService) Delete(entityType, id, tenantID string) error {

	return s.repo.Delete(entityType, id, tenantID)
}


