package repositories

import (
	"furniflow-backend/models"
	"gorm.io/gorm"
)

type MenuRepository struct {
	db *gorm.DB
}

func NewMenuRepository(db *gorm.DB) *MenuRepository {
	return &MenuRepository{db: db}
}

// FindAllByTenant retrieves all menus for a given tenant, ordered by SortOrder.
// In a full implementation, this could also filter strictly by user roles, but
// typically the frontend evaluates the exact permissions per-menu locally,
// or we pre-filter it. Document 06 requires menus to be dynamic. 
// We'll return active menus and let the Flutter provider map them based on role.
func (r *MenuRepository) FindAllActiveByTenant(tenantID string) ([]models.Menu, error) {
	var menus []models.Menu
	if err := r.db.Where("tenant_id = ? AND is_active = ?", tenantID, true).Order("sort_order ASC").Find(&menus).Error; err != nil {
		return nil, err
	}
	return menus, nil
}
