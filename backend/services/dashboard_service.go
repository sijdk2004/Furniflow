package services

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"
)

type DashboardService struct {
	repo *repositories.DashboardRepository
}

func NewDashboardService(repo *repositories.DashboardRepository) *DashboardService {
	return &DashboardService{repo: repo}
}

func (s *DashboardService) GetDashboardData(tenantID string, filter *models.DashboardFilterRequest) (*models.DashboardResponse, error) {
	if filter.Timeframe == "" {
		filter.Timeframe = "YTD"
	}
	return s.repo.GetDashboardData(tenantID, filter)
}
