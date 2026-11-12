--Suppliers
    --supplier_country
        --frequency distribution
            SELECT
                supplier_country,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_country
            ORDER BY row_count DESC, supplier_country;
        --expose hidden whitespace and blanks
            SELECT
                supplier_country,
                LENGTH(supplier_country) AS original_length,
                LENGTH(TRIM(supplier_country)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.suppliers
            WHERE LENGTH(supplier_country) <> LENGTH(TRIM(supplier_country))
            GROUP BY supplier_country
            ORDER BY supplier_country;
        --Compare raw and normalized candidates
            SELECT
                supplier_country AS raw_value,
                LOWER(TRIM(supplier_country)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_country, LOWER(TRIM(supplier_country))
            ORDER BY normalized_candidate, raw_value;
    --supplier_city
        --frequency distribution
            SELECT
                supplier_city,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_city
            ORDER BY row_count DESC, supplier_city;

        --expose hidden whitespace and blanks
            SELECT
                supplier_city,
                LENGTH(supplier_city) AS original_length,
                LENGTH(TRIM(supplier_city)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.suppliers
            WHERE LENGTH(supplier_city) <> LENGTH(TRIM(supplier_city))
            GROUP BY supplier_city
            ORDER BY supplier_city;

        --Compare raw and normalized candidates
            SELECT
                supplier_city AS raw_value,
                LOWER(TRIM(supplier_city)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_city, LOWER(TRIM(supplier_city))
            ORDER BY normalized_candidate, raw_value;

    --supplier_status
        --frequency distribution

            SELECT
                supplier_status,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_status
            ORDER BY row_count DESC, supplier_status;

        --expose hidden whitespace and blanks
            SELECT
                supplier_status,
                LENGTH(supplier_status) AS original_length,
                LENGTH(TRIM(supplier_status)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.suppliers
            WHERE LENGTH(supplier_status) <> LENGTH(TRIM(supplier_status))
            GROUP BY supplier_status
            ORDER BY supplier_status;
        --Compare raw and normalized candidates
            SELECT
                supplier_status AS raw_value,
                LOWER(TRIM(supplier_status)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.suppliers
            GROUP BY supplier_status, LOWER(TRIM(supplier_status))
            ORDER BY normalized_candidate, raw_value;

-------------------------------------------------------------------------

--Products

    --product_category
        --frequency distribution
            SELECT
                product_category,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_category
            ORDER BY row_count DESC, product_category;

        --expose hidden whitespace and blanks
            SELECT
                product_category,
                LENGTH(product_category) AS original_length,
                LENGTH(TRIM(product_category)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            WHERE LENGTH(product_category) <> LENGTH(TRIM(product_category))
            GROUP BY product_category
            ORDER BY product_category;

        --Compare raw and normalized candidates
            SELECT
                product_category AS raw_value,
                LOWER(TRIM(product_category)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_category, LOWER(TRIM(product_category))
            ORDER BY normalized_candidate, raw_value;

    --product_subcategory
        --frequency distribution
            SELECT
                product_subcategory,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_subcategory
            ORDER BY product_subcategory, row_count DESC ;

        --expose hidden whitespace and blanks
            SELECT
                product_subcategory,
                LENGTH(product_subcategory) AS original_length,
                LENGTH(TRIM(product_subcategory)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            WHERE LENGTH(product_subcategory) <> LENGTH(TRIM(product_subcategory))
            GROUP BY product_subcategory
            ORDER BY product_subcategory;

        --Compare raw and normalized candidates
            SELECT
                product_subcategory AS raw_value,
                LOWER(TRIM(product_subcategory)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_subcategory, LOWER(TRIM(product_subcategory))
            ORDER BY normalized_candidate, raw_value;


    --material
        --frequency distribution
            SELECT
                material,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY material
            ORDER BY row_count DESC, material;

        --expose hidden whitespace and blanks
            SELECT
                material,
                LENGTH(material) AS original_length,
                LENGTH(TRIM(material)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            WHERE LENGTH(material) <> LENGTH(TRIM(material))
            GROUP BY material
            ORDER BY material;

        --Compare raw and normalized candidates
            SELECT
                material AS raw_value,
                LOWER(TRIM(material)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY material, LOWER(TRIM(material))
            ORDER BY normalized_candidate, raw_value;


    --color
        --frequency distribution
            SELECT
                color,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY color
            ORDER BY row_count DESC, color;

        --expose hidden whitespace and blanks
            SELECT
                color,
                LENGTH(color) AS original_length,
                LENGTH(TRIM(color)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            WHERE LENGTH(color) <> LENGTH(TRIM(color))
            GROUP BY color
            ORDER BY color;

        --Compare raw and normalized candidates
            SELECT
                color AS raw_value,
                LOWER(TRIM(color)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY color, LOWER(TRIM(color))
            ORDER BY normalized_candidate, raw_value;


    --shipping_class
        --frequency distribution
            SELECT
                shipping_class,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY shipping_class
            ORDER BY row_count DESC, shipping_class;

        --expose hidden whitespace and blanks
            SELECT
                shipping_class,
                LENGTH(shipping_class) AS original_length,
                LENGTH(TRIM(shipping_class)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            WHERE LENGTH(shipping_class) <> LENGTH(TRIM(shipping_class))
            GROUP BY shipping_class
            ORDER BY shipping_class;

        --Compare raw and normalized candidates
            SELECT
                shipping_class AS raw_value,
                LOWER(TRIM(shipping_class)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY shipping_class, LOWER(TRIM(shipping_class))
            ORDER BY normalized_candidate, raw_value;


    --is_fragile
        --frequency distribution
            SELECT
                is_fragile,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY is_fragile
            ORDER BY row_count DESC, is_fragile;


    --assembly_required
        --frequency distribution
            SELECT
                assembly_required,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY assembly_required
            ORDER BY row_count DESC, assembly_required;


    --product_status
        --frequency distribution
            SELECT
                product_status,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_status
            ORDER BY row_count DESC, product_status;

        --expose hidden whitespace and blanks
            SELECT
                product_status,
                LENGTH(product_status) AS original_length,
                LENGTH(TRIM(product_status)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_status
            ORDER BY product_status;

        --Compare raw and normalized candidates
            SELECT
                product_status AS raw_value,
                LOWER(TRIM(product_status)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY product_status, LOWER(TRIM(product_status))
            ORDER BY normalized_candidate, raw_value;


    --country_of_origin
        --frequency distribution
            SELECT
                country_of_origin,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY country_of_origin
            ORDER BY row_count DESC, country_of_origin;

        --expose hidden whitespace and blanks
            SELECT
                country_of_origin,
                LENGTH(country_of_origin) AS original_length,
                LENGTH(TRIM(country_of_origin)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY country_of_origin
            ORDER BY country_of_origin;

        --Compare raw and normalized candidates
            SELECT
                country_of_origin AS raw_value,
                LOWER(TRIM(country_of_origin)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY country_of_origin, LOWER(TRIM(country_of_origin))
            ORDER BY normalized_candidate, raw_value;


    --return_policy_class
        --frequency distribution
            SELECT
                return_policy_class,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY return_policy_class
            ORDER BY row_count DESC, return_policy_class;

        --expose hidden whitespace and blanks
            SELECT
                return_policy_class,
                LENGTH(return_policy_class) AS original_length,
                LENGTH(TRIM(return_policy_class)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY return_policy_class
            ORDER BY return_policy_class;

        --Compare raw and normalized candidates
            SELECT
                return_policy_class AS raw_value,
                LOWER(TRIM(return_policy_class)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY return_policy_class, LOWER(TRIM(return_policy_class))
            ORDER BY normalized_candidate, raw_value;


    --store_pickup_eligible
        --frequency distribution
            SELECT
                store_pickup_eligible,
                COUNT(*) AS row_count
            FROM staging.products
            GROUP BY store_pickup_eligible
            ORDER BY row_count DESC, store_pickup_eligible;

--Materials has ALL CAPS
--Colors has ALL CAPS

-------------------------------------------------------------------------

--Customers

    --customer_city
        --frequency distribution
            SELECT customer_city, COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_city
            ORDER BY row_count DESC, customer_city;

        --expose hidden whitespace and blanks
            SELECT
                customer_city,
                LENGTH(customer_city) AS original_length,
                LENGTH(TRIM(customer_city)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.customers
            WHERE LENGTH(customer_city) <> LENGTH(TRIM(customer_city))
            GROUP BY customer_city
            ORDER BY customer_city;

        --Compare raw and normalized candidates
            SELECT
                customer_city AS raw_value,
                LOWER(TRIM(customer_city)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_city, LOWER(TRIM(customer_city))
            ORDER BY normalized_candidate, raw_value;

            SELECT
                LOWER(TRIM(customer_city)) AS normalized_candidate,
                COUNT(DISTINCT customer_city) AS raw_variations,
                COUNT(*) AS total_rows
            FROM staging.customers
            GROUP BY LOWER(TRIM(customer_city))
            HAVING COUNT(DISTINCT customer_city) > 1
            ORDER BY raw_variations DESC, normalized_candidate;

    --customer_state
        --frequency distribution
            SELECT customer_state, COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_state
            ORDER BY row_count DESC, customer_state;

        --expose hidden whitespace and blanks
            SELECT
                customer_state,
                LENGTH(customer_state) AS original_length,
                LENGTH(TRIM(customer_state)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_state
            ORDER BY customer_state;

        --Compare raw and normalized candidates
            SELECT
                customer_state AS raw_value,
                LOWER(TRIM(customer_state)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_state, LOWER(TRIM(customer_state))
            ORDER BY normalized_candidate, raw_value;


    --loyalty_member
        --frequency distribution
            SELECT loyalty_member, COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY loyalty_member
            ORDER BY row_count DESC, loyalty_member;


    --customer_type
        --frequency distribution
            SELECT customer_type, COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_type
            ORDER BY row_count DESC, customer_type;

        --expose hidden whitespace and blanks
            SELECT
                customer_type,
                LENGTH(customer_type) AS original_length,
                LENGTH(TRIM(customer_type)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_type
            ORDER BY customer_type;

        --Compare raw and normalized candidates
            SELECT
                customer_type AS raw_value,
                LOWER(TRIM(customer_type)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY customer_type, LOWER(TRIM(customer_type))
            ORDER BY normalized_candidate, raw_value;


    --loyalty_tier
        --frequency distribution
            SELECT loyalty_tier, COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY loyalty_tier
            ORDER BY row_count DESC, loyalty_tier;

        --expose hidden whitespace and blanks
            SELECT
                loyalty_tier,
                LENGTH(loyalty_tier) AS original_length,
                LENGTH(TRIM(loyalty_tier)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY loyalty_tier
            ORDER BY loyalty_tier;

        --Compare raw and normalized candidates
            SELECT
                loyalty_tier AS raw_value,
                LOWER(TRIM(loyalty_tier)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.customers
            GROUP BY loyalty_tier, LOWER(TRIM(loyalty_tier))
            ORDER BY normalized_candidate, raw_value;

-------------------------------------------------------------------------

--Fulfillment Centers

    --fulfillment_center_city
        --frequency distribution
            SELECT fulfillment_center_city, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_city
            ORDER BY row_count DESC, fulfillment_center_city;

        --expose hidden whitespace and blanks
            SELECT fulfillment_center_city,
                   LENGTH(fulfillment_center_city) AS original_length,
                   LENGTH(TRIM(fulfillment_center_city)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_city
            ORDER BY fulfillment_center_city;

        --Compare raw and normalized candidates
            SELECT fulfillment_center_city AS raw_value,
                   LOWER(TRIM(fulfillment_center_city)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_city, LOWER(TRIM(fulfillment_center_city))
            ORDER BY normalized_candidate, raw_value;


    --fulfillment_center_state
        --frequency distribution
            SELECT fulfillment_center_state, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_state
            ORDER BY row_count DESC, fulfillment_center_state;

        --expose hidden whitespace and blanks
            SELECT fulfillment_center_state,
                   LENGTH(fulfillment_center_state) AS original_length,
                   LENGTH(TRIM(fulfillment_center_state)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_state
            ORDER BY fulfillment_center_state;

        --Compare raw and normalized candidates
            SELECT fulfillment_center_state AS raw_value,
                   LOWER(TRIM(fulfillment_center_state)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_state, LOWER(TRIM(fulfillment_center_state))
            ORDER BY normalized_candidate, raw_value;


    --service_region
        --frequency distribution
            SELECT service_region, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY service_region
            ORDER BY row_count DESC, service_region;

        --expose hidden whitespace and blanks
            SELECT service_region,
                   LENGTH(service_region) AS original_length,
                   LENGTH(TRIM(service_region)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY service_region
            ORDER BY service_region;

        --Compare raw and normalized candidates
            SELECT service_region AS raw_value,
                   LOWER(TRIM(service_region)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY service_region, LOWER(TRIM(service_region))
            ORDER BY normalized_candidate, raw_value;


    --fulfillment_center_status
        --frequency distribution
            SELECT fulfillment_center_status, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_status
            ORDER BY row_count DESC, fulfillment_center_status;

        --expose hidden whitespace and blanks
            SELECT fulfillment_center_status,
                   LENGTH(fulfillment_center_status) AS original_length,
                   LENGTH(TRIM(fulfillment_center_status)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_status
            ORDER BY fulfillment_center_status;

        --Compare raw and normalized candidates
            SELECT fulfillment_center_status AS raw_value,
                   LOWER(TRIM(fulfillment_center_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY fulfillment_center_status, LOWER(TRIM(fulfillment_center_status))
            ORDER BY normalized_candidate, raw_value;


    --oversized_item_capable
        --frequency distribution
            SELECT oversized_item_capable, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY oversized_item_capable
            ORDER BY row_count DESC, oversized_item_capable;


    --white_glove_capable
        --frequency distribution
            SELECT white_glove_capable, COUNT(*) AS row_count
            FROM staging.fulfillment_centers
            GROUP BY white_glove_capable
            ORDER BY row_count DESC, white_glove_capable;

-------------------------------------------------------------------------

--Stores

    --store_city
        --frequency distribution
            SELECT
                store_city,
                COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_city
            ORDER BY row_count DESC, store_city;

        --expose hidden whitespace and blanks
            SELECT
                store_city,
                LENGTH(store_city) AS original_length,
                LENGTH(TRIM(store_city)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.stores
            WHERE LENGTH(store_city) <> LENGTH(TRIM(store_city))
            GROUP BY store_city
            ORDER BY store_city;

        --Compare raw and normalized candidates
            SELECT
                store_city AS raw_value,
                LOWER(TRIM(store_city)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_city, LOWER(TRIM(store_city))
            ORDER BY normalized_candidate, raw_value;


    --store_state
        --frequency distribution
            SELECT store_state, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_state
            ORDER BY row_count DESC, store_state;

        --expose hidden whitespace and blanks
            SELECT store_state, LENGTH(store_state) AS original_length,
                   LENGTH(TRIM(store_state)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_state
            ORDER BY store_state;

        --Compare raw and normalized candidates
            SELECT store_state AS raw_value,
                   LOWER(TRIM(store_state)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_state, LOWER(TRIM(store_state))
            ORDER BY normalized_candidate, raw_value;


    --market_region
        --frequency distribution
            SELECT market_region, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY market_region
            ORDER BY row_count DESC, market_region;

        --expose hidden whitespace and blanks
            SELECT market_region, LENGTH(market_region) AS original_length,
                   LENGTH(TRIM(market_region)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY market_region
            ORDER BY market_region;

        --Compare raw and normalized candidates
            SELECT market_region AS raw_value,
                   LOWER(TRIM(market_region)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY market_region, LOWER(TRIM(market_region))
            ORDER BY normalized_candidate, raw_value;


    --inventory_capacity_tier
        --frequency distribution
            SELECT inventory_capacity_tier, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY inventory_capacity_tier
            ORDER BY row_count DESC, inventory_capacity_tier;

        --expose hidden whitespace and blanks
            SELECT inventory_capacity_tier,
                   LENGTH(inventory_capacity_tier) AS original_length,
                   LENGTH(TRIM(inventory_capacity_tier)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY inventory_capacity_tier
            ORDER BY inventory_capacity_tier;

        --Compare raw and normalized candidates
            SELECT inventory_capacity_tier AS raw_value,
                   LOWER(TRIM(inventory_capacity_tier)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY inventory_capacity_tier, LOWER(TRIM(inventory_capacity_tier))
            ORDER BY normalized_candidate, raw_value;


    --click_collect_enabled
        --frequency distribution
            SELECT click_collect_enabled, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY click_collect_enabled
            ORDER BY row_count DESC, click_collect_enabled;


    --return_processing_enabled
        --frequency distribution
            SELECT return_processing_enabled, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY return_processing_enabled
            ORDER BY row_count DESC, return_processing_enabled;


    --store_status
        --frequency distribution
            SELECT store_status, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_status
            ORDER BY row_count DESC, store_status;

        --expose hidden whitespace and blanks
            SELECT store_status, LENGTH(store_status) AS original_length,
                   LENGTH(TRIM(store_status)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_status
            ORDER BY store_status;

        --Compare raw and normalized candidates
            SELECT store_status AS raw_value,
                   LOWER(TRIM(store_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY store_status, LOWER(TRIM(store_status))
            ORDER BY normalized_candidate, raw_value;


    --oversized_pickup_capable
        --frequency distribution
            SELECT oversized_pickup_capable, COUNT(*) AS row_count
            FROM staging.stores
            GROUP BY oversized_pickup_capable
            ORDER BY row_count DESC, oversized_pickup_capable;

-------------------------------------------------------------------------

--Orders

    --sales_channel
        --frequency distribution
            SELECT sales_channel, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY sales_channel
            ORDER BY row_count DESC, sales_channel;

        --expose hidden whitespace and blanks
            SELECT sales_channel, LENGTH(sales_channel) AS original_length,
                   LENGTH(TRIM(sales_channel)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY sales_channel
            ORDER BY sales_channel;

        --Compare raw and normalized candidates
            SELECT sales_channel AS raw_value,
                   LOWER(TRIM(sales_channel)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY sales_channel, LOWER(TRIM(sales_channel))
            ORDER BY normalized_candidate, raw_value;


    --order_status
        --frequency distribution
            SELECT order_status, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY order_status
            ORDER BY row_count DESC, order_status;

        --expose hidden whitespace and blanks
            SELECT order_status, LENGTH(order_status) AS original_length,
                   LENGTH(TRIM(order_status)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY order_status
            ORDER BY order_status;

        --Compare raw and normalized candidates
            SELECT order_status AS raw_value,
                   LOWER(TRIM(order_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY order_status, LOWER(TRIM(order_status))
            ORDER BY normalized_candidate, raw_value;


    --destination_city
        --frequency distribution
            SELECT destination_city, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY destination_city
            ORDER BY row_count DESC, destination_city;

        --expose hidden whitespace and blanks
            SELECT destination_city, LENGTH(destination_city) AS original_length,
                   LENGTH(TRIM(destination_city)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            WHERE LENGTH(destination_city) <> LENGTH(TRIM(destination_city))
            GROUP BY destination_city
            ORDER BY destination_city;

        --Compare raw and normalized candidates
            SELECT destination_city AS raw_value,
                   LOWER(TRIM(destination_city)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY destination_city, LOWER(TRIM(destination_city))
            ORDER BY normalized_candidate, raw_value;

            SELECT
                LOWER(TRIM(destination_city)) AS normalized_candidate,
                COUNT(DISTINCT destination_city) AS raw_variations,
                COUNT(*) AS total_rows
            FROM staging.orders
            GROUP BY LOWER(TRIM(destination_city))
            HAVING COUNT(DISTINCT destination_city) > 1
            ORDER BY raw_variations DESC, normalized_candidate;


    --destination_state
        --frequency distribution
            SELECT destination_state, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY destination_state
            ORDER BY row_count DESC, destination_state;

        --expose hidden whitespace and blanks
            SELECT destination_state, LENGTH(destination_state) AS original_length,
                   LENGTH(TRIM(destination_state)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY destination_state
            ORDER BY destination_state;

        --Compare raw and normalized candidates
            SELECT destination_state AS raw_value,
                   LOWER(TRIM(destination_state)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY destination_state, LOWER(TRIM(destination_state))
            ORDER BY normalized_candidate, raw_value;


    --cancellation_reason
        --frequency distribution
            SELECT cancellation_reason, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY cancellation_reason
            ORDER BY row_count DESC, cancellation_reason;

        --expose hidden whitespace and blanks
            SELECT cancellation_reason, LENGTH(cancellation_reason) AS original_length,
                   LENGTH(TRIM(cancellation_reason)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY cancellation_reason
            ORDER BY cancellation_reason;

        --Compare raw and normalized candidates
            SELECT cancellation_reason AS raw_value,
                   LOWER(TRIM(cancellation_reason)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY cancellation_reason, LOWER(TRIM(cancellation_reason))
            ORDER BY normalized_candidate, raw_value;


    --promotion_code
        --frequency distribution
            SELECT promotion_code, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY promotion_code
            ORDER BY row_count DESC, promotion_code;

        --expose hidden whitespace and blanks
            SELECT promotion_code, LENGTH(promotion_code) AS original_length,
                   LENGTH(TRIM(promotion_code)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY promotion_code
            ORDER BY promotion_code;

        --Compare raw and normalized candidates
            SELECT promotion_code AS raw_value,
                   LOWER(TRIM(promotion_code)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY promotion_code, LOWER(TRIM(promotion_code))
            ORDER BY normalized_candidate, raw_value;


    --requested_service_level
        --frequency distribution
            SELECT requested_service_level, COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY requested_service_level
            ORDER BY row_count DESC, requested_service_level;

        --expose hidden whitespace and blanks
            SELECT requested_service_level,
                   LENGTH(requested_service_level) AS original_length,
                   LENGTH(TRIM(requested_service_level)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY requested_service_level
            ORDER BY requested_service_level;

        --Compare raw and normalized candidates
            SELECT requested_service_level AS raw_value,
                   LOWER(TRIM(requested_service_level)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.orders
            GROUP BY requested_service_level, LOWER(TRIM(requested_service_level))
            ORDER BY normalized_candidate, raw_value;
-- Sales Channel has All CAPs
-- Order Status has All CAPs
-- Requested Service Level has All CAPs

-------------------------------------------------------------------------

--Shipments

    --carrier_name
        --frequency distribution
            SELECT carrier_name, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY carrier_name
            ORDER BY row_count DESC, carrier_name;

        --expose hidden whitespace and blanks
            SELECT carrier_name, LENGTH(carrier_name) AS original_length,
                   LENGTH(TRIM(carrier_name)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.shipments
            WHERE LENGTH(carrier_name) <> LENGTH(TRIM(carrier_name))
            GROUP BY carrier_name
            ORDER BY carrier_name;

        --Compare raw and normalized candidates
            SELECT carrier_name AS raw_value,
                   LOWER(TRIM(carrier_name)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY carrier_name, LOWER(TRIM(carrier_name))
            ORDER BY normalized_candidate, raw_value;


    --shipping_method
        --frequency distribution
            SELECT shipping_method, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipping_method
            ORDER BY row_count DESC, shipping_method;

        --expose hidden whitespace and blanks
            SELECT shipping_method, LENGTH(shipping_method) AS original_length,
                   LENGTH(TRIM(shipping_method)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipping_method
            ORDER BY shipping_method;

        --Compare raw and normalized candidates
            SELECT shipping_method AS raw_value,
                   LOWER(TRIM(shipping_method)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipping_method, LOWER(TRIM(shipping_method))
            ORDER BY normalized_candidate, raw_value;


    --shipment_status
        --frequency distribution
            SELECT shipment_status, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipment_status
            ORDER BY row_count DESC, shipment_status;

        --expose hidden whitespace and blanks
            SELECT shipment_status, LENGTH(shipment_status) AS original_length,
                   LENGTH(TRIM(shipment_status)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipment_status
            ORDER BY shipment_status;

        --Compare raw and normalized candidates
            SELECT shipment_status AS raw_value,
                   LOWER(TRIM(shipment_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY shipment_status, LOWER(TRIM(shipment_status))
            ORDER BY normalized_candidate, raw_value;


    --delivery_exception_reason
        --frequency distribution
            SELECT delivery_exception_reason, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY delivery_exception_reason
            ORDER BY row_count DESC, delivery_exception_reason;

        --expose hidden whitespace and blanks
            SELECT delivery_exception_reason,
                   LENGTH(delivery_exception_reason) AS original_length,
                   LENGTH(TRIM(delivery_exception_reason)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY delivery_exception_reason
            ORDER BY delivery_exception_reason;

        --Compare raw and normalized candidates
            SELECT delivery_exception_reason AS raw_value,
                   LOWER(TRIM(delivery_exception_reason)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY delivery_exception_reason,
                     LOWER(TRIM(delivery_exception_reason))
            ORDER BY normalized_candidate, raw_value;


    --is_cross_region_fulfillment
        --frequency distribution
            SELECT is_cross_region_fulfillment, COUNT(*) AS row_count
            FROM staging.shipments
            GROUP BY is_cross_region_fulfillment
            ORDER BY row_count DESC, is_cross_region_fulfillment;

--carrier name has all caps and possibly dups
--shipping method has all caps
--shipping statements has all caps

-------------------------------------------------------------------------

--Order Items

    --fulfillment_method
        --frequency distribution
            SELECT fulfillment_method, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY fulfillment_method
            ORDER BY row_count DESC, fulfillment_method;

        --expose hidden whitespace and blanks
            SELECT fulfillment_method, LENGTH(fulfillment_method) AS original_length,
                   LENGTH(TRIM(fulfillment_method)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY fulfillment_method
            ORDER BY fulfillment_method;

        --Compare raw and normalized candidates
            SELECT fulfillment_method AS raw_value,
                   LOWER(TRIM(fulfillment_method)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY fulfillment_method, LOWER(TRIM(fulfillment_method))
            ORDER BY normalized_candidate, raw_value;


    --order_item_status
        --frequency distribution
            SELECT order_item_status, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY order_item_status
            ORDER BY row_count DESC, order_item_status;

        --expose hidden whitespace and blanks
            SELECT order_item_status, LENGTH(order_item_status) AS original_length,
                   LENGTH(TRIM(order_item_status)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY order_item_status
            ORDER BY order_item_status;

        --Compare raw and normalized candidates
            SELECT order_item_status AS raw_value,
                   LOWER(TRIM(order_item_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY order_item_status, LOWER(TRIM(order_item_status))
            ORDER BY normalized_candidate, raw_value;


    --discount_type
        --frequency distribution
            SELECT discount_type, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY discount_type
            ORDER BY row_count DESC, discount_type;

        --expose hidden whitespace and blanks
            SELECT discount_type, LENGTH(discount_type) AS original_length,
                   LENGTH(TRIM(discount_type)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY discount_type
            ORDER BY discount_type;

        --Compare raw and normalized candidates
            SELECT discount_type AS raw_value,
                   LOWER(TRIM(discount_type)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY discount_type, LOWER(TRIM(discount_type))
            ORDER BY normalized_candidate, raw_value;


    --backorder_flag
        --frequency distribution
            SELECT backorder_flag, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY backorder_flag
            ORDER BY row_count DESC, backorder_flag;


    --item_cancellation_reason
        --frequency distribution
            SELECT item_cancellation_reason, COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY item_cancellation_reason
            ORDER BY row_count DESC, item_cancellation_reason;

        --expose hidden whitespace and blanks
            SELECT item_cancellation_reason,
                   LENGTH(item_cancellation_reason) AS original_length,
                   LENGTH(TRIM(item_cancellation_reason)) AS trimmed_length,
                   COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY item_cancellation_reason
            ORDER BY item_cancellation_reason;

        --Compare raw and normalized candidates
            SELECT item_cancellation_reason AS raw_value,
                   LOWER(TRIM(item_cancellation_reason)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.order_items
            GROUP BY item_cancellation_reason,
                     LOWER(TRIM(item_cancellation_reason))
            ORDER BY normalized_candidate, raw_value;

--fulfillment method has all caps
--order_item_status has all caps
--discount type has all caps

-------------------------------------------------------------------------

--Returns

    --return_status
        --frequency distribution
            SELECT return_status, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_status
            ORDER BY row_count DESC, return_status;

        --expose hidden whitespace and blanks
            SELECT return_status, LENGTH(return_status) AS original_length,
                   LENGTH(TRIM(return_status)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_status
            ORDER BY return_status;

        --Compare raw and normalized candidates
            SELECT return_status AS raw_value,
                   LOWER(TRIM(return_status)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_status, LOWER(TRIM(return_status))
            ORDER BY normalized_candidate, raw_value;


    --return_reason
        --frequency distribution
            SELECT return_reason, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_reason
            ORDER BY row_count DESC, return_reason;

        --expose hidden whitespace and blanks
            SELECT return_reason, LENGTH(return_reason) AS original_length,
                   LENGTH(TRIM(return_reason)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_reason
            ORDER BY return_reason;

        --Compare raw and normalized candidates
            SELECT return_reason AS raw_value,
                   LOWER(TRIM(return_reason)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_reason, LOWER(TRIM(return_reason))
            ORDER BY normalized_candidate, raw_value;


    --return_channel
        --frequency distribution
            SELECT return_channel, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_channel
            ORDER BY row_count DESC, return_channel;

        --expose hidden whitespace and blanks
            SELECT return_channel, LENGTH(return_channel) AS original_length,
                   LENGTH(TRIM(return_channel)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_channel
            ORDER BY return_channel;

        --Compare raw and normalized candidates
            SELECT return_channel AS raw_value,
                   LOWER(TRIM(return_channel)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY return_channel, LOWER(TRIM(return_channel))
            ORDER BY normalized_candidate, raw_value;


    --product_condition
        --frequency distribution
            SELECT product_condition, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY product_condition
            ORDER BY row_count DESC, product_condition;

        --expose hidden whitespace and blanks
            SELECT product_condition, LENGTH(product_condition) AS original_length,
                   LENGTH(TRIM(product_condition)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY product_condition
            ORDER BY product_condition;

        --Compare raw and normalized candidates
            SELECT product_condition AS raw_value,
                   LOWER(TRIM(product_condition)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY product_condition, LOWER(TRIM(product_condition))
            ORDER BY normalized_candidate, raw_value;


    --disposition_outcome
        --frequency distribution
            SELECT disposition_outcome, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY disposition_outcome
            ORDER BY row_count DESC, disposition_outcome;

        --expose hidden whitespace and blanks
            SELECT disposition_outcome, LENGTH(disposition_outcome) AS original_length,
                   LENGTH(TRIM(disposition_outcome)) AS trimmed_length, COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY disposition_outcome
            ORDER BY disposition_outcome;

        --Compare raw and normalized candidates
            SELECT disposition_outcome AS raw_value,
                   LOWER(TRIM(disposition_outcome)) AS normalized_candidate,
                   COUNT(*) AS row_count
            FROM staging.returns
            GROUP BY disposition_outcome, LOWER(TRIM(disposition_outcome))
            ORDER BY normalized_candidate, raw_value;

--return reason has all caps
--return channel has all caps
--product condition has all caps
--disposition outcome has lagacy?

-------------------------------------------------------------------------

--Inventory Activity

    --activity_type
        --frequency distribution
            SELECT
                activity_type,
                COUNT(*) AS row_count
            FROM staging.inventory_activity
            GROUP BY activity_type
            ORDER BY row_count DESC, activity_type;

        --expose hidden whitespace and blanks
            SELECT
                activity_type,
                LENGTH(activity_type) AS original_length,
                LENGTH(TRIM(activity_type)) AS trimmed_length,
                COUNT(*) AS row_count
            FROM staging.inventory_activity
            GROUP BY activity_type
            ORDER BY activity_type;

        --Compare raw and normalized candidates
            SELECT
                activity_type AS raw_value,
                LOWER(TRIM(activity_type)) AS normalized_candidate,
                COUNT(*) AS row_count
            FROM staging.inventory_activity
            GROUP BY activity_type, LOWER(TRIM(activity_type))
            ORDER BY normalized_candidate, raw_value;
--activity type has all caps and has lagacy?



--Materials has ALL CAPS
--Colors has ALL CAPS and WHITE SPACES
--Customer_City has 1239 white spaces & 1215 normalized cities have 2 variations (all caps and all lower)
--Customer State has White Spaces
-- Sales Channel has All CAPs and white spaces
-- Order Status has All CAPs and white spaces
-- Requested Service Level has All CAPs and white spaces
--carrier name has all caps and possibly dups and white spaces
--shipping method has all caps and white spaces
--shipping statements has all caps and white spaces
--shipping status has all caps and white spaces
--fulfillment method has all caps and white spaces
--order_item_status has all caps and white spaces
--discount type has all caps and white spaces
--return reason has all caps and white spaces
--return channel has all caps and white spaces
--product condition has all caps and white spaces
--disposition outcome has lagacy and white spaces
--activity type has all caps and has lagacy and white spaces