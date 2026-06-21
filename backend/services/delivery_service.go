package services

import (
	"furniflow-backend/models"
	"furniflow-backend/repositories"

	"github.com/google/uuid"
)

type DeliveryService struct {
	repo *repositories.DeliveryRepository
}

func NewDeliveryService(repo *repositories.DeliveryRepository) *DeliveryService {
	return &DeliveryService{repo: repo}
}

func (s *DeliveryService) GetDeliveries(tenantID string) ([]models.DeliveryDetailResponse, error) {
	return s.repo.GetDeliveries(tenantID)
}

func (s *DeliveryService) GetDeliveryByID(id string, tenantID string) (*models.DeliveryDetailResponse, error) {
	return s.repo.GetDeliveryByID(id, tenantID)
}

func (s *DeliveryService) CreateDelivery(req *models.CreateDeliveryRequest, tenantID string, userID *uuid.UUID) (*models.Delivery, error) {
	return s.repo.CreateDelivery(req, tenantID, userID)
}

func (s *DeliveryService) UpdateDeliveryStatus(id string, req *models.UpdateDeliveryStatusRequest, tenantID string, userID *uuid.UUID) error {
	return s.repo.UpdateDeliveryStatus(id, req, tenantID, userID)
}
