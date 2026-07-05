package services

import (
	"errors"
	"furniflow-backend/models"
	"furniflow-backend/repositories"

	"github.com/google/uuid"
)

type ProductionOrderService struct {
	repo        *repositories.ProductionOrderRepository
	bomRepo     *repositories.BOMRepository
}

func NewProductionOrderService(repo *repositories.ProductionOrderRepository, bomRepo *repositories.BOMRepository) *ProductionOrderService {
	return &ProductionOrderService{
		repo:    repo,
		bomRepo: bomRepo,
	}
}

func (s *ProductionOrderService) CreateProductionOrder(req *models.CreateProductionOrderRequest, tenantID string, userID *uuid.UUID, orgID *string) (*models.ProductionOrder, error) {
	// Find Active BOM for Product
	activeBOM, err := s.bomRepo.GetActiveBOMByProduct(req.ProductID, tenantID)
	if err != nil {
		return nil, errors.New("no active BOM found for this product. A product must have an active BOM version to be manufactured")
	}

	// Calculate costs based on BOM snapshot and quantity
	qty := float64(req.Quantity)
	materialCost := activeBOM.MaterialCost * qty
	laborCost := activeBOM.LaborCost * qty
	overheadCost := activeBOM.OverheadCost * qty
	totalCost := activeBOM.TotalCost * qty

	order := &models.ProductionOrder{
		BaseModel: models.BaseModel{
			TenantID:       tenantID,
			OrganizationID: orgID,
			CreatedBy:      userID,
			UpdatedBy:      userID,
			Remarks:        req.Remarks,
			IsActive:       true,
		},
		SalesOrderID:     req.SalesOrderID,
		ProductID:        req.ProductID,
		BOMID:            activeBOM.ID.String(),
		BOMVersion:       activeBOM.VersionNumber,
		Quantity:         req.Quantity,
		PlannedStartDate: req.PlannedStartDate,
		PlannedEndDate:   req.PlannedEndDate,
		Status:           "Draft",
		MaterialCost:     materialCost,
		LaborCost:        laborCost,
		OverheadCost:     overheadCost,
		TotalCost:        totalCost,
	}

	err = s.repo.Create(order)
	if err != nil {
		return nil, err
	}

	return s.repo.GetByID(order.ID.String(), tenantID)
}

func (s *ProductionOrderService) GetProductionOrders(tenantID string, status string) ([]models.ProductionOrder, error) {
	return s.repo.GetAll(tenantID, status)
}

func (s *ProductionOrderService) GetProductionOrderByID(id string, tenantID string) (*models.ProductionOrder, error) {
	return s.repo.GetByID(id, tenantID)
}

func (s *ProductionOrderService) UpdateStatus(id string, tenantID string, status string) error {
	validStatuses := map[string]bool{"Draft": true, "Released": true, "In Progress": true, "Completed": true, "Cancelled": true}
	if !validStatuses[status] {
		return errors.New("invalid status transition")
	}

	return s.repo.UpdateStatus(id, tenantID, status)
}
