-- customers: one raw customer record per row
-- orders: one raw order record per row
-- order_items: one product line item within an order per row




CREATE TABLE staging.customers (
    customer_id INTEGER,
    first_name VARCHAR(75),
    last_name VARCHAR(75),
    email_address VARCHAR(254),
    customer_city VARCHAR(100),
    customer_state CHAR(2), -- Altered to TEXT. Will adjust when cleaning
    customer_zip_code VARCHAR(10),
    customer_created_date DATE,
    loyalty_member BOOLEAN,
    loyalty_join_date DATE,
    customer_type VARCHAR(30),
    loyalty_tier VARCHAR(20)
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'customers'
ORDER BY ordinal_position;

--FIX FOR STATE ERROR
--spaces from dirty data making breaking the CHAR(2) data type
ALTER TABLE staging.customers
ALTER COLUMN customer_state TYPE TEXT;


CREATE TABLE staging.orders (
    order_id BIGINT,
    customer_id INTEGER,
    store_id INTEGER,
    order_datetime TIMESTAMP,
    sales_channel VARCHAR(25),
    order_status VARCHAR(25), --Altered to TEXT. Will adjust when cleaning
    destination_city VARCHAR(100),
    destination_state CHAR(2),
    destination_zip_code VARCHAR(10),
    customer_shipping_fee NUMERIC(10,2),
    cancellation_reason VARCHAR(50),
    cancellation_datetime TIMESTAMP,
    promotion_code VARCHAR(30),
    requested_service_level VARCHAR(25)
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'orders'
ORDER BY ordinal_position;

--FIX FOR ORDER STATUS ERROR
--ORDER STATUS HAD TOO MANY CHARACTERS FOR VARCHAR(25)
ALTER TABLE staging.orders
ALTER COLUMN order_status TYPE TEXT;

CREATE TABLE staging.order_items (
    order_item_id BIGINT,
    order_id BIGINT,
    product_id INTEGER,
    shipment_id BIGINT,
    quantity SMALLINT,
    unit_list_price NUMERIC(10,2),
    unit_discount_amount NUMERIC(10,2),
    unit_product_cost NUMERIC(10,2),
    fulfillment_method VARCHAR(25),
    order_item_status VARCHAR(25),
    store_handling_cost NUMERIC(10,2),
    discount_type VARCHAR(30),
    backorder_flag BOOLEAN,
    item_cancellation_reason VARCHAR(50),
    item_cancellation_datetime TIMESTAMP
);

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name = 'order_items'
ORDER BY ordinal_position;


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND table_name IN ('customers', 'orders', 'order_items')
ORDER BY table_name;


SELECT COUNT(*) FROM staging.customers;
SELECT COUNT(*) FROM staging.orders;
SELECT COUNT(*) FROM staging.order_items;