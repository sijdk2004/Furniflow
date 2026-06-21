package services

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"
)

type ManufacturingDashboardService struct {
	repo *repositories.ManufacturingDashboardRepository
}

func NewManufacturingDashboardService(repo *repositories.ManufacturingDashboardRepository) *ManufacturingDashboardService {
	return &ManufacturingDashboardService{repo: repo}
}

func (s *ManufacturingDashboardService) GetManufacturingDashboardData(tenantID string, filter *models.ManufacturingDashboardFilterRequest) (*models.ManufacturingDashboardResponse, error) {
	return s.repo.GetManufacturingDashboardData(tenantID, filter)
}
