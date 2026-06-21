-- Seed BOM for Premium Oak Dining Table
INSERT INTO boms (id, tenant_id, product_id, version_number, active_version, status, material_cost, labor_cost, overhead_cost, total_cost)
VALUES 
('d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', 'SYSTEM_TENANT', '5f77154d-b199-4f9e-b207-73d43a39b2ce', 1, true, 'Active', 150.00, 50.00, 20.00, 220.00)
ON CONFLICT (id) DO NOTHING;

-- Seed BOM Items for the Table (using Classic Oak Chair as a mock component since we don't have other raw materials)
INSERT INTO bom_items (bom_id, component_id, quantity, uom_id, unit_cost, total_cost)
VALUES
('d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d', '9c7b1c9b-aa54-4b43-85c0-a557df0c11cc', 4.00, '6a01a95c-9fd6-40ff-a8ef-cec53636e45b', 37.50, 150.00);

