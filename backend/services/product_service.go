package services

import (
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"furniflow-backend/validators"
	"github.com/google/uuid"
	"time"
)

type ProductService struct {
	repo *repositories.ProductRepository
}

func NewProductService(repo *repositories.ProductRepository) *ProductService {
	return &ProductService{repo: repo}
}

func (s *ProductService) GetAll(tenantID string) ([]models.Product, error) {
	return s.repo.FindAll(tenantID)
}

func (s *ProductService) GetByID(id, tenantID string) (*models.Product, error) {
	return s.repo.FindByID(id, tenantID)
}

func (s *ProductService) Create(tenantID, userID string, req dtos.ProductRequest) (*models.Product, error) {
	if err := validators.ValidateProductRequest(&req); err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)

	var catID, woodID, uomID *uuid.UUID

	if req.CategoryID != nil && *req.CategoryID != "" {
		parsed, _ := uuid.Parse(*req.CategoryID)
		catID = &parsed
	}
	if req.WoodTypeID != nil && *req.WoodTypeID != "" {
		parsed, _ := uuid.Parse(*req.WoodTypeID)
		woodID = &parsed
	}
	if req.UOMID != nil && *req.UOMID != "" {
		parsed, _ := uuid.Parse(*req.UOMID)
		uomID = &parsed
	}

	record := &models.Product{
		BaseModel: models.BaseModel{
			TenantID:  tenantID,
			IsActive:  req.IsActive,
			CreatedBy: &uid,
			CreatedOn: time.Now(),
		},
		ProductCode: req.ProductCode,
		ProductName: req.ProductName,
		CategoryID:  catID,
		WoodTypeID:  woodID,
		UOMID:       uomID,
		BasePrice:   req.BasePrice,
		Description: req.Description,
		ImageURL:    req.ImageURL,
	}

	err := s.repo.Create(record)
	return record, err
}

func (s *ProductService) Update(id, tenantID, userID string, req dtos.ProductRequest) (*models.Product, error) {
	if err := validators.ValidateProductRequest(&req); err != nil {
		return nil, err
	}

	record, err := s.repo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)

	var catID, woodID, uomID *uuid.UUID

	if req.CategoryID != nil && *req.CategoryID != "" {
		parsed, _ := uuid.Parse(*req.CategoryID)
		catID = &parsed
	}
	if req.WoodTypeID != nil && *req.WoodTypeID != "" {
		parsed, _ := uuid.Parse(*req.WoodTypeID)
		woodID = &parsed
	}
	if req.UOMID != nil && *req.UOMID != "" {
		parsed, _ := uuid.Parse(*req.UOMID)
		uomID = &parsed
	}

	record.ProductCode = req.ProductCode
	record.ProductName = req.ProductName
	record.CategoryID = catID
	record.WoodTypeID = woodID
	record.UOMID = uomID
	record.BasePrice = req.BasePrice
	record.Description = req.Description
	record.ImageURL = req.ImageURL
	record.IsActive = req.IsActive
	record.UpdatedBy = &uid
	record.UpdatedOn = time.Now()

	err = s.repo.Update(record)
	return record, err
}

func (s *ProductService) Delete(id, tenantID string) error {
	return s.repo.Delete(id, tenantID)
}
