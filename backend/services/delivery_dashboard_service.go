package services

import (
	"errors"
	"time"

	"furniflow-backend/models"
	"furniflow-backend/repositories"
)

type DeliveryDashboardService struct {
	repo *repositories.DeliveryDashboardRepository
}

func NewDeliveryDashboardService(repo *repositories.DeliveryDashboardRepository) *DeliveryDashboardService {
	return &DeliveryDashboardService{repo: repo}
}

func (s *DeliveryDashboardService) GetDashboardData(tenantID string, filter models.DeliveryDashboardFilterRequest) (*models.DeliveryDashboardResponse, error) {
	if tenantID == "" {
		return nil, errors.New("tenant_id is required")
	}

	if filter.Timeframe == "" {
		filter.Timeframe = "1M" // default timeframe
	}

	// Validate start and end date logic if provided
	if filter.StartDate != nil && filter.EndDate != nil {
		if filter.StartDate.After(*filter.EndDate) {
			return nil, errors.New("start date cannot be after end date")
		}
	} else if filter.StartDate != nil {
		now := time.Now()
		filter.EndDate = &now
	}

	return s.repo.GetDeliveryDashboardData(tenantID, filter)
}
