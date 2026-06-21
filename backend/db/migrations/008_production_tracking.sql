-- ==============================================================================
-- Migration: 008_production_tracking
-- Description: Creates tables for Production Tracking and Stage History
-- ==============================================================================

-- 1. Production Trackings Table
CREATE TABLE IF NOT EXISTS production_trackings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    remarks TEXT,
    
    production_order_id UUID NOT NULL REFERENCES production_orders(id) ON DELETE CASCADE,
    current_stage VARCHAR(100) NOT NULL,
    assigned_team VARCHAR(100),
    assigned_employee_id UUID REFERENCES users(id),
    completion_percentage INTEGER DEFAULT 0,
    stage_start_date TIMESTAMP,
    stage_end_date TIMESTAMP,
    
    CONSTRAINT uq_tracking_order UNIQUE (production_order_id)
);

-- 2. Production Stage Histories Table
CREATE TABLE IF NOT EXISTS production_stage_histories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    remarks TEXT,
    
    tracking_id UUID NOT NULL REFERENCES production_trackings(id) ON DELETE CASCADE,
    stage VARCHAR(100) NOT NULL,
    stage_entered_at TIMESTAMP NOT NULL,
    stage_started_at TIMESTAMP,
    stage_completed_at TIMESTAMP,
    duration_minutes INTEGER,
    delay_reason VARCHAR(255),
    completed_by_user_id UUID REFERENCES users(id)
);

-- Register Screens
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES 
('TRK_BOARD', 'Production Board', 'MFG', '/tracking/board'),
('TRK_LIST', 'Production Tracking', 'MFG', '/tracking')
ON CONFLICT (screen_code) DO NOTHING;

-- Register Menus
INSERT INTO menus (menu_code, menu_name, icon_name, module_code, screen_code, sort_order) VALUES 
('MENU_TRK_BOARD', 'Production Board', 'layoutDashboard', 'MFG', 'TRK_BOARD', 55),
('MENU_TRK_LIST', 'Production Tracking', 'activity', 'MFG', 'TRK_LIST', 60)
ON CONFLICT (menu_code) DO NOTHING;

-- Register Permissions
INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('MFG.TRK.VIEW', 'MFG', 'TRK_LIST', 'VIEW'),
('MFG.TRK.UPDATE', 'MFG', 'TRK_LIST', 'UPDATE'),
('MFG.TRK.VIEW_BOARD', 'MFG', 'TRK_BOARD', 'VIEW')
ON CONFLICT (permission_code) DO NOTHING;

-- Assign Permissions to Admin Role
INSERT INTO role_permissions (role_id, permission_id, tenant_id)
SELECT r.id, p.id, 'SYSTEM_TENANT'
FROM roles r
CROSS JOIN permissions p
WHERE r.role_code = 'SYS_ADMIN'
AND p.permission_code LIKE 'MFG.TRK.%'
ON CONFLICT DO NOTHING;
