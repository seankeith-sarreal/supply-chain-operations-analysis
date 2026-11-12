--Confirm the staging layer
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


--Review columns and data types
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'staging'
    AND table_name = 'inventory_activity'
ORDER BY table_name, ordinal_position;



--Table Grains

-- customers:
-- One row represents one customer record.

-- fulfillment_centers:
-- One row represents one fulfillment center.

-- inventory_activity:
-- One row represents one inventory activity/event record.

-- order_items:
-- One row represents one product line item within an order.

-- orders:
-- One row represents one order.

-- products:
-- One row represents one product record.

-- returns:
-- One row represents one return record.

-- shipments:
-- One row represents one shipment record.

-- stores:
-- One row represents one store.

-- suppliers:
-- One row represents one supplier record.



--Test obvious ID columns for duplicates
--Suppliers
SELECT
    COUNT(*) AS total_rows,
    COUNT(supplier_id) AS non_null_key_rows,
    COUNT(DISTINCT supplier_id) AS distinct_key_rows,
    COUNT(*) - COUNT(supplier_id) AS null_key_rows, --All rows - rows that have an ID = rows missing an ID
    COUNT(supplier_id) - COUNT(DISTINCT supplier_id) AS duplicate_key_rows, --checks for duplicate IDs
    CASE
        WHEN COUNT(*) = COUNT(supplier_id) --no missing IDs?
         AND COUNT(supplier_id) = COUNT(DISTINCT supplier_id) --no duplicate IDs?
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.suppliers;

--Products
SELECT
    COUNT(*) AS total_rows,
    COUNT(product_id) AS non_null_key_rows,
    COUNT(DISTINCT product_id) AS distinct_key_rows,
    COUNT(*) - COUNT(product_id) AS null_key_rows,
    COUNT(product_id) - COUNT(DISTINCT product_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(product_id)
         AND COUNT(product_id) = COUNT(DISTINCT product_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.products;


--Customers
SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS non_null_key_rows,
    COUNT(DISTINCT customer_id) AS distinct_key_rows,
    COUNT(*) - COUNT(customer_id) AS null_key_rows,
    COUNT(customer_id) - COUNT(DISTINCT customer_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(customer_id)
         AND COUNT(customer_id) = COUNT(DISTINCT customer_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.customers;

--Fulfillment Centerse
SELECT
    COUNT(*) AS total_rows,
    COUNT(fulfillment_center_id) AS non_null_key_rows,
    COUNT(DISTINCT fulfillment_center_id) AS distinct_key_rows,
    COUNT(*) - COUNT(fulfillment_center_id) AS null_key_rows,
    COUNT(fulfillment_center_id) - COUNT(DISTINCT fulfillment_center_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(fulfillment_center_id)
         AND COUNT(fulfillment_center_id) = COUNT(DISTINCT fulfillment_center_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.fulfillment_centers;

--Stores
SELECT
    COUNT(*) AS total_rows,
    COUNT(store_id) AS non_null_key_rows,
    COUNT(DISTINCT store_id) AS distinct_key_rows,
    COUNT(*) - COUNT(store_id) AS null_key_rows,
    COUNT(store_id) - COUNT(DISTINCT store_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(store_id)
         AND COUNT(store_id) = COUNT(DISTINCT store_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.stores;


--Orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS non_null_key_rows,
    COUNT(DISTINCT order_id) AS distinct_key_rows,
    COUNT(*) - COUNT(order_id) AS null_key_rows,
    COUNT(order_id) - COUNT(DISTINCT order_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(order_id)
         AND COUNT(order_id) = COUNT(DISTINCT order_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.orders;
--FAIL

--Shipments
SELECT
    COUNT(*) AS total_rows,
    COUNT(shipment_id) AS non_null_key_rows,
    COUNT(DISTINCT shipment_id) AS distinct_key_rows,
    COUNT(*) - COUNT(shipment_id) AS null_key_rows,
    COUNT(shipment_id) - COUNT(DISTINCT shipment_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(shipment_id)
         AND COUNT(shipment_id) = COUNT(DISTINCT shipment_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.shipments;
--Fail

--Order Items
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_item_id) AS non_null_key_rows,
    COUNT(DISTINCT order_item_id) AS distinct_key_rows,
    COUNT(*) - COUNT(order_item_id) AS null_key_rows,
    COUNT(order_item_id) - COUNT(DISTINCT order_item_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(order_item_id)
         AND COUNT(order_item_id) = COUNT(DISTINCT order_item_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.order_items;

--Returns
SELECT
    COUNT(*) AS total_rows,
    COUNT(return_id) AS non_null_key_rows,
    COUNT(DISTINCT return_id) AS distinct_key_rows,
    COUNT(*) - COUNT(return_id) AS null_key_rows,
    COUNT(return_id) - COUNT(DISTINCT return_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(return_id)
         AND COUNT(return_id) = COUNT(DISTINCT return_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.returns;
--Fail

--Inventory Activity
SELECT
    COUNT(*) AS total_rows,
    COUNT(inventory_activity_id) AS non_null_key_rows,
    COUNT(DISTINCT inventory_activity_id) AS distinct_key_rows,
    COUNT(*) - COUNT(inventory_activity_id) AS null_key_rows,
    COUNT(inventory_activity_id) - COUNT(DISTINCT inventory_activity_id) AS duplicate_key_rows,
    CASE
        WHEN COUNT(*) = COUNT(inventory_activity_id)
         AND COUNT(inventory_activity_id) = COUNT(DISTINCT inventory_activity_id)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM staging.inventory_activity;
--Fail

--Failed Primary Key Candidates
--Orders
--Shipments
--Returns
--Inventory Activity

/*
--Tables that failed the validations status
WITH pk_validation AS (

    SELECT
        'suppliers' AS table_name,
        'supplier_id' AS primary_key_candidate,
        COUNT(*) - COUNT(supplier_id) AS null_key_rows,
        COUNT(supplier_id) - COUNT(DISTINCT supplier_id) AS duplicate_key_rows
    FROM staging.suppliers

    UNION ALL

    SELECT
        'products',
        'product_id',
        COUNT(*) - COUNT(product_id),
        COUNT(product_id) - COUNT(DISTINCT product_id)
    FROM staging.products

    UNION ALL

    SELECT
        'customers',
        'customer_id',
        COUNT(*) - COUNT(customer_id),
        COUNT(customer_id) - COUNT(DISTINCT customer_id)
    FROM staging.customers

    UNION ALL

    SELECT
        'fulfillment_centers',
        'fulfillment_center_id',
        COUNT(*) - COUNT(fulfillment_center_id),
        COUNT(fulfillment_center_id) - COUNT(DISTINCT fulfillment_center_id)
    FROM staging.fulfillment_centers

    UNION ALL

    SELECT
        'stores',
        'store_id',
        COUNT(*) - COUNT(store_id),
        COUNT(store_id) - COUNT(DISTINCT store_id)
    FROM staging.stores

    UNION ALL

    SELECT
        'orders',
        'order_id',
        COUNT(*) - COUNT(order_id),
        COUNT(order_id) - COUNT(DISTINCT order_id)
    FROM staging.orders

    UNION ALL

    SELECT
        'shipments',
        'shipment_id',
        COUNT(*) - COUNT(shipment_id),
        COUNT(shipment_id) - COUNT(DISTINCT shipment_id)
    FROM staging.shipments

    UNION ALL

    SELECT
        'order_items',
        'order_item_id',
        COUNT(*) - COUNT(order_item_id),
        COUNT(order_item_id) - COUNT(DISTINCT order_item_id)
    FROM staging.order_items

    UNION ALL

    SELECT
        'returns',
        'return_id',
        COUNT(*) - COUNT(return_id),
        COUNT(return_id) - COUNT(DISTINCT return_id)
    FROM staging.returns

    UNION ALL

    SELECT
        'inventory_activity',
        'inventory_activity_id',
        COUNT(*) - COUNT(inventory_activity_id),
        COUNT(inventory_activity_id) - COUNT(DISTINCT inventory_activity_id)
    FROM staging.inventory_activity
)

SELECT
    table_name,
    primary_key_candidate,
    null_key_rows,
    duplicate_key_rows,
    'FAIL' AS validation_status
FROM pk_validation
WHERE null_key_rows > 0
   OR duplicate_key_rows > 0
ORDER BY table_name;
*/
--------------------------------------------------------------------------

--Tables that failed the validations status with percentage

WITH pk_validation AS (

    SELECT
        'suppliers' AS table_name,
        'supplier_id' AS primary_key_candidate,
        COUNT(*) AS total_rows,
        COUNT(*) - COUNT(supplier_id) AS null_key_rows,
        COUNT(supplier_id) - COUNT(DISTINCT supplier_id) AS duplicate_key_rows
    FROM staging.suppliers

    UNION ALL

    SELECT
        'products',
        'product_id',
        COUNT(*),
        COUNT(*) - COUNT(product_id),
        COUNT(product_id) - COUNT(DISTINCT product_id)
    FROM staging.products

    UNION ALL

    SELECT
        'customers',
        'customer_id',
        COUNT(*),
        COUNT(*) - COUNT(customer_id),
        COUNT(customer_id) - COUNT(DISTINCT customer_id)
    FROM staging.customers

    UNION ALL

    SELECT
        'fulfillment_centers',
        'fulfillment_center_id',
        COUNT(*),
        COUNT(*) - COUNT(fulfillment_center_id),
        COUNT(fulfillment_center_id) - COUNT(DISTINCT fulfillment_center_id)
    FROM staging.fulfillment_centers

    UNION ALL

    SELECT
        'stores',
        'store_id',
        COUNT(*),
        COUNT(*) - COUNT(store_id),
        COUNT(store_id) - COUNT(DISTINCT store_id)
    FROM staging.stores

    UNION ALL

    SELECT
        'orders',
        'order_id',
        COUNT(*),
        COUNT(*) - COUNT(order_id),
        COUNT(order_id) - COUNT(DISTINCT order_id)
    FROM staging.orders

    UNION ALL

    SELECT
        'shipments',
        'shipment_id',
        COUNT(*),
        COUNT(*) - COUNT(shipment_id),
        COUNT(shipment_id) - COUNT(DISTINCT shipment_id)
    FROM staging.shipments

    UNION ALL

    SELECT
        'order_items',
        'order_item_id',
        COUNT(*),
        COUNT(*) - COUNT(order_item_id),
        COUNT(order_item_id) - COUNT(DISTINCT order_item_id)
    FROM staging.order_items

    UNION ALL

    SELECT
        'returns',
        'return_id',
        COUNT(*),
        COUNT(*) - COUNT(return_id),
        COUNT(return_id) - COUNT(DISTINCT return_id)
    FROM staging.returns

    UNION ALL

    SELECT
        'inventory_activity',
        'inventory_activity_id',
        COUNT(*),
        COUNT(*) - COUNT(inventory_activity_id),
        COUNT(inventory_activity_id) - COUNT(DISTINCT inventory_activity_id)
    FROM staging.inventory_activity
)

SELECT
    table_name,
    primary_key_candidate,
    total_rows,
    null_key_rows,
    duplicate_key_rows,
    ROUND(
        100.0 * duplicate_key_rows / NULLIF(total_rows, 0),
        2
    ) AS duplicate_key_pct,
    CASE
        WHEN null_key_rows = 0
         AND duplicate_key_rows = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM pk_validation
ORDER BY table_name;