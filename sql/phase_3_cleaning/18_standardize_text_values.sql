-- -- Phase 3 / Task 16 — Standardize Text Values
-- Read-only validation and candidate previews against staging.
-- Apply the approved formatting in the clean layer.

-- ============================================================
-- Customers: customer_state
-- Business rule:
-- Remove leading and trailing spaces while preserving the
-- existing state abbreviation.
--
-- Approved transformation: TRIM(customer_state)
-- Grain: one row = one customer
-- ============================================================

WITH customer_state_validation AS (
    SELECT
        customer_state AS raw_state,
        TRIM(customer_state) AS cleaned_state,
        UPPER(customer_state) AS uppercase_state
    FROM staging.customers
)
SELECT
    COUNT(*) AS total_customer_rows,
    COUNT(*) FILTER (WHERE raw_state <> cleaned_state) AS rows_requiring_trim,
    COUNT(*) FILTER (WHERE raw_state = cleaned_state) AS unchanged_non_null_rows,
    COUNT(*) FILTER (WHERE raw_state IS NULL) AS null_state_count,
    COUNT(*) FILTER (WHERE raw_state <> uppercase_state) AS capitalization_issue_count,
    COUNT(*) FILTER (WHERE LENGTH(cleaned_state) <> 2) AS invalid_length_count
FROM customer_state_validation;

-- Verified: 2,049 require TRIM + 198,751 unchanged + 0 NULL = 200,800.
-- Capitalization issues: 0. Invalid lengths: 0. UPPER is unnecessary.

-- Inspect distinct codes. A two-character code can still be invalid.
SELECT DISTINCT
    TRIM(customer_state) AS cleaned_customer_state
FROM staging.customers
ORDER BY cleaned_customer_state;

-- Targeted cross-column investigation of the invalid code ZZ.
SELECT
    COUNT(*) AS zz_state_count,
    COUNT(*) FILTER (
        WHERE customer_zip_code IS NULL OR TRIM(customer_zip_code) = ''
    ) AS zz_missing_zip_count
FROM staging.customers
WHERE TRIM(customer_state) = 'ZZ';

-- Verified: 402 ZZ rows, with 0 NULL or blank ZIP values.
-- A populated ZIP does not establish a replacement state.
-- Preserve ZZ for separate categorical/geographic investigation.

-- Final candidates: all customer rows whose state changes under TRIM.
WITH customer_state_candidates AS (
    SELECT
        customer_id,
        customer_state AS original_customer_state,
        TRIM(customer_state) AS cleaned_customer_state
    FROM staging.customers
)
SELECT customer_id, original_customer_state, cleaned_customer_state
FROM customer_state_candidates
WHERE original_customer_state <> cleaned_customer_state;

-- ============================================================
-- Customers: customer_city
-- Business rule:
-- Remove leading and trailing spaces and standardize populated
-- city values to lowercase while preserving the city name.
--
-- Approved transformation: LOWER(TRIM(customer_city))
-- Grain: one row = one customer
-- ============================================================

WITH customer_city_validation AS (
    SELECT
        customer_city AS raw_city,
        TRIM(customer_city) AS trimmed_city,
        LOWER(customer_city) AS lowercase_raw_city,
        LOWER(TRIM(customer_city)) AS cleaned_city
    FROM staging.customers
)
SELECT
    COUNT(*) AS total_customer_rows,
    COUNT(*) FILTER (WHERE raw_city <> cleaned_city) AS rows_to_standardize,
    COUNT(*) FILTER (WHERE raw_city = cleaned_city) AS unchanged_non_null_rows,
    COUNT(*) FILTER (WHERE raw_city <> trimmed_city) AS whitespace_row_count,
    COUNT(*) FILTER (WHERE raw_city <> lowercase_raw_city) AS capitalization_change_count,
    COUNT(*) FILTER (
        WHERE raw_city <> trimmed_city AND trimmed_city <> cleaned_city
    ) AS whitespace_and_case_count,
    COUNT(*) FILTER (WHERE raw_city IS NULL) AS null_city_count,
    COUNT(*) FILTER (WHERE trimmed_city = '') AS blank_city_count
FROM customer_city_validation;

-- Verified: 199,541 changed + 0 unchanged populated + 1,259 NULL = 200,800.
-- Case changes: 199,541. Whitespace changes: 1,944, all also requiring
-- lowercase standardization. Blank after TRIM: 0.
-- Case changes reflect the chosen format. NULL handling belongs to Task 20.

-- Compare distinct text representations separately from customer-row counts.
WITH customer_city_values AS (
    SELECT
        customer_city AS raw_city,
        TRIM(customer_city) AS trimmed_city,
        LOWER(TRIM(customer_city)) AS cleaned_city
    FROM staging.customers
    WHERE customer_city IS NOT NULL
)
SELECT
    COUNT(DISTINCT raw_city) FILTER (
        WHERE raw_city <> trimmed_city
    ) AS distinct_whitespace_city_count,
    COUNT(DISTINCT raw_city) AS raw_distinct_city_count,
    COUNT(DISTINCT cleaned_city) AS cleaned_distinct_city_count,
    COUNT(DISTINCT raw_city) - COUNT(DISTINCT cleaned_city)
        AS raw_text_variants_collapsed
FROM customer_city_values;

-- Verified: 1,239 distinct whitespace-affected raw values.
-- 15,489 raw distinct values - 14,274 cleaned distinct values = 1,215.

-- Inspect up to 20 normalized cities with multiple raw representations.
WITH customer_city_variants AS (
    SELECT
        LOWER(TRIM(customer_city)) AS normalized_customer_city,
        COUNT(DISTINCT customer_city) AS raw_distinct_city_count
    FROM staging.customers
    WHERE customer_city IS NOT NULL
    GROUP BY LOWER(TRIM(customer_city))
)
SELECT normalized_customer_city, raw_distinct_city_count
FROM customer_city_variants
WHERE raw_distinct_city_count > 1
ORDER BY raw_distinct_city_count DESC, normalized_customer_city
LIMIT 20;

-- Verified across the full population: 1,215 normalized cities with
-- multiple raw variants. Maximum raw variants per normalized city: 2.

SELECT DISTINCT
    customer_city AS raw_customer_city,
    LOWER(TRIM(customer_city)) AS normalized_customer_city
FROM staging.customers
WHERE LOWER(TRIM(customer_city)) = 'aberdeen'
ORDER BY raw_customer_city;

-- Verified example: ' ABERDEEN ' and 'Aberdeen' both become 'aberdeen'.

-- Final candidates: all affected customer rows.
-- For a representative preview, add LIMIT 20 before the semicolon.
WITH customer_city_candidates AS (
    SELECT
        customer_id,
        customer_city AS original_customer_city,
        LOWER(TRIM(customer_city)) AS cleaned_customer_city
    FROM staging.customers
)
SELECT customer_id, original_customer_city, cleaned_customer_city
FROM customer_city_candidates
WHERE original_customer_city <> cleaned_customer_city;

-- ============================================================
-- Products: material
-- Business rule:
-- Remove leading and trailing spaces and standardize populated
-- material values to lowercase while preserving the material category.
--
-- Approved transformation: LOWER(TRIM(material))
-- Grain: one row = one product
-- ============================================================

WITH material_validation AS (
    SELECT
        material AS raw_material,
        TRIM(material) AS trimmed_material,
        LOWER(material) AS lowercase_raw_material,
        LOWER(TRIM(material)) AS cleaned_material
    FROM staging.products
)
SELECT
    COUNT(*) AS total_product_rows,
    COUNT(*) FILTER (WHERE raw_material <> cleaned_material) AS rows_to_standardize,
    COUNT(*) FILTER (WHERE raw_material = cleaned_material) AS unchanged_non_null_rows,
    COUNT(*) FILTER (WHERE raw_material <> trimmed_material) AS rows_to_trim,
    COUNT(*) FILTER (WHERE raw_material <> lowercase_raw_material) AS rows_to_lower,
    COUNT(*) FILTER (
        WHERE raw_material <> trimmed_material AND trimmed_material <> cleaned_material
    ) AS rows_to_lower_and_trim,
    COUNT(*) FILTER (WHERE raw_material IS NULL) AS null_material_count,
    COUNT(*) FILTER (WHERE trimmed_material = '') AS blank_material_count
FROM material_validation;

-- Verified: 1,987 changed + 0 unchanged populated + 13 NULL = 2,000.
-- Case changes: 1,987. Whitespace changes: 23, all also requiring
-- lowercase standardization. Blank after TRIM: 0.
-- Case changes reflect the chosen format. NULL handling belongs to Task 20.

-- Compare distinct text representations separately from product-row counts.
WITH material_values AS (
    SELECT
        material AS raw_material,
        LOWER(TRIM(material)) AS cleaned_material
    FROM staging.products
    WHERE material IS NOT NULL
)
SELECT
    COUNT(DISTINCT raw_material) AS raw_distinct_material_count,
    COUNT(DISTINCT cleaned_material) AS cleaned_distinct_material_count,
    COUNT(DISTINCT raw_material) - COUNT(DISTINCT cleaned_material)
        AS raw_text_variants_collapsed
FROM material_values;

-- Verified: 10 raw distinct values - 5 cleaned distinct values = 5.

-- Inspect normalized material categories with multiple raw representations.
WITH material_variants AS (
    SELECT
        LOWER(TRIM(material)) AS normalized_material,
        COUNT(DISTINCT material) AS raw_distinct_material_count
    FROM staging.products
    WHERE material IS NOT NULL
    GROUP BY LOWER(TRIM(material))
)
SELECT normalized_material, raw_distinct_material_count
FROM material_variants
WHERE raw_distinct_material_count > 1
ORDER BY normalized_material;

-- Verified: 5 normalized categories with exactly 2 raw variants each.

SELECT DISTINCT
    material AS raw_material,
    LOWER(TRIM(material)) AS normalized_material
FROM staging.products
WHERE LOWER(TRIM(material)) = 'metal'
ORDER BY raw_material;

-- Verified example: ' METAL ' and 'Metal' both become 'metal'.

-- Final candidates: all affected product rows.
-- For a representative preview, add LIMIT 20 before the semicolon.
WITH material_candidates AS (
    SELECT
        product_id,
        material AS original_material,
        LOWER(TRIM(material)) AS cleaned_material
    FROM staging.products
)
SELECT product_id, original_material, cleaned_material
FROM material_candidates
WHERE original_material <> cleaned_material;
-- ============================================================
-- Products: color
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- color values to lowercase while preserving color meaning.
--
-- Approved transformation: LOWER(TRIM(color))
-- Grain: one row = one product
-- ============================================================


-- 1. Summary validation
WITH color_validation AS (
    SELECT
        product_id,
        color AS original_color,
        LOWER(TRIM(color)) AS cleaned_color,

        CASE
            WHEN color <> TRIM(color) THEN 1
            ELSE 0
        END AS needs_trim_flag,

        CASE
            WHEN color <> LOWER(color) THEN 1
            ELSE 0
        END AS needs_lowercase_flag,

        CASE
            WHEN color IS NULL THEN 1
            ELSE 0
        END AS null_color_flag,

        CASE
            WHEN color IS NOT NULL
                AND TRIM(color) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag

    FROM staging.products
)

SELECT
    COUNT(*) AS total_product_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_color_flag) AS null_color_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_color <> cleaned_color
    ) AS rows_changed_by_cleaning
FROM color_validation;

-- Verified: 2,000 total product rows. All 2,000 populated color values
-- change under LOWER(TRIM(color)).
-- 25 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- The 2,000 changed rows do not represent 2,000 defects:
-- lowercase is the chosen clean format, while 25 rows have confirmed whitespace.

-- 2. Compare raw vs. cleaned distinct color values
WITH color_validation AS (
    SELECT
        color AS original_color,
        LOWER(TRIM(color)) AS cleaned_color
    FROM staging.products
)

SELECT
    COUNT(DISTINCT original_color) AS raw_distinct_color_count,
    COUNT(DISTINCT cleaned_color) AS cleaned_distinct_color_count
FROM color_validation;

-- Verified: 12 raw distinct color values become 6 cleaned values.
-- Formatting standardization collapses 6 extra raw text representations.


-- 3. Identify cleaned colors with multiple raw representations
WITH color_validation AS (
    SELECT
        color AS original_color,
        LOWER(TRIM(color)) AS cleaned_color
    FROM staging.products
)

SELECT
    cleaned_color,
    COUNT(DISTINCT original_color) AS raw_variant_count
FROM color_validation
GROUP BY cleaned_color
HAVING COUNT(DISTINCT original_color) > 1
ORDER BY cleaned_color;

-- Verified: all 6 cleaned colors have exactly 2 raw representations each.
-- This supports formatting fragmentation rather than separate color categories.

-- 4. Inspect the actual raw variants and their frequency
WITH color_validation AS (
    SELECT
        color AS original_color,
        LOWER(TRIM(color)) AS cleaned_color
    FROM staging.products
)

SELECT
    cleaned_color,
    original_color,
    COUNT(*) AS product_count
FROM color_validation
GROUP BY
    cleaned_color,
    original_color
ORDER BY
    cleaned_color,
    original_color;

-- Verified whitespace variants:
-- BLACK = 7, BLUE = 1, GRAY = 5, NATURAL = 7, WALNUT = 2, WHITE = 3.
-- 7 + 1 + 5 + 7 + 2 + 3 = 25 rows requiring TRIM,
-- matching the Part 1 control total.
-- All raw-variant frequencies reconcile to 2,000 product rows.

-- 5. Final cleaning candidate
WITH color_validation AS (
    SELECT
        product_id,
        color AS original_color,
        LOWER(TRIM(color)) AS cleaned_color
    FROM staging.products
)

SELECT
    product_id,
    original_color,
    cleaned_color
FROM color_validation
WHERE original_color <> cleaned_color
ORDER BY product_id;

-- Verified: representative candidates change only case and/or surrounding
-- whitespace while preserving the underlying color meaning.
-- Final Task 16 candidate: LOWER(TRIM(color)).

-- ============================================================
-- Orders: sales_channel
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- sales_channel values to lowercase while preserving the
-- underlying sales-channel meaning.
--
-- Approved transformation: LOWER(TRIM(sales_channel))
-- Grain: one row = one order
-- ============================================================


-- 1. Summary validation
WITH sales_channel_validation AS (
    SELECT
        order_id,
        sales_channel AS original_sales_channel,
        LOWER(TRIM(sales_channel)) AS cleaned_sales_channel,

        CASE
            WHEN sales_channel <> TRIM(sales_channel) THEN 1
            ELSE 0
        END AS needs_trim_flag,

        CASE
            WHEN sales_channel <> LOWER(sales_channel) THEN 1
            ELSE 0
        END AS needs_lowercase_flag,

        CASE
            WHEN sales_channel IS NULL THEN 1
            ELSE 0
        END AS null_sales_channel_flag,

        CASE
            WHEN sales_channel IS NOT NULL
                AND TRIM(sales_channel) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag

    FROM staging.orders
)

SELECT
    COUNT(*) AS total_order_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_sales_channel_flag) AS null_sales_channel_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_sales_channel <> cleaned_sales_channel
    ) AS rows_changed_by_cleaning
FROM sales_channel_validation;

-- Verified: 501,000 total order rows. All 501,000 values change under
-- LOWER(TRIM(sales_channel)).
-- 6,012 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Case changes reflect the chosen lowercase format; 6,012 rows have
-- confirmed surrounding-whitespace formatting issues.

-- 2. Compare raw vs. cleaned distinct sales_channel values
WITH sales_channel_validation AS (
    SELECT
        sales_channel AS original_sales_channel,
        LOWER(TRIM(sales_channel)) AS cleaned_sales_channel
    FROM staging.orders
)

SELECT
    COUNT(DISTINCT original_sales_channel) AS raw_distinct_sales_channel_count,
    COUNT(DISTINCT cleaned_sales_channel) AS cleaned_distinct_sales_channel_count
FROM sales_channel_validation;

-- Verified: 6 raw distinct sales_channel values become 3 cleaned values.
-- Formatting standardization collapses 3 extra raw text representations.

-- 3. Identify cleaned sales channels with multiple raw representations
WITH sales_channel_validation AS (
    SELECT
        sales_channel AS original_sales_channel,
        LOWER(TRIM(sales_channel)) AS cleaned_sales_channel
    FROM staging.orders
)

SELECT
    cleaned_sales_channel,
    COUNT(DISTINCT original_sales_channel) AS raw_variant_count
FROM sales_channel_validation
GROUP BY cleaned_sales_channel
HAVING COUNT(DISTINCT original_sales_channel) > 1
ORDER BY cleaned_sales_channel;

-- Verified: click-and-collect, in-store, and online each have exactly
-- 2 raw formatting representations.

-- 4. Inspect the actual raw variants and their frequency
WITH sales_channel_validation AS (
    SELECT
        sales_channel AS original_sales_channel,
        LOWER(TRIM(sales_channel)) AS cleaned_sales_channel
    FROM staging.orders
)

SELECT
    cleaned_sales_channel,
    original_sales_channel,
    COUNT(*) AS order_count
FROM sales_channel_validation
GROUP BY
    cleaned_sales_channel,
    original_sales_channel
ORDER BY
    cleaned_sales_channel,
    original_sales_channel;

-- Verified whitespace variants:
-- CLICK-AND-COLLECT = 942, IN-STORE = 1,873, ONLINE = 3,197.
-- 942 + 1,873 + 3,197 = 6,012 rows requiring TRIM,
-- matching the Part 1 control total.
-- All raw-variant frequencies reconcile to 501,000 order rows.

-- 5. Final cleaning candidate
WITH sales_channel_validation AS (
    SELECT
        order_id,
        sales_channel AS original_sales_channel,
        LOWER(TRIM(sales_channel)) AS cleaned_sales_channel
    FROM staging.orders
)

SELECT
    order_id,
    original_sales_channel,
    cleaned_sales_channel
FROM sales_channel_validation
WHERE original_sales_channel <> cleaned_sales_channel
ORDER BY order_id;

-- Verified: representative candidates change formatting only and preserve
-- the underlying sales-channel meaning.
-- Final Task 16 candidate: LOWER(TRIM(sales_channel)).

-- ============================================================
-- Orders: order_status
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- order_status values to lowercase while preserving the
-- underlying order_status meaning.
--
-- Approved transformation: LOWER(TRIM(order_status))
-- Grain: one row = one order
--
-- Note:
-- Legacy status labels are standardized for whitespace/case only.
-- Semantic mapping of legacy statuses is deferred to Task 17.
-- ============================================================


-- 1. Summary validation
WITH order_status_validation AS (
    SELECT
        order_id,
        order_status AS original_order_status,
        LOWER(TRIM(order_status)) AS cleaned_order_status,

        CASE
            WHEN order_status <> TRIM(order_status) THEN 1
            ELSE 0
        END AS needs_trim_flag,

        CASE
            WHEN order_status <> LOWER(order_status) THEN 1
            ELSE 0
        END AS needs_lowercase_flag,

        CASE
            WHEN order_status IS NULL THEN 1
            ELSE 0
        END AS null_order_status_flag,

        CASE
            WHEN order_status IS NOT NULL
                AND TRIM(order_status) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag

    FROM staging.orders
)

SELECT
    COUNT(*) AS total_order_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_order_status_flag) AS null_order_status_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_order_status <> cleaned_order_status
    ) AS rows_changed_by_cleaning
FROM order_status_validation;

-- Verified: 501,000 total order rows. All 501,000 values change under
-- LOWER(TRIM(order_status)).
-- 6,081 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Legacy labels remain present and are not semantically mapped in Task 16.

-- 2. Compare raw vs. cleaned distinct order_status values
WITH order_status_validation AS (
    SELECT
        order_status AS original_order_status,
        LOWER(TRIM(order_status)) AS cleaned_order_status
    FROM staging.orders
)

SELECT
    COUNT(DISTINCT original_order_status) AS raw_distinct_order_status_count,
    COUNT(DISTINCT cleaned_order_status) AS cleaned_distinct_order_status_count
FROM order_status_validation;

-- Verified: 12 raw distinct order_status values become 8 cleaned values.
-- Formatting standardization collapses 4 extra raw text representations.

-- 3. Identify cleaned order statuses with multiple raw representations
WITH order_status_validation AS (
    SELECT
        order_status AS original_order_status,
        LOWER(TRIM(order_status)) AS cleaned_order_status
    FROM staging.orders
)

SELECT
    cleaned_order_status,
    COUNT(DISTINCT original_order_status) AS raw_variant_count
FROM order_status_validation
GROUP BY cleaned_order_status
HAVING COUNT(DISTINCT original_order_status) > 1
ORDER BY cleaned_order_status;

-- Verified: cancelled, completed, delivered, and partially cancelled
-- each have 2 raw formatting representations.
-- Legacy-prefixed statuses remain separate cleaned values.

-- 4. Inspect the actual raw variants and their frequency
WITH order_status_validation AS (
    SELECT
        order_status AS original_order_status,
        LOWER(TRIM(order_status)) AS cleaned_order_status
    FROM staging.orders
)

SELECT
    cleaned_order_status,
    original_order_status,
    COUNT(*) AS order_count
FROM order_status_validation
GROUP BY
    cleaned_order_status,
    original_order_status
ORDER BY
    cleaned_order_status,
    original_order_status;

-- Verified whitespace variants:
-- CANCELLED = 104, COMPLETED = 2,706, DELIVERED = 3,203,
-- PARTIALLY CANCELLED = 68.
-- 104 + 2,706 + 3,203 + 68 = 6,081 rows requiring TRIM.
-- All raw-variant frequencies reconcile to 501,000 order rows.
-- legacy: values are preserved for semantic review in Task 17.

-- 5. Final cleaning candidate
WITH order_status_validation AS (
    SELECT
        order_id,
        order_status AS original_order_status,
        LOWER(TRIM(order_status)) AS cleaned_order_status
    FROM staging.orders
)

SELECT
    order_id,
    original_order_status,
    cleaned_order_status
FROM order_status_validation
WHERE original_order_status <> cleaned_order_status
ORDER BY order_id;

-- Verified: Task 16 changes whitespace/case only.
-- The legacy: prefix remains intact and no semantic categories are merged.
-- Final Task 16 candidate: LOWER(TRIM(order_status)).

-- ============================================================
-- Orders: requested_service_level
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- requested_service_level values to lowercase while preserving the
-- underlying requested_service_level meaning.
--
-- Approved transformation: LOWER(TRIM(requested_service_level))
-- Grain: one row = one order
--
-- Note:
-- NULL requested_service_level values are preserved.
-- Missing-value handling is deferred to Task 20.
-- ============================================================

-- 1. Summary validation
WITH requested_service_level_validation AS (
    SELECT
        order_id,
        requested_service_level AS original_requested_service_level,
        LOWER(TRIM(requested_service_level)) AS cleaned_requested_service_level,

        CASE
            WHEN requested_service_level <> TRIM(requested_service_level) THEN 1
            ELSE 0
        END AS needs_trim_flag,

        CASE
            WHEN requested_service_level <> LOWER(requested_service_level) THEN 1
            ELSE 0
        END AS needs_lowercase_flag,

        CASE
            WHEN requested_service_level IS NULL THEN 1
            ELSE 0
        END AS null_requested_service_level_flag,

        CASE
            WHEN requested_service_level IS NOT NULL
                AND TRIM(requested_service_level) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag

    FROM staging.orders
)

SELECT
    COUNT(*) AS total_order_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_requested_service_level_flag) AS null_requested_service_level_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_requested_service_level <> cleaned_requested_service_level
    ) AS rows_changed_by_cleaning
FROM requested_service_level_validation;

-- Verified: 501,000 total order rows.
-- 350,990 populated values change under LOWER(TRIM(requested_service_level)).
-- 4,150 rows require TRIM. 150,010 values are NULL.
-- 0 populated values become blank after TRIM.
-- 350,990 populated + 150,010 NULL = 501,000 total rows.

-- 2. Compare raw vs. cleaned distinct requested_service_level values
WITH requested_service_level_validation AS (
    SELECT
        requested_service_level AS original_requested_service_level,
        LOWER(TRIM(requested_service_level)) AS cleaned_requested_service_level
    FROM staging.orders
)

SELECT
    COUNT(DISTINCT original_requested_service_level) AS raw_distinct_requested_service_level_count,
    COUNT(DISTINCT cleaned_requested_service_level) AS cleaned_distinct_requested_service_level_count
FROM requested_service_level_validation;

-- Verified: 10 raw distinct populated service-level values become
-- 5 cleaned values.
-- Formatting standardization collapses 5 extra raw text representations.

-- 3. Identify cleaned requested service level with multiple raw representations
WITH requested_service_level_validation AS (
    SELECT
        requested_service_level AS original_requested_service_level,
        LOWER(TRIM(requested_service_level)) AS cleaned_requested_service_level
    FROM staging.orders
)

SELECT
    cleaned_requested_service_level,
    COUNT(DISTINCT original_requested_service_level) AS raw_variant_count
FROM requested_service_level_validation
GROUP BY cleaned_requested_service_level
HAVING COUNT(DISTINCT original_requested_service_level) > 1
ORDER BY cleaned_requested_service_level;

-- Verified: expedited, premium, scheduled, standard, and store pickup
-- each have exactly 2 raw formatting representations.

-- 4. Inspect the actual raw variants and their frequency
WITH requested_service_level_validation AS (
    SELECT
        requested_service_level AS original_requested_service_level,
        LOWER(TRIM(requested_service_level)) AS cleaned_requested_service_level
    FROM staging.orders
)

SELECT
    cleaned_requested_service_level,
    original_requested_service_level,
    COUNT(*) AS order_count
FROM requested_service_level_validation
GROUP BY
    cleaned_requested_service_level,
    original_requested_service_level
ORDER BY
    cleaned_requested_service_level,
    original_requested_service_level;

-- Verified whitespace variants:
-- EXPEDITED = 285, PREMIUM = 180, SCHEDULED = 373,
-- STANDARD = 2,387, STORE PICKUP = 925.
-- 285 + 180 + 373 + 2,387 + 925 = 4,150 rows requiring TRIM.
-- Frequencies, including the 150,010 NULL rows, reconcile to
-- 501,000 total order rows.

-- 5. Final cleaning candidate
WITH requested_service_level_validation AS (
    SELECT
        order_id,
        requested_service_level AS original_requested_service_level,
        LOWER(TRIM(requested_service_level)) AS cleaned_requested_service_level
    FROM staging.orders
)

SELECT
    order_id,
    original_requested_service_level,
    cleaned_requested_service_level
FROM requested_service_level_validation
WHERE original_requested_service_level <> cleaned_requested_service_level
ORDER BY order_id;

-- Verified: populated candidates change formatting only.
-- NULL requested_service_level values are preserved because NULL handling
-- belongs to Task 20.
-- Final Task 16 candidate: LOWER(TRIM(requested_service_level)).

-- ============================================================
-- Shipments: carrier_name
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- carrier_name values to lowercase while preserving the
-- underlying carrier meaning.
--
-- Approved transformation: LOWER(TRIM(carrier_name))
-- Grain: one row = one shipment staging record
--
-- Note:
-- Potential duplicate carrier names are not merged in Task 16.
-- Any semantic consolidation requires separate validation.
-- ============================================================

-- 1. Summary validation
WITH carrier_name_validation AS (
    SELECT
        shipment_id,
        carrier_name AS original_carrier_name,
        LOWER(TRIM(carrier_name)) AS cleaned_carrier_name,

        CASE
            WHEN carrier_name <> TRIM(carrier_name) THEN 1
            ELSE 0
        END AS needs_trim_flag,

        CASE
            WHEN carrier_name <> LOWER(carrier_name) THEN 1
            ELSE 0
        END AS needs_lowercase_flag,

        CASE
            WHEN carrier_name IS NULL THEN 1
            ELSE 0
        END AS null_carrier_name_flag,

        CASE
            WHEN carrier_name IS NOT NULL
                AND TRIM(carrier_name) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag

    FROM staging.shipments
)

SELECT
    COUNT(*) AS total_shipment_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_carrier_name_flag) AS null_carrier_name_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_carrier_name <> cleaned_carrier_name
    ) AS rows_changed_by_cleaning
FROM carrier_name_validation;

-- Verified: 287,191 shipment staging rows.
-- All 287,191 carrier_name values change under LOWER(TRIM(carrier_name)).
-- 2,807 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen format; 2,807 rows have
-- confirmed surrounding-whitespace issues.

-- 2. Compare raw vs. cleaned distinct carrier_name values
WITH carrier_name_validation AS (
    SELECT
        carrier_name AS original_carrier_name,
        LOWER(TRIM(carrier_name)) AS cleaned_carrier_name
    FROM staging.shipments
)

SELECT
    COUNT(DISTINCT original_carrier_name) AS raw_distinct_carrier_name_count,
    COUNT(DISTINCT cleaned_carrier_name) AS cleaned_distinct_carrier_name_count
FROM carrier_name_validation;

-- Verified: 33 raw distinct carrier_name values become 22 cleaned values.
-- Formatting standardization collapses 11 extra raw text representations.

-- 3. Identify cleaned carrier name with multiple raw representations
WITH carrier_name_validation AS (
    SELECT
        carrier_name AS original_carrier_name,
        LOWER(TRIM(carrier_name)) AS cleaned_carrier_name
    FROM staging.shipments
)

SELECT
    cleaned_carrier_name,
    COUNT(DISTINCT original_carrier_name) AS raw_variant_count
FROM carrier_name_validation
GROUP BY cleaned_carrier_name
HAVING COUNT(DISTINCT original_carrier_name) > 1
ORDER BY cleaned_carrier_name;

-- Verified: 11 current carrier names have multiple raw formatting
-- representations, with 2 raw variants each.
-- Legacy-prefixed carrier names remain separate cleaned values.

-- 4. Inspect the actual raw variants and their frequency
WITH carrier_name_validation AS (
    SELECT
        carrier_name AS original_carrier_name,
        LOWER(TRIM(carrier_name)) AS cleaned_carrier_name
    FROM staging.shipments
)

SELECT
    cleaned_carrier_name,
    original_carrier_name,
    COUNT(*) AS shipment_count
FROM carrier_name_validation
GROUP BY
    cleaned_carrier_name,
    original_carrier_name
ORDER BY
    cleaned_carrier_name,
    original_carrier_name;

-- Verified: the whitespace-affected raw variants sum to 2,807 rows,
-- exactly matching the Part 1 rows_requiring_trim count.
-- The cleaned population contains 11 current carrier labels and
-- 11 corresponding legacy-prefixed labels.
-- No current/legacy semantic merging is performed in Task 16.

-- 5. Final cleaning candidate
WITH carrier_name_validation AS (
    SELECT
        shipment_id,
        carrier_name AS original_carrier_name,
        LOWER(TRIM(carrier_name)) AS cleaned_carrier_name
    FROM staging.shipments
)

SELECT
    shipment_id,
    original_carrier_name,
    cleaned_carrier_name
FROM carrier_name_validation
WHERE original_carrier_name <> cleaned_carrier_name
ORDER BY shipment_id;

-- Verified: candidate changes preserve carrier text meaning while
-- standardizing case and surrounding whitespace.
-- The legacy: prefix remains intact for later semantic validation.
-- Final Task 16 candidate: LOWER(TRIM(carrier_name)).

-- ============================================================
-- shipments: shipping_method
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- shipping_method values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(shipping_method))
-- Grain: one row = one shipment staging record
-- ============================================================

-- Part 1. Summary validation
WITH shipping_method_validation AS (
    SELECT
        shipment_id,
        shipping_method AS original_shipping_method,
        LOWER(TRIM(shipping_method)) AS cleaned_shipping_method,
        CASE WHEN shipping_method <> TRIM(shipping_method) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN shipping_method <> LOWER(shipping_method) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN shipping_method IS NULL THEN 1 ELSE 0 END
            AS null_shipping_method_flag,
        CASE
            WHEN shipping_method IS NOT NULL AND TRIM(shipping_method) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.shipments
)
SELECT
    COUNT(*) AS total_shipment_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_shipping_method_flag) AS null_shipping_method_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_shipping_method <> cleaned_shipping_method
    ) AS rows_changed_by_cleaning
FROM shipping_method_validation;

-- Verified: 287,191 shipment staging rows.
-- All 287,191 shipping_method values change under
-- LOWER(TRIM(shipping_method)).
-- 2,830 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 2,830 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH shipping_method_validation AS (
    SELECT
        shipping_method AS original_shipping_method,
        LOWER(TRIM(shipping_method)) AS cleaned_shipping_method
    FROM staging.shipments
)
SELECT
    COUNT(DISTINCT original_shipping_method) AS raw_distinct_shipping_method_count,
    COUNT(DISTINCT cleaned_shipping_method) AS cleaned_distinct_shipping_method_count
FROM shipping_method_validation;

-- Verified: 6 raw distinct shipping_method values become 3 cleaned values.
-- Formatting standardization collapses 3 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH shipping_method_validation AS (
    SELECT
        shipping_method AS original_shipping_method,
        LOWER(TRIM(shipping_method)) AS cleaned_shipping_method
    FROM staging.shipments
)
SELECT
    cleaned_shipping_method,
    COUNT(DISTINCT original_shipping_method) AS raw_variant_count
FROM shipping_method_validation
GROUP BY cleaned_shipping_method
HAVING COUNT(DISTINCT original_shipping_method) > 1
ORDER BY cleaned_shipping_method;

-- Verified: less-than-truckload freight, parcel, and white glove
-- each have exactly 2 raw formatting representations.
-- No additional semantic categories were exposed by normalization.

-- Part 4. Inspect original values and their staging-row frequencies
WITH shipping_method_validation AS (
    SELECT
        shipping_method AS original_shipping_method,
        LOWER(TRIM(shipping_method)) AS cleaned_shipping_method
    FROM staging.shipments
)
SELECT
    cleaned_shipping_method,
    original_shipping_method,
    COUNT(*) AS shipment_count
FROM shipping_method_validation
GROUP BY cleaned_shipping_method, original_shipping_method
ORDER BY cleaned_shipping_method, original_shipping_method;

-- Verified whitespace variants:
-- LESS-THAN-TRUCKLOAD FREIGHT = 608,
-- PARCEL = 2,023,
-- WHITE GLOVE = 199.
-- 608 + 2,023 + 199 = 2,830 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All 6 raw-variant frequencies reconcile to 287,191 shipment staging rows.

-- Part 5. Final cleaning candidates
WITH shipping_method_validation AS (
    SELECT
        shipment_id,
        shipping_method AS original_shipping_method,
        LOWER(TRIM(shipping_method)) AS cleaned_shipping_method
    FROM staging.shipments
)
SELECT
    shipment_id,
    original_shipping_method,
    cleaned_shipping_method
FROM shipping_method_validation
WHERE original_shipping_method <> cleaned_shipping_method
ORDER BY shipment_id;

-- Verified representative examples:
-- 'Parcel' -> 'parcel'
-- 'Less-than-Truckload Freight' -> 'less-than-truckload freight'
-- ' WHITE GLOVE ' -> 'white glove'
-- Changes are formatting-only and preserve shipping-method meaning.
-- No additional targeted validation is required from the observed evidence.
-- Final Task 16 candidate: LOWER(TRIM(shipping_method)).

-- ============================================================
-- shipments: shipment_status
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- shipment_status values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(shipment_status))
-- Grain: one row = one shipment staging record
-- ============================================================

-- Part 1. Summary validation
WITH shipment_status_validation AS (
    SELECT
        shipment_id,
        shipment_status AS original_shipment_status,
        LOWER(TRIM(shipment_status)) AS cleaned_shipment_status,
        CASE WHEN shipment_status <> TRIM(shipment_status) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN shipment_status <> LOWER(shipment_status) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN shipment_status IS NULL THEN 1 ELSE 0 END
            AS null_shipment_status_flag,
        CASE
            WHEN shipment_status IS NOT NULL AND TRIM(shipment_status) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.shipments
)
SELECT
    COUNT(*) AS total_shipment_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_shipment_status_flag) AS null_shipment_status_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_shipment_status <> cleaned_shipment_status
    ) AS rows_changed_by_cleaning
FROM shipment_status_validation;

-- Verified: 287,191 shipment staging rows.
-- All 287,191 shipment_status values change under
-- LOWER(TRIM(shipment_status)).
-- 2,986 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 2,986 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH shipment_status_validation AS (
    SELECT
        shipment_status AS original_shipment_status,
        LOWER(TRIM(shipment_status)) AS cleaned_shipment_status
    FROM staging.shipments
)
SELECT
    COUNT(DISTINCT original_shipment_status) AS raw_distinct_shipment_status_count,
    COUNT(DISTINCT cleaned_shipment_status) AS cleaned_distinct_shipment_status_count
FROM shipment_status_validation;

-- Verified: 3 raw distinct shipment_status values become 2 cleaned values.
-- Formatting standardization collapses 1 extra raw text representation.

-- Part 3. Identify cleaned values with multiple raw representations
WITH shipment_status_validation AS (
    SELECT
        shipment_status AS original_shipment_status,
        LOWER(TRIM(shipment_status)) AS cleaned_shipment_status
    FROM staging.shipments
)
SELECT
    cleaned_shipment_status,
    COUNT(DISTINCT original_shipment_status) AS raw_variant_count
FROM shipment_status_validation
GROUP BY cleaned_shipment_status
HAVING COUNT(DISTINCT original_shipment_status) > 1
ORDER BY cleaned_shipment_status;

-- Verified: delivered is the only cleaned shipment_status with
-- multiple raw representations, with 2 raw variants.
-- The other cleaned shipment status has a single raw representation.

-- Part 4. Inspect original values and their staging-row frequencies
WITH shipment_status_validation AS (
    SELECT
        shipment_status AS original_shipment_status,
        LOWER(TRIM(shipment_status)) AS cleaned_shipment_status
    FROM staging.shipments
)
SELECT
    cleaned_shipment_status,
    original_shipment_status,
    COUNT(*) AS shipment_count
FROM shipment_status_validation
GROUP BY cleaned_shipment_status, original_shipment_status
ORDER BY cleaned_shipment_status, original_shipment_status;

-- Verified raw variants:
-- ' DELIVERED ' = 2,986
-- 'Delivered' = 283,050
-- 'legacy:Delivered' = 1,155
-- The 2,986 whitespace-affected rows exactly match the Part 1
-- rows_requiring_trim control total.
-- 2,986 + 283,050 + 1,155 = 287,191 shipment staging rows.
-- legacy:delivered remains a separate cleaned value; semantic mapping
-- is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH shipment_status_validation AS (
    SELECT
        shipment_id,
        shipment_status AS original_shipment_status,
        LOWER(TRIM(shipment_status)) AS cleaned_shipment_status
    FROM staging.shipments
)
SELECT
    shipment_id,
    original_shipment_status,
    cleaned_shipment_status
FROM shipment_status_validation
WHERE original_shipment_status <> cleaned_shipment_status
ORDER BY shipment_id;

-- Verified: representative candidates change case only while preserving
-- shipment-status meaning.
-- Full-population validation also confirmed the whitespace variant
-- ' DELIVERED ' -> 'delivered' and preserved
-- 'legacy:Delivered' -> 'legacy:delivered'.
-- No semantic status mapping is performed in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(shipment_status)).

-- ============================================================
-- order_items: fulfillment_method
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- fulfillment_method values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(fulfillment_method))
-- Grain: one row = one order item staging record
-- ============================================================

-- Part 1. Summary validation
WITH fulfillment_method_validation AS (
    SELECT
        order_item_id,
        fulfillment_method AS original_fulfillment_method,
        LOWER(TRIM(fulfillment_method)) AS cleaned_fulfillment_method,
        CASE WHEN fulfillment_method <> TRIM(fulfillment_method) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN fulfillment_method <> LOWER(fulfillment_method) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN fulfillment_method IS NULL THEN 1 ELSE 0 END
            AS null_fulfillment_method_flag,
        CASE
            WHEN fulfillment_method IS NOT NULL AND TRIM(fulfillment_method) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.order_items
)
SELECT
    COUNT(*) AS total_order_item_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_fulfillment_method_flag) AS null_fulfillment_method_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_fulfillment_method <> cleaned_fulfillment_method
    ) AS rows_changed_by_cleaning
FROM fulfillment_method_validation;

-- Verified: 874,891 order-item staging rows.
-- All 874,891 fulfillment_method values change under
-- LOWER(TRIM(fulfillment_method)).
-- 10,488 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 10,488 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH fulfillment_method_validation AS (
    SELECT
        fulfillment_method AS original_fulfillment_method,
        LOWER(TRIM(fulfillment_method)) AS cleaned_fulfillment_method
    FROM staging.order_items
)
SELECT
    COUNT(DISTINCT original_fulfillment_method) AS raw_distinct_fulfillment_method_count,
    COUNT(DISTINCT cleaned_fulfillment_method) AS cleaned_distinct_fulfillment_method_count
FROM fulfillment_method_validation;

-- Verified: 6 raw distinct fulfillment_method values become 3 cleaned values.
-- Formatting standardization collapses 3 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH fulfillment_method_validation AS (
    SELECT
        fulfillment_method AS original_fulfillment_method,
        LOWER(TRIM(fulfillment_method)) AS cleaned_fulfillment_method
    FROM staging.order_items
)
SELECT
    cleaned_fulfillment_method,
    COUNT(DISTINCT original_fulfillment_method) AS raw_variant_count
FROM fulfillment_method_validation
GROUP BY cleaned_fulfillment_method
HAVING COUNT(DISTINCT original_fulfillment_method) > 1
ORDER BY cleaned_fulfillment_method;

-- Verified: home delivery, in-store, and store pickup each have
-- exactly 2 raw formatting representations.
-- This supports formatting fragmentation rather than separate
-- fulfillment-method categories.

-- Part 4. Inspect original values and their staging-row frequencies
WITH fulfillment_method_validation AS (
    SELECT
        fulfillment_method AS original_fulfillment_method,
        LOWER(TRIM(fulfillment_method)) AS cleaned_fulfillment_method
    FROM staging.order_items
)
SELECT
    cleaned_fulfillment_method,
    original_fulfillment_method,
    COUNT(*) AS order_item_count
FROM fulfillment_method_validation
GROUP BY cleaned_fulfillment_method, original_fulfillment_method
ORDER BY cleaned_fulfillment_method, original_fulfillment_method;

-- Verified whitespace variants:
-- HOME DELIVERY = 5,783
-- IN-STORE = 3,087
-- STORE PICKUP = 1,618
-- 5,783 + 3,087 + 1,618 = 10,488 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All 6 raw-variant frequencies reconcile to 874,891 order-item staging rows.

-- Part 5. Final cleaning candidates
WITH fulfillment_method_validation AS (
    SELECT
        order_item_id,
        fulfillment_method AS original_fulfillment_method,
        LOWER(TRIM(fulfillment_method)) AS cleaned_fulfillment_method
    FROM staging.order_items
)
SELECT
    order_item_id,
    original_fulfillment_method,
    cleaned_fulfillment_method
FROM fulfillment_method_validation
WHERE original_fulfillment_method <> cleaned_fulfillment_method
ORDER BY order_item_id;

-- Verified representative examples:
-- 'Home Delivery' -> 'home delivery'
-- 'In-Store' -> 'in-store'
-- 'Store Pickup' -> 'store pickup'
-- ' STORE PICKUP ' -> 'store pickup'
-- Changes are formatting-only and preserve fulfillment-method meaning.
-- No additional targeted validation is required from the observed evidence.
-- Final Task 16 candidate: LOWER(TRIM(fulfillment_method)).

-- ============================================================
-- order_items: order_item_status
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- order_item_status values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(order_item_status))
-- Grain: one row = one order item staging record
-- ============================================================

-- Part 1. Summary validation
WITH order_item_status_validation AS (
    SELECT
        order_item_id,
        order_item_status AS original_order_item_status,
        LOWER(TRIM(order_item_status)) AS cleaned_order_item_status,
        CASE WHEN order_item_status <> TRIM(order_item_status) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN order_item_status <> LOWER(order_item_status) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN order_item_status IS NULL THEN 1 ELSE 0 END
            AS null_order_item_status_flag,
        CASE
            WHEN order_item_status IS NOT NULL AND TRIM(order_item_status) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.order_items
)
SELECT
    COUNT(*) AS total_order_item_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_order_item_status_flag) AS null_order_item_status_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_order_item_status <> cleaned_order_item_status
    ) AS rows_changed_by_cleaning
FROM order_item_status_validation;

-- Verified: 874,891 order-item staging rows.
-- All 874,891 order_item_status values change under
-- LOWER(TRIM(order_item_status)).
-- 10,571 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 10,571 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH order_item_status_validation AS (
    SELECT
        order_item_status AS original_order_item_status,
        LOWER(TRIM(order_item_status)) AS cleaned_order_item_status
    FROM staging.order_items
)
SELECT
    COUNT(DISTINCT original_order_item_status) AS raw_distinct_order_item_status_count,
    COUNT(DISTINCT cleaned_order_item_status) AS cleaned_distinct_order_item_status_count
FROM order_item_status_validation;

-- Verified: 9 raw distinct order_item_status values become 6 cleaned values.
-- Formatting standardization collapses 3 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH order_item_status_validation AS (
    SELECT
        order_item_status AS original_order_item_status,
        LOWER(TRIM(order_item_status)) AS cleaned_order_item_status
    FROM staging.order_items
)
SELECT
    cleaned_order_item_status,
    COUNT(DISTINCT original_order_item_status) AS raw_variant_count
FROM order_item_status_validation
GROUP BY cleaned_order_item_status
HAVING COUNT(DISTINCT original_order_item_status) > 1
ORDER BY cleaned_order_item_status;

-- Verified: cancelled, completed, and delivered each have
-- exactly 2 raw formatting representations.
-- These 3 duplicate representations fully explain the reduction
-- from 9 raw distinct values to 6 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH order_item_status_validation AS (
    SELECT
        order_item_status AS original_order_item_status,
        LOWER(TRIM(order_item_status)) AS cleaned_order_item_status
    FROM staging.order_items
)
SELECT
    cleaned_order_item_status,
    original_order_item_status,
    COUNT(*) AS order_item_count
FROM order_item_status_validation
GROUP BY cleaned_order_item_status, original_order_item_status
ORDER BY cleaned_order_item_status, original_order_item_status;

-- Verified whitespace variants:
-- CANCELLED = 262
-- COMPLETED = 4,592
-- DELIVERED = 5,717
-- 262 + 4,592 + 5,717 = 10,571 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All raw-variant frequencies reconcile to 874,891 order-item staging rows.
-- legacy:cancelled, legacy:completed, and legacy:delivered remain
-- separate cleaned values; semantic mapping is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH order_item_status_validation AS (
    SELECT
        order_item_id,
        order_item_status AS original_order_item_status,
        LOWER(TRIM(order_item_status)) AS cleaned_order_item_status
    FROM staging.order_items
)
SELECT
    order_item_id,
    original_order_item_status,
    cleaned_order_item_status
FROM order_item_status_validation
WHERE original_order_item_status <> cleaned_order_item_status
ORDER BY order_item_id;

-- Verified representative examples:
-- 'Delivered' -> 'delivered'
-- 'Completed' -> 'completed'
-- Full-population validation also confirmed whitespace variants for
-- cancelled, completed, and delivered.
-- legacy:cancelled, legacy:completed, and legacy:delivered remain
-- separate cleaned values; no semantic mapping is performed in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(order_item_status)).

-- ============================================================
-- order_items: discount_type
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- discount_type values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(discount_type))
-- Grain: one row = one order item staging record
-- ============================================================

-- Part 1. Summary validation
WITH discount_type_validation AS (
    SELECT
        order_item_id,
        discount_type AS original_discount_type,
        LOWER(TRIM(discount_type)) AS cleaned_discount_type,
        CASE WHEN discount_type <> TRIM(discount_type) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN discount_type <> LOWER(discount_type) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN discount_type IS NULL THEN 1 ELSE 0 END
            AS null_discount_type_flag,
        CASE
            WHEN discount_type IS NOT NULL AND TRIM(discount_type) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.order_items
)
SELECT
    COUNT(*) AS total_order_item_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_discount_type_flag) AS null_discount_type_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_discount_type <> cleaned_discount_type
    ) AS rows_changed_by_cleaning
FROM discount_type_validation;

-- Verified: 874,891 order-item staging rows.
-- All 874,891 discount_type values change under
-- LOWER(TRIM(discount_type)).
-- 10,437 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 10,437 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH discount_type_validation AS (
    SELECT
        discount_type AS original_discount_type,
        LOWER(TRIM(discount_type)) AS cleaned_discount_type
    FROM staging.order_items
)
SELECT
    COUNT(DISTINCT original_discount_type) AS raw_distinct_discount_type_count,
    COUNT(DISTINCT cleaned_discount_type) AS cleaned_distinct_discount_type_count
FROM discount_type_validation;

-- Verified: 18 raw distinct discount_type values become 12 cleaned values.
-- Formatting standardization collapses 6 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH discount_type_validation AS (
    SELECT
        discount_type AS original_discount_type,
        LOWER(TRIM(discount_type)) AS cleaned_discount_type
    FROM staging.order_items
)
SELECT
    cleaned_discount_type,
    COUNT(DISTINCT original_discount_type) AS raw_variant_count
FROM discount_type_validation
GROUP BY cleaned_discount_type
HAVING COUNT(DISTINCT original_discount_type) > 1
ORDER BY cleaned_discount_type;

-- Verified: category promotion, clearance, coupon, none,
-- product-specific, and seasonal sale each have exactly
-- 2 raw formatting representations.
-- These 6 duplicate representations fully explain the reduction
-- from 18 raw distinct values to 12 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH discount_type_validation AS (
    SELECT
        discount_type AS original_discount_type,
        LOWER(TRIM(discount_type)) AS cleaned_discount_type
    FROM staging.order_items
)
SELECT
    cleaned_discount_type,
    original_discount_type,
    COUNT(*) AS order_item_count
FROM discount_type_validation
GROUP BY cleaned_discount_type, original_discount_type
ORDER BY cleaned_discount_type, original_discount_type;

-- Verified whitespace variants:
-- CATEGORY PROMOTION = 951
-- CLEARANCE = 243
-- COUPON = 964
-- NONE = 7,098
-- PRODUCT-SPECIFIC = 53
-- SEASONAL SALE = 1,128
-- 951 + 243 + 964 + 7,098 + 53 + 1,128 = 10,437 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All raw-variant frequencies reconcile to 874,891 order-item staging rows.
-- Six legacy: discount labels remain separate cleaned values;
-- semantic mapping is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH discount_type_validation AS (
    SELECT
        order_item_id,
        discount_type AS original_discount_type,
        LOWER(TRIM(discount_type)) AS cleaned_discount_type
    FROM staging.order_items
)
SELECT
    order_item_id,
    original_discount_type,
    cleaned_discount_type
FROM discount_type_validation
WHERE original_discount_type <> cleaned_discount_type
ORDER BY order_item_id;

-- Verified representative examples:
-- 'None' -> 'none'
-- 'Coupon' -> 'coupon'
-- 'Seasonal Sale' -> 'seasonal sale'
-- ' SEASONAL SALE ' -> 'seasonal sale'
-- 'Category Promotion' -> 'category promotion'
-- Changes are formatting-only and preserve discount-type meaning.
-- Full-population validation confirmed that legacy: discount labels remain
-- separate cleaned values; no semantic mapping is performed in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(discount_type)).

-- ============================================================
-- returns: return_reason
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- return_reason values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(return_reason))
-- Grain: one row = one return staging record
-- ============================================================

-- Part 1. Summary validation
WITH return_reason_validation AS (
    SELECT
        return_id,
        return_reason AS original_return_reason,
        LOWER(TRIM(return_reason)) AS cleaned_return_reason,
        CASE WHEN return_reason <> TRIM(return_reason) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN return_reason <> LOWER(return_reason) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN return_reason IS NULL THEN 1 ELSE 0 END
            AS null_return_reason_flag,
        CASE
            WHEN return_reason IS NOT NULL AND TRIM(return_reason) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.returns
)
SELECT
    COUNT(*) AS total_return_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_return_reason_flag) AS null_return_reason_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_return_reason <> cleaned_return_reason
    ) AS rows_changed_by_cleaning
FROM return_reason_validation;

-- Verified: 77,716 return staging rows.
-- All 77,716 return_reason values change under
-- LOWER(TRIM(return_reason)).
-- 750 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 750 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH return_reason_validation AS (
    SELECT
        return_reason AS original_return_reason,
        LOWER(TRIM(return_reason)) AS cleaned_return_reason
    FROM staging.returns
)
SELECT
    COUNT(DISTINCT original_return_reason) AS raw_distinct_return_reason_count,
    COUNT(DISTINCT cleaned_return_reason) AS cleaned_distinct_return_reason_count
FROM return_reason_validation;

-- Verified: 21 raw distinct return_reason values become 14 cleaned values.
-- Formatting standardization collapses 7 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH return_reason_validation AS (
    SELECT
        return_reason AS original_return_reason,
        LOWER(TRIM(return_reason)) AS cleaned_return_reason
    FROM staging.returns
)
SELECT
    cleaned_return_reason,
    COUNT(DISTINCT original_return_reason) AS raw_variant_count
FROM return_reason_validation
GROUP BY cleaned_return_reason
HAVING COUNT(DISTINCT original_return_reason) > 1
ORDER BY cleaned_return_reason;

-- Verified: changed mind, damaged, defective, fit/size,
-- not as expected, other, and wrong item each have exactly
-- 2 raw formatting representations.
-- These 7 duplicate representations fully explain the reduction
-- from 21 raw distinct values to 14 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH return_reason_validation AS (
    SELECT
        return_reason AS original_return_reason,
        LOWER(TRIM(return_reason)) AS cleaned_return_reason
    FROM staging.returns
)
SELECT
    cleaned_return_reason,
    original_return_reason,
    COUNT(*) AS return_count
FROM return_reason_validation
GROUP BY cleaned_return_reason, original_return_reason
ORDER BY cleaned_return_reason, original_return_reason;

-- Verified whitespace variants:
-- CHANGED MIND = 203
-- DAMAGED = 175
-- DEFECTIVE = 137
-- FIT/SIZE = 57
-- NOT AS EXPECTED = 96
-- OTHER = 29
-- WRONG ITEM = 53
-- 203 + 175 + 137 + 57 + 96 + 29 + 53 = 750 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All raw-variant frequencies reconcile to 77,716 return staging rows.
-- Seven legacy: return_reason labels remain separate cleaned values;
-- semantic mapping is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH return_reason_validation AS (
    SELECT
        return_id,
        return_reason AS original_return_reason,
        LOWER(TRIM(return_reason)) AS cleaned_return_reason
    FROM staging.returns
)
SELECT
    return_id,
    original_return_reason,
    cleaned_return_reason
FROM return_reason_validation
WHERE original_return_reason <> cleaned_return_reason
ORDER BY return_id;

-- Verified representative examples:
-- 'Wrong Item' -> 'wrong item'
-- 'Defective' -> 'defective'
-- 'Changed Mind' -> 'changed mind'
-- 'Not as Expected' -> 'not as expected'
-- 'Fit/Size' -> 'fit/size'
-- 'Damaged' -> 'damaged'
-- Changes are formatting-only and preserve return-reason meaning.
-- Full-population validation confirmed that legacy: return_reason labels
-- remain separate cleaned values; no semantic mapping is performed in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(return_reason)).

-- ============================================================
-- returns: return_channel
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- return_channel values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(return_channel))
-- Grain: one row = one return staging record
-- ============================================================

-- Part 1. Summary validation
WITH return_channel_validation AS (
    SELECT
        return_id,
        return_channel AS original_return_channel,
        LOWER(TRIM(return_channel)) AS cleaned_return_channel,
        CASE WHEN return_channel <> TRIM(return_channel) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN return_channel <> LOWER(return_channel) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN return_channel IS NULL THEN 1 ELSE 0 END
            AS null_return_channel_flag,
        CASE
            WHEN return_channel IS NOT NULL AND TRIM(return_channel) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.returns
)
SELECT
    COUNT(*) AS total_return_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_return_channel_flag) AS null_return_channel_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_return_channel <> cleaned_return_channel
    ) AS rows_changed_by_cleaning
FROM return_channel_validation;

-- Verified: 77,716 return staging rows.
-- All 77,716 return_channel values change under
-- LOWER(TRIM(return_channel)).
-- 779 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 779 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH return_channel_validation AS (
    SELECT
        return_channel AS original_return_channel,
        LOWER(TRIM(return_channel)) AS cleaned_return_channel
    FROM staging.returns
)
SELECT
    COUNT(DISTINCT original_return_channel) AS raw_distinct_return_channel_count,
    COUNT(DISTINCT cleaned_return_channel) AS cleaned_distinct_return_channel_count
FROM return_channel_validation;

-- Verified: 6 raw distinct return_channel values become 3 cleaned values.
-- Formatting standardization collapses 3 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH return_channel_validation AS (
    SELECT
        return_channel AS original_return_channel,
        LOWER(TRIM(return_channel)) AS cleaned_return_channel
    FROM staging.returns
)
SELECT
    cleaned_return_channel,
    COUNT(DISTINCT original_return_channel) AS raw_variant_count
FROM return_channel_validation
GROUP BY cleaned_return_channel
HAVING COUNT(DISTINCT original_return_channel) > 1
ORDER BY cleaned_return_channel;

-- Verified: carrier pickup, mail, and store each have exactly
-- 2 raw formatting representations.
-- These 3 duplicate representations fully explain the reduction
-- from 6 raw distinct values to 3 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH return_channel_validation AS (
    SELECT
        return_channel AS original_return_channel,
        LOWER(TRIM(return_channel)) AS cleaned_return_channel
    FROM staging.returns
)
SELECT
    cleaned_return_channel,
    original_return_channel,
    COUNT(*) AS return_count
FROM return_channel_validation
GROUP BY cleaned_return_channel, original_return_channel
ORDER BY cleaned_return_channel, original_return_channel;

-- Verified whitespace variants:
-- CARRIER PICKUP = 107
-- MAIL = 245
-- STORE = 427
-- 107 + 245 + 427 = 779 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- All 6 raw-variant frequencies reconcile to 77,716 return staging rows.
-- No additional or legacy return-channel categories were observed.

-- Part 5. Final cleaning candidates
WITH return_channel_validation AS (
    SELECT
        return_id,
        return_channel AS original_return_channel,
        LOWER(TRIM(return_channel)) AS cleaned_return_channel
    FROM staging.returns
)
SELECT
    return_id,
    original_return_channel,
    cleaned_return_channel
FROM return_channel_validation
WHERE original_return_channel <> cleaned_return_channel
ORDER BY return_id;

-- Verified representative examples:
-- 'Store' -> 'store'
-- 'Mail' -> 'mail'
-- 'Carrier Pickup' -> 'carrier pickup'
-- ' STORE ' -> 'store'
-- Changes are formatting-only and preserve return-channel meaning.
-- No additional targeted validation is required from the observed evidence.
-- Final Task 16 candidate: LOWER(TRIM(return_channel)).

-- ============================================================
-- returns: product_condition
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- product_condition values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(product_condition))
-- Grain: one row = one return staging record
-- Note:
-- NULL product_condition values are preserved.
-- Missing-value and conditional validation are deferred to Task 20.
-- ============================================================

-- Part 1. Summary validation
WITH product_condition_validation AS (
    SELECT
        return_id,
        product_condition AS original_product_condition,
        LOWER(TRIM(product_condition)) AS cleaned_product_condition,
        CASE WHEN product_condition <> TRIM(product_condition) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN product_condition <> LOWER(product_condition) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN product_condition IS NULL THEN 1 ELSE 0 END
            AS null_product_condition_flag,
        CASE
            WHEN product_condition IS NOT NULL AND TRIM(product_condition) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.returns
)
SELECT
    COUNT(*) AS total_return_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_product_condition_flag) AS null_product_condition_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_product_condition <> cleaned_product_condition
    ) AS rows_changed_by_cleaning
FROM product_condition_validation;

-- Verified: 77,716 return staging rows.
-- 77,230 populated product_condition values change under
-- LOWER(TRIM(product_condition)).
-- 798 rows require TRIM. 486 values are NULL.
-- 0 populated values become blank after TRIM.
-- 77,230 populated + 486 NULL = 77,716 total return staging rows.
-- The 486 NULL values are preserved in Task 16; their missing-value
-- and conditional treatment belongs to Task 20.

-- Part 2. Compare raw and cleaned distinct values
WITH product_condition_validation AS (
    SELECT
        product_condition AS original_product_condition,
        LOWER(TRIM(product_condition)) AS cleaned_product_condition
    FROM staging.returns
)
SELECT
    COUNT(DISTINCT original_product_condition) AS raw_distinct_product_condition_count,
    COUNT(DISTINCT cleaned_product_condition) AS cleaned_distinct_product_condition_count
FROM product_condition_validation;

-- Verified: 10 raw distinct populated product_condition values become
-- 5 cleaned values.
-- Formatting standardization collapses 5 extra raw text representations.
-- COUNT(DISTINCT ...) excludes the 486 NULL values.

-- Part 3. Identify cleaned values with multiple raw representations
WITH product_condition_validation AS (
    SELECT
        product_condition AS original_product_condition,
        LOWER(TRIM(product_condition)) AS cleaned_product_condition
    FROM staging.returns
)
SELECT
    cleaned_product_condition,
    COUNT(DISTINCT original_product_condition) AS raw_variant_count
FROM product_condition_validation
GROUP BY cleaned_product_condition
HAVING COUNT(DISTINCT original_product_condition) > 1
ORDER BY cleaned_product_condition;

-- Verified: damaged, defective, new, opened, and used each have
-- exactly 2 raw formatting representations.
-- These 5 duplicate representations fully explain the reduction
-- from 10 raw distinct populated values to 5 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH product_condition_validation AS (
    SELECT
        product_condition AS original_product_condition,
        LOWER(TRIM(product_condition)) AS cleaned_product_condition
    FROM staging.returns
)
SELECT
    cleaned_product_condition,
    original_product_condition,
    COUNT(*) AS return_count
FROM product_condition_validation
GROUP BY cleaned_product_condition, original_product_condition
ORDER BY cleaned_product_condition, original_product_condition;

-- Verified whitespace variants:
-- DAMAGED = 175
-- DEFECTIVE = 131
-- NEW = 158
-- OPENED = 303
-- USED = 31
-- 175 + 131 + 158 + 303 + 31 = 798 rows requiring TRIM,
-- exactly matching the Part 1 control total.
-- Populated raw-variant frequencies reconcile to 77,230 rows.
-- 77,230 populated + 486 NULL = 77,716 total return staging rows.
-- NULL product_condition values remain unchanged in Task 16.

-- Part 5. Final cleaning candidates
WITH product_condition_validation AS (
    SELECT
        return_id,
        product_condition AS original_product_condition,
        LOWER(TRIM(product_condition)) AS cleaned_product_condition
    FROM staging.returns
)
SELECT
    return_id,
    original_product_condition,
    cleaned_product_condition
FROM product_condition_validation
WHERE original_product_condition <> cleaned_product_condition
ORDER BY return_id;

-- Verified representative examples:
-- 'New' -> 'new'
-- 'Defective' -> 'defective'
-- 'Used' -> 'used'
-- 'Opened' -> 'opened'
-- 'Damaged' -> 'damaged'
-- Changes are formatting-only and preserve product-condition meaning.
-- NULL product_condition values are excluded from the candidate set
-- and remain unchanged in Task 16.
-- The 486 NULL values remain a separate confirmed missing-value issue
-- for Task 20.
-- Final Task 16 candidate: LOWER(TRIM(product_condition)).

-- ============================================================
-- returns: disposition_outcome
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- disposition_outcome values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(disposition_outcome))
-- Grain: one row = one return staging record
-- Note:
-- Known legacy labels are standardized for whitespace/case only.
-- Preserve the legacy: prefix. Semantic merging belongs to Task 17.
-- ============================================================

-- Part 1. Summary validation
WITH disposition_outcome_validation AS (
    SELECT
        return_id,
        disposition_outcome AS original_disposition_outcome,
        LOWER(TRIM(disposition_outcome)) AS cleaned_disposition_outcome,
        CASE WHEN disposition_outcome <> TRIM(disposition_outcome) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN disposition_outcome <> LOWER(disposition_outcome) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN disposition_outcome IS NULL THEN 1 ELSE 0 END
            AS null_disposition_outcome_flag,
        CASE
            WHEN disposition_outcome IS NOT NULL AND TRIM(disposition_outcome) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.returns
)
SELECT
    COUNT(*) AS total_return_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_disposition_outcome_flag) AS null_disposition_outcome_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_disposition_outcome <> cleaned_disposition_outcome
    ) AS rows_changed_by_cleaning
FROM disposition_outcome_validation;

-- Verified: 77,716 return staging rows.
-- All 77,716 disposition_outcome values change under
-- LOWER(TRIM(disposition_outcome)).
-- 0 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- All observed changes are due to the chosen lowercase clean format;
-- no surrounding-whitespace formatting issues were detected.

-- Part 2. Compare raw and cleaned distinct values
WITH disposition_outcome_validation AS (
    SELECT
        disposition_outcome AS original_disposition_outcome,
        LOWER(TRIM(disposition_outcome)) AS cleaned_disposition_outcome
    FROM staging.returns
)
SELECT
    COUNT(DISTINCT original_disposition_outcome) AS raw_distinct_disposition_outcome_count,
    COUNT(DISTINCT cleaned_disposition_outcome) AS cleaned_distinct_disposition_outcome_count
FROM disposition_outcome_validation;

-- Verified: 10 raw distinct disposition_outcome values remain
-- 10 distinct cleaned values.
-- Formatting standardization does not collapse any distinct categories.
-- The observed Task 16 change is case standardization only.

-- Part 3. Identify cleaned values with multiple raw representations
WITH disposition_outcome_validation AS (
    SELECT
        disposition_outcome AS original_disposition_outcome,
        LOWER(TRIM(disposition_outcome)) AS cleaned_disposition_outcome
    FROM staging.returns
)
SELECT
    cleaned_disposition_outcome,
    COUNT(DISTINCT original_disposition_outcome) AS raw_variant_count
FROM disposition_outcome_validation
GROUP BY cleaned_disposition_outcome
HAVING COUNT(DISTINCT original_disposition_outcome) > 1
ORDER BY cleaned_disposition_outcome;

-- Verified: no cleaned disposition_outcome value has multiple
-- raw formatting representations.
-- Each of the 10 cleaned values corresponds to exactly 1 raw value.

-- Part 4. Inspect original values and their staging-row frequencies
WITH disposition_outcome_validation AS (
    SELECT
        disposition_outcome AS original_disposition_outcome,
        LOWER(TRIM(disposition_outcome)) AS cleaned_disposition_outcome
    FROM staging.returns
)
SELECT
    cleaned_disposition_outcome,
    original_disposition_outcome,
    COUNT(*) AS return_count
FROM disposition_outcome_validation
GROUP BY cleaned_disposition_outcome, original_disposition_outcome
ORDER BY cleaned_disposition_outcome, original_disposition_outcome;

-- Verified: all 10 disposition_outcome categories have a single
-- raw representation and require case standardization only.
-- All category frequencies reconcile to 77,716 return staging rows.
-- 0 whitespace variants were observed, matching the Part 1
-- rows_requiring_trim control total of 0.
-- Five current values and five corresponding legacy: values remain
-- separate cleaned categories; semantic mapping is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH disposition_outcome_validation AS (
    SELECT
        return_id,
        disposition_outcome AS original_disposition_outcome,
        LOWER(TRIM(disposition_outcome)) AS cleaned_disposition_outcome
    FROM staging.returns
)
SELECT
    return_id,
    original_disposition_outcome,
    cleaned_disposition_outcome
FROM disposition_outcome_validation
WHERE original_disposition_outcome <> cleaned_disposition_outcome
ORDER BY return_id;

-- Verified representative examples:
-- 'Restocked' -> 'restocked'
-- 'Written Off' -> 'written off'
-- 'Supplier Return' -> 'supplier return'
-- 'Discounted Resale' -> 'discounted resale'
-- 'legacy:Discounted Resale' -> 'legacy:discounted resale'
-- Changes are case-only and preserve disposition-outcome meaning.
-- legacy: values remain separate; no semantic mapping is performed
-- in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(disposition_outcome)).

-- ============================================================
-- inventory_activity: activity_type
-- Business rule:
-- Remove leading/trailing whitespace and standardize populated
-- activity_type values to lowercase while preserving the
-- underlying business meaning.
--
-- Approved transformation: LOWER(TRIM(activity_type))
-- Grain: one row = one inventory activity event staging record
-- Note:
-- Known legacy labels are standardized for whitespace/case only.
-- Preserve the legacy: prefix. Semantic merging belongs to Task 17.
-- ============================================================

-- Part 1. Summary validation
WITH activity_type_validation AS (
    SELECT
        inventory_activity_id,
        activity_type AS original_activity_type,
        LOWER(TRIM(activity_type)) AS cleaned_activity_type,
        CASE WHEN activity_type <> TRIM(activity_type) THEN 1 ELSE 0 END
            AS needs_trim_flag,
        CASE WHEN activity_type <> LOWER(activity_type) THEN 1 ELSE 0 END
            AS needs_lowercase_flag,
        CASE WHEN activity_type IS NULL THEN 1 ELSE 0 END
            AS null_activity_type_flag,
        CASE
            WHEN activity_type IS NOT NULL AND TRIM(activity_type) = '' THEN 1
            ELSE 0
        END AS blank_after_trim_flag
    FROM staging.inventory_activity
)
SELECT
    COUNT(*) AS total_inventory_activity_rows,
    SUM(needs_trim_flag) AS rows_requiring_trim,
    SUM(needs_lowercase_flag) AS rows_requiring_lowercase,
    SUM(null_activity_type_flag) AS null_activity_type_count,
    SUM(blank_after_trim_flag) AS blank_after_trim_count,
    COUNT(*) FILTER (
        WHERE original_activity_type <> cleaned_activity_type
    ) AS rows_changed_by_cleaning
FROM activity_type_validation;

-- Verified: 1,241,264 inventory activity staging rows.
-- All 1,241,264 activity_type values change under
-- LOWER(TRIM(activity_type)).
-- 23,599 rows require TRIM. 0 NULL and 0 blank-after-TRIM values.
-- Lowercase changes reflect the chosen clean format; 23,599 rows have
-- confirmed surrounding-whitespace formatting issues.

-- Part 2. Compare raw and cleaned distinct values
WITH activity_type_validation AS (
    SELECT
        activity_type AS original_activity_type,
        LOWER(TRIM(activity_type)) AS cleaned_activity_type
    FROM staging.inventory_activity
)
SELECT
    COUNT(DISTINCT original_activity_type) AS raw_distinct_activity_type_count,
    COUNT(DISTINCT cleaned_activity_type) AS cleaned_distinct_activity_type_count
FROM activity_type_validation;

-- Verified: 21 raw distinct activity_type values become 14 cleaned values.
-- Formatting standardization collapses 7 extra raw text representations.

-- Part 3. Identify cleaned values with multiple raw representations
WITH activity_type_validation AS (
    SELECT
        activity_type AS original_activity_type,
        LOWER(TRIM(activity_type)) AS cleaned_activity_type
    FROM staging.inventory_activity
)
SELECT
    cleaned_activity_type,
    COUNT(DISTINCT original_activity_type) AS raw_variant_count
FROM activity_type_validation
GROUP BY cleaned_activity_type
HAVING COUNT(DISTINCT original_activity_type) > 1
ORDER BY cleaned_activity_type;

-- Verified: cycle count adjustment, damage write-off, return restock,
-- sale fulfillment, supplier receipt, transfer in, and transfer out
-- each have exactly 2 raw formatting representations.
-- These 7 duplicate representations fully explain the reduction
-- from 21 raw distinct values to 14 cleaned values.

-- Part 4. Inspect original values and their staging-row frequencies
WITH activity_type_validation AS (
    SELECT
        activity_type AS original_activity_type,
        LOWER(TRIM(activity_type)) AS cleaned_activity_type
    FROM staging.inventory_activity
)
SELECT
    cleaned_activity_type,
    original_activity_type,
    COUNT(*) AS inventory_activity_event_count
FROM activity_type_validation
GROUP BY cleaned_activity_type, original_activity_type
ORDER BY cleaned_activity_type, original_activity_type;

-- Verified whitespace variants:
-- CYCLE COUNT ADJUSTMENT = 40
-- DAMAGE WRITE-OFF = 52
-- RETURN RESTOCK = 855
-- SALE FULFILLMENT = 16,237
-- SUPPLIER RECEIPT = 4,332
-- TRANSFER IN = 1,054
-- TRANSFER OUT = 1,029
-- 40 + 52 + 855 + 16,237 + 4,332 + 1,054 + 1,029
-- = 23,599 rows requiring TRIM, exactly matching the Part 1 control total.
-- All 21 raw-variant frequencies reconcile to
-- 1,241,264 inventory activity staging rows.
-- Seven legacy: activity_type values remain separate cleaned categories;
-- semantic mapping is deferred to Task 17.

-- Part 5. Final cleaning candidates
WITH activity_type_validation AS (
    SELECT
        inventory_activity_id,
        activity_type AS original_activity_type,
        LOWER(TRIM(activity_type)) AS cleaned_activity_type
    FROM staging.inventory_activity
)
SELECT
    inventory_activity_id,
    original_activity_type,
    cleaned_activity_type
FROM activity_type_validation
WHERE original_activity_type <> cleaned_activity_type
ORDER BY inventory_activity_id;

-- Verified representative example:
-- 'Sale Fulfillment' -> 'sale fulfillment'
-- Full-population validation confirmed whitespace variants across all
-- 7 current activity types and preserved all 7 legacy: activity types.
-- Changes are formatting-only and preserve activity-type meaning.
-- No semantic mapping is performed in Task 16.
-- Final Task 16 candidate: LOWER(TRIM(activity_type)).