-- 004_customers.sql

CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    country_id UUID NOT NULL REFERENCES countries(id),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE cities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    state_id UUID NOT NULL REFERENCES states(id),
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    UNIQUE(tenant_id, code)
);

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    customer_type_id UUID REFERENCES customer_types(id),
    name VARCHAR(200) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(50),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    country_id UUID REFERENCES countries(id),
    state_id UUID REFERENCES states(id),
    city_id UUID REFERENCES cities(id),
    zip_code VARCHAR(20),
    tax_id VARCHAR(50),
    credit_limit DECIMAL(15, 2) DEFAULT 0.0,
    is_active BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID
);

-- Location Seed Data
INSERT INTO countries (id, tenant_id, code, name) VALUES 
('11111111-1111-1111-1111-111111111111', 'SYSTEM_TENANT', 'US', 'United States'),
('22222222-2222-2222-2222-222222222222', 'SYSTEM_TENANT', 'IN', 'India');

INSERT INTO states (id, tenant_id, country_id, code, name) VALUES 
('33333333-3333-3333-3333-333333333333', 'SYSTEM_TENANT', '11111111-1111-1111-1111-111111111111', 'CA', 'California'),
('44444444-4444-4444-4444-444444444444', 'SYSTEM_TENANT', '22222222-2222-2222-2222-222222222222', 'TN', 'Tamil Nadu');

INSERT INTO cities (id, tenant_id, state_id, code, name) VALUES 
('55555555-5555-5555-5555-555555555555', 'SYSTEM_TENANT', '33333333-3333-3333-3333-333333333333', 'SF', 'San Francisco'),
('66666666-6666-6666-6666-666666666666', 'SYSTEM_TENANT', '44444444-4444-4444-4444-444444444444', 'CHE', 'Chennai');

-- Permissions & Module
INSERT INTO modules (module_code, module_name, module_type) VALUES ('CUS', 'Customer Management', 'CORE') ON CONFLICT DO NOTHING;
INSERT INTO screens (screen_code, screen_name, module_code, route_path) VALUES ('CUS_LIST', 'Customers', 'CUS', '/customers') ON CONFLICT DO NOTHING;

INSERT INTO permissions (permission_code, module_code, screen_code, action_type) VALUES 
('CUS.CUS_LIST.VIEW', 'CUS', 'CUS_LIST', 'VIEW'),
('CUS.CUS_LIST.CREATE', 'CUS', 'CUS_LIST', 'CREATE'),
('CUS.CUS_LIST.UPDATE', 'CUS', 'CUS_LIST', 'UPDATE'),
('CUS.CUS_LIST.DELETE', 'CUS', 'CUS_LIST', 'DELETE')
ON CONFLICT DO NOTHING;
