package repositories

import (
	"furniflow-backend/models"

	"gorm.io/gorm"
)

type ProductionTrackingRepository struct {
	db *gorm.DB
}

func NewProductionTrackingRepository(db *gorm.DB) *ProductionTrackingRepository {
	return &ProductionTrackingRepository{db: db}
}

// GetTrackingByID fetches a tracking record along with its history and related production order
func (r *ProductionTrackingRepository) GetTrackingByID(id string, tenantID string) (*models.ProductionTracking, error) {
	var tracking models.ProductionTracking
	err := r.db.Where("id = ? AND tenant_id = ?", id, tenantID).
		Preload("Histories", func(db *gorm.DB) *gorm.DB {
			return db.Order("stage_entered_at DESC")
		}).
		Preload("ProductionOrder").
		Preload("ProductionOrder.Product").
		First(&tracking).Error
	return &tracking, err
}

// GetTrackingByOrderID fetches the tracking record by the production order ID
func (r *ProductionTrackingRepository) GetTrackingByOrderID(orderID string, tenantID string) (*models.ProductionTracking, error) {
	var tracking models.ProductionTracking
	err := r.db.Where("production_order_id = ? AND tenant_id = ?", orderID, tenantID).
		Preload("Histories", func(db *gorm.DB) *gorm.DB {
			return db.Order("stage_entered_at DESC")
		}).
		First(&tracking).Error
	return &tracking, err
}

// GetBoardItems returns flattened tracking data suitable for a Kanban or list board
func (r *ProductionTrackingRepository) GetBoardItems(tenantID string) ([]models.ProductionBoardItem, error) {
	var items []models.ProductionBoardItem
	
	query := `
		SELECT 
			pt.id as tracking_id,
			po.id as production_order_id,
			'PO-' || left(po.id::text, 8) as order_number,
			po.sales_order_id,
			p.id as product_id,
			p.product_name as product_name,
			c.name as customer_name,
			po.status as status,
			po.planned_end_date,
			pt.current_stage,
			pt.completion_percentage,
			pt.is_on_hold,
			pt.assigned_team
		FROM production_trackings pt
		JOIN production_orders po ON pt.production_order_id = po.id
		JOIN products p ON po.product_id = p.id
		LEFT JOIN sales_orders so ON po.sales_order_id = so.id
		LEFT JOIN customers c ON so.customer_id = c.id
		WHERE pt.tenant_id = ?
		ORDER BY po.created_on DESC
	`
	
	err := r.db.Raw(query, tenantID).Scan(&items).Error
	return items, err
}

func (r *ProductionTrackingRepository) CreateTracking(tracking *models.ProductionTracking) error {
	return r.db.Create(tracking).Error
}

func (r *ProductionTrackingRepository) UpdateTracking(tracking *models.ProductionTracking) error {
	return r.db.Save(tracking).Error
}

func (r *ProductionTrackingRepository) CreateHistory(history *models.ProductionStageHistory) error {
	return r.db.Create(history).Error
}

func (r *ProductionTrackingRepository) UpdateHistory(history *models.ProductionStageHistory) error {
	return r.db.Save(history).Error
}
