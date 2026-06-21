-- 003_master_data.sql

-- Generic function to apply to all master data tables
-- All master data tables share the same core columns:
-- id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by

CREATE TABLE customer_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE wood_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE units_of_measure (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE production_stages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE order_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE quotation_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE delivery_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

-- SEED DATA for SYSTEM_TENANT (Used as template for new tenants)
INSERT INTO units_of_measure (tenant_id, code, name, sort_order) VALUES
('SYSTEM_TENANT', 'PCS', 'Pieces', 10),
('SYSTEM_TENANT', 'KG', 'Kilograms', 20),
('SYSTEM_TENANT', 'M', 'Meters', 30);

INSERT INTO wood_types (tenant_id, code, name, sort_order) VALUES
('SYSTEM_TENANT', 'TEAK', 'Teak Wood', 10),
('SYSTEM_TENANT', 'MAHOGANY', 'Mahogany', 20),
('SYSTEM_TENANT', 'OAK', 'Oak Wood', 30);

INSERT INTO order_statuses (tenant_id, code, name, sort_order) VALUES
('SYSTEM_TENANT', 'DRAFT', 'Draft', 10),
('SYSTEM_TENANT', 'CONFIRMED', 'Confirmed', 20),
('SYSTEM_TENANT', 'PROCESSING', 'Processing', 30),
('SYSTEM_TENANT', 'COMPLETED', 'Completed', 40),
('SYSTEM_TENANT', 'CANCELLED', 'Cancelled', 50);

INSERT INTO production_stages (tenant_id, code, name, sort_order) VALUES
('SYSTEM_TENANT', 'CUTTING', 'Cutting', 10),
('SYSTEM_TENANT', 'CARPENTRY', 'Carpentry', 20),
('SYSTEM_TENANT', 'SANDING', 'Sanding', 30),
('SYSTEM_TENANT', 'POLISHING', 'Polishing', 40),
('SYSTEM_TENANT', 'QC', 'Quality Control', 50);

-- Master Data UI Permissions
INSERT INTO modules (module_code, module_name, module_type) VALUES ('SYS', 'System Admin', 'FOUNDATION') ON CONFLICT DO NOTHING;
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES ('MASTER_DATA', 'Master Data', 'SYS', '/master-data') ON CONFLICT DO NOTHING;

INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('SYS.MASTER_DATA.VIEW', 'SYS', 'MASTER_DATA', 'VIEW'),
('SYS.MASTER_DATA.CREATE', 'SYS', 'MASTER_DATA', 'CREATE'),
('SYS.MASTER_DATA.UPDATE', 'SYS', 'MASTER_DATA', 'UPDATE'),
('SYS.MASTER_DATA.DELETE', 'SYS', 'MASTER_DATA', 'DELETE')
ON CONFLICT DO NOTHING;
