--Staging SUPPLIERS tables with no primary key or foreign key
CREATE TABLE staging.suppliers (
    supplier_id INTEGER,
    supplier_name VARCHAR(150),
    supplier_country VARCHAR(75),
    supplier_city VARCHAR(100),
    standard_lead_time_days SMALLINT,
    on_time_delivery_rate NUMERIC(5,2),
    supplier_defect_rate NUMERIC(5,2),
    supplier_status VARCHAR(20)
);

--Verify the columns & data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'suppliers'
ORDER BY ordinal_position;

--Staging PRODUCTS tables with no primary key or foreign key
CREATE TABLE staging.products (
    product_id INTEGER,
    sku VARCHAR(30),
    supplier_id INTEGER,
    product_name VARCHAR(150),
    product_category VARCHAR(50),
    product_subcategory VARCHAR(75),
    material VARCHAR(75),
    color VARCHAR(50),
    base_unit_price NUMERIC(10,2),
    standard_unit_cost NUMERIC(10,2),
    unit_weight_lbs NUMERIC(10,2),
    product_length_in NUMERIC(10,2),
    product_width_in NUMERIC(10,2),
    product_height_in NUMERIC(10,2),
    shipping_class VARCHAR(30),
    is_fragile BOOLEAN,
    assembly_required BOOLEAN,
    product_status VARCHAR(20),
    launch_date DATE,
    discontinue_date DATE,
    country_of_origin VARCHAR(75),
    return_policy_class VARCHAR(30),
    store_pickup_eligible BOOLEAN,
    package_count SMALLINT
);

--Verify the columns & data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'products'
ORDER BY ordinal_position;


--Staging FULFILLMENT CENTERS tables with no primary key or foreign key
CREATE TABLE staging.fulfillment_centers (
    fulfillment_center_id INTEGER,
    fulfillment_center_name VARCHAR(100),
    fulfillment_center_city VARCHAR(100),
    fulfillment_center_state CHAR(2),
    fulfillment_center_zip_code VARCHAR(10),
    service_region VARCHAR(30),
    daily_order_capacity INTEGER,
    standard_handling_cost_per_item NUMERIC(10,2),
    opened_date DATE,
    fulfillment_center_status VARCHAR(25),
    labor_cost_index NUMERIC(5,2),
    oversized_item_capable BOOLEAN,
    white_glove_capable BOOLEAN
);

--Verify the columns & data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'fulfillment_centers'
ORDER BY ordinal_position;



--Staging STORES tables with no primary key or foreign key
CREATE TABLE staging.stores (
    store_id INTEGER,
    store_name VARCHAR(100),
    store_city VARCHAR(100),
    store_state CHAR(2),
    store_zip_code VARCHAR(10),
    market_region VARCHAR(30),
    inventory_capacity_tier VARCHAR(10),
    click_collect_enabled BOOLEAN,
    return_processing_enabled BOOLEAN,
    standard_handling_cost_per_item NUMERIC(10,2),
    opened_date DATE,
    store_status VARCHAR(25),
    labor_cost_index NUMERIC(5,2),
    oversized_pickup_capable BOOLEAN
);

--Verify the columns & data types
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'stores'
ORDER BY ordinal_position;