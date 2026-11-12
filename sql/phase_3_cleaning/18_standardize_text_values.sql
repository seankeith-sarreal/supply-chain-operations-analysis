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