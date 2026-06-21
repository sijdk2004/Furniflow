-- Seed Data for FurniFlow Platform

-- Core Modules
INSERT INTO modules (module_code, module_name, module_type) VALUES 
('IAM', 'Identity Access Management', 'CORE'),
('USR', 'User Management', 'CORE'),
('ROL', 'Role Management', 'CORE'),
('DSH', 'Dashboard', 'CORE'),
('CUS', 'Customer Management', 'FOUNDATION'),
('PRD', 'Product Catalog', 'FOUNDATION'),
('MFG', 'Manufacturing', 'INDUSTRY')
ON CONFLICT (module_code) DO NOTHING;

-- Core Screens
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES 
('DSH_HOME', 'Dashboard Home', 'DSH', '/dashboard'),
('USR_LIST', 'Users', 'USR', '/users'),
('ROL_LIST', 'Roles', 'ROL', '/roles'),
('CUS_LIST', 'Customers', 'CUS', '/customers'),
('PRD_LIST', 'Products', 'PRD', '/products'),
('MFG_DSH', 'Manufacturing Dashboard', 'MFG', '/manufacturing-dashboard')
ON CONFLICT (screen_code) DO NOTHING;

-- Core Permissions
INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('DSH.DSH_HOME.VIEW', 'DSH', 'DSH_HOME', 'VIEW'),
('USR.USR_LIST.VIEW', 'USR', 'USR_LIST', 'VIEW'),
('USR.USR_LIST.CREATE', 'USR', 'USR_LIST', 'CREATE'),
('USR.USR_LIST.UPDATE', 'USR', 'USR_LIST', 'UPDATE'),
('ROL.ROL_LIST.VIEW', 'ROL', 'ROL_LIST', 'VIEW'),
('ROL.ROL_LIST.CREATE', 'ROL', 'ROL_LIST', 'CREATE'),
('ROL.ROL_LIST.UPDATE', 'ROL', 'ROL_LIST', 'UPDATE'),
('CUS.CUS_LIST.VIEW', 'CUS', 'CUS_LIST', 'VIEW'),
('PRD.PRD_LIST.VIEW', 'PRD', 'PRD_LIST', 'VIEW'),
('MFG.DSH.VIEW', 'MFG', 'MFG_DSH', 'VIEW')
ON CONFLICT (permission_code) DO NOTHING;

-- Default Menus
INSERT INTO menus (menu_code, menu_name, module_code, screen_code, icon_name, sort_order) VALUES
('MENU_DASHBOARD', 'Dashboard', 'DSH', 'DSH_HOME', 'dashboard', 10),
('MENU_MFG_DASHBOARD', 'Mfg Dashboard', 'MFG', 'MFG_DSH', 'factory', 15),
('MENU_CUSTOMERS', 'Customers', 'CUS', 'CUS_LIST', 'users', 20),
('MENU_PRODUCTS', 'Catalog', 'PRD', 'PRD_LIST', 'box', 30),
('MENU_SYSTEM', 'System', NULL, NULL, 'settings', 90)
ON CONFLICT (menu_code) DO NOTHING;

-- System Submenus
INSERT INTO menus (menu_code, menu_name, module_code, screen_code, parent_menu_id, sort_order) 
SELECT 'MENU_USERS', 'Users', 'USR', 'USR_LIST', id, 10 FROM menus WHERE menu_code = 'MENU_SYSTEM'
ON CONFLICT (menu_code) DO NOTHING;

INSERT INTO menus (menu_code, menu_name, module_code, screen_code, parent_menu_id, sort_order) 
SELECT 'MENU_ROLES', 'Roles', 'ROL', 'ROL_LIST', id, 20 FROM menus WHERE menu_code = 'MENU_SYSTEM'
ON CONFLICT (menu_code) DO NOTHING;

-- Default System Roles
INSERT INTO roles (id, tenant_id, role_code, role_name, is_system_role) VALUES 
('00000000-0000-0000-0000-000000000001', 'SYSTEM_TENANT', 'PLATFORM_ADMIN', 'Platform Administrator', TRUE),
('00000000-0000-0000-0000-000000000002', 'SYSTEM_TENANT', 'SYS_ADMIN', 'System Administrator', TRUE)
ON CONFLICT (id) DO NOTHING;

-- Assign ALL permissions to PLATFORM_ADMIN
INSERT INTO role_permissions (role_id, permission_id, tenant_id)
SELECT '00000000-0000-0000-0000-000000000001', id, 'SYSTEM_TENANT' FROM permissions
ON CONFLICT DO NOTHING;

-- Default Admin User (Password is 'password' - bcrypt hash)
INSERT INTO users (id, tenant_id, username, email, password_hash, first_name, last_name) VALUES 
('00000000-0000-0000-0000-000000000001', 'SYSTEM_TENANT', 'admin', 'admin@furniflow.com', '$2a$10$tZ2zV95JgQ.qL3J5/q9mOeQW8UqP6sB3EwG/h7o7w6QhQ8XjB9hM2', 'Platform', 'Admin')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_roles (user_id, role_id, tenant_id) VALUES 
('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'SYSTEM_TENANT')
ON CONFLICT DO NOTHING;
