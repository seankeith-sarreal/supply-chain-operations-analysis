
--Customers Table
    --Columns with Null Values
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
            COUNT(*) FILTER (WHERE first_name IS NULL) AS first_name_nulls,
            COUNT(*) FILTER (WHERE last_name IS NULL) AS last_name_nulls,
            COUNT(*) FILTER (WHERE email_address IS NULL) AS email_address_nulls,
            COUNT(*) FILTER (WHERE customer_city IS NULL) AS customer_city_nulls,
            COUNT(*) FILTER (WHERE customer_state IS NULL) AS customer_state_nulls,
            COUNT(*) FILTER (WHERE customer_zip_code IS NULL) AS customer_zip_code_nulls,
            COUNT(*) FILTER (WHERE customer_created_date IS NULL) AS customer_created_date_nulls,
            COUNT(*) FILTER (WHERE loyalty_member IS NULL) AS loyalty_member_nulls,
            COUNT(*) FILTER (WHERE loyalty_join_date IS NULL) AS loyalty_join_date_nulls,
            COUNT(*) FILTER (WHERE customer_type IS NULL) AS customer_type_nulls,
            COUNT(*) FILTER (WHERE loyalty_tier IS NULL) AS loyalty_tier_nulls
        FROM staging.customers;

    --Percentage of null values for Customer_City
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE customer_city IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS customer_city_null_pct
        FROM staging.customers;
        --0.63% of customers have missing city data

    --Suspicious Rows
        SELECT *
        FROM(
            SELECT
                'loyalty_member_missing_join_date' AS rule_name,
                COUNT(*) AS suspicious_rows
            FROM staging.customers
            WHERE loyalty_member = TRUE
            AND loyalty_join_date IS NULL

            UNION ALL

            SELECT
                'non_loyalty_member_has_join_date',
                COUNT(*)
            FROM staging.customers
            WHERE loyalty_member = FALSE
            AND loyalty_join_date IS NOT NULL

            UNION ALL

            SELECT
                'loyalty_member_missing_tier',
                COUNT(*)
            FROM staging.customers
            WHERE loyalty_member = TRUE
            AND loyalty_tier IS NULL

            UNION ALL

            SELECT
                'non_loyalty_member_has_tier',
                COUNT(*)
            FROM staging.customers
            WHERE loyalty_member = FALSE
            AND loyalty_tier IS NOT NULL

            UNION ALL

            SELECT
                'loyalty_join_date_before_customer_created_date',
                COUNT(*)
            FROM staging.customers
            WHERE loyalty_join_date IS NOT NULL
            AND loyalty_join_date < customer_created_date
            ) AS suspicious_summary
            WHERE suspicious_rows > 0
        ORDER BY suspicious_rows DESC;

-- Fulfillment Centers Table
    --Nulls in Fulfillment Centers
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE fulfillment_center_id IS NULL) AS fulfillment_center_id_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_name IS NULL) AS fulfillment_center_name_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_city IS NULL) AS fulfillment_center_city_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_state IS NULL) AS fulfillment_center_state_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_zip_code IS NULL) AS fulfillment_center_zip_code_nulls,
            COUNT(*) FILTER (WHERE service_region IS NULL) AS service_region_nulls,
            COUNT(*) FILTER (WHERE daily_order_capacity IS NULL) AS daily_order_capacity_nulls,
            COUNT(*) FILTER (WHERE standard_handling_cost_per_item IS NULL) AS standard_handling_cost_per_item_nulls,
            COUNT(*) FILTER (WHERE opened_date IS NULL) AS opened_date_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_status IS NULL) AS fulfillment_center_status_nulls,
            COUNT(*) FILTER (WHERE labor_cost_index IS NULL) AS labor_cost_index_nulls,
            COUNT(*) FILTER (WHERE oversized_item_capable IS NULL) AS oversized_item_capable_nulls,
            COUNT(*) FILTER (WHERE white_glove_capable IS NULL) AS white_glove_capable_nulls
        FROM staging.fulfillment_centers;
--0 nulls

--Suppliers Table
    --Nulls in Suppliers
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE supplier_id IS NULL) AS supplier_id_nulls,
            COUNT(*) FILTER (WHERE supplier_name IS NULL) AS supplier_name_nulls,
            COUNT(*) FILTER (WHERE supplier_country IS NULL) AS supplier_country_nulls,
            COUNT(*) FILTER (WHERE supplier_city IS NULL) AS supplier_city_nulls,
            COUNT(*) FILTER (WHERE standard_lead_time_days IS NULL) AS standard_lead_time_days_nulls,
            COUNT(*) FILTER (WHERE on_time_delivery_rate IS NULL) AS on_time_delivery_rate_nulls,
            COUNT(*) FILTER (WHERE supplier_defect_rate IS NULL) AS supplier_defect_rate_nulls,
            COUNT(*) FILTER (WHERE supplier_status IS NULL) AS supplier_status_nulls
        FROM staging.suppliers;
        --0 Nulls

--Products Table
    --Nulls in Products
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
            COUNT(*) FILTER (WHERE sku IS NULL) AS sku_nulls,
            COUNT(*) FILTER (WHERE supplier_id IS NULL) AS supplier_id_nulls,
            COUNT(*) FILTER (WHERE product_name IS NULL) AS product_name_nulls,
            COUNT(*) FILTER (WHERE product_category IS NULL) AS product_category_nulls,
            COUNT(*) FILTER (WHERE product_subcategory IS NULL) AS product_subcategory_nulls,
            COUNT(*) FILTER (WHERE material IS NULL) AS material_nulls,
            COUNT(*) FILTER (WHERE color IS NULL) AS color_nulls,
            COUNT(*) FILTER (WHERE base_unit_price IS NULL) AS base_unit_price_nulls,
            COUNT(*) FILTER (WHERE standard_unit_cost IS NULL) AS standard_unit_cost_nulls,
            COUNT(*) FILTER (WHERE unit_weight_lbs IS NULL) AS unit_weight_lbs_nulls,
            COUNT(*) FILTER (WHERE product_length_in IS NULL) AS product_length_in_nulls,
            COUNT(*) FILTER (WHERE product_width_in IS NULL) AS product_width_in_nulls,
            COUNT(*) FILTER (WHERE product_height_in IS NULL) AS product_height_in_nulls,
            COUNT(*) FILTER (WHERE shipping_class IS NULL) AS shipping_class_nulls,
            COUNT(*) FILTER (WHERE is_fragile IS NULL) AS is_fragile_nulls,
            COUNT(*) FILTER (WHERE assembly_required IS NULL) AS assembly_required_nulls,
            COUNT(*) FILTER (WHERE product_status IS NULL) AS product_status_nulls,
            COUNT(*) FILTER (WHERE launch_date IS NULL) AS launch_date_nulls,
            COUNT(*) FILTER (WHERE discontinue_date IS NULL) AS discontinue_date_nulls,
            COUNT(*) FILTER (WHERE country_of_origin IS NULL) AS country_of_origin_nulls,
            COUNT(*) FILTER (WHERE return_policy_class IS NULL) AS return_policy_class_nulls,
            COUNT(*) FILTER (WHERE store_pickup_eligible IS NULL) AS store_pickup_eligible_nulls,
            COUNT(*) FILTER (WHERE package_count IS NULL) AS package_count_nulls
        FROM staging.products;
        --discontinue_date is expected to have null values
        --null values for materials are not impactful

    --Suspicious Rows
        SELECT *
            FROM(
                SELECT
                    'discontinued_product_missing_discontinue_date' AS rule_name,
                    COUNT(*) AS suspicious_rows
                FROM staging.products
                WHERE product_status = 'Discontinued'
                AND discontinue_date IS NULL

                UNION ALL

                SELECT
                    'non_discontinued_product_has_discontinue_date',
                    COUNT(*)
                FROM staging.products
                WHERE product_status <> 'Discontinued'
                AND discontinue_date IS NOT NULL
                ) AS suspicious_summary
                WHERE suspicious_rows > 0
                ORDER BY suspicious_rows DESC;

--Stores
    --Nulls in Stores
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE store_id IS NULL) AS store_id_nulls,
            COUNT(*) FILTER (WHERE store_name IS NULL) AS store_name_nulls,
            COUNT(*) FILTER (WHERE store_city IS NULL) AS store_city_nulls,
            COUNT(*) FILTER (WHERE store_state IS NULL) AS store_state_nulls,
            COUNT(*) FILTER (WHERE store_zip_code IS NULL) AS store_zip_code_nulls,
            COUNT(*) FILTER (WHERE market_region IS NULL) AS market_region_nulls,
            COUNT(*) FILTER (WHERE inventory_capacity_tier IS NULL) AS inventory_capacity_tier_nulls,
            COUNT(*) FILTER (WHERE click_collect_enabled IS NULL) AS click_collect_enabled_nulls,
            COUNT(*) FILTER (WHERE return_processing_enabled IS NULL) AS return_processing_enabled_nulls,
            COUNT(*) FILTER (WHERE standard_handling_cost_per_item IS NULL) AS standard_handling_cost_per_item_nulls,
            COUNT(*) FILTER (WHERE opened_date IS NULL) AS opened_date_nulls,
            COUNT(*) FILTER (WHERE store_status IS NULL) AS store_status_nulls,
            COUNT(*) FILTER (WHERE labor_cost_index IS NULL) AS labor_cost_index_nulls,
            COUNT(*) FILTER (WHERE oversized_pickup_capable IS NULL) AS oversized_pickup_capable_nulls
        FROM staging.stores;
    --0 Nulls

--Orders Table
    --Nulls in Orders
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
            COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
            COUNT(*) FILTER (WHERE store_id IS NULL) AS store_id_nulls,
            COUNT(*) FILTER (WHERE order_datetime IS NULL) AS order_datetime_nulls,
            COUNT(*) FILTER (WHERE sales_channel IS NULL) AS sales_channel_nulls,
            COUNT(*) FILTER (WHERE order_status IS NULL) AS order_status_nulls,
            COUNT(*) FILTER (WHERE destination_city IS NULL) AS destination_city_nulls,
            COUNT(*) FILTER (WHERE destination_state IS NULL) AS destination_state_nulls,
            COUNT(*) FILTER (WHERE destination_zip_code IS NULL) AS destination_zip_code_nulls,
            COUNT(*) FILTER (WHERE customer_shipping_fee IS NULL) AS customer_shipping_fee_nulls,
            COUNT(*) FILTER (WHERE cancellation_reason IS NULL) AS cancellation_reason_nulls,
            COUNT(*) FILTER (WHERE cancellation_datetime IS NULL) AS cancellation_datetime_nulls,
            COUNT(*) FILTER (WHERE promotion_code IS NULL) AS promotion_code_nulls,
            COUNT(*) FILTER (WHERE requested_service_level IS NULL) AS requested_service_level_nulls
        FROM staging.orders;

    --Percentage of null values
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE store_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS store_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE requested_service_level IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS requested_service_level_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE destination_state IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS destination_state_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE destination_city IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS destination_city_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE destination_zip_code IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS destination_zip_code_null_pct
        FROM staging.orders;
        --store_id = 55.08% null
        --requested_service_level = 29.94% null
        --destination_state, destination_city, and destination_zip_code = 44.92% null

    --Suspicious Rows
        SELECT *
            FROM(
                SELECT
                    'non_instore_order_missing_customer_id' AS rule_name,
                    COUNT(*) AS suspicious_rows
                FROM staging.orders
                WHERE sales_channel <> 'In-Store'
                AND customer_id IS NULL

                UNION ALL

                SELECT
                    'instore_or_click_collect_missing_store_id',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel IN ('In-Store', 'Click-and-Collect')
                AND store_id IS NULL

                UNION ALL

                SELECT
                    'online_order_has_store_id',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel = 'Online'
                AND store_id IS NOT NULL

                UNION ALL

                SELECT
                    'online_order_missing_destination_city',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel = 'Online'
                AND destination_city IS NULL

                UNION ALL

                SELECT
                    'online_order_missing_destination_state',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel = 'Online'
                AND destination_state IS NULL

                UNION ALL

                SELECT
                    'online_order_missing_destination_zip_code',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel = 'Online'
                AND destination_zip_code IS NULL

                UNION ALL

                SELECT
                    'non_online_order_has_destination',
                    COUNT(*)
                FROM staging.orders
                WHERE sales_channel IN ('In-Store', 'Click-and-Collect')
                AND (
                    destination_city IS NOT NULL
                    OR destination_state IS NOT NULL
                    OR destination_zip_code IS NOT NULL
                )

                UNION ALL

                SELECT
                    'cancelled_order_missing_cancellation_reason',
                    COUNT(*)
                FROM staging.orders
                WHERE order_status = 'Cancelled'
                AND cancellation_reason IS NULL

                UNION ALL

                SELECT
                    'cancelled_order_missing_cancellation_datetime',
                    COUNT(*)
                FROM staging.orders
                WHERE order_status = 'Cancelled'
                AND cancellation_datetime IS NULL

                UNION ALL

                SELECT
                    'non_cancelled_order_has_cancellation_reason',
                    COUNT(*)
                FROM staging.orders
                WHERE order_status <> 'Cancelled'
                AND cancellation_reason IS NOT NULL

                UNION ALL

                SELECT
                    'non_cancelled_order_has_cancellation_datetime',
                    COUNT(*)
                FROM staging.orders
                WHERE order_status <> 'Cancelled'
                AND cancellation_datetime IS NOT NULL
                ) AS suspicious_summary
                WHERE suspicious_rows > 0
                ORDER BY suspicious_rows DESC;
        --non_cancelled_order_has_cancellation_datetime = 145
        --non_cancelled_order_has_cancellation_reason = 145

        SELECT
            COUNT(*) FILTER(WHERE cancellation_datetime IS NOT NULL) AS non_cancelled_with_cancellation_datetime,
            COUNT(*) FILTER(WHERE cancellation_reason IS NOT NULL) AS non_cancelled_with_cancellation_reason,
            COUNT(*) FILTER(WHERE cancellation_datetime IS NOT NULL
            AND cancellation_reason IS NOT NULL) AS non_cancelled_with_cancellation_date_time_and_reason
        FROM staging.orders
        WHERE LOWER(TRIM(order_status)) NOT IN ('cancelled', 'canceled', 'legacy:cancelled');


        SELECT
            order_status,
            COUNT(*) AS row_count
        FROM staging.orders
        WHERE cancellation_datetime IS NOT NULL
            OR cancellation_reason IS NOT NULL
        GROUP BY order_status;



--Shipments Table
    --Nulls in Shipments
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE shipment_id IS NULL) AS shipment_id_nulls,
            COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_id IS NULL) AS fulfillment_center_id_nulls,
            COUNT(*) FILTER (WHERE carrier_name IS NULL) AS carrier_name_nulls,
            COUNT(*) FILTER (WHERE shipping_method IS NULL) AS shipping_method_nulls,
            COUNT(*) FILTER (WHERE shipment_status IS NULL) AS shipment_status_nulls,
            COUNT(*) FILTER (WHERE shipped_datetime IS NULL) AS shipped_datetime_nulls,
            COUNT(*) FILTER (WHERE expected_delivery_date IS NULL) AS expected_delivery_date_nulls,
            COUNT(*) FILTER (WHERE delivered_datetime IS NULL) AS delivered_datetime_nulls,
            COUNT(*) FILTER (WHERE shipping_distance_miles IS NULL) AS shipping_distance_miles_nulls,
            COUNT(*) FILTER (WHERE shipment_weight_lbs IS NULL) AS shipment_weight_lbs_nulls,
            COUNT(*) FILTER (WHERE package_count IS NULL) AS package_count_nulls,
            COUNT(*) FILTER (WHERE outbound_shipping_cost IS NULL) AS outbound_shipping_cost_nulls,
            COUNT(*) FILTER (WHERE fulfillment_handling_cost IS NULL) AS fulfillment_handling_cost_nulls,
            COUNT(*) FILTER (WHERE delivery_exception_reason IS NULL) AS delivery_exception_reason_nulls,
            COUNT(*) FILTER (WHERE is_cross_region_fulfillment IS NULL) AS is_cross_region_fulfillment_nulls
        FROM staging.shipments;

    --Percentage of null values
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE expected_delivery_date IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS expected_delivery_date_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE delivery_exception_reason IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS delivery_exception_reason_null_pct
        FROM staging.shipments;
        --expected_delivery_date = 0.63%
        --delivery_exception_reason = 100%

    --Suspicious Rows
        SELECT *
            FROM(
                SELECT
                    'delivered_shipment_missing_shipped_datetime' AS rule_name,
                    COUNT(*) AS suspicious_rows
                FROM staging.shipments
                WHERE shipment_status = 'Delivered'
                AND shipped_datetime IS NULL

                UNION ALL

                SELECT
                    'delivered_shipment_missing_delivered_datetime',
                    COUNT(*)
                FROM staging.shipments
                WHERE shipment_status = 'Delivered'
                AND delivered_datetime IS NULL

                UNION ALL

                SELECT
                    'non_delivered_shipment_has_delivered_datetime',
                    COUNT(*)
                FROM staging.shipments
                WHERE shipment_status <> 'Delivered'
                AND delivered_datetime IS NOT NULL
                ) AS suspicious_summary
                WHERE suspicious_rows > 0
                ORDER BY suspicious_rows DESC;
        --non_delivered_shipment_has_delivered_datetime = 4141


        SELECT
            shipment_status,
            COUNT(*) AS row_count
        FROM staging.shipments
        GROUP BY shipment_status
        ORDER BY row_count DESC;

        SELECT
            COUNT(*) AS row_count
        FROM staging.shipments
        WHERE delivered_datetime IS NOT NULL
        AND LOWER(TRIM(shipment_status)) NOT IN ('delivered', 'legacy:delivered');


--Order Items Table
    --Nulls in Order Items
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE order_item_id IS NULL) AS order_item_id_nulls,
            COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
            COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
            COUNT(*) FILTER (WHERE shipment_id IS NULL) AS shipment_id_nulls,
            COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulls,
            COUNT(*) FILTER (WHERE unit_list_price IS NULL) AS unit_list_price_nulls,
            COUNT(*) FILTER (WHERE unit_discount_amount IS NULL) AS unit_discount_amount_nulls,
            COUNT(*) FILTER (WHERE unit_product_cost IS NULL) AS unit_product_cost_nulls,
            COUNT(*) FILTER (WHERE fulfillment_method IS NULL) AS fulfillment_method_nulls,
            COUNT(*) FILTER (WHERE order_item_status IS NULL) AS order_item_status_nulls,
            COUNT(*) FILTER (WHERE store_handling_cost IS NULL) AS store_handling_cost_nulls,
            COUNT(*) FILTER (WHERE discount_type IS NULL) AS discount_type_nulls,
            COUNT(*) FILTER (WHERE backorder_flag IS NULL) AS backorder_flag_nulls,
            COUNT(*) FILTER (WHERE item_cancellation_reason IS NULL) AS item_cancellation_reason_nulls,
            COUNT(*) FILTER (WHERE item_cancellation_datetime IS NULL) AS item_cancellation_datetime_nulls
        FROM staging.order_items;

    --Percentage of null values
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE shipment_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS shipment_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE item_cancellation_reason IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS item_cancellation_reason_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE item_cancellation_datetime IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS item_cancellation_datetime_null_pct
        FROM staging.order_items;
        --shipment_id = 46.43%
        --item_cancellation_reason = 97.55%
        --item_cancellation_datetime = 97.55%

    --suspicious_rows
        SELECT *
        FROM(
                SELECT
                    'shipment_missing_for_home_delivery' AS rule_name,
                    COUNT(*) AS suspicious_rows
                FROM staging.order_items
                WHERE fulfillment_method = 'Home Delivery'
                AND shipment_id IS NULL

                UNION ALL

                SELECT
                    'shipment_present_for_in_store',
                    COUNT(*)
                FROM staging.order_items
                WHERE fulfillment_method = 'In-Store'
                AND shipment_id IS NOT NULL

                UNION ALL

                SELECT
                    'cancelled_item_missing_reason',
                    COUNT(*)
                FROM staging.order_items
                WHERE order_item_status = 'Cancelled'
                AND item_cancellation_reason IS NULL

                UNION ALL

                SELECT
                    'cancelled_item_missing_datetime',
                    COUNT(*)
                FROM staging.order_items
                WHERE order_item_status = 'Cancelled'
                AND item_cancellation_datetime IS NULL

                UNION ALL

                SELECT
                    'non_cancelled_item_has_cancellation_reason',
                    COUNT(*)
                FROM staging.order_items
                WHERE order_item_status <> 'Cancelled'
                AND item_cancellation_reason IS NOT NULL

                UNION ALL

                SELECT
                    'non_cancelled_item_has_cancellation_datetime',
                    COUNT(*)
                FROM staging.order_items
                WHERE order_item_status <> 'Cancelled'
                AND item_cancellation_datetime IS NOT NULL

                UNION ALL

                SELECT
                    'discount_exceeds_list_price',
                    COUNT(*)
                FROM staging.order_items
                WHERE unit_discount_amount > unit_list_price

                UNION ALL

                SELECT
                    'home_delivery_has_store_handling_cost',
                    COUNT(*)
                FROM staging.order_items
                WHERE fulfillment_method = 'Home Delivery'
                AND store_handling_cost > 0
            ) AS suspicious_summary
            WHERE suspicious_rows > 0
            ORDER BY suspicious_rows DESC;
        --shipment_mission_for_home_delivery = 13422
        --discount_exceeds_list_price = 656
        --non_cancelled_item_has_cancellation_reason = 360
        --non_cancelled_item_has_cancellation_datetime = 360

SELECT *
FROM staging.order_items
LIMIT 5


        SELECT
            LOWER(TRIM(order_item_status)),
            COUNT(*) AS row_count
        FROM staging.order_items
        WHERE shipment_id IS NULL and
            LOWER(TRIM(fulfillment_method)) = 'home delivery'
        GROUP BY LOWER(TRIM(order_item_status));


        SELECT
            COUNT(*) FILTER (WHERE LOWER(TRIM(order_item_status)) = 'cancelled') AS order_item_cancelled_ct,
            COUNT(*) FILTER (WHERE shipment_id IS NULL AND LOWER(TRIM(order_item_status)) = 'cancelled') AS cancelled_shipment_id_nulls
        FROM staging.order_items


--------------------------------


SELECT
    COUNT(*) FILTER (
        WHERE item_cancellation_datetime IS NOT NULL
    ) AS non_cancelled_order_items_datetime,
    COUNT(*) FILTER (
        WHERE item_cancellation_reason IS NOT NULL
    ) AS non_cancelled_order_item_reason,
    COUNT(*) FILTER (
        WHERE item_cancellation_datetime IS NOT NULL
            AND item_cancellation_reason IS NOT NULL
    ) AS non_cancelled_order_item_reason_and_datetime
FROM staging.order_items
WHERE LOWER(TRIM(order_item_status)) NOT IN ('cancelled', 'canceled', 'legacy:cancelled');


SELECT
    order_item_status,
    COUNT(*) AS row_count
FROM staging.order_items
WHERE item_cancellation_datetime IS NOT NULL OR item_cancellation_reason IS NOT NULL
GROUP BY order_item_status;

--Returns Table
    --Nulls in Returns
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE return_id IS NULL) AS return_id_nulls,
            COUNT(*) FILTER (WHERE order_item_id IS NULL) AS order_item_id_nulls,
            COUNT(*) FILTER (WHERE return_datetime IS NULL) AS return_datetime_nulls,
            COUNT(*) FILTER (WHERE return_status IS NULL) AS return_status_nulls,
            COUNT(*) FILTER (WHERE return_quantity IS NULL) AS return_quantity_nulls,
            COUNT(*) FILTER (WHERE return_reason IS NULL) AS return_reason_nulls,
            COUNT(*) FILTER (WHERE return_channel IS NULL) AS return_channel_nulls,
            COUNT(*) FILTER (WHERE processing_store_id IS NULL) AS processing_store_id_nulls,
            COUNT(*) FILTER (WHERE processing_fulfillment_center_id IS NULL) AS processing_fulfillment_center_id_nulls,
            COUNT(*) FILTER (WHERE refund_amount IS NULL) AS refund_amount_nulls,
            COUNT(*) FILTER (WHERE return_processing_cost IS NULL) AS return_processing_cost_nulls,
            COUNT(*) FILTER (WHERE product_condition IS NULL) AS product_condition_nulls,
            COUNT(*) FILTER (WHERE disposition_outcome IS NULL) AS disposition_outcome_nulls,
            COUNT(*) FILTER (WHERE reverse_shipping_cost IS NULL) AS reverse_shipping_cost_nulls,
            COUNT(*) FILTER (WHERE restocking_fee IS NULL) AS restocking_fee_nulls
        FROM staging.returns;

    --Percentage of Null Values
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE processing_store_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS processing_store_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE processing_fulfillment_center_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS processing_fulfillment_center_id_null_pct
        FROM staging.returns;
        --shipment_id = 45.58%
        --item_cancellation_reason = 54.42%

    --Suspicious_rows
        SELECT *
        FROM(
            SELECT
                'both_processing_locations_missing' AS rule_name,
                COUNT(*) AS suspicious_rows
            FROM staging.returns
            WHERE processing_store_id IS NULL
            AND processing_fulfillment_center_id IS NULL

            UNION ALL

            SELECT
                'both_processing_locations_populated',
                COUNT(*)
            FROM staging.returns
            WHERE processing_store_id IS NOT NULL
            AND processing_fulfillment_center_id IS NOT NULL

            UNION ALL

            SELECT
                'processed_return_missing_product_condition',
                COUNT(*)
            FROM staging.returns
            WHERE return_status = 'Processed'
            AND product_condition IS NULL

            UNION ALL

            SELECT
                'processed_return_missing_disposition_outcome',
                COUNT(*)
            FROM staging.returns
            WHERE return_status = 'Processed'
            AND disposition_outcome IS NULL

            UNION ALL

            SELECT
                'unprocessed_return_has_disposition_outcome',
                COUNT(*)
            FROM staging.returns
            WHERE return_status <> 'Processed'
            AND disposition_outcome IS NOT NULL

            UNION ALL

            SELECT
                'store_return_has_reverse_shipping_cost',
                COUNT(*)
            FROM staging.returns
            WHERE return_channel = 'Store'
            AND reverse_shipping_cost > 0
            ) AS suspicious_summary
            WHERE suspicious_rows > 0
            ORDER BY suspicious_rows DESC;
        --processed_return_missing_product_condition = 486

        SELECT
            return_status,
            COUNT(*) AS row_count,
            COUNT(DISTINCT return_id) AS unique_affected_returns
        FROM staging.returns
        WHERE product_condition IS NULL
            AND LOWER(TRIM(return_status)) = 'processed'
        GROUP BY return_status

--Inventory Activity Table
    --Nulls in Inventory Activity
        SELECT
            COUNT(*) AS total_rows,
            COUNT(*) FILTER (WHERE inventory_activity_id IS NULL) AS inventory_activity_id_nulls,
            COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
            COUNT(*) FILTER (WHERE fulfillment_center_id IS NULL) AS fulfillment_center_id_nulls,
            COUNT(*) FILTER (WHERE store_id IS NULL) AS store_id_nulls,
            COUNT(*) FILTER (WHERE order_item_id IS NULL) AS order_item_id_nulls,
            COUNT(*) FILTER (WHERE return_id IS NULL) AS return_id_nulls,
            COUNT(*) FILTER (WHERE activity_datetime IS NULL) AS activity_datetime_nulls,
            COUNT(*) FILTER (WHERE activity_type IS NULL) AS activity_type_nulls,
            COUNT(*) FILTER (WHERE quantity_change IS NULL) AS quantity_change_nulls,
            COUNT(*) FILTER (WHERE quantity_on_hand_after IS NULL) AS quantity_on_hand_after_nulls,
            COUNT(*) FILTER (WHERE transfer_reference_id IS NULL) AS transfer_reference_id_nulls,
            COUNT(*) FILTER (WHERE reorder_point_at_event IS NULL) AS reorder_point_at_event_nulls,
            COUNT(*) FILTER (WHERE activity_reason IS NULL) AS activity_reason_nulls
        FROM staging.inventory_activity;

    --Percentage of Null Values
        SELECT
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE fulfillment_center_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS fulfillment_center_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE store_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS store_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE order_item_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS order_item_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE return_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS return_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE transfer_reference_id IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS transfer_reference_id_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE reorder_point_at_event IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS reorder_point_at_event_null_pct,
            ROUND(
                100.0 * COUNT(*) FILTER (WHERE activity_reason IS NULL)
                / NULLIF(COUNT(*), 0), 2
            ) AS activity_reason_null_pct
        FROM staging.inventory_activity;
        --fulfillment_center_id = 43.24%
        --store_id = 56.76%
        --order_item_id = 31.10%
        --return_id = 96.26%
        --transfer_reference_id = 91.38%
        --reorder_point_at_event = 1.25%
        --activity_reason = 99.60%

    --Suspicious Rows
        SELECT *
        FROM(
            SELECT
                'both_locations_missing' AS rule_name,
                COUNT(*) AS suspicious_rows
            FROM staging.inventory_activity
            WHERE fulfillment_center_id IS NULL
            AND store_id IS NULL

            UNION ALL

            SELECT
                'both_locations_populated',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE fulfillment_center_id IS NOT NULL
            AND store_id IS NOT NULL

            UNION ALL

            SELECT
                'sale_fulfillment_missing_order_item_id',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type = 'Sale Fulfillment'
            AND order_item_id IS NULL

            UNION ALL

            SELECT
                'return_restock_missing_return_id',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type = 'Return Restock'
            AND return_id IS NULL

            UNION ALL

            SELECT
                'transfer_missing_reference_id',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type IN ('Transfer In', 'Transfer Out')
            AND transfer_reference_id IS NULL

            UNION ALL

            SELECT
                'non_transfer_has_reference_id',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type NOT IN ('Transfer In', 'Transfer Out')
            AND transfer_reference_id IS NOT NULL

            UNION ALL

            SELECT
                'cycle_count_missing_activity_reason',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type = 'Cycle Count Adjustment'
            AND activity_reason IS NULL

            UNION ALL

            SELECT
                'damage_writeoff_missing_activity_reason',
                COUNT(*)
            FROM staging.inventory_activity
            WHERE activity_type = 'Damage Write-Off'
            AND activity_reason IS NULL
            ) AS suspicious_summary
            WHERE suspicious_rows > 0
            ORDER BY suspicious_rows DESC;
        --non_transfer_has_reference_id = 2653

SELECT
    COUNT(*) AS row_count
FROM staging.inventory_activity
WHERE LOWER(TRIM(activity_type)) NOT IN ('transfer in', 'transfer out', 'legacy:transfer in', 'legacy:transfer out')
    AND transfer_reference_id IS NOT NULL;

