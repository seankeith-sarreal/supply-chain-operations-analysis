--Products
        SELECT
            MIN(launch_date) AS earliest_date,
            MAX(launch_date) AS latest_date
        FROM staging.products

        SELECT
            MIN(discontinue_date) AS earliest_date,
            MAX(discontinue_date) AS latest_date
        FROM staging.products

        SELECT
            COUNT(*) AS affected_rows
        FROM staging.products
        WHERE discontinue_date < launch_date;

        --Verify that all all 2000 products have the same launch-date
        SELECT
            launch_date,
            COUNT(*) AS row_count
        FROM staging.products
        GROUP BY launch_date
        ORDER BY launch_date;

        --Check to see the number of product_status = Discontinued
        SELECT
            product_status,
            COUNT(*) AS row_count,
            COUNT(discontinue_date) AS populated_discontinue_dates
        FROM staging.products
        GROUP BY product_status
        ORDER BY product_status;

/* 
Table: products
Column: launch_date
Finding: All 2,000 rows share the same launch date.
Classification: Suspicious / unrealistic distribution
Reason: launch_date is defined as the date each product first became available, so a single identical launch date across the full 2,000-SKU catalog is unlikely unless intentionally generated that way. 
Phase 3 action: Verify whether this was intentional in the synthetic-data generation before changing anything.
*/


------------------------------------------------------------------------------------

--Customers
        SELECT
            'customer_created' AS date_investigated,
            MIN(customer_created_date) AS earliest_date,
            MAX(customer_created_date) AS latest_date
        FROM staging.customers

        UNION ALL

        SELECT
            'loyalty',
            MIN(loyalty_join_date),
            MAX(loyalty_join_date)
        FROM staging.customers

        --Check how many customers are loyalty memebers
        SELECT
            COUNT(customer_id) AS num_of_customers
        FROM staging.customers
        WHERE loyalty_member = 'TRUE'
        
        SELECT
            COUNT(loyalty_join_date) AS num_of_loyalty_joined
        FROM staging.customers

        --Verify there is no date variation at all among those 96,260 loyalty customers
        SELECT
            loyalty_join_date,
            COUNT(*) AS row_count
        FROM staging.customers
        WHERE loyalty_join_date IS NOT NULL
        GROUP BY loyalty_join_date
        ORDER BY loyalty_join_date;
        --All loyalty members were assigned the same loyalty join date.

        --Check to see if loyalty_join
        SELECT COUNT(*) AS affected_rows
        FROM staging.customers
        WHERE loyalty_join_date < customer_created_date;

/*
loyalty_join_date < customer_created_date → 0 rows- Good: no customer joined loyalty before becoming a customer.

96,260 loyalty members and 96,260 populated loyalty join dates- Good: the conditional completeness appears consistent.

All 96,260 loyalty members share the same loyalty_join_date- Suspicious: the dates are logically valid, but the distribution is unrealistic.
*/

------------------------------------------------------------------------------------

--Fulfillment Centers
        SELECT
            MIN(opened_date) AS earliest_date,
            MAX(opened_date) AS latest_date
        FROM staging.fulfillment_centers

        --confirm pattern that fulfillment centers have the same dates
        SELECT
            opened_date,
            COUNT(*) AS row_count
        FROM staging.fulfillment_centers
        GROUP BY opened_date
        ORDER BY opened_date;

/*
Affected rows: 8 of 8
Finding: Every fulfillment center has the same opening date.
Classification: Suspicious / unrealistic date distribution
Why: It is possible, but unusual for all fulfillment centers in a large national retailer to have opened on the exact same date.
*/

------------------------------------------------------------------------------------

--Stores
    --Step 2: Check date range
        SELECT
            MIN(opened_date) AS earliest_opened_date,
            MAX(opened_date) AS latest_opened_date
        FROM staging.stores;

    --Step 3: Not applicable
        --Stores contains only one date column, so there is no sequence to test.

    --Step 4: Test required date
        SELECT
            COUNT(*) AS missing_opened_date
        FROM staging.stores
        WHERE opened_date IS NULL;

/*
- Every store has a populated opened_date.
- All stores share the exact same opening date.
- There are 0 missing dates, so completeness is good.
- The lack of variation is the suspicious part.
For Task 13, I would document it like this:
- Finding: All stores have the same opened_date.
- Missing dates: 0.
- Classification: Suspicious / unrealistic date distribution.
- Why: A retailer with multiple stores would usually have stores opened at different times unless the synthetic dataset intentionally assumes a single rollout date.
- Phase 3 action: Verify whether the shared date was intentionally generated before changing it.
*/


------------------------------------------------------------------------------------

--Orders
    --Step 2: Check date ranges
        SELECT
            MIN(order_datetime) AS earliest_order_datetime,
            MAX(order_datetime) AS latest_order_datetime,
            MIN(cancellation_datetime) AS earliest_cancellation_datetime,
            MAX(cancellation_datetime) AS latest_cancellation_datetime
        FROM staging.orders;

    --Step 3: Test cancellation sequence
        SELECT
            COUNT(*) AS cancellation_before_order
        FROM staging.orders
        WHERE cancellation_datetime < order_datetime;

    --Step 4: Test dates against order status
        SELECT
            COUNT(*) FILTER (
                WHERE order_status = 'Cancelled'
                  AND cancellation_datetime IS NULL
            ) AS cancelled_missing_datetime,

            COUNT(*) FILTER (
                WHERE order_status <> 'Cancelled'
                  AND cancellation_datetime IS NOT NULL
            ) AS non_cancelled_has_datetime
        FROM staging.orders;


/*
Table: orders
Columns: order_status, cancellation_datetime
Finding: 145 non-cancelled orders contain a cancellation datetime.
Classification: Confirmed issue
Why: A cancellation timestamp should only exist when order_status = 'Cancelled'.
*/

------------------------------------------------------------------------------------


--Shipments
    --Step 2: Check date ranges
        SELECT
            MIN(shipped_datetime) AS earliest_shipped_datetime,
            MAX(shipped_datetime) AS latest_shipped_datetime,
            MIN(expected_delivery_date) AS earliest_expected_delivery_date,
            MAX(expected_delivery_date) AS latest_expected_delivery_date,
            MIN(delivered_datetime) AS earliest_delivered_datetime,
            MAX(delivered_datetime) AS latest_delivered_datetime
        FROM staging.shipments;

    --Step 3A: Test expected delivery against shipment date
        SELECT
            COUNT(*) AS expected_delivery_before_shipment
        FROM staging.shipments
        WHERE expected_delivery_date < shipped_datetime::date;

    --Step 3B: Test actual delivery against shipment date
        SELECT
            COUNT(*) AS delivery_before_shipment
        FROM staging.shipments
        WHERE delivered_datetime < shipped_datetime;

    --Step 3C: Test shipment against parent order
        SELECT
            COUNT(*) AS shipment_before_order
        FROM staging.shipments AS s
        INNER JOIN staging.orders AS o
            ON s.order_id = o.order_id
        WHERE s.shipped_datetime < o.order_datetime;

    --Step 4: Test dates against shipment status
        SELECT
            COUNT(*) FILTER (
                WHERE shipment_status = 'Delivered'
                  AND shipped_datetime IS NULL
            ) AS delivered_missing_shipped_datetime,

            COUNT(*) FILTER (
                WHERE shipment_status = 'Delivered'
                  AND delivered_datetime IS NULL
            ) AS delivered_missing_delivered_datetime,

            COUNT(*) FILTER (
                WHERE shipment_status <> 'Delivered'
                  AND delivered_datetime IS NOT NULL
            ) AS non_delivered_has_delivered_datetime
        FROM staging.shipments;

/*
Table: shipments
Columns: shipped_datetime, expected_delivery_date, delivered_datetime, shipment_status, order_id
Finding: Shipment date ranges show normal variation. No shipments have an expected delivery date before shipment, and no shipments occur before their parent order. However, 288 shipments have delivered_datetime earlier than shipped_datetime, and 4,141 non-delivered shipments contain a populated delivered_datetime.
Classification: Confirmed issue
Why: A shipment cannot be delivered before it ships, and delivered_datetime should only be populated for shipments whose status indicates delivery. 
Phase 3 action: Investigate whether the shipment timestamps or shipment statuses are incorrect before cleaning. Keep the 288 impossible-sequence rows and the 4,141 status/date conflicts as separate findings until overlap is checked.
*/


------------------------------------------------------------------------------------


--Order Items
    --Step 2: Check date range
        SELECT
            MIN(item_cancellation_datetime) AS earliest_item_cancellation,
            MAX(item_cancellation_datetime) AS latest_item_cancellation
        FROM staging.order_items;

    --Step 3: Test cancellation against parent order
        SELECT
            COUNT(*) AS item_cancelled_before_order
        FROM staging.order_items AS oi
        INNER JOIN staging.orders AS o
            ON oi.order_id = o.order_id
        WHERE oi.item_cancellation_datetime < o.order_datetime;

    --Step 4: Test date against item status
        SELECT
            COUNT(*) FILTER (
                WHERE order_item_status = 'Cancelled'
                  AND item_cancellation_datetime IS NULL
            ) AS cancelled_items_missing_datetime,

            COUNT(*) FILTER (
                WHERE order_item_status <> 'Cancelled'
                  AND item_cancellation_datetime IS NOT NULL
            ) AS non_cancelled_items_have_datetime
        FROM staging.order_items;

/*
Table: order_items
Columns: item_cancellation_datetime, order_item_status, order_id
Finding: Item cancellation dates show normal variation. No Order Items were cancelled before their parent Order was created, and no cancelled items are missing item_cancellation_datetime. However, 360 non-cancelled Order Items contain a populated item_cancellation_datetime.
Classification: Confirmed issue
Why: item_cancellation_datetime should only be populated when order_item_status = 'Cancelled'. The locked Order Items rules also state that cancellation datetime cannot precede the parent order_datetime. 
Phase 3 action: Investigate whether the 360 rows have an incorrect item status or an incorrect cancellation timestamp before cleaning.
*/
------------------------------------------------------------------------------------


--Returns
    --Step 2: Check date range
        SELECT
            MIN(return_datetime) AS earliest_return_datetime,
            MAX(return_datetime) AS latest_return_datetime
        FROM staging.returns;

    --Step 3A: Test return against parent order
        SELECT
            COUNT(*) AS return_before_order
        FROM staging.returns AS r
        INNER JOIN staging.order_items AS oi
            ON r.order_item_id = oi.order_item_id
        INNER JOIN staging.orders AS o
            ON oi.order_id = o.order_id
        WHERE r.return_datetime < o.order_datetime;

    --Step 3B: Test return against delivery
        SELECT
            COUNT(*) AS return_before_delivery
        FROM staging.returns AS r
        INNER JOIN staging.order_items AS oi
            ON r.order_item_id = oi.order_item_id
        INNER JOIN staging.shipments AS s
            ON oi.shipment_id = s.shipment_id
        WHERE r.return_datetime < s.delivered_datetime;

    --Step 4: Test required timestamp
        SELECT
            COUNT(*) AS missing_return_datetime
        FROM staging.returns
        WHERE return_datetime IS NULL;

/*
Table: returns
Columns: return_datetime, order_item_id
Finding: Return dates show normal variation, and no Return records are missing return_datetime. However, 79 Returns occur before the parent Order was created, and 52 Returns occur before the associated Shipment was delivered.
Classification: Confirmed issue
Why: The locked Returns rules state that return_datetime cannot precede the parent order_datetime and should follow fulfillment. Returns occurring before the Order or before delivery violate that chronology. 
Phase 3 action: Investigate whether the return timestamps, parent order dates, or shipment delivery dates are incorrect before cleaning. Keep the 79 and 52 findings separate until you check whether some rows overlap.
*/

------------------------------------------------------------------------------------


--Inventory Activity
    --Step 2: Check date range
        SELECT
            MIN(activity_datetime) AS earliest_activity_datetime,
            MAX(activity_datetime) AS latest_activity_datetime
        FROM staging.inventory_activity;

    --Step 3A: Test sale fulfillment against parent order
        SELECT
            COUNT(*) AS sale_activity_before_order
        FROM staging.inventory_activity AS ia
        INNER JOIN staging.order_items AS oi
            ON ia.order_item_id = oi.order_item_id
        INNER JOIN staging.orders AS o
            ON oi.order_id = o.order_id
        WHERE ia.activity_type = 'Sale Fulfillment'
          AND ia.activity_datetime < o.order_datetime;

    --Step 3B: Test return restock against return event
        SELECT
            COUNT(*) AS restock_before_return
        FROM staging.inventory_activity AS ia
        INNER JOIN staging.returns AS r
            ON ia.return_id = r.return_id
        WHERE ia.activity_type = 'Return Restock'
          AND ia.activity_datetime < r.return_datetime;

    --Step 3C: Test transfer sequence
        WITH transfer_dates AS (
            SELECT
                transfer_reference_id,
                MIN(activity_datetime) FILTER (
                    WHERE activity_type = 'Transfer Out'
                ) AS transfer_out_datetime,
                MIN(activity_datetime) FILTER (
                    WHERE activity_type = 'Transfer In'
                ) AS transfer_in_datetime
            FROM staging.inventory_activity
            WHERE transfer_reference_id IS NOT NULL
            GROUP BY transfer_reference_id
        )

        SELECT
            COUNT(*) AS transfer_in_before_transfer_out
        FROM transfer_dates
        WHERE transfer_in_datetime < transfer_out_datetime;

    --Step 4: Test required timestamp
        SELECT
            COUNT(*) AS missing_activity_datetime
        FROM staging.inventory_activity
        WHERE activity_datetime IS NULL;

/*
Table: inventory_activity
Columns: activity_datetime, activity_type, order_item_id, return_id, transfer_reference_id
Finding: Inventory activity dates show normal variation. No Sale Fulfillment activity occurs before its parent Order, no Return Restock activity occurs before the related Return event, no Transfer In occurs before its matching Transfer Out, and no Inventory Activity rows are missing activity_datetime.
Classification: Valid / no date-sequence issue found
Why: All tested inventory-event chronology rules are being followed, and every inventory activity record has the required timestamp. 
Phase 3 action: No date-specific cleaning action is currently needed for Inventory Activity. Keep the existing date values unless another profiling task reveals a related issue.
*/