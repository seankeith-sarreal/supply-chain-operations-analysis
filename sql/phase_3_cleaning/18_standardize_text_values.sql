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