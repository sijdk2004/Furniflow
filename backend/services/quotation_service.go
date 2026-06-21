package services

import (
	"errors"
	"fmt"
	"furniflow-backend/dtos"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"github.com/google/uuid"
	"time"
)

type QuotationService struct {
	repo *repositories.QuotationRepository
}

func NewQuotationService(repo *repositories.QuotationRepository) *QuotationService {
	return &QuotationService{repo: repo}
}

func (s *QuotationService) calculateTotals(req dtos.QuotationRequest, items []models.QuotationItem) (subtotal, total float64) {
	for _, item := range items {
		subtotal += item.TotalPrice
	}
	total = subtotal - req.Discount + req.Tax
	return subtotal, total
}

func (s *QuotationService) buildItems(quotationID string, reqItems []dtos.QuotationItemRequest) []models.QuotationItem {
	var items []models.QuotationItem
	for _, itReq := range reqItems {
		itemTotal := float64(itReq.Quantity) * itReq.UnitPrice
		items = append(items, models.QuotationItem{
			ID:          fmt.Sprintf("QI-%s", uuid.New().String()[:8]),
			QuotationID: quotationID,
			ProductID:   itReq.ProductID,
			Quantity:    itReq.Quantity,
			UnitPrice:   itReq.UnitPrice,
			TotalPrice:  itemTotal,
		})
	}
	return items
}

func (s *QuotationService) Create(tenantID, userID string, req dtos.QuotationRequest) (*models.Quotation, error) {
	qID := fmt.Sprintf("QT-%s", uuid.New().String()[:8])
	
	items := s.buildItems(qID, req.Items)
	subtotal, total := s.calculateTotals(req, items)

	quotation := &models.Quotation{
		ID:          qID,
		TenantID:    tenantID,
		CustomerID:  req.CustomerID,
		Status:      "Draft",
		DateCreated: time.Now(),
		ValidUntil:  req.ValidUntil,
		Subtotal:    subtotal,
		Discount:    req.Discount,
		Tax:         req.Tax,
		Total:       total,
		Notes:       req.Notes,
		Items:       items,
		CreatedBy:   userID,
		IsActive:    true,
	}

	if err := s.repo.Create(quotation); err != nil {
		return nil, err
	}
	return quotation, nil
}

func (s *QuotationService) GetAll(tenantID string) ([]models.Quotation, error) {
	return s.repo.FindAll(tenantID)
}

func (s *QuotationService) GetByID(id, tenantID string) (*models.Quotation, error) {
	return s.repo.FindByID(id, tenantID)
}

func (s *QuotationService) Update(id, tenantID, userID string, req dtos.QuotationRequest) (*models.Quotation, error) {
	existing, err := s.repo.FindByID(id, tenantID)
	if err != nil {
		return nil, err
	}

	if existing.Status != "Draft" && existing.Status != "Rejected" {
		return nil, errors.New("cannot edit quotation unless it is Draft or Rejected")
	}

	items := s.buildItems(existing.ID, req.Items)
	subtotal, total := s.calculateTotals(req, items)

	existing.CustomerID = req.CustomerID
	existing.ValidUntil = req.ValidUntil
	existing.Subtotal = subtotal
	existing.Discount = req.Discount
	existing.Tax = req.Tax
	existing.Total = total
	existing.Notes = req.Notes
	existing.Items = items
	existing.UpdatedBy = userID
	existing.Status = "Draft" // reset status if edited

	if err := s.repo.Update(existing); err != nil {
		return nil, err
	}

	return s.GetByID(id, tenantID) // reload with relations
}

func (s *QuotationService) Delete(id, tenantID string) error {
	existing, err := s.repo.FindByID(id, tenantID)
	if err != nil {
		return err
	}
	if existing.Status == "Converted" {
		return errors.New("cannot delete converted quotation")
	}
	return s.repo.Delete(id, tenantID)
}

func (s *QuotationService) UpdateStatus(id, tenantID, userID, status string) error {
	existing, err := s.repo.FindByID(id, tenantID)
	if err != nil {
		return err
	}

	if status == "Converted" {
		if existing.Status != "Approved" {
			return errors.New("only Approved quotations can be converted")
		}
		// Generate Sales Order draft record
		soID := fmt.Sprintf("SO-%s", uuid.New().String()[:8])
		
		var soItems []models.SalesOrderItem
		for _, qItem := range existing.Items {
			soItems = append(soItems, models.SalesOrderItem{
				ID:           fmt.Sprintf("SOI-%s", uuid.New().String()[:8]),
				SalesOrderID: soID,
				ProductID:    qItem.ProductID,
				Quantity:     qItem.Quantity,
				UnitPrice:    qItem.UnitPrice,
				TotalPrice:   qItem.TotalPrice,
			})
		}

		so := &models.SalesOrder{
			ID:          soID,
			TenantID:    tenantID,
			CustomerID:  existing.CustomerID,
			QuotationID: &existing.ID,
			Status:      "Draft",
			OrderDate:   time.Now(),
			Subtotal:    existing.Subtotal,
			Discount:    existing.Discount,
			Tax:         existing.Tax,
			TotalAmount: existing.Total,
			Items:       soItems,
			CreatedBy:   userID,
			IsActive:    true,
		}
		if err := s.repo.CreateSalesOrder(so); err != nil {
			return err
		}
	}

	return s.repo.UpdateStatus(id, tenantID, status)
}
