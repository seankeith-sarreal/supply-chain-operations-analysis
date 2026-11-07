--Verify Imported Data

--SUPPLIERS
SELECT COUNT(*) --60
FROM staging.suppliers;

SELECT *
FROM staging.suppliers
LIMIT 20;

--PRODUCTS
SELECT COUNT(*) --2000
FROM staging.products;

SELECT *
FROM staging.products
LIMIT 10;

--FULFILLMENT CENTERS
SELECT COUNT(*) --8
FROM staging.fulfillment_centers;

SELECT *
FROM staging.fulfillment_centers
LIMIT 10;

--STORES
SELECT COUNT(*) --35
FROM staging.stores;

SELECT *
FROM staging.stores
LIMIT 10;