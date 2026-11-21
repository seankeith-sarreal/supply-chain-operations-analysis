-- ============================================================
-- Phase 3 - Task 16: Standardize Text Values
-- ============================================================
-- Goal:
-- Standardize applicable text fields without changing
-- business meaning.
--
-- Current column:
-- staging.customers.customer_state
-- ============================================================


-- ------------------------------------------------------------
-- 1. BUSINESS RULE
-- ------------------------------------------------------------
-- Remove leading and trailing spaces from customer_state values
-- while preserving the existing two-letter state abbreviation.


-- ------------------------------------------------------------
-- 2. IDENTIFY ROWS REQUIRING WHITESPACE CLEANING
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS rows_requiring_trim
FROM staging.customers
WHERE customer_state <> TRIM(customer_state);

-- Verified result: 2,049 rows


-- ------------------------------------------------------------
-- 3. CHECK FOR CAPITALIZATION ISSUES
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS capitalization_issue_count
FROM staging.customers
WHERE customer_state <> UPPER(customer_state);

-- Verified result: 0 rows
-- Decision: UPPER() is not required for the current data.


-- ------------------------------------------------------------
-- 4. VALIDATE EXPECTED STATE-CODE LENGTH
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS invalid_length_count
FROM staging.customers
WHERE LENGTH(TRIM(customer_state)) <> 2;

-- Verified result: 0 rows


-- ------------------------------------------------------------
-- 5. REVIEW DISTINCT CLEANED STATE VALUES
-- ------------------------------------------------------------
SELECT DISTINCT
    TRIM(customer_state) AS cleaned_customer_state
FROM staging.customers
ORDER BY cleaned_customer_state;

-- Review identified 'ZZ' as an invalid state code.
-- 'ZZ' is not corrected during Task 16 because its intended
-- replacement cannot be determined from text formatting alone.


-- ------------------------------------------------------------
-- 6. INVESTIGATE INVALID 'ZZ' STATE VALUE
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS zz_state_count
FROM staging.customers
WHERE TRIM(customer_state) = 'ZZ';

-- Verified result: 402 rows


-- Check whether ZZ records are missing usable ZIP-code evidence.
SELECT
    COUNT(*) AS zz_missing_zip_count
FROM staging.customers
WHERE TRIM(customer_state) = 'ZZ'
    AND (
        customer_zip_code IS NULL
        OR TRIM(customer_zip_code) = ''
    );

-- Verified result: 0 rows
-- All 402 ZZ records contain a populated customer_zip_code.
-- Do not infer or replace their states during Task 16.


-- ------------------------------------------------------------
-- 7. CONTROL-TOTAL VALIDATION
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_customer_rows
FROM staging.customers;

-- Verified result: 200,800 rows


SELECT
    COUNT(*) AS null_state_count
FROM staging.customers
WHERE customer_state IS NULL;

-- Verified result: 0 rows


-- Reconciliation:
-- 2,049 rows require TRIM().
-- 198,751 rows remain unchanged.
-- 2,049 + 198,751 = 200,800 total customer rows.
-- The cleaning rule preserves the customer-row grain.


-- ------------------------------------------------------------
-- 8. FINAL CLEANING CANDIDATE
-- ------------------------------------------------------------
SELECT
    customer_id,
    customer_state AS original_customer_state,
    TRIM(customer_state) AS cleaned_customer_state
FROM staging.customers
WHERE customer_state <> TRIM(customer_state);

-- Final customer_state decision:
-- Apply TRIM() to remove surrounding whitespace.
--
-- Verified findings:
-- Total customer rows: 200,800
-- Rows requiring TRIM(): 2,049
-- Rows unchanged: 198,751
-- NULL customer_state values: 0
-- Capitalization issues: 0
-- Invalid state code 'ZZ': 402 rows
--
-- Limitation:
-- Do not correct 'ZZ' during Task 16.
-- It requires separate categorical/geographic investigation.

-- ============================================================
-- customer_city
-- ============================================================

-- ------------------------------------------------------------
-- 1. BUSINESS RULE
-- ------------------------------------------------------------
-- Remove leading and trailing whitespace from customer_city
-- and standardize all non-NULL city values to lowercase while
-- preserving the underlying city name.


-- ------------------------------------------------------------
-- 2. INSPECT REPRESENTATIVE CHANGES
-- ------------------------------------------------------------
SELECT
    customer_id,
    customer_city AS original_customer_city,
    LOWER(TRIM(customer_city)) AS cleaned_customer_city
FROM staging.customers
WHERE customer_city <> LOWER(TRIM(customer_city))
LIMIT 20;


-- ------------------------------------------------------------
-- 3. QUANTIFY ROWS AFFECTED BY STANDARDIZATION
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS rows_to_standardize
FROM staging.customers
WHERE customer_city <> LOWER(TRIM(customer_city));

-- Verified result: 199,541 customer rows


-- ------------------------------------------------------------
-- 4. ISOLATE WHITESPACE AND CAPITALIZATION EFFECTS
-- ------------------------------------------------------------

-- Rows containing leading/trailing whitespace.
SELECT
    COUNT(*) AS whitespace_row_count
FROM staging.customers
WHERE customer_city <> TRIM(customer_city);

-- Verified result: 1,944 customer rows


-- Rows whose capitalization changes under the lowercase standard.
SELECT
    COUNT(*) AS capitalization_change_count
FROM staging.customers
WHERE customer_city <> LOWER(customer_city);

-- Verified result: 199,541 customer rows


-- Rows affected by both whitespace and capitalization.
SELECT
    COUNT(*) AS whitespace_and_case_count
FROM staging.customers
WHERE customer_city <> TRIM(customer_city)
    AND TRIM(customer_city) <> LOWER(TRIM(customer_city));

-- Verified result: 1,944 customer rows
-- All whitespace-affected rows also require lowercase standardization.


-- ------------------------------------------------------------
-- 5. VALIDATE DISTINCT WHITESPACE-AFFECTED VALUES
-- ------------------------------------------------------------
SELECT
    COUNT(DISTINCT customer_city) AS distinct_whitespace_city_count
FROM staging.customers
WHERE customer_city <> TRIM(customer_city);

-- Verified result: 1,239 distinct raw city values


-- ------------------------------------------------------------
-- 6. VALIDATE NULL AND BLANK VALUES
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS null_city_count
FROM staging.customers
WHERE customer_city IS NULL;

-- Verified result: 1,259 rows
-- Decision: Defer NULL handling to Task 20.


SELECT
    COUNT(*) AS blank_city_count
FROM staging.customers
WHERE customer_city IS NOT NULL
    AND TRIM(customer_city) = '';

-- Verified result: 0 rows


-- ------------------------------------------------------------
-- 7. COMPARE RAW VS. CLEANED DISTINCT CITY VALUES
-- ------------------------------------------------------------

SELECT
    COUNT(DISTINCT customer_city) AS raw_distinct_city_count
FROM staging.customers
WHERE customer_city IS NOT NULL;

-- Verified result: 15,489 distinct raw city values


SELECT
    COUNT(DISTINCT LOWER(TRIM(customer_city)))
        AS cleaned_distinct_city_count
FROM staging.customers
WHERE customer_city IS NOT NULL;

-- Verified result: 14,274 distinct cleaned city values


-- Reconciliation:
-- 15,489 raw distinct city values
-- - 14,274 cleaned distinct city values
-- = 1,215 raw text variants collapsed during standardization.


-- ------------------------------------------------------------
-- 8. VALIDATE MULTIPLE RAW VARIANTS
-- ------------------------------------------------------------
SELECT
    LOWER(TRIM(customer_city)) AS normalized_customer_city,
    COUNT(DISTINCT customer_city) AS raw_distinct_city_count
FROM staging.customers
WHERE customer_city IS NOT NULL
GROUP BY LOWER(TRIM(customer_city))
HAVING COUNT(DISTINCT customer_city) > 1
ORDER BY raw_distinct_city_count DESC, normalized_customer_city
LIMIT 20;

-- Verified result:
-- 1,215 normalized city values have multiple raw text variants.
-- Maximum observed raw variants per normalized city: 2.


-- Representative example.
SELECT DISTINCT
    customer_city AS raw_customer_city,
    LOWER(TRIM(customer_city)) AS normalized_customer_city
FROM staging.customers
WHERE LOWER(TRIM(customer_city)) = 'aberdeen';

-- Verified example:
-- " ABERDEEN " -> "aberdeen"
-- "Aberdeen"    -> "aberdeen"


-- ------------------------------------------------------------
-- 9. CONTROL-TOTAL RECONCILIATION
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_customer_rows
FROM staging.customers;

-- Verified result: 200,800 rows

-- Reconciliation:
-- 199,541 non-NULL customer_city rows standardized
-- + 1,259 NULL customer_city rows
-- = 200,800 total customer rows
--
-- All customer rows are accounted for.
-- NULL values are preserved for Task 20.


-- ------------------------------------------------------------
-- 10. FINAL CLEANING CANDIDATE
-- ------------------------------------------------------------
SELECT
    customer_id,
    customer_city AS original_customer_city,
    LOWER(TRIM(customer_city)) AS cleaned_customer_city
FROM staging.customers
WHERE customer_city <> LOWER(TRIM(customer_city));


-- ------------------------------------------------------------
-- FINAL DECISION / VERIFIED RESULTS
-- ------------------------------------------------------------
-- Decision:
-- Apply LOWER(TRIM(customer_city)) to populated customer_city
-- values in the clean layer.
--
-- Verified results:
-- Total customer rows: 200,800
-- Rows standardized: 199,541
-- Rows containing leading/trailing whitespace: 1,944
-- Distinct raw city values containing whitespace: 1,239
-- Raw distinct city values: 15,489
-- Cleaned distinct city values: 14,274
-- Normalized cities with multiple raw variants: 1,215
-- NULL customer_city values: 1,259
-- Blank-after-TRIM values: 0
--
-- Limitation:
-- NULL customer_city values are not replaced during Task 16.
-- Missing-value handling is deferred to Task 20.


-- ============================================================
-- products.material
-- ============================================================

-- ------------------------------------------------------------
-- 1. BUSINESS RULE
-- ------------------------------------------------------------
-- Remove leading and trailing whitespace from material values
-- and standardize all non-NULL material values to lowercase,
-- changing only formatting and preserving the underlying
-- material category.


-- ------------------------------------------------------------
-- 2. INSPECT REPRESENTATIVE CHANGES
-- ------------------------------------------------------------
SELECT
    product_id,
    material AS original_material,
    LOWER(TRIM(material)) AS cleaned_material
FROM staging.products
WHERE material <> LOWER(TRIM(material))
LIMIT 20;


-- ------------------------------------------------------------
-- 3. QUANTIFY ROWS AFFECTED BY STANDARDIZATION
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS rows_to_standardize
FROM staging.products
WHERE material <> LOWER(TRIM(material));

-- Verified result: 1,987 product rows


-- ------------------------------------------------------------
-- 4. ISOLATE WHITESPACE AND CAPITALIZATION EFFECTS
-- ------------------------------------------------------------

-- Rows containing leading/trailing whitespace.
SELECT
    COUNT(*) AS rows_to_trim
FROM staging.products
WHERE material <> TRIM(material);

-- Verified result: 23 product rows


-- Rows whose capitalization changes under the lowercase standard.
SELECT
    COUNT(*) AS rows_to_lower
FROM staging.products
WHERE material <> LOWER(material);

-- Verified result: 1,987 product rows


-- Rows affected by both whitespace and capitalization.
SELECT
    COUNT(*) AS rows_to_lower_and_trim
FROM staging.products
WHERE material <> TRIM(material)
    AND TRIM(material) <> LOWER(TRIM(material));

-- Verified result: 23 product rows
-- All whitespace-affected material rows also require
-- lowercase standardization.


-- ------------------------------------------------------------
-- 5. VALIDATE NULL AND BLANK VALUES
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS null_material_count
FROM staging.products
WHERE material IS NULL;

-- Verified result: 13 rows
-- Decision: Defer NULL handling to Task 20.


SELECT
    COUNT(*) AS blank_material_count
FROM staging.products
WHERE material IS NOT NULL
    AND TRIM(material) = '';

-- Verified result: 0 rows


-- ------------------------------------------------------------
-- 6. COMPARE RAW VS. CLEANED DISTINCT MATERIAL VALUES
-- ------------------------------------------------------------
SELECT
    COUNT(DISTINCT material) AS raw_distinct_material_count
FROM staging.products
WHERE material IS NOT NULL;

-- Verified result: 10 distinct raw material values


SELECT
    COUNT(DISTINCT LOWER(TRIM(material)))
        AS cleaned_distinct_material_count
FROM staging.products
WHERE material IS NOT NULL;

-- Verified result: 5 distinct cleaned material values


-- Reconciliation:
-- 10 raw distinct material values
-- - 5 cleaned distinct material values
-- = 5 redundant raw text representations removed
--   during standardization.


-- ------------------------------------------------------------
-- 7. VALIDATE MULTIPLE RAW VARIANTS
-- ------------------------------------------------------------
SELECT
    LOWER(TRIM(material)) AS normalized_material,
    COUNT(DISTINCT material) AS raw_distinct_material_count
FROM staging.products
WHERE material IS NOT NULL
GROUP BY LOWER(TRIM(material))
HAVING COUNT(DISTINCT material) > 1
ORDER BY normalized_material;

-- Verified result:
-- 5 normalized material categories have multiple raw variants.
-- Each normalized category has exactly 2 distinct raw variants.


-- ------------------------------------------------------------
-- 8. INSPECT REPRESENTATIVE RAW VARIANTS
-- ------------------------------------------------------------
SELECT DISTINCT
    material AS raw_material,
    LOWER(TRIM(material)) AS normalized_material
FROM staging.products
WHERE LOWER(TRIM(material)) = 'metal';

-- Verified example:
-- " METAL " -> "metal"
-- "Metal"    -> "metal"


-- ------------------------------------------------------------
-- 9. CONTROL-TOTAL RECONCILIATION
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_product_rows
FROM staging.products;

-- Verified result: 2,000 rows

-- Reconciliation:
-- 1,987 non-NULL material rows standardized
-- + 13 NULL material rows
-- = 2,000 total product rows
--
-- All product rows are accounted for.
-- NULL material values are preserved for Task 20.


-- ------------------------------------------------------------
-- 10. FINAL CLEANING CANDIDATE
-- ------------------------------------------------------------
SELECT
    product_id,
    material AS original_material,
    LOWER(TRIM(material)) AS cleaned_material
FROM staging.products
WHERE material <> LOWER(TRIM(material));


-- ------------------------------------------------------------
-- FINAL DECISION / VERIFIED RESULTS
-- ------------------------------------------------------------
-- Decision:
-- Apply LOWER(TRIM(material)) to populated material values
-- in the clean layer.
--
-- Verified results:
-- Total product rows: 2,000
-- Rows standardized: 1,987
-- Rows containing leading/trailing whitespace: 23
-- NULL material values: 13
-- Blank-after-TRIM values: 0
-- Raw distinct material values: 10
-- Cleaned distinct material values: 5
-- Normalized material categories with multiple raw variants: 5
-- Raw variants per normalized material category: 2
--
-- Limitation:
-- NULL material values are not replaced during Task 16.
-- Missing-value handling is deferred to Task 20.

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