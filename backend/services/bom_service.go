package services

import (
	"errors"
	"furniflow-backend/models"
	"furniflow-backend/repositories"

	"github.com/google/uuid"
)

type BOMService struct {
	repo        *repositories.BOMRepository
	productRepo *repositories.ProductRepository
}

func NewBOMService(repo *repositories.BOMRepository, productRepo *repositories.ProductRepository) *BOMService {
	return &BOMService{
		repo:        repo,
		productRepo: productRepo,
	}
}

func (s *BOMService) CreateBOM(req *models.CreateBOMRequest, tenantID string, userID *uuid.UUID, orgID *string) (*models.BOM, error) {
	// Calculate totals and format items
	var totalMaterialCost float64 = req.MaterialCost
	var items []models.BOMItem

	for _, reqItem := range req.Items {
		itemTotal := reqItem.Quantity * reqItem.UnitCost
		totalMaterialCost += itemTotal

		items = append(items, models.BOMItem{
			ComponentID: reqItem.ComponentID,
			Quantity:    reqItem.Quantity,
			UomID:       reqItem.UomID,
			UnitCost:    reqItem.UnitCost,
			TotalCost:   itemTotal,
		})
	}

	totalCost := totalMaterialCost + req.LaborCost + req.OverheadCost

	// Determine next version number
	versionNumber := 1
	existingBOMs, err := s.repo.GetByProductID(req.ProductID, tenantID)
	if err == nil && len(existingBOMs) > 0 {
		versionNumber = existingBOMs[0].VersionNumber + 1
	}

	bom := &models.BOM{
		BaseModel: models.BaseModel{
			TenantID:       tenantID,
			OrganizationID: orgID,
			CreatedBy:      userID,
			UpdatedBy:      userID,
			Remarks:        req.Remarks,
			IsActive:       true,
		},
		ProductID:     req.ProductID,
		VersionNumber: versionNumber,
		ActiveVersion: false, // Must be explicitly activated
		Status:        "Draft",
		MaterialCost:  totalMaterialCost,
		LaborCost:     req.LaborCost,
		OverheadCost:  req.OverheadCost,
		TotalCost:     totalCost,
		Items:         items,
	}

	err = s.repo.Create(bom)
	if err != nil {
		return nil, err
	}

	return s.repo.GetByID(bom.ID.String(), tenantID)
}

func (s *BOMService) GetBOMs(tenantID string) ([]models.BOM, error) {
	return s.repo.GetAll(tenantID)
}

func (s *BOMService) GetBOMByID(id string, tenantID string) (*models.BOM, error) {
	return s.repo.GetByID(id, tenantID)
}

func (s *BOMService) UpdateStatus(id string, tenantID string, status string) error {
	validStatuses := map[string]bool{"Draft": true, "Approved": true, "Active": true}
	if !validStatuses[status] {
		return errors.New("invalid status transition")
	}

	bom, err := s.repo.GetByID(id, tenantID)
	if err != nil {
		return err
	}

	// If transitioning to Active, must be Approved first, or direct from Draft based on business rules
	// And we must deactivate other versions for this product
	if status == "Active" {
		if bom.Status != "Approved" {
			return errors.New("bom must be approved before becoming active")
		}
		err = s.repo.SetActiveVersion(id, bom.ProductID, tenantID)
		if err != nil {
			return err
		}
	}

	return s.repo.UpdateStatus(id, tenantID, status)
}
