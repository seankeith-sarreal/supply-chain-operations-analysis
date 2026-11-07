SELECT 'customers' AS table_name, COUNT(*) AS sql_rows FROM staging.customers
UNION ALL
SELECT 'products', COUNT(*) FROM staging.products
UNION ALL
SELECT 'suppliers', COUNT(*) FROM staging.suppliers
UNION ALL
SELECT 'fulfillment_centers', COUNT(*) FROM staging.fulfillment_centers
UNION ALL
SELECT 'stores', COUNT(*) FROM staging.stores
UNION ALL
SELECT 'orders', COUNT(*) FROM staging.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM staging.order_items
UNION ALL
SELECT 'shipments', COUNT(*) FROM staging.shipments
UNION ALL
SELECT 'returns', COUNT(*) FROM staging.returns
UNION ALL
SELECT 'inventory_activity', COUNT(*) FROM staging.inventory_activity
ORDER BY table_name;

--Verify the table count
SELECT COUNT(*) AS staging_table_count
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND table_type = 'BASE TABLE';
--Expected 10

--Verify every table is queryable
SELECT * FROM staging.customers LIMIT 5;
SELECT * FROM staging.products LIMIT 5;
SELECT * FROM staging.suppliers LIMIT 5;
SELECT * FROM staging.fulfillment_centers LIMIT 5;
SELECT * FROM staging.stores LIMIT 5;
SELECT * FROM staging.orders LIMIT 5;
SELECT * FROM staging.order_items LIMIT 5;
SELECT * FROM staging.shipments LIMIT 5;
SELECT * FROM staging.returns LIMIT 5;
SELECT * FROM staging.inventory_activity LIMIT 5;


--Reconciliation record
WITH expected_counts AS (
    SELECT *
    FROM (
        VALUES
            ('suppliers', 60),
            ('products', 2000),
            ('customers', 200800),
            ('fulfillment_centers', 8),
            ('stores', 35),
            ('orders', 501000),
            ('shipments', 287191),
            ('order_items', 874891),
            ('returns', 77716),
            ('inventory_activity', 1241264)
    ) AS t(table_name, expected_row_count)
),

actual_counts AS (
    SELECT 'suppliers' AS table_name, COUNT(*) AS actual_row_count FROM staging.suppliers
    UNION ALL
    SELECT 'products', COUNT(*) FROM staging.products
    UNION ALL
    SELECT 'customers', COUNT(*) FROM staging.customers
    UNION ALL
    SELECT 'fulfillment_centers', COUNT(*) FROM staging.fulfillment_centers
    UNION ALL
    SELECT 'stores', COUNT(*) FROM staging.stores
    UNION ALL
    SELECT 'orders', COUNT(*) FROM staging.orders
    UNION ALL
    SELECT 'shipments', COUNT(*) FROM staging.shipments
    UNION ALL
    SELECT 'order_items', COUNT(*) FROM staging.order_items
    UNION ALL
    SELECT 'returns', COUNT(*) FROM staging.returns
    UNION ALL
    SELECT 'inventory_activity', COUNT(*) FROM staging.inventory_activity
)

SELECT
    e.table_name,
    e.expected_row_count,
    a.actual_row_count,
    a.actual_row_count - e.expected_row_count AS difference,
    CASE
        WHEN a.actual_row_count = e.expected_row_count THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM expected_counts e
JOIN actual_counts a
    ON e.table_name = a.table_name
ORDER BY e.table_name;


--Varify Total imported raw rows = 3184965
WITH total_rows AS (
    SELECT
        (SELECT COUNT(*) FROM staging.suppliers)
            +
        (SELECT COUNT(*) FROM staging.products)
            +
        (SELECT COUNT(*) FROM staging.customers)
            +
        (SELECT COUNT(*) FROM staging.fulfillment_centers)
            +
        (SELECT COUNT(*) FROM staging.stores)
            +
        (SELECT COUNT(*) FROM staging.orders)
            +
        (SELECT COUNT(*) FROM staging.shipments)
            +
        (SELECT COUNT(*) FROM staging.order_items)
            +
        (SELECT COUNT(*) FROM staging.returns)
            +
        (SELECT COUNT(*) FROM staging.inventory_activity) AS actual_total_raw_rows
    )

SELECT
    3184965 AS expected_total_raw_rows,
    actual_total_raw_rows,
    actual_total_raw_rows - 3184965 AS difference,
    CASE
        WHEN actual_total_raw_rows = 3184965 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM total_rows;