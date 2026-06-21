-- BOM Module
INSERT INTO modules (module_code, module_name, module_type) VALUES 
('MFG', 'Manufacturing', 'CORE')
ON CONFLICT (module_code) DO NOTHING;

-- BOM Screen
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES 
('BOM_LIST', 'Bill of Materials', 'MFG', '/bom')
ON CONFLICT (screen_code) DO NOTHING;

-- BOM Menu
INSERT INTO menus (id, tenant_id, menu_code, menu_name, module_code, screen_code, icon_name, sort_order, is_active) VALUES
(gen_random_uuid(), 'SYSTEM_TENANT', 'MENU_BOM', 'Bill of Materials', 'MFG', 'BOM_LIST', 'box', 35, true)
ON CONFLICT (menu_code) DO NOTHING;

-- BOM Permissions
INSERT INTO permissions (id, tenant_id, permission_code, module_code, screen_code, action_type, is_active) VALUES 
(gen_random_uuid(), 'SYSTEM_TENANT', 'MFG.BOM.VIEW', 'MFG', 'BOM_LIST', 'VIEW', true),
(gen_random_uuid(), 'SYSTEM_TENANT', 'MFG.BOM.CREATE', 'MFG', 'BOM_LIST', 'CREATE', true),
(gen_random_uuid(), 'SYSTEM_TENANT', 'MFG.BOM.UPDATE', 'MFG', 'BOM_LIST', 'UPDATE', true)
ON CONFLICT (permission_code) DO NOTHING;

-- Assign to PLATFORM_ADMIN
INSERT INTO role_permissions (role_id, permission_id, tenant_id)
SELECT '00000000-0000-0000-0000-000000000001', id, 'SYSTEM_TENANT' FROM permissions WHERE module_code = 'MFG'
ON CONFLICT DO NOTHING;
