CREATE TABLE boms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id VARCHAR(50) NOT NULL,
    organization_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    remarks TEXT,
    
    product_id UUID NOT NULL REFERENCES products(id),
    version_number INT NOT NULL DEFAULT 1,
    active_version BOOLEAN DEFAULT false,
    status VARCHAR(50) NOT NULL DEFAULT 'Draft',
    material_cost DECIMAL(12,2) DEFAULT 0,
    labor_cost DECIMAL(12,2) DEFAULT 0,
    overhead_cost DECIMAL(12,2) DEFAULT 0,
    total_cost DECIMAL(12,2) DEFAULT 0
);

CREATE TABLE bom_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bom_id UUID NOT NULL REFERENCES boms(id) ON DELETE CASCADE,
    component_id UUID NOT NULL REFERENCES products(id),
    quantity DECIMAL(10,2) NOT NULL,
    uom_id UUID NOT NULL REFERENCES master_data(id),
    unit_cost DECIMAL(12,2) DEFAULT 0,
    total_cost DECIMAL(12,2) DEFAULT 0
);
