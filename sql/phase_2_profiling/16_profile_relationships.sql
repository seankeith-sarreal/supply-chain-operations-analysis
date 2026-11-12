/*
Identify child records whose non-NULL foreign key does not match a parent row.

Interpretation:
- 0 means every populated child foreign key has a matching parent.
- A result greater than 0 means broken—or orphaned—foreign-key references exist.
    -- broken_shipment_order_references = 115
    -- broken_inventory_product_references = 496
    -- broken_return_order_item_references = 31

- These queries do not count NULL foreign keys. Required-versus-optional NULLs should be evaluated separately according to the conditional relationship rules.
*/

--==========================================================
--SUPPLIERS AS PARENT
--==========================================================

--Products → Suppliers
SELECT
    COUNT(*) AS broken_supplier_references
FROM staging.products AS p
LEFT JOIN staging.suppliers AS s
    ON p.supplier_id = s.supplier_id
WHERE p.supplier_id IS NOT NULL
  AND s.supplier_id IS NULL;


--==========================================================
--CUSTOMERS AS PARENT
--==========================================================

--Orders → Customers
SELECT
    COUNT(*) AS broken_customer_references
FROM staging.orders AS o
LEFT JOIN staging.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND c.customer_id IS NULL;


--==========================================================
--STORES AS PARENT
--==========================================================

--Orders → Stores
SELECT
    COUNT(*) AS broken_order_store_references
FROM staging.orders AS o
LEFT JOIN staging.stores AS s
    ON o.store_id = s.store_id
WHERE o.store_id IS NOT NULL
  AND s.store_id IS NULL;


--Returns → Stores
SELECT
    COUNT(*) AS broken_return_store_references
FROM staging.returns AS r
LEFT JOIN staging.stores AS s
    ON r.processing_store_id = s.store_id
WHERE r.processing_store_id IS NOT NULL
  AND s.store_id IS NULL;


--Inventory Activity → Stores
SELECT
    COUNT(*) AS broken_inventory_store_references
FROM staging.inventory_activity AS ia
LEFT JOIN staging.stores AS s
    ON ia.store_id = s.store_id
WHERE ia.store_id IS NOT NULL
  AND s.store_id IS NULL;


--==========================================================
--ORDERS AS PARENT
--==========================================================

--Shipments → Orders
SELECT
    COUNT(*) AS broken_shipment_order_references
FROM staging.shipments AS sh
LEFT JOIN staging.orders AS o
    ON sh.order_id = o.order_id
WHERE sh.order_id IS NOT NULL
  AND o.order_id IS NULL;

-- broken_shipment_order_references = 115

--Order Items → Orders
SELECT
    COUNT(*) AS broken_order_item_order_references
FROM staging.order_items AS oi
LEFT JOIN staging.orders AS o
    ON oi.order_id = o.order_id
WHERE oi.order_id IS NOT NULL
  AND o.order_id IS NULL;


--==========================================================
--FULFILLMENT CENTERS AS PARENT
--==========================================================

--Shipments → Fulfillment Centers
SELECT
    COUNT(*) AS broken_shipment_fulfillment_center_references
FROM staging.shipments AS sh
LEFT JOIN staging.fulfillment_centers AS fc
    ON sh.fulfillment_center_id = fc.fulfillment_center_id
WHERE sh.fulfillment_center_id IS NOT NULL
  AND fc.fulfillment_center_id IS NULL;


--Returns → Fulfillment Centers
SELECT
    COUNT(*) AS broken_return_fulfillment_center_references
FROM staging.returns AS r
LEFT JOIN staging.fulfillment_centers AS fc
    ON r.processing_fulfillment_center_id = fc.fulfillment_center_id
WHERE r.processing_fulfillment_center_id IS NOT NULL
  AND fc.fulfillment_center_id IS NULL;


--Inventory Activity → Fulfillment Centers
SELECT
    COUNT(*) AS broken_inventory_fulfillment_center_references
FROM staging.inventory_activity AS ia
LEFT JOIN staging.fulfillment_centers AS fc
    ON ia.fulfillment_center_id = fc.fulfillment_center_id
WHERE ia.fulfillment_center_id IS NOT NULL
  AND fc.fulfillment_center_id IS NULL;


--==========================================================
--PRODUCTS AS PARENT
--==========================================================

--Order Items → Products
SELECT
    COUNT(*) AS broken_order_item_product_references
FROM staging.order_items AS oi
LEFT JOIN staging.products AS p
    ON oi.product_id = p.product_id
WHERE oi.product_id IS NOT NULL
  AND p.product_id IS NULL;


--Inventory Activity → Products
SELECT
    COUNT(*) AS broken_inventory_product_references
FROM staging.inventory_activity AS ia
LEFT JOIN staging.products AS p
    ON ia.product_id = p.product_id
WHERE ia.product_id IS NOT NULL
  AND p.product_id IS NULL;

-- broken_inventory_product_references = 496

--==========================================================
--SHIPMENTS AS PARENT
--==========================================================

--Order Items → Shipments
SELECT
    COUNT(*) AS broken_order_item_shipment_references
FROM staging.order_items AS oi
LEFT JOIN staging.shipments AS sh
    ON oi.shipment_id = sh.shipment_id
WHERE oi.shipment_id IS NOT NULL
  AND sh.shipment_id IS NULL;


--==========================================================
--ORDER ITEMS AS PARENT
--==========================================================

--Returns → Order Items
SELECT
    COUNT(*) AS broken_return_order_item_references
FROM staging.returns AS r
LEFT JOIN staging.order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_id IS NOT NULL
  AND oi.order_item_id IS NULL;

-- broken_return_order_item_references = 31

--Inventory Activity → Order Items
SELECT
    COUNT(*) AS broken_inventory_order_item_references
FROM staging.inventory_activity AS ia
LEFT JOIN staging.order_items AS oi
    ON ia.order_item_id = oi.order_item_id
WHERE ia.order_item_id IS NOT NULL
  AND oi.order_item_id IS NULL;


--==========================================================
--RETURNS AS PARENT
--==========================================================

--Inventory Activity → Returns
SELECT
    COUNT(*) AS broken_inventory_return_references
FROM staging.inventory_activity AS ia
LEFT JOIN staging.returns AS r
    ON ia.return_id = r.return_id
WHERE ia.return_id IS NOT NULL
  AND r.return_id IS NULL;

--============================================================
--============================================================


--==========================================================
--SHIPMENTS → ORDERS
--115 affected rows
--==========================================================

SELECT
    sh.*,
    'Missing parent order' AS relationship_issue
FROM staging.shipments AS sh
LEFT JOIN staging.orders AS o
    ON sh.order_id = o.order_id
WHERE sh.order_id IS NOT NULL
  AND o.order_id IS NULL
ORDER BY sh.order_id, sh.shipment_id;


--==========================================================
--INVENTORY ACTIVITY → PRODUCTS
--496 affected rows
--==========================================================

SELECT
    ia.*,
    'Missing parent product' AS relationship_issue
FROM staging.inventory_activity AS ia
LEFT JOIN staging.products AS p
    ON ia.product_id = p.product_id
WHERE ia.product_id IS NOT NULL
  AND p.product_id IS NULL
ORDER BY ia.product_id, ia.inventory_activity_id;

--==========================================================
--RETURNS → ORDER ITEMS
--31 affected rows
--==========================================================

SELECT
    r.*,
    'Missing parent order item' AS relationship_issue
FROM staging.returns AS r
LEFT JOIN staging.order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_id IS NOT NULL
  AND oi.order_item_id IS NULL
ORDER BY r.order_item_id, r.return_id;

/*
For Shipments → Orders:
- Table: shipments
- Columns: order_id
- Finding: 115 Shipment rows reference a nonexistent Order. All 115 use the same orphan key, 999999999.
- Distinct orphan keys: 1
- Classification: Confirmed issue
- Why: shipments.order_id must reference an existing Order, but no parent Order exists for 999999999.
- Phase 3 action: Quarantine or exclude these unresolved Shipment records from the clean relational layer rather than inventing a replacement Order.
***The same is for the other 2***
The big takeaway from Step 3 is:
Affected rows tell you the size of the problem. Distinct orphan keys tell you the shape of the problem.

Here, the shape is very simple: three broken relationships, each caused by one repeated invalid placeholder key.
*/

--Are those two quantity-102 Returns part of the already-known Task 15 orphan population?

SELECT
    return_id,
    order_item_id,
    return_quantity
FROM staging.returns
WHERE return_quantity = 102;

--Does order_item_id 21937 exist, and does 999999999 exist?

SELECT
    order_item_id
FROM staging.order_items
WHERE order_item_id IN (21937, 999999999);

--It returned 102 units — how many units were actually purchased on order_item_id = 21937?

SELECT
    order_item_id,
    quantity
FROM staging.order_items
WHERE order_item_id = 21937;

--How many times does each of these two return_id values appear in staging.returns?

SELECT
    return_id,
    COUNT(*) AS row_count
FROM staging.returns
WHERE return_id IN (2000, 54799)
GROUP BY return_id;

SELECT
    returns.return_id,
    returns.order_item_id,
    returns.return_quantity,
    order_items.quantity
FROM staging.returns AS returns
LEFT JOIN staging.order_items AS order_items
    ON returns.order_item_id = order_items.order_item_id
WHERE returns.return_id IN (2000, 54799)

--============================================================

--Test conditional relationships separately

--============================================================

--==========================================================
-- Orders → Customers
--==========================================================

--A missing customer_id is permitted only for anonymous in-store orders.

SELECT
    COUNT(*) AS invalid_missing_customer_id
FROM staging.orders
WHERE customer_id IS NULL
  AND LOWER(TRIM(sales_channel)) IS DISTINCT FROM 'in-store';
  --AND sales_channel IS DISTINCT FROM 'In-Store';


--==========================================================
-- Orders → Stores
--==========================================================

-- Store-based orders missing store_id

SELECT
    COUNT(*) AS store_orders_missing_store_id
FROM staging.orders
WHERE LOWER(TRIM(sales_channel)) IN ('in-store', 'click-and-collect')
--WHERE sales_channel IN ('In-Store', 'Click-and-Collect')
  AND store_id IS NULL;

-- Online orders unexpectedly containing store_id

SELECT
    COUNT(*) AS online_orders_with_store_id
FROM staging.orders
WHERE LOWER(TRIM(sales_channel)) = 'online'
  AND store_id IS NOT NULL;

--a review test because an online order might still legitimately be associated with a store under certain business processes.

--==========================================================
-- Order Items → Shipments
--==========================================================

-- Home-delivery items should normally have a shipment assigned unless the item was cancelled or is still pending.

SELECT
    COUNT(*) AS home_delivery_items_missing_shipment
FROM staging.order_items
WHERE LOWER(TRIM(fulfillment_method)) = 'home delivery'
  AND LOWER(TRIM(order_item_status)) NOT IN ('cancelled', 'legacy:cancelled', 'pending')
  AND shipment_id IS NULL;

-- To avoid missing rows where the status itself is NULL:

SELECT
    COUNT(*) AS home_delivery_items_missing_shipment
FROM staging.order_items
WHERE fulfillment_method = 'Home Delivery'
  AND order_item_status IS DISTINCT FROM 'Cancelled'
  AND order_item_status IS DISTINCT FROM 'Pending'
  AND shipment_id IS NULL;
--final test.

-- home_delivery_items_missing_shipment = 198

--==========================================================
-- Returns → Processing Stores
--==========================================================

-- A return cannot be assigned to both a Store and a Fulfillment Center.

SELECT
    COUNT(*) AS returns_with_both_processing_locations
FROM staging.returns
WHERE processing_store_id IS NOT NULL
  AND processing_fulfillment_center_id IS NOT NULL;
  

--==========================================================
-- Returns → Processing Fulfillment Centers
--==========================================================

-- An assigned physical return should not be missing both processing locations.

SELECT
    COUNT(*) AS returns_missing_processing_location
FROM staging.returns
WHERE processing_store_id IS NULL
  AND processing_fulfillment_center_id IS NULL;

/*
Together, the previous two queries test the rule that a return should use exactly one processing location:
- Store, or
- Fulfillment Center
- Never both
- Never neither
*/


--==========================================================
-- Inventory Activity → Stores
--==========================================================

-- An inventory event cannot be assigned to both a Store and a Fulfillment Center.

SELECT
    COUNT(*) AS inventory_events_with_both_locations
FROM staging.inventory_activity
WHERE store_id IS NOT NULL
  AND fulfillment_center_id IS NOT NULL;

--==========================================================
-- Inventory Activity → Fulfillment Centers
--==========================================================

-- Every inventory event must have one physical location.

SELECT
    COUNT(*) AS inventory_events_missing_location
FROM staging.inventory_activity
WHERE store_id IS NULL
  AND fulfillment_center_id IS NULL;
  
-- Together, these test the rule that every inventory event uses exactly one location.

--==========================================================
-- Inventory Activity → Order Items
--==========================================================

-- Sale Fulfillment activity should reference the affected Order Item.

SELECT
    COUNT(*) AS sale_fulfillment_missing_order_item
FROM staging.inventory_activity
WHERE LOWER(TRIM(activity_type)) = 'sale fulfillment'
  AND order_item_id IS NULL;

-- This review query finds other activity types that unexpectedly contain an order_item_id:

SELECT
    activity_type,
    COUNT(*) AS events_with_order_item_id
FROM staging.inventory_activity
WHERE activity_type <> 'Sale Fulfillment'
  AND order_item_id IS NOT NULL
GROUP BY activity_type
ORDER BY events_with_order_item_id DESC;

/*
activity_type = Events_with_order_item_id
SALE FULFILLMENT = 16237
legacy:Sale Fulfillment = 4275
*/

-- Do not automatically classify these as errors because other activity types may legitimately reference an Order Item.

--==========================================================
-- Inventory Activity → Returns
--==========================================================

-- Return Restock activity should reference the corresponding Return.

SELECT
    COUNT(*) AS return_restock_missing_return_id
FROM staging.inventory_activity
WHERE LOWER(TRIM(activity_type)) = 'return restock'
  AND return_id IS NULL;

-- This review query finds other activity types containing a return_id:
SELECT
    activity_type,
    COUNT(*) AS events_with_return_id
FROM staging.inventory_activity
WHERE activity_type <> 'Return Restock'
  AND return_id IS NOT NULL
GROUP BY activity_type
ORDER BY events_with_return_id DESC;

/*
activity_type = Events_with_return_id
RETURN RESTOCK = 855
legacy:Return Restock = 229
*/