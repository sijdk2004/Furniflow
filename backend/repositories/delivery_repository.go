package repositories

import (
	"errors"
	"fmt"
	"furniflow-backend/models"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DeliveryRepository struct {
	db *gorm.DB
}

func NewDeliveryRepository(db *gorm.DB) *DeliveryRepository {
	return &DeliveryRepository{db: db}
}

// GetDeliveries returns all deliveries
func (r *DeliveryRepository) GetDeliveries(tenantID string) ([]models.DeliveryDetailResponse, error) {
	var deliveries []models.Delivery
	err := r.db.Where("tenant_id = ?", tenantID).Order("created_on desc").Find(&deliveries).Error
	if err != nil {
		return nil, err
	}
	
	var responses []models.DeliveryDetailResponse
	for _, d := range deliveries {
		resp := models.DeliveryDetailResponse{Delivery: d}
		
		var customer models.Customer
		if err := r.db.Where("id = ? AND tenant_id = ?", d.CustomerID, tenantID).First(&customer).Error; err == nil {
			resp.CustomerName = customer.Name
		}
		
		var po models.ProductionOrder
		if err := r.db.Where("id = ? AND tenant_id = ?", d.ProductionOrderID, tenantID).First(&po).Error; err == nil {
			resp.OrderNumber = "PO-" + po.ID.String()[:8]
			var prod models.Product
			if err := r.db.Where("id = ? AND tenant_id = ?", po.ProductID, tenantID).First(&prod).Error; err == nil {
				resp.Product = prod.ProductName
			}
		}
		
		responses = append(responses, resp)
	}
	
	return responses, nil
}

func (r *DeliveryRepository) GetDeliveryByID(id string, tenantID string) (*models.DeliveryDetailResponse, error) {
	var d models.Delivery
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).First(&d).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("delivery not found")
		}
		return nil, err
	}
	
	resp := &models.DeliveryDetailResponse{Delivery: d}
	
	var customer models.Customer
	if err := r.db.Where("id = ? AND tenant_id = ?", d.CustomerID, tenantID).First(&customer).Error; err == nil {
		resp.CustomerName = customer.Name
	}
	
	var po models.ProductionOrder
	if err := r.db.Where("id = ? AND tenant_id = ?", d.ProductionOrderID, tenantID).First(&po).Error; err == nil {
		resp.OrderNumber = "PO-" + po.ID.String()[:8]
		var prod models.Product
		if err := r.db.Where("id = ? AND tenant_id = ?", po.ProductID, tenantID).First(&prod).Error; err == nil {
			resp.Product = prod.ProductName
		}
	}

	var histories []models.DeliveryTimelineHistory
	err = r.db.Where("delivery_id = ? AND tenant_id = ?", id, tenantID).Order("timestamp asc").Find(&histories).Error
	if err == nil {
		resp.Histories = histories
	} else {
		resp.Histories = []models.DeliveryTimelineHistory{}
	}

	return resp, nil
}

func (r *DeliveryRepository) CreateDelivery(req *models.CreateDeliveryRequest, tenantID string, userID *uuid.UUID) (*models.Delivery, error) {
	var po models.ProductionOrder
	if err := r.db.Where("id = ? AND tenant_id = ?", req.ProductionOrderID, tenantID).First(&po).Error; err != nil {
		return nil, errors.New("production order not found")
	}

	var pt models.ProductionTracking
	err := r.db.Where("production_order_id = ? AND tenant_id = ?", req.ProductionOrderID, tenantID).First(&pt).Error
	
	if po.Status != "Completed" && (err != nil || pt.CurrentStage != "Ready For Delivery") {
		return nil, errors.New("production order is not Ready For Delivery")
	}

	var customerID uuid.UUID
	if po.SalesOrderID != nil && *po.SalesOrderID != "" {
		var so models.SalesOrder
		if err := r.db.Where("id = ? AND tenant_id = ?", *po.SalesOrderID, tenantID).First(&so).Error; err == nil {
			if parsed, err := uuid.Parse(so.CustomerID); err == nil {
				customerID = parsed
			}
		}
	}
	
	if customerID == uuid.Nil {
		var customer models.Customer
		if err := r.db.Where("tenant_id = ?", tenantID).First(&customer).Error; err == nil {
			customerID = customer.ID
		} else {
			return nil, errors.New("no customer available to link to delivery")
		}
	}

	deliveryID := uuid.New()
	deliveryNumber := fmt.Sprintf("DEL-%s", time.Now().Format("20060102-150405"))

	delivery := models.Delivery{
		BaseModel: models.BaseModel{
			ID:        deliveryID,
			TenantID:  tenantID,
			CreatedOn: time.Now(),
			CreatedBy: userID,
			UpdatedOn: time.Now(),
			UpdatedBy: userID,
			IsActive:  true,
		},
		DeliveryNumber:       deliveryNumber,
		ProductionOrderID:    req.ProductionOrderID,
		CustomerID:           customerID,
		ExpectedDeliveryDate: req.ExpectedDeliveryDate,
		Status:               "Scheduled",
		AssignedVehicle:      req.AssignedVehicle,
		AssignedDriver:       req.AssignedDriver,
		DeliveryNotes:        req.DeliveryNotes,
	}

	if po.SalesOrderID != nil && *po.SalesOrderID != "" {
		delivery.SalesOrderID = po.SalesOrderID
	}

	tx := r.db.Begin()
	if err := tx.Create(&delivery).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	remarks := "Delivery Scheduled"
	history := models.DeliveryTimelineHistory{
		ID:         uuid.New(),
		TenantID:   tenantID,
		DeliveryID: deliveryID,
		Stage:      "Scheduled",
		Timestamp:  time.Now(),
		UserID:     userID,
		Remarks:    &remarks,
	}

	if err := tx.Create(&history).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	tx.Commit()
	return &delivery, nil
}

func (r *DeliveryRepository) UpdateDeliveryStatus(id string, req *models.UpdateDeliveryStatusRequest, tenantID string, userID *uuid.UUID) error {
	tx := r.db.Begin()

	var delivery models.Delivery
	if err := tx.Set("gorm:query_option", "FOR UPDATE").Where("id = ? AND tenant_id = ?", id, tenantID).First(&delivery).Error; err != nil {
		tx.Rollback()
		return errors.New("delivery not found")
	}

	if delivery.Status == "Delivered" {
		tx.Rollback()
		return errors.New("delivery is already delivered and is read-only")
	}

	delivery.Status = req.Status
	delivery.CustomerAcknowledgement = req.CustomerAcknowledgement
	delivery.UpdatedBy = userID
	delivery.UpdatedOn = time.Now()

	if req.Status == "Delivered" {
		now := time.Now()
		delivery.DeliveryDate = &now
	}

	if err := tx.Save(&delivery).Error; err != nil {
		tx.Rollback()
		return err
	}

	history := models.DeliveryTimelineHistory{
		ID:         uuid.New(),
		TenantID:   tenantID,
		DeliveryID: delivery.ID,
		Stage:      req.Status,
		Timestamp:  time.Now(),
		UserID:     userID,
		Remarks:    req.Remarks,
	}

	if err := tx.Create(&history).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}
