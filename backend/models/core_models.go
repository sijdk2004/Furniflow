package models

import (
	"time"

	"github.com/google/uuid"
)

// BaseModel contains standard universal entity columns
type BaseModel struct {
	ID             uuid.UUID  `gorm:"type:uuid;default:uuid_generate_v4();primaryKey" json:"id"`
	TenantID       string     `gorm:"type:varchar(50);not null" json:"tenant_id"`
	OrganizationID *string    `gorm:"type:varchar(50)" json:"organization_id"`
	IsActive       bool       `gorm:"default:true" json:"is_active"`
	CreatedOn      time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"created_on"`
	CreatedBy      *uuid.UUID `json:"created_by"`
	UpdatedOn      time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"updated_on"`
	UpdatedBy      *uuid.UUID `json:"updated_by"`
	Remarks        *string    `json:"remarks"`
}

// User model
type User struct {
	BaseModel
	BranchID     *string `gorm:"type:varchar(50)" json:"branch_id"`
	DepartmentID *string `gorm:"type:varchar(50)" json:"department_id"`
	Username     string  `gorm:"type:varchar(100);uniqueIndex;not null" json:"username"`
	Email        string  `gorm:"type:varchar(255);uniqueIndex;not null" json:"email"`
	PasswordHash string  `gorm:"type:varchar(255);not null" json:"-"`
	FirstName    string  `gorm:"type:varchar(100);not null" json:"first_name"`
	LastName     *string `gorm:"type:varchar(100)" json:"last_name"`
	Mobile       *string `gorm:"type:varchar(20)" json:"mobile"`
	Designation  *string `gorm:"type:varchar(100)" json:"designation"`
	Department   *string `gorm:"type:varchar(100)" json:"department"`

	Roles []Role `gorm:"many2many:user_roles;" json:"roles,omitempty"`
}

// Role model
type Role struct {
	BaseModel
	RoleCode     string `gorm:"type:varchar(50);not null" json:"role_code"`
	RoleName     string `gorm:"type:varchar(100);not null" json:"role_name"`
	IsSystemRole bool   `gorm:"default:false" json:"is_system_role"`

	Permissions []Permission `gorm:"many2many:role_permissions;" json:"permissions,omitempty"`
	Users       []User       `gorm:"many2many:user_roles;" json:"users,omitempty"`
}

// Permission model
type Permission struct {
	BaseModel
	PermissionCode string    `gorm:"type:varchar(100);uniqueIndex;not null" json:"permission_code"`
	ModuleCode     string    `gorm:"type:varchar(50);not null" json:"module_code"`
	ScreenCode     string    `gorm:"type:varchar(50);not null" json:"screen_code"`
	ActionType     string    `gorm:"type:varchar(50);not null" json:"action_type"`
	DisplayName    *string   `gorm:"type:varchar(100)" json:"display_name"`
	Description    *string   `gorm:"type:text" json:"description"`
}

// Menu model (Dynamic Navigation)
type Menu struct {
	BaseModel
	MenuCode     string    `gorm:"type:varchar(50);uniqueIndex;not null"`
	MenuName     string    `gorm:"type:varchar(100);not null"`
	ModuleCode   *string   `gorm:"type:varchar(50)"`
	ScreenCode   *string   `gorm:"type:varchar(50)"`
	ParentMenuID *uuid.UUID
	IconName     *string `gorm:"type:varchar(50)"`
	SortOrder    int     `gorm:"default:0"`
}

// AuditLog model
type AuditLog struct {
	BaseModel
	UserID       *uuid.UUID `json:"user_id"`
	Action       string     `gorm:"type:varchar(100);not null" json:"action"`
	EntityName   *string    `gorm:"type:varchar(100)" json:"entity_name"`
	EntityID     *string    `gorm:"type:varchar(100)" json:"entity_id"`
	Details      string     `gorm:"type:text" json:"details"`
	IPAddress    *string    `gorm:"type:varchar(50)" json:"ip_address"`
	UserAgent    *string    `gorm:"type:varchar(255)" json:"user_agent"`
}
