package services

import (
	"errors"
	"fmt"
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"github.com/google/uuid"
)

type SalesOrderService struct {
	repo *repositories.SalesOrderRepository
}

func NewSalesOrderService(repo *repositories.SalesOrderRepository) *SalesOrderService {
	return &SalesOrderService{repo: repo}
}

func (s *SalesOrderService) GetAll(tenantID string, isRestricted bool, userID string) ([]models.SalesOrder, error) {
	return s.repo.FindAll(tenantID, isRestricted, userID)
}

func (s *SalesOrderService) GetByID(id, tenantID string, isRestricted bool, userID string) (*models.SalesOrder, error) {
	return s.repo.FindByID(id, tenantID, isRestricted, userID)
}

func (s *SalesOrderService) Update(id, tenantID, userID string, req dtos.SalesOrderUpdateRequest, isRestricted bool) (*models.SalesOrder, error) {
	existing, err := s.repo.FindByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return nil, err
	}

	if existing.Status != "Draft" {
		return nil, errors.New("cannot edit sales order unless it is in Draft status")
	}

	// Rebuild items if provided
	if len(req.Items) > 0 {
		var newItems []models.SalesOrderItem
		var subtotal float64
		for _, itReq := range req.Items {
			itemTotal := float64(itReq.Quantity) * itReq.UnitPrice
			subtotal += itemTotal
			newItems = append(newItems, models.SalesOrderItem{
				ID:           fmt.Sprintf("SOI-%s", uuid.New().String()[:8]),
				SalesOrderID: existing.ID,
				ProductID:    itReq.ProductID,
				Quantity:     itReq.Quantity,
				UnitPrice:    itReq.UnitPrice,
				TotalPrice:   itemTotal,
			})
		}
		existing.Items = newItems
		existing.Subtotal = subtotal
	}

	// Update financial totals
	existing.Discount = req.Discount
	existing.TotalAmount = existing.Subtotal - existing.Discount + existing.Tax

	// Update administrative fields
	if req.OrderNumber != nil {
		existing.OrderNumber = *req.OrderNumber
	}
	if req.SalesPerson != nil {
		existing.SalesPerson = *req.SalesPerson
	}
	existing.ExpectedDeliveryDate = req.ExpectedDeliveryDate
	existing.Remarks = req.Remarks
	existing.UpdatedBy = userID

	if err := s.repo.Update(existing); err != nil {
		return nil, err
	}

	return s.GetByID(id, tenantID, isRestricted, userID) // reload with relations
}

func (s *SalesOrderService) UpdateStatus(id, tenantID, userID, newStatus string, isRestricted bool) error {
	existing, err := s.repo.FindByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return err
	}

	// Workflow Validation
	validTransitions := map[string][]string{
		"Draft":              {"Confirmed", "Cancelled"},
		"Confirmed":          {"In Production", "Cancelled"},
		"In Production":      {"Ready For Delivery"},
		"Ready For Delivery": {"Delivered"},
		"Delivered":          {},
		"Cancelled":          {},
	}

	allowed, ok := validTransitions[existing.Status]
	if !ok {
		return errors.New("invalid current status")
	}

	isValidTransition := false
	for _, st := range allowed {
		if st == newStatus {
			isValidTransition = true
			break
		}
	}

	if !isValidTransition {
		return fmt.Errorf("invalid transition from %s to %s", existing.Status, newStatus)
	}

	return s.repo.UpdateStatus(id, tenantID, newStatus, isRestricted, userID)
}
