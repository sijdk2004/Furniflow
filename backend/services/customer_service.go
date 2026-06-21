package services

import (
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"furniflow-backend/validators"
	"github.com/google/uuid"
	"time"
)

type CustomerService struct {
	repo *repositories.CustomerRepository
}

func NewCustomerService(repo *repositories.CustomerRepository) *CustomerService {
	return &CustomerService{repo: repo}
}

func (s *CustomerService) GetAll(tenantID string) ([]models.Customer, error) {
	return s.repo.FindAll(tenantID)
}

func (s *CustomerService) GetByID(id, tenantID string) (*models.Customer, error) {
	return s.repo.FindByID(id, tenantID)
}

func (s *CustomerService) Create(tenantID, userID string, req dtos.CustomerRequest) (*models.Customer, error) {
	if err := validators.ValidateCustomerRequest(&req); err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)

	var custTypeID, countryID, stateID, cityID *uuid.UUID

	if req.CustomerTypeID != nil && *req.CustomerTypeID != "" {
		parsed, _ := uuid.Parse(*req.CustomerTypeID)
		custTypeID = &parsed
	}
	if req.CountryID != nil && *req.CountryID != "" {
		parsed, _ := uuid.Parse(*req.CountryID)
		countryID = &parsed
	}
	if req.StateID != nil && *req.StateID != "" {
		parsed, _ := uuid.Parse(*req.StateID)
		stateID = &parsed
	}
	if req.CityID != nil && *req.CityID != "" {
		parsed, _ := uuid.Parse(*req.CityID)
		cityID = &parsed
	}

	record := &models.Customer{
		BaseModel: models.BaseModel{
			TenantID:  tenantID,
			IsActive:  req.IsActive,
			CreatedBy: &uid,
			CreatedOn: time.Now(),
		},
		Name:           req.Name,
		Email:          req.Email,
		Phone:          req.Phone,
		AddressLine1:   req.AddressLine1,
		AddressLine2:   req.AddressLine2,
		ZipCode:        req.ZipCode,
		TaxID:          req.TaxID,
		CreditLimit:    req.CreditLimit,
		CustomerTypeID: custTypeID,
		CountryID:      countryID,
		StateID:        stateID,
		CityID:         cityID,
	}

	err := s.repo.Create(record)
	return record, err
}

func (s *CustomerService) Update(id, tenantID, userID string, req dtos.CustomerRequest) (*models.Customer, error) {
	if err := validators.ValidateCustomerRequest(&req); err != nil {
		return nil, err
	}

	record, err := s.repo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}

	uid, _ := uuid.Parse(userID)

	var custTypeID, countryID, stateID, cityID *uuid.UUID

	if req.CustomerTypeID != nil && *req.CustomerTypeID != "" {
		parsed, _ := uuid.Parse(*req.CustomerTypeID)
		custTypeID = &parsed
	}
	if req.CountryID != nil && *req.CountryID != "" {
		parsed, _ := uuid.Parse(*req.CountryID)
		countryID = &parsed
	}
	if req.StateID != nil && *req.StateID != "" {
		parsed, _ := uuid.Parse(*req.StateID)
		stateID = &parsed
	}
	if req.CityID != nil && *req.CityID != "" {
		parsed, _ := uuid.Parse(*req.CityID)
		cityID = &parsed
	}

	record.Name = req.Name
	record.Email = req.Email
	record.Phone = req.Phone
	record.AddressLine1 = req.AddressLine1
	record.AddressLine2 = req.AddressLine2
	record.ZipCode = req.ZipCode
	record.TaxID = req.TaxID
	record.CreditLimit = req.CreditLimit
	record.CustomerTypeID = custTypeID
	record.CountryID = countryID
	record.StateID = stateID
	record.CityID = cityID
	record.IsActive = req.IsActive
	record.UpdatedBy = &uid
	record.UpdatedOn = time.Now()

	err = s.repo.Update(record)
	return record, err
}

func (s *CustomerService) Delete(id, tenantID string) error {
	return s.repo.Delete(id, tenantID)
}
