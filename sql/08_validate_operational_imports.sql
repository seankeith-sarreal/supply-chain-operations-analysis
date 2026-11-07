SELECT COUNT(*) --287,191
FROM staging.shipments;

SELECT *
FROM staging.shipments
LIMIT 10;

--ORDERS
SELECT COUNT(*) --77,716
FROM staging.returns;

SELECT *
FROM staging.returns
LIMIT 10;

--ORDER ITEMS
SELECT COUNT(*) --1,241,264
FROM staging.inventory_activity;

SELECT *
FROM staging.inventory_activity
LIMIT 10;