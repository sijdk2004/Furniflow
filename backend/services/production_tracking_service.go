package services

import (
	"errors"
	"furniflow-backend/models"
	"furniflow-backend/repositories"
	"time"

	"github.com/google/uuid"
)

var ProductionStages = []string{
	"Raw Material Ready",
	"Cutting",
	"Carpentry",
	"Assembly",
	"Sanding",
	"Sealer",
	"Painting",
	"Polishing",
	"Drying",
	"Quality Inspection",
	"Packing",
	"Ready For Delivery",
}

func (s *ProductionTrackingService) getStages(tenantID string) []string {
	records, err := s.masterRepo.FindAll("production_stages", tenantID)
	if err != nil || len(records) == 0 {
		return ProductionStages // Fallback to hardcoded if none in DB
	}
	var stages []string
	for _, r := range records {
		stages = append(stages, r.Name)
	}
	return stages
}

type ProductionTrackingService struct {
	repo    *repositories.ProductionTrackingRepository
	poService *ProductionOrderService
	masterRepo *repositories.MasterDataRepository
}

func NewProductionTrackingService(repo *repositories.ProductionTrackingRepository, poService *ProductionOrderService, masterRepo *repositories.MasterDataRepository) *ProductionTrackingService {
	return &ProductionTrackingService{
		repo:    repo,
		poService: poService,
		masterRepo: masterRepo,
	}
}

func (s *ProductionTrackingService) GetBoardItems(tenantID string) ([]models.ProductionBoardItem, error) {
	items, err := s.repo.GetBoardItems(tenantID)
	if err != nil {
		return nil, err
	}

	stages := s.getStages(tenantID)

	// Dynamically recalculate completion percentage in case of data inconsistencies
	for i := range items {
		idx := s.getStageIndex(items[i].CurrentStage, tenantID)
		if idx != -1 {
			percentage := 0
			if len(stages) > 1 {
				percentage = int((float64(idx) / float64(len(stages)-1)) * 100)
			} else {
				percentage = 100
			}
			if percentage > 100 {
				percentage = 100
			}
			items[i].CompletionPercentage = percentage
		}
	}

	return items, nil
}

func (s *ProductionTrackingService) GetTrackingByID(id string, tenantID string) (*models.ProductionTracking, error) {
	return s.repo.GetTrackingByID(id, tenantID)
}

// EnsureTrackingExists checks if a Production Order has a Tracking record, and creates one if missing
func (s *ProductionTrackingService) EnsureTrackingExists(orderID string, tenantID string, userID *uuid.UUID) (*models.ProductionTracking, error) {
	tracking, err := s.repo.GetTrackingByOrderID(orderID, tenantID)
	if err == nil && tracking != nil {
		return tracking, nil
	}

	poID, err := uuid.Parse(orderID)
	if err != nil {
		return nil, errors.New("invalid production order ID")
	}

	// Make sure the order exists
	po, err := s.poService.GetProductionOrderByID(orderID, tenantID)
	if err != nil {
		return nil, errors.New("production order not found")
	}

	if po.Status == "Draft" || po.Status == "Cancelled" {
		return nil, errors.New("cannot track draft or cancelled orders")
	}

	stages := s.getStages(tenantID)

	newTracking := &models.ProductionTracking{
		ProductionOrderID: poID,
		CurrentStage:      stages[0], // Dynamically fetch first stage
		BaseModel: models.BaseModel{
			TenantID: tenantID,
		},
	}

	if userID != nil {
		newTracking.CreatedBy = userID
		newTracking.UpdatedBy = userID
	}

	if err := s.repo.CreateTracking(newTracking); err != nil {
		return nil, err
	}

	// Create initial history
	now := time.Now()
	history := &models.ProductionStageHistory{
		TrackingID:     newTracking.ID,
		Stage:          newTracking.CurrentStage,
		StageEnteredAt: now,
		BaseModel: models.BaseModel{
			TenantID: tenantID,
		},
	}
	
	if userID != nil {
		history.CreatedBy = userID
		history.UpdatedBy = userID
	}
	s.repo.CreateHistory(history)

	return s.GetTrackingByID(newTracking.ID.String(), tenantID)
}

func (s *ProductionTrackingService) getStageIndex(stage string, tenantID string) int {
	stages := s.getStages(tenantID)
	for i, s := range stages {
		if s == stage {
			return i
		}
	}
	return -1
}

func (s *ProductionTrackingService) UpdateStage(trackingID string, req *models.UpdateTrackingStageRequest, tenantID string, userID *uuid.UUID) error {
	tracking, err := s.repo.GetTrackingByID(trackingID, tenantID)
	if err != nil {
		return errors.New("tracking record not found")
	}

	currentIndex := s.getStageIndex(tracking.CurrentStage, tenantID)
	nextIndex := s.getStageIndex(req.NextStage, tenantID)

	if nextIndex == -1 {
		return errors.New("invalid next stage")
	}

	// Business Rule: Stage transitions must be sequential (but allow jumping back if rework is needed)
	// We will strictly enforce sequential forward, but allow going back.
	if nextIndex > currentIndex+1 {
		return errors.New("stage transitions must be strictly sequential forward")
	}

	// Complete the current stage history
	if len(tracking.Histories) > 0 {
		currentHistory := &tracking.Histories[0] // Because we order by DESC
		if currentHistory.Stage == tracking.CurrentStage && currentHistory.StageCompletedAt == nil {
			now := time.Now()
			currentHistory.StageCompletedAt = &now
			currentHistory.CompletedByUserID = userID
			
			if currentHistory.StageStartedAt != nil {
				duration := int(now.Sub(*currentHistory.StageStartedAt).Minutes())
				currentHistory.DurationMinutes = &duration
			}

			s.repo.UpdateHistory(currentHistory)
		}
	}

	// Move to next stage
	tracking.CurrentStage = req.NextStage
	tracking.AssignedTeam = req.AssignedTeam
	tracking.AssignedEmployeeID = req.AssignedEmployeeID
	if userID != nil {
		tracking.UpdatedBy = userID
	}
	
	// Auto calculate completion percentage
	stages := s.getStages(tenantID)
	percentage := 0
	if len(stages) > 1 {
		percentage = int((float64(nextIndex) / float64(len(stages)-1)) * 100)
	} else {
		percentage = 100
	}
	if percentage > 100 {
		percentage = 100
	}
	tracking.CompletionPercentage = percentage

	if err := s.repo.UpdateTracking(tracking); err != nil {
		return err
	}

	// Create new history for next stage
	now := time.Now()
	newHistory := &models.ProductionStageHistory{
		TrackingID:     tracking.ID,
		Stage:          tracking.CurrentStage,
		StageEnteredAt: now,
		DelayReason:    req.DelayReason,
		BaseModel: models.BaseModel{
			TenantID: tenantID,
			Remarks:  req.Remarks,
		},
	}
	if userID != nil {
		newHistory.CreatedBy = userID
		newHistory.UpdatedBy = userID
	}
	s.repo.CreateHistory(newHistory)

	// Business Rule: Automatically update PO status
	if nextIndex == len(stages)-1 {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "Completed")
	} else {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "In Progress")
	}

	return nil
}

func (s *ProductionTrackingService) ToggleHold(trackingID string, req *models.ToggleHoldRequest, tenantID string, userID *uuid.UUID) error {
	tracking, err := s.repo.GetTrackingByID(trackingID, tenantID)
	if err != nil {
		return errors.New("tracking record not found")
	}

	tracking.IsOnHold = req.IsOnHold
	if userID != nil {
		tracking.UpdatedBy = userID
	}

	if err := s.repo.UpdateTracking(tracking); err != nil {
		return err
	}

	if tracking.IsOnHold {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "On Hold")
	} else {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "In Progress")
	}

	now := time.Now()
	remarks := req.Reason
	action := "Paused (On Hold)"
	if !req.IsOnHold {
		action = "Resumed"
	}
	if remarks == "" {
		remarks = action
	} else {
		remarks = action + " - " + remarks
	}

	history := &models.ProductionStageHistory{
		TrackingID:     tracking.ID,
		Stage:          tracking.CurrentStage,
		StageEnteredAt: now,
		BaseModel: models.BaseModel{
			TenantID: tenantID,
			Remarks:  &remarks,
		},
	}
	if userID != nil {
		history.CreatedBy = userID
		history.UpdatedBy = userID
	}
	s.repo.CreateHistory(history)

	return nil
}

func (s *ProductionTrackingService) StartStage(trackingID string, tenantID string) error {
	tracking, err := s.repo.GetTrackingByID(trackingID, tenantID)
	if err != nil {
		return err
	}
	if len(tracking.Histories) > 0 {
		currentHistory := &tracking.Histories[0]
		if currentHistory.StageStartedAt == nil {
			now := time.Now()
			currentHistory.StageStartedAt = &now
			
			if tracking.StageStartDate == nil {
				tracking.StageStartDate = &now
				s.repo.UpdateTracking(tracking)
			}
			
			return s.repo.UpdateHistory(currentHistory)
		}
	}
	return nil
}
