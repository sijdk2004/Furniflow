INSERT INTO deliveries (
    id, tenant_id, is_active, created_on, updated_on, 
    delivery_number, production_order_id, customer_id, 
    status, expected_delivery_date, delivery_notes, 
    assigned_vehicle, assigned_driver
) VALUES (
    uuid_generate_v4(), 'SYSTEM_TENANT', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'DLV-001', '9d67f243-bb40-48c5-a718-702ec243e106', '0c56601e-f6c8-4d97-8c4e-198d14f71890',
    'Scheduled', CURRENT_TIMESTAMP + INTERVAL '2 days', 'Handle with care. Premium oak table.',
    'Truck A-123', 'John Doe'
);

INSERT INTO deliveries (
    id, tenant_id, is_active, created_on, updated_on, 
    delivery_number, production_order_id, customer_id, 
    status, expected_delivery_date, delivery_notes, 
    assigned_vehicle, assigned_driver
) VALUES (
    uuid_generate_v4(), 'SYSTEM_TENANT', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'DLV-002', '9d67f243-bb40-48c5-a718-702ec243e106', '0c56601e-f6c8-4d97-8c4e-198d14f71890',
    'In Transit', CURRENT_TIMESTAMP + INTERVAL '1 days', 'Call customer before arrival.',
    'Van B-456', 'Jane Smith'
);
