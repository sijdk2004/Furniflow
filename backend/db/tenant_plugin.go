package db

import (
	"context"
	"gorm.io/gorm"
)

type TenantKey struct{}

func TenantScope(ctx context.Context) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		if tenantID, ok := ctx.Value(TenantKey{}).(string); ok && tenantID != "" {
			return db.Where("tenant_id = ?", tenantID)
		}
		return db
	}
}

// TenantPlugin automatically injects the tenant_id scope into all queries if present in context.
type TenantPlugin struct{}

func (p *TenantPlugin) Name() string {
	return "tenant_plugin"
}

func (p *TenantPlugin) Initialize(db *gorm.DB) error {
	// Register for query, update, delete callbacks
	callback := db.Callback()
	

	// This is a simplified version. A true GORM callback for multitenancy:
	queryCallback := func(db *gorm.DB) {
		if tenantID, ok := db.Statement.Context.Value(TenantKey{}).(string); ok && tenantID != "" {
			db.Statement.Where("tenant_id = ?", tenantID)
		}
	}

	callback.Query().Before("gorm:query").Register("tenant_plugin:query", queryCallback)
	callback.Update().Before("gorm:update").Register("tenant_plugin:update", queryCallback)
	callback.Delete().Before("gorm:delete").Register("tenant_plugin:delete", queryCallback)

	return nil
}
