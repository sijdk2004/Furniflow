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
	"On Hold",
	"Resumed",
}

type ProductionTrackingService struct {
	repo    *repositories.ProductionTrackingRepository
	poService *ProductionOrderService
}

func NewProductionTrackingService(repo *repositories.ProductionTrackingRepository, poService *ProductionOrderService) *ProductionTrackingService {
	return &ProductionTrackingService{
		repo:    repo,
		poService: poService,
	}
}

func (s *ProductionTrackingService) GetBoardItems(tenantID string) ([]models.ProductionBoardItem, error) {
	return s.repo.GetBoardItems(tenantID)
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

	newTracking := &models.ProductionTracking{
		ProductionOrderID: poID,
		CurrentStage:      ProductionStages[0], // Raw Material Ready
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

func (s *ProductionTrackingService) getStageIndex(stage string) int {
	for i, s := range ProductionStages {
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

	currentIndex := s.getStageIndex(tracking.CurrentStage)
	nextIndex := s.getStageIndex(req.NextStage)

	if nextIndex == -1 {
		return errors.New("invalid next stage")
	}

	// Business Rule: Stage transitions must be sequential (but allow jumping back if rework is needed)
	// We will strictly enforce sequential forward, but allow going back.
	if nextIndex > currentIndex+1 {
		// Exception for "On Hold" and "Resumed"
		if req.NextStage != "On Hold" && req.NextStage != "Resumed" && tracking.CurrentStage != "Resumed" {
			return errors.New("stage transitions must be strictly sequential forward")
		}
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
	
	// Auto calculate completion percentage, ignore for On Hold/Resumed
	if req.NextStage != "On Hold" && req.NextStage != "Resumed" {
		tracking.CompletionPercentage = int((float64(nextIndex) / float64(len(ProductionStages)-3)) * 100)
	}

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
	if tracking.CurrentStage == "Ready For Delivery" {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "Completed")
	} else if tracking.CurrentStage == "On Hold" {
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "On Hold")
	} else if tracking.CurrentStage == "Quality Inspection" {
		// Just keeping it In Progress
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "In Progress")
	} else {
		// Ensure it's marked In Progress
		s.poService.UpdateStatus(tracking.ProductionOrderID.String(), tenantID, "In Progress")
	}

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
