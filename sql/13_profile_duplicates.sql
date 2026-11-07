--Identify genuine duplicate keys and likely repeated transaction/event rows.
    --Test intended unique IDs
        --Suppliers
            --Test supplier_id uniqueness
                SELECT
                    supplier_id,
                    COUNT(*) AS occurrences
                FROM staging.suppliers
                GROUP BY supplier_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, supplier_id;

        --Products
            --Test product_id uniqueness
                SELECT
                    product_id,
                    COUNT(*) AS occurrences
                FROM staging.products
                GROUP BY product_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, product_id;

        --Customers
            --Test customer_id uniqueness
                SELECT
                    customer_id,
                    COUNT(*) AS occurrences
                FROM staging.customers
                GROUP BY customer_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, customer_id;

        --Fulfillment Centers
            --Test fulfillment_center_id uniqueness
                SELECT
                    fulfillment_center_id,
                    COUNT(*) AS occurrences
                FROM staging.fulfillment_centers
                GROUP BY fulfillment_center_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, fulfillment_center_id;

        --Stores
            --Test store_id uniqueness
                SELECT
                    store_id,
                    COUNT(*) AS occurrences
                FROM staging.stores
                GROUP BY store_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, store_id;

        --Orders
            --Test order_id uniqueness
                SELECT
                    order_id,
                    COUNT(*) AS occurrences
                FROM staging.orders
                GROUP BY order_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, order_id;

        --Shipments
            --Test shipment_id uniqueness
                SELECT
                    shipment_id,
                    COUNT(*) AS occurrences
                FROM staging.shipments
                GROUP BY shipment_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, shipment_id;

        --Order Items
            --Test order_item_id uniqueness
                SELECT
                    order_item_id,
                    COUNT(*) AS occurrences
                FROM staging.order_items
                GROUP BY order_item_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, order_item_id;

        --Returns
            --Test return_id uniqueness
                SELECT
                    return_id,
                    COUNT(*) AS occurrences
                FROM staging.returns
                GROUP BY return_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, return_id;

        --Inventory Activity
            --Test inventory_activity_id uniqueness
                SELECT
                    inventory_activity_id,
                    COUNT(*) AS occurrences
                FROM staging.inventory_activity
                GROUP BY inventory_activity_id
                HAVING COUNT(*) > 1
                ORDER BY occurrences DESC, inventory_activity_id;
    --Inventory Activity, Returns, Shipments, Orders have repeated IDs

        --Inventory Activity
            --Classify repeated inventory_activity_id values
                SELECT
                    inventory_activity_id,
                    COUNT(*) AS row_count,
                    COUNT(DISTINCT ia) AS distinct_row_versions,
                    CASE
                        WHEN COUNT(DISTINCT ia) = 1
                            THEN 'Exact duplicate rows'
                        ELSE 'Same ID, different row data'
                    END AS duplicate_type
                FROM staging.inventory_activity AS ia
                GROUP BY inventory_activity_id
                HAVING COUNT(*) > 1
                ORDER BY row_count DESC, inventory_activity_id;


        --Returns
            --Classify repeated return_id values
                SELECT
                    return_id,
                    COUNT(*) AS row_count,
                    COUNT(DISTINCT r) AS distinct_row_versions,
                    CASE
                        WHEN COUNT(DISTINCT r) = 1
                            THEN 'Exact duplicate rows'
                        ELSE 'Same ID, different row data'
                    END AS duplicate_type
                FROM staging.returns AS r
                GROUP BY return_id
                HAVING COUNT(*) > 1
                ORDER BY row_count DESC, return_id;


        --Shipments
            --Classify repeated shipment_id values
                SELECT
                    shipment_id,
                    COUNT(*) AS row_count,
                    COUNT(DISTINCT s) AS distinct_row_versions,
                    CASE
                        WHEN COUNT(DISTINCT s) = 1
                            THEN 'Exact duplicate rows'
                        ELSE 'Same ID, different row data'
                    END AS duplicate_type
                FROM staging.shipments AS s
                GROUP BY shipment_id
                HAVING COUNT(*) > 1
                ORDER BY row_count DESC, shipment_id;


        --Orders
            --Classify repeated order_id values
                SELECT
                    order_id,
                    COUNT(*) AS row_count,
                    COUNT(DISTINCT o) AS distinct_row_versions,
                    CASE
                        WHEN COUNT(DISTINCT o) = 1
                            THEN 'Exact duplicate rows'
                        ELSE 'Same ID, different row data'
                    END AS duplicate_type
                FROM staging.orders AS o
                GROUP BY order_id
                HAVING COUNT(*) > 1
                ORDER BY row_count DESC, order_id;

/*
duplicate_groups: number of distinct records duplicated
rows_in_duplicate_groups: all rows involved, including the original copies
excess_duplicate_rows: redundant copies beyond the first row*/
WITH all_rows AS (
    SELECT 'inventory_activity' AS table_name, TO_JSONB(ia) AS row_data
    FROM staging.inventory_activity AS ia

    UNION ALL

    SELECT 'returns', TO_JSONB(r)
    FROM staging.returns AS r

    UNION ALL

    SELECT 'shipments', TO_JSONB(s)
    FROM staging.shipments AS s

    UNION ALL

    SELECT 'orders', TO_JSONB(o)
    FROM staging.orders AS o
),

duplicate_groups AS (
    SELECT
        table_name,
        row_data,
        COUNT(*) AS occurrences
    FROM all_rows
    GROUP BY table_name, row_data
    HAVING COUNT(*) > 1
)

SELECT
    table_name,
    COUNT(*) AS duplicate_groups,
    SUM(occurrences) AS rows_in_duplicate_groups,
    SUM(occurrences - 1) AS excess_duplicate_rows
FROM duplicate_groups
GROUP BY table_name
ORDER BY table_name;


---------------------------------------------------------------

--Inventory Activity
    --Test potential duplicate inventory events
        SELECT
            product_id,
            fulfillment_center_id,
            store_id,
            activity_datetime,
            activity_type,
            quantity_change,
            COUNT(*) AS occurrences,
            COUNT(DISTINCT inventory_activity_id) AS distinct_ids,
            ARRAY_AGG(DISTINCT inventory_activity_id) AS related_ids
        FROM staging.inventory_activity
        GROUP BY
            product_id,
            fulfillment_center_id,
            store_id,
            activity_datetime,
            activity_type,
            quantity_change
        HAVING COUNT(DISTINCT inventory_activity_id) > 1
        ORDER BY distinct_ids DESC, occurrences DESC;


--Returns
    --Test potential duplicate return events
        SELECT
            order_item_id,
            return_datetime,
            return_quantity,
            return_reason,
            return_channel,
            COUNT(*) AS occurrences,
            COUNT(DISTINCT return_id) AS distinct_ids,
            ARRAY_AGG(DISTINCT return_id) AS related_ids
        FROM staging.returns
        GROUP BY
            order_item_id,
            return_datetime,
            return_quantity,
            return_reason,
            return_channel
        HAVING COUNT(DISTINCT return_id) > 1
        ORDER BY distinct_ids DESC, occurrences DESC;


--Order Items
    --Test potential duplicate product lines
        SELECT
            order_id,
            product_id,
            shipment_id,
            fulfillment_method,
            unit_list_price,
            unit_discount_amount,
            COUNT(*) AS occurrences,
            COUNT(DISTINCT order_item_id) AS distinct_ids,
            ARRAY_AGG(DISTINCT order_item_id) AS related_ids
        FROM staging.order_items
        GROUP BY
            order_id,
            product_id,
            shipment_id,
            fulfillment_method,
            unit_list_price,
            unit_discount_amount
        HAVING COUNT(DISTINCT order_item_id) > 1
        ORDER BY distinct_ids DESC, occurrences DESC;


--Shipments
    --Test potential duplicate shipment events
        SELECT
            order_id,
            fulfillment_center_id,
            shipped_datetime,
            carrier_name,
            shipping_method,
            COUNT(*) AS occurrences,
            COUNT(DISTINCT shipment_id) AS distinct_ids,
            ARRAY_AGG(DISTINCT shipment_id) AS related_ids
        FROM staging.shipments
        GROUP BY
            order_id,
            fulfillment_center_id,
            shipped_datetime,
            carrier_name,
            shipping_method
        HAVING COUNT(DISTINCT shipment_id) > 1
        ORDER BY distinct_ids DESC, occurrences DESC;


--Orders
    --Test potential duplicate order events
        SELECT
            customer_id,
            order_datetime,
            sales_channel,
            store_id,
            COUNT(*) AS occurrences,
            COUNT(DISTINCT order_id) AS distinct_ids,
            ARRAY_AGG(DISTINCT order_id) AS related_ids
        FROM staging.orders
        GROUP BY
            customer_id,
            order_datetime,
            sales_channel,
            store_id
        HAVING COUNT(DISTINCT order_id) > 1
        ORDER BY distinct_ids DESC, occurrences DESC;


/*
Sample Inspection

Inventory Activity contains groups of records with the same product, location, activity datetime, activity type, and quantity change, but different `inventory_activity_id` values.

These records should be reviewed as potential duplicate business events. Matching business-event fields do not automatically prove the records are duplicates, because separate inventory events can occasionally share the same characteristics.

Proposed Rule

Preserve legitimate repeated inventory events. During Phase 3, remove records only when review confirms that multiple rows represent the same business event. Records with matching business-event fields but different IDs should be treated as suspicious until validated.
*/