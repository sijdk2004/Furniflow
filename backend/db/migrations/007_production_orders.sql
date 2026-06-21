-- 007_production_orders.sql

CREATE TABLE production_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    remarks TEXT,
    
    sales_order_id VARCHAR(50),
    product_id UUID NOT NULL REFERENCES products(id),
    bom_id UUID NOT NULL REFERENCES boms(id),
    bom_version INT NOT NULL,
    
    quantity INT NOT NULL DEFAULT 1,
    planned_start_date TIMESTAMP,
    planned_end_date TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'Draft',
    
    material_cost DECIMAL(12,2) DEFAULT 0,
    labor_cost DECIMAL(12,2) DEFAULT 0,
    overhead_cost DECIMAL(12,2) DEFAULT 0,
    total_cost DECIMAL(12,2) DEFAULT 0
);

-- Register Module
INSERT INTO modules (module_code, module_name, module_type) VALUES 
('MFG', 'Manufacturing', 'CORE')
ON CONFLICT (module_code) DO NOTHING;

-- Register Screen
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES 
('MFG_ORD_LIST', 'Production Orders', 'MFG', '/production')
ON CONFLICT (screen_code) DO NOTHING;

-- Register Menu
INSERT INTO menus (menu_code, menu_name, icon_name, module_code, screen_code, sort_order) VALUES 
('MENU_PRD', 'Production', 'factory', 'MFG', 'MFG_ORD_LIST', 50)
ON CONFLICT (menu_code) DO NOTHING;

-- Register Permissions
INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('MFG.PRD.VIEW', 'MFG', 'MFG_ORD_LIST', 'VIEW'),
('MFG.PRD.CREATE', 'MFG', 'MFG_ORD_LIST', 'CREATE'),
('MFG.PRD.UPDATE', 'MFG', 'MFG_ORD_LIST', 'UPDATE'),
('MFG.PRD.DELETE', 'MFG', 'MFG_ORD_LIST', 'DELETE')
ON CONFLICT (permission_code) DO NOTHING;

-- Assign Permissions to Admin Role
INSERT INTO role_permissions (role_id, permission_id, tenant_id)
SELECT r.id, p.id, r.tenant_id
FROM roles r
CROSS JOIN permissions p
WHERE r.role_code = 'SYSTEM_ADMIN' 
  AND p.permission_code IN ('MFG.PRD.VIEW', 'MFG.PRD.CREATE', 'MFG.PRD.UPDATE', 'MFG.PRD.DELETE')
ON CONFLICT DO NOTHING;
