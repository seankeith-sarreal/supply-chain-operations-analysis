--CUSTOMERS
SELECT COUNT(*) --200,800
FROM staging.customers;

SELECT *
FROM staging.customers
LIMIT 10;

--ORDERS
SELECT COUNT(*) --501,000
FROM staging.orders;

SELECT *
FROM staging.orders
LIMIT 10;

--ORDER ITEMS
SELECT COUNT(*) --874,891
FROM staging.order_items;

SELECT *
FROM staging.order_items
LIMIT 10;