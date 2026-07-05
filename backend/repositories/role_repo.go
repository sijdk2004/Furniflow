package repositories

import (
	"furniflow-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RoleRepository struct {
	db *gorm.DB
}

func NewRoleRepository(db *gorm.DB) *RoleRepository {
	return &RoleRepository{db: db}
}

func (r *RoleRepository) GetAll(tenantID string) ([]models.Role, error) {
	var roles []models.Role
	if err := r.db.Where("tenant_id = ?", tenantID).Find(&roles).Error; err != nil {
		return nil, err
	}
	return roles, nil
}

func (r *RoleRepository) FindByID(id string, tenantID string) (*models.Role, error) {
	var role models.Role
	if err := r.db.Preload("Permissions").Where("id = ? AND tenant_id = ?", id, tenantID).First(&role).Error; err != nil {
		return nil, err
	}
	return &role, nil
}

func (r *RoleRepository) Create(role *models.Role) error {
	return r.db.Create(role).Error
}

func (r *RoleRepository) Update(role *models.Role) error {
	return r.db.Save(role).Error
}

func (r *RoleRepository) Delete(id string, tenantID string) error {
	return r.db.Where("id = ? AND tenant_id = ?", id, tenantID).Delete(&models.Role{}).Error
}

func (r *RoleRepository) GetAllPermissions() ([]models.Permission, error) {
	var permissions []models.Permission
	if err := r.db.Find(&permissions).Error; err != nil {
		return nil, err
	}
	return permissions, nil
}

func (r *RoleRepository) UpdatePermissions(roleID string, tenantID string, permissionIDs []string, updatedBy *uuid.UUID) error {
	var role models.Role
	if err := r.db.Where("id = ? AND tenant_id = ?", roleID, tenantID).First(&role).Error; err != nil {
		return err
	}

	var permissions []models.Permission
	if len(permissionIDs) > 0 {
		if err := r.db.Where("id IN ?", permissionIDs).Find(&permissions).Error; err != nil {
			return err
		}
	}

	err := r.db.Transaction(func(tx *gorm.DB) error {
		// Clear existing permissions
		if err := tx.Exec("DELETE FROM role_permissions WHERE role_id = ? AND tenant_id = ?", roleID, tenantID).Error; err != nil {
			return err
		}
		
		// Insert new permissions with tenant_id
		for _, p := range permissions {
			if err := tx.Exec("INSERT INTO role_permissions (role_id, permission_id, tenant_id) VALUES (?, ?, ?)", roleID, p.ID, tenantID).Error; err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return err
	}
	
	auditLog := models.AuditLog{
		BaseModel:  models.BaseModel{TenantID: tenantID},
		UserID:     updatedBy,
		Action:     "Permissions Updated",
		EntityName: stringPtr("roles"),
		EntityID:   &roleID,
		Details:    "Role permissions updated",
	}
	return r.db.Create(&auditLog).Error
}

func (r *RoleRepository) GetUsersByRole(roleID string, tenantID string) ([]models.User, error) {
	var users []models.User
	if err := r.db.Joins("JOIN user_roles ur ON ur.user_id = users.id").
		Where("ur.role_id = ? AND users.tenant_id = ?", roleID, tenantID).
		Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

func (r *RoleRepository) UpdateUsers(roleID string, tenantID string, userIDs []string, updatedBy *uuid.UUID) error {
	var role models.Role
	if err := r.db.Where("id = ? AND tenant_id = ?", roleID, tenantID).First(&role).Error; err != nil {
		return err
	}

	var users []models.User
	if len(userIDs) > 0 {
		if err := r.db.Where("id IN ? AND tenant_id = ?", userIDs, tenantID).Find(&users).Error; err != nil {
			return err
		}
	}

	err := r.db.Transaction(func(tx *gorm.DB) error {
		// Clear existing users for this role
		if err := tx.Exec("DELETE FROM user_roles WHERE role_id = ? AND tenant_id = ?", roleID, tenantID).Error; err != nil {
			return err
		}
		
		// Insert new users with tenant_id
		for _, u := range users {
			if err := tx.Exec("INSERT INTO user_roles (role_id, user_id, tenant_id) VALUES (?, ?, ?)", roleID, u.ID, tenantID).Error; err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return err
	}

	auditLog := models.AuditLog{
		BaseModel:  models.BaseModel{TenantID: tenantID},
		UserID:     updatedBy,
		Action:     "Users Assigned",
		EntityName: stringPtr("roles"),
		EntityID:   &roleID,
		Details:    "Role users updated",
	}
	return r.db.Create(&auditLog).Error
}

func stringPtr(s string) *string {
	return &s
}

func (r *RoleRepository) GetAuditLogs(roleID string, tenantID string) ([]models.AuditLog, error) {
	var logs []models.AuditLog
	if err := r.db.Where("entity_name = ? AND entity_id = ? AND tenant_id = ?", "roles", roleID, tenantID).
		Order("created_on DESC").
		Find(&logs).Error; err != nil {
		return nil, err
	}
	return logs, nil
}
