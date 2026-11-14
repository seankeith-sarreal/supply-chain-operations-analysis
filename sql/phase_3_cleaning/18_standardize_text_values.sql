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