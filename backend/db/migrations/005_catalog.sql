-- 005_catalog.sql

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    product_code VARCHAR(50) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    category_id UUID REFERENCES product_categories(id),
    wood_type_id UUID REFERENCES wood_types(id),
    uom_id UUID REFERENCES units_of_measure(id),
    base_price DECIMAL(15, 2) DEFAULT 0.0,
    description TEXT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, product_code)
);

-- Permissions & Module
INSERT INTO modules (module_code, module_name, module_type) VALUES ('CAT', 'Product Catalog', 'CORE') ON CONFLICT DO NOTHING;

INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES 
('CAT_PROD', 'Products', 'CAT', '/catalog'),
('CAT_CAT', 'Categories', 'CAT', '/catalog/categories')
ON CONFLICT DO NOTHING;

INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('CAT.CAT_PROD.VIEW', 'CAT', 'CAT_PROD', 'VIEW'),
('CAT.CAT_PROD.CREATE', 'CAT', 'CAT_PROD', 'CREATE'),
('CAT.CAT_PROD.UPDATE', 'CAT', 'CAT_PROD', 'UPDATE'),
('CAT.CAT_PROD.DELETE', 'CAT', 'CAT_PROD', 'DELETE'),
('CAT.CAT_CAT.VIEW', 'CAT', 'CAT_CAT', 'VIEW'),
('CAT.CAT_CAT.CREATE', 'CAT', 'CAT_CAT', 'CREATE'),
('CAT.CAT_CAT.UPDATE', 'CAT', 'CAT_CAT', 'UPDATE'),
('CAT.CAT_CAT.DELETE', 'CAT', 'CAT_CAT', 'DELETE')
ON CONFLICT DO NOTHING;
