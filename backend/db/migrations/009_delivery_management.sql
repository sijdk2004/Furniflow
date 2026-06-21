CREATE TABLE IF NOT EXISTS deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    remarks TEXT,
    
    delivery_number VARCHAR(50) UNIQUE NOT NULL,
    quotation_id UUID,
    sales_order_id UUID,
    production_order_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    
    delivery_date TIMESTAMP,
    expected_delivery_date TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Scheduled',
    assigned_vehicle VARCHAR(100),
    assigned_driver VARCHAR(100),
    delivery_notes TEXT,
    customer_acknowledgement BOOLEAN DEFAULT false,
    
    CONSTRAINT fk_dlv_prod_order FOREIGN KEY (production_order_id) REFERENCES production_orders(id),
    CONSTRAINT fk_dlv_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS delivery_timeline_histories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    delivery_id UUID NOT NULL,
    stage VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id UUID,
    remarks TEXT,
    
    CONSTRAINT fk_dlv_timeline_delivery FOREIGN KEY (delivery_id) REFERENCES deliveries(id) ON DELETE CASCADE
);

-- Insert module and screen
INSERT INTO modules (id, module_code, module_name, module_type)
VALUES (uuid_generate_v4(), 'DLV', 'Delivery Management', 'CORE')
ON CONFLICT (module_code) DO NOTHING;

INSERT INTO screens (id, screen_code, screen_name, module_code, route_path)
VALUES (uuid_generate_v4(), 'DLV_LIST', 'Delivery List', 'DLV', '/delivery')
ON CONFLICT (screen_code) DO NOTHING;

-- Insert Permissions
INSERT INTO permissions (id, tenant_id, permission_code, module_code, screen_code, action_type)
VALUES 
    (uuid_generate_v4(), 'SYSTEM_TENANT', 'DLV.DLV_LIST.VIEW', 'DLV', 'DLV_LIST', 'VIEW'),
    (uuid_generate_v4(), 'SYSTEM_TENANT', 'DLV.DLV_LIST.CREATE', 'DLV', 'DLV_LIST', 'CREATE'),
    (uuid_generate_v4(), 'SYSTEM_TENANT', 'DLV.DLV_LIST.UPDATE', 'DLV', 'DLV_LIST', 'UPDATE')
ON CONFLICT (permission_code) DO NOTHING;

-- Map to SYS_ADMIN role
DO $$
DECLARE
    admin_role_id UUID;
BEGIN
    SELECT id INTO admin_role_id FROM roles WHERE role_code = 'SYS_ADMIN' AND tenant_id = 'SYSTEM_TENANT';
    
    IF admin_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (tenant_id, role_id, permission_id)
        SELECT 'SYSTEM_TENANT', admin_role_id, p.id
        FROM permissions p
        WHERE p.permission_code LIKE 'DLV.%'
        AND NOT EXISTS (
            SELECT 1 FROM role_permissions rp WHERE rp.role_id = admin_role_id AND rp.permission_id = p.id
        );
    END IF;
END $$;
