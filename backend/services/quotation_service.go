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
	milli := time.Now().UnixMilli()
	qID := fmt.Sprintf("QT-%06d", milli%1000000)
	
	items := s.buildItems(qID, req.Items)
	subtotal, total := s.calculateTotals(req, items)

	quotationNum := ""
	if req.QuotationNumber != nil {
		quotationNum = *req.QuotationNumber
	} else {
		quotationNum = qID
	}

	quotation := &models.Quotation{
		ID:              qID,
		QuotationNumber: quotationNum,
		TenantID:        tenantID,
		CustomerID:      req.CustomerID,
		SalesPerson:     req.SalesPerson,
		Status:          "Draft",
		DateCreated:     time.Time{}, // Will use time.Now()
		ValidUntil:      req.ValidUntil,
		Subtotal:        subtotal,
		Discount:        req.Discount,
		Tax:             req.Tax,
		AdvanceAmount:   req.AdvanceAmount,
		BalanceAmount:   total - req.AdvanceAmount,
		Total:           total,
		Notes:           req.Notes,
		Items:           items,
		CreatedBy:       userID,
		IsActive:        true,
	}
	quotation.DateCreated = time.Now()

	if err := s.repo.Create(quotation); err != nil {
		return nil, err
	}
	return quotation, nil
}

func (s *QuotationService) GetAll(tenantID string, isRestricted bool, userID string) ([]models.Quotation, error) {
	return s.repo.FindAll(tenantID, isRestricted, userID)
}

func (s *QuotationService) GetByID(id, tenantID string, isRestricted bool, userID string) (*models.Quotation, error) {
	return s.repo.FindByID(id, tenantID, isRestricted, userID)
}

func (s *QuotationService) Update(id, tenantID, userID string, req dtos.QuotationRequest, isRestricted bool) (*models.Quotation, error) {
	existing, err := s.repo.FindByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return nil, err
	}

	if existing.Status != "Draft" && existing.Status != "Rejected" {
		return nil, errors.New("cannot edit quotation unless it is Draft or Rejected")
	}

	items := s.buildItems(existing.ID, req.Items)
	subtotal, total := s.calculateTotals(req, items)

	if req.QuotationNumber != nil {
		existing.QuotationNumber = *req.QuotationNumber
	}
	existing.CustomerID = req.CustomerID
	existing.SalesPerson = req.SalesPerson
	existing.ValidUntil = req.ValidUntil
	existing.Subtotal = subtotal
	existing.Discount = req.Discount
	existing.Tax = req.Tax
	existing.AdvanceAmount = req.AdvanceAmount
	existing.BalanceAmount = total - req.AdvanceAmount
	existing.Total = total
	existing.Notes = req.Notes
	existing.Items = items
	existing.UpdatedBy = userID
	existing.Status = "Draft" // reset status if edited

	if err := s.repo.Update(existing); err != nil {
		return nil, err
	}

	return s.GetByID(id, tenantID, isRestricted, userID) // reload with relations
}

func (s *QuotationService) Delete(id, tenantID string, isRestricted bool, userID string) error {
	existing, err := s.repo.FindByID(id, tenantID, isRestricted, userID)
	if err != nil {
		return err
	}
	if existing.Status == "Converted" {
		return errors.New("cannot delete converted quotation")
	}
	return s.repo.Delete(id, tenantID, isRestricted, userID)
}

func (s *QuotationService) UpdateStatus(id, tenantID, userID, status string, isRestricted bool) error {
	existing, err := s.repo.FindByID(id, tenantID, isRestricted, userID)
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

		salesPersonStr := ""
		if existing.SalesPerson != nil {
			salesPersonStr = *existing.SalesPerson
		}

		so := &models.SalesOrder{
			ID:          soID,
			OrderNumber: soID, // Default to SO ID for Order Number initially
			TenantID:    tenantID,
			CustomerID:  existing.CustomerID,
			QuotationID: &existing.ID,
			SalesPerson: salesPersonStr,
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

	return s.repo.UpdateStatus(id, tenantID, status, isRestricted, userID)
}
