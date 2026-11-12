CREATE TABLE staging.shipments (
    shipment_id BIGINT,
    order_id BIGINT,
    fulfillment_center_id INTEGER,
    carrier_name VARCHAR(75),
    shipping_method VARCHAR(40),
    shipment_status VARCHAR(25),
    shipped_datetime TIMESTAMP,
    expected_delivery_date DATE,
    delivered_datetime TIMESTAMP,
    shipping_distance_miles NUMERIC(10,2),
    shipment_weight_lbs NUMERIC(10,2),
    package_count SMALLINT,
    outbound_shipping_cost NUMERIC(10,2),
    fulfillment_handling_cost NUMERIC(10,2),
    delivery_exception_reason VARCHAR(75),
    is_cross_region_fulfillment BOOLEAN
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'shipments'
ORDER BY ordinal_position;


CREATE TABLE staging.returns (
    return_id BIGINT,
    order_item_id BIGINT,
    return_datetime TIMESTAMP,
    return_status VARCHAR(20),
    return_quantity SMALLINT,
    return_reason VARCHAR(50),
    return_channel VARCHAR(25),
    processing_store_id INTEGER,
    processing_fulfillment_center_id INTEGER,
    refund_amount NUMERIC(10,2),
    return_processing_cost NUMERIC(10,2),
    product_condition VARCHAR(20),
    disposition_outcome VARCHAR(30),
    reverse_shipping_cost NUMERIC(10,2),
    restocking_fee NUMERIC(10,2)
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'returns'
ORDER BY ordinal_position;

CREATE TABLE staging.inventory_activity (
    inventory_activity_id BIGINT,
    product_id INTEGER,
    fulfillment_center_id INTEGER,
    store_id INTEGER,
    order_item_id BIGINT,
    return_id BIGINT,
    activity_datetime TIMESTAMP,
    activity_type VARCHAR(30),
    quantity_change INTEGER,
    quantity_on_hand_after INTEGER,
    transfer_reference_id BIGINT,
    reorder_point_at_event INTEGER,
    activity_reason VARCHAR(100)
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'inventory_activity'
ORDER BY ordinal_position;


SELECT COUNT(*) FROM staging.shipments;
SELECT COUNT(*) FROM staging.returns;
SELECT COUNT(*) FROM staging.inventory_activity;