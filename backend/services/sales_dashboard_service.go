package services

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"
)

type SalesDashboardService struct {
	repo *repositories.SalesDashboardRepository
}

func NewSalesDashboardService(repo *repositories.SalesDashboardRepository) *SalesDashboardService {
	return &SalesDashboardService{repo: repo}
}

func (s *SalesDashboardService) GetSalesDashboardData(tenantID string, filter *models.SalesDashboardFilterRequest, isRestricted bool) (*models.SalesDashboardResponse, error) {
	return s.repo.GetSalesDashboardData(tenantID, filter, isRestricted)
}
