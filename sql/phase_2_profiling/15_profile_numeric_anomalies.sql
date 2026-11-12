-- Task 14 | Numeric profiling | Read-only PostgreSQL queries
-- Select one table region or one complete query to run.
-- Region folding depends on the SQL editor and extension.
-- Existing business-rule checks retained; reported counts must be rerun.

-- #region TASK 14 | SUPPLIERS | Numeric anomalies
-- Suggested file: 15_profile_numeric_anomalies.sql
-- Table: staging.suppliers | Grain: one row per supplier company
-- Read-only. Run Steps 1-3 together, then Step 4 for review evidence.
-- Each executable step is self-contained; no earlier CTE is required.

-- #region STEP 1 | Summarize numeric measures
-- Supplier summary statistics | MIN, MAX, AVG, sample standard deviation.
-- Aggregates exclude NULLs; Step 2 reports missing values separately.
WITH supplier_stats AS (
    SELECT
        MIN(standard_lead_time_days) AS min_lead_time,
        MAX(standard_lead_time_days) AS max_lead_time,
        AVG(standard_lead_time_days) AS avg_lead_time,
        STDDEV(standard_lead_time_days) AS stddev_lead_time,

        MIN(on_time_delivery_rate) AS min_on_time_delivery_rate,
        MAX(on_time_delivery_rate) AS max_on_time_delivery_rate,
        AVG(on_time_delivery_rate) AS avg_on_time_delivery_rate,
        STDDEV(on_time_delivery_rate) AS stddev_on_time_delivery_rate,

        MIN(supplier_defect_rate) AS min_defect_rate,
        MAX(supplier_defect_rate) AS max_defect_rate,
        AVG(supplier_defect_rate) AS avg_defect_rate,
        STDDEV(supplier_defect_rate) AS stddev_defect_rate
    FROM staging.suppliers
)

SELECT
    'Minimum' AS statistic,
    min_lead_time AS standard_lead_time_days,
    min_on_time_delivery_rate AS on_time_delivery_rate,
    min_defect_rate AS supplier_defect_rate
FROM supplier_stats

UNION ALL

SELECT
    'Maximum',
    max_lead_time,
    max_on_time_delivery_rate,
    max_defect_rate
FROM supplier_stats

UNION ALL

SELECT
    'Average',
    avg_lead_time,
    avg_on_time_delivery_rate,
    avg_defect_rate
FROM supplier_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_lead_time,
    stddev_on_time_delivery_rate,
    stddev_defect_rate
FROM supplier_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
-- Supplier numeric boundary checks | One output row per measure; counts are staging rows.
-- Lead time: positive whole number. Rates: 0 through 100 inclusive.
-- NULLs violate required-field rules and are counted separately.
WITH measures AS (
    SELECT measure_values.measure, measure_values.value, measure_values.invalid_value
    FROM staging.suppliers AS supplier
    CROSS JOIN LATERAL (
        VALUES
            ('standard_lead_time_days', supplier.standard_lead_time_days::numeric,
                supplier.standard_lead_time_days <= 0
                OR supplier.standard_lead_time_days::numeric <> TRUNC(supplier.standard_lead_time_days::numeric)),
            ('on_time_delivery_rate', supplier.on_time_delivery_rate::numeric,
                supplier.on_time_delivery_rate < 0 OR supplier.on_time_delivery_rate > 100),
            ('supplier_defect_rate', supplier.supplier_defect_rate::numeric,
                supplier.supplier_defect_rate < 0 OR supplier.supplier_defect_rate > 100)
    ) AS measure_values(measure, value, invalid_value)
),
measure_names (measure) AS (
    VALUES ('standard_lead_time_days'), ('on_time_delivery_rate'), ('supplier_defect_rate')
)
SELECT
    'Supplier numeric boundary checks' AS check_name,
    measure_name.measure,
    COUNT(measure_result.measure) AS total_rows,
    COUNT(*) FILTER (WHERE measure_result.measure IS NOT NULL AND measure_result.value IS NULL) AS null_rows,
    COUNT(*) FILTER (WHERE measure_result.invalid_value) AS invalid_non_null_rows,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE measure_result.invalid_value)
        / NULLIF(COUNT(measure_result.measure), 0), 2
    ) AS invalid_pct_of_all_rows
FROM measure_names AS measure_name
LEFT JOIN measures AS measure_result ON measure_result.measure = measure_name.measure
GROUP BY measure_name.measure
ORDER BY measure_name.measure;
-- #endregion

-- #region STEP 3 | Test cross-column rules
-- Supplier cross-column rules | NOT APPLICABLE under the locked Suppliers design.
-- No approved numeric rule compares these supplier measures.
-- Delivery rate and defect rate measure different outcomes;
-- they do not need to sum to 100 or be ordered relative to each other.
-- Products -> Suppliers foreign-key checks belong to Task 15.
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Supplier extreme value review | Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded from ranking; see Step 2 for NULL counts.
-- An extreme value is a review candidate, not automatically an error.
WITH supplier_measures AS (
    SELECT
        supplier.supplier_id,
        supplier.supplier_name,
        measure_values.measure,
        measure_values.value
    FROM staging.suppliers AS supplier
    CROSS JOIN LATERAL (
        VALUES
            ('standard_lead_time_days', supplier.standard_lead_time_days::numeric),
            ('on_time_delivery_rate', supplier.on_time_delivery_rate::numeric),
            ('supplier_defect_rate', supplier.supplier_defect_rate::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM supplier_measures
)
SELECT
    'Supplier extreme value review' AS check_name,
    measure,
    supplier_id,
    supplier_name,
    value,
    lowest_rank,
    highest_rank,
    CASE
        WHEN measure = 'standard_lead_time_days'
             AND (value <= 0 OR value <> TRUNC(value))
            THEN 'Violates approved boundary'
        WHEN measure IN ('on_time_delivery_rate', 'supplier_defect_rate')
             AND (value < 0 OR value > 100)
            THEN 'Violates approved boundary'
        ELSE 'Within boundary; review business plausibility'
    END AS review_note
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, supplier_id;

-- Findings worksheet: complete after executing the queries.
-- Check ID:
-- Column(s) / rule:
-- Observed range / average / standard deviation:
-- Affected rows / affected % (specify denominator):
-- Example supplier_id and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / rationale:
-- Proposed Phase 3 action:
-- Step 3: N/A - no approved numeric cross-column rule.
--
-- Previous inline notes retained for reference only; not rerun/verified:
-- Lead time: min 6; max 50; avg 19.15; stddev 12.6743100.
-- On-time delivery: min 75.86; max 97.90; avg 89.99667; stddev 5.2601.
-- Defect rate: min 0.32; max 5.26; avg 1.5635; stddev 1.2325.
-- #endregion

-- #endregion

-- #region TASK 14 | PRODUCTS | Numeric anomalies
-- Table: staging.products
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.

-- #region STEP 1 | Summarize numeric measures
WITH product_stats AS (
    SELECT
        MIN(base_unit_price) AS min_base_price, 
        MAX(base_unit_price) AS max_base_price, 
        AVG(base_unit_price) AS avg_base_price, 
        STDDEV(base_unit_price) AS stddev_base_price,

        MIN(standard_unit_cost) AS min_unit_cost,
        MAX(standard_unit_cost) AS max_unit_cost,
        AVG(standard_unit_cost) AS avg_unit_cost,
        STDDEV(standard_unit_cost) AS stddev_unit_cost,

        MIN(unit_weight_lbs) AS min_unit_weight,
        MAX(unit_weight_lbs) AS max_unit_weight,
        AVG(unit_weight_lbs) AS avg_unit_weight,
        STDDEV(unit_weight_lbs) AS stddev_unit_weight,

        MIN(product_length_in) AS min_product_length,
        MAX(product_length_in) AS max_product_length,
        AVG(product_length_in) AS avg_product_length,
        STDDEV(product_length_in) AS stddev_product_length,

        MIN(product_width_in) AS min_product_width,
        MAX(product_width_in) AS max_product_width,
        AVG(product_width_in) AS avg_product_width,
        STDDEV(product_width_in) AS stddev_product_width,

        MIN(product_height_in) AS min_product_height,
        MAX(product_height_in) AS max_product_height,
        AVG(product_height_in) AS avg_product_height,
        STDDEV(product_height_in) AS stddev_product_height,

        MIN(package_count) AS min_package_count,
        MAX(package_count) AS max_package_count,
        AVG(package_count) AS avg_package_count,
        STDDEV(package_count) AS stddev_package_count
    FROM staging.products
)

SELECT
    'Minimum' AS statistic,
    min_base_price AS base_unit_price,
    min_unit_cost AS standard_unit_cost,
    min_unit_weight AS unit_weight_lbs,
    min_product_length AS product_length_in,
    min_product_width AS product_width_in,
    min_product_height AS product_height_in,
    min_package_count AS package_count
FROM product_stats

UNION ALL

SELECT
    'Maximum',
    max_base_price,
    max_unit_cost,
    max_unit_weight,
    max_product_length,
    max_product_width,
    max_product_height,
    max_package_count
FROM product_stats

UNION ALL

SELECT
    'Average',
    avg_base_price,
    avg_unit_cost,
    avg_unit_weight,
    avg_product_length,
    avg_product_width,
    avg_product_height,
    avg_package_count
FROM product_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_base_price,
    stddev_unit_cost,
    stddev_unit_weight,
    stddev_product_length,
    stddev_product_width,
    stddev_product_height,
    stddev_package_count
FROM product_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE base_unit_price <= 0
    ) AS invalid_base_unit_price,

    COUNT(*) FILTER (
        WHERE standard_unit_cost <= 0
    ) AS invalid_standard_unit_cost,

    COUNT(*) FILTER (
        WHERE unit_weight_lbs <= 0
    ) AS invalid_unit_weight,

    COUNT(*) FILTER (
        WHERE product_length_in <= 0
    ) AS invalid_product_length,

    COUNT(*) FILTER (
        WHERE product_width_in <= 0
    ) AS invalid_product_width,

    COUNT(*) FILTER (
        WHERE product_height_in <= 0
    ) AS invalid_product_height,

    COUNT(*) FILTER (
        WHERE package_count < 1
    ) AS invalid_package_count
FROM staging.products;
-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
--Identify products with cost above selling price
SELECT
    COUNT(*) AS products_with_cost_above_price
FROM staging.products
WHERE standard_unit_cost > base_unit_price;

SELECT
    product_id,
    sku,
    product_name,
    base_unit_price,
    standard_unit_cost,
    standard_unit_cost - base_unit_price AS loss_per_unit_before_other_costs
FROM staging.products
WHERE standard_unit_cost > base_unit_price
ORDER BY loss_per_unit_before_other_costs DESC;
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.product_id,
        measure_values.measure,
        measure_values.value
    FROM staging.products AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('base_unit_price', source_row.base_unit_price::numeric),
            ('standard_unit_cost', source_row.standard_unit_cost::numeric),
            ('unit_weight_lbs', source_row.unit_weight_lbs::numeric),
            ('product_length_in', source_row.product_length_in::numeric),
            ('product_width_in', source_row.product_width_in::numeric),
            ('product_height_in', source_row.product_height_in::numeric),
            ('package_count', source_row.package_count::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Products extreme value review' AS check_name,
    product_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, product_id;

----------------------------------------------------------------------

--Simplify by showing the five lowest and five highest distinct values for each numeric measure, and how many products have each

WITH numeric_values AS (
    SELECT
        source_row.product_id,
        measure_values.measure,
        measure_values.value
    FROM staging.products AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('base_unit_price', source_row.base_unit_price::numeric),
            ('standard_unit_cost', source_row.standard_unit_cost::numeric),
            ('unit_weight_lbs', source_row.unit_weight_lbs::numeric),
            ('product_length_in', source_row.product_length_in::numeric),
            ('product_width_in', source_row.product_width_in::numeric),
            ('product_height_in', source_row.product_height_in::numeric),
            ('package_count', source_row.package_count::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
value_counts AS (
    SELECT
        measure,
        value,
        COUNT(*) AS products_at_value
    FROM numeric_values
    GROUP BY measure, value
),
ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value
        ) AS lowest_rank,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value DESC
        ) AS highest_rank
    FROM value_counts
)
SELECT
    measure,
    value,
    products_at_value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY measure, value;

-----------------------------------------------------------------------------

--run a targeted detail query only for that value to see the actual product

SELECT
    product_id,
    sku,
    product_name,
    product_category,
    product_subcategory,
    shipping_class,
    base_unit_price,
    standard_unit_cost,
    unit_weight_lbs,
    product_length_in,
    product_width_in,
    product_height_in,
    package_count
FROM staging.products
WHERE standard_unit_cost >= 1776.95
   OR unit_weight_lbs >= 276.82
   OR base_unit_price >= 3601.07
ORDER BY
    unit_weight_lbs DESC,
    standard_unit_cost DESC,
    base_unit_price DESC;

----------------------------------------------------------

--Run one targeted detail query for the most informative extremes

SELECT
    REGEXP_REPLACE(product_name, '\s+\d+$', '') AS product_family,
    product_category,
    product_subcategory,
    shipping_class,
    COUNT(*) AS product_count,

    MIN(base_unit_price) AS min_price,
    MAX(base_unit_price) AS max_price,

    MIN(standard_unit_cost) AS min_cost,
    MAX(standard_unit_cost) AS max_cost,

    MIN(unit_weight_lbs) AS min_weight,
    MAX(unit_weight_lbs) AS max_weight,

    MIN(product_length_in) AS min_length,
    MAX(product_length_in) AS max_length,

    MIN(product_width_in) AS min_width,
    MAX(product_width_in) AS max_width,

    MIN(product_height_in) AS min_height,
    MAX(product_height_in) AS max_height,

    MIN(package_count) AS min_package_count,
    MAX(package_count) AS max_package_count

FROM staging.products
WHERE standard_unit_cost >= 1776.95
   OR unit_weight_lbs >= 276.82
   OR base_unit_price >= 3601.07
GROUP BY
    REGEXP_REPLACE(product_name, '\s+\d+$', ''),
    product_category,
    product_subcategory,
    shipping_class
ORDER BY
    max_weight DESC,
    max_cost DESC,
    max_price DESC;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- No prior result counts were recorded in this source section.
-- #endregion
-- #endregion

-- #region TASK 14 | FULFILLMENT CENTERS | Numeric anomalies
-- Table: staging.fulfillment_centers
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.

-- #region STEP 1 | Summarize numeric measures
WITH fulfillment_center_stats AS (
    SELECT
        MIN(daily_order_capacity) AS min_daily_capacity,
        MAX(daily_order_capacity) AS max_daily_capacity,
        AVG(daily_order_capacity) AS avg_daily_capacity,
        STDDEV(daily_order_capacity) AS stddev_daily_capacity,

        MIN(standard_handling_cost_per_item) AS min_handling_cost,
        MAX(standard_handling_cost_per_item) AS max_handling_cost,
        AVG(standard_handling_cost_per_item) AS avg_handling_cost,
        STDDEV(standard_handling_cost_per_item) AS stddev_handling_cost,

        MIN(labor_cost_index) AS min_labor_cost_index,
        MAX(labor_cost_index) AS max_labor_cost_index,
        AVG(labor_cost_index) AS avg_labor_cost_index,
        STDDEV(labor_cost_index) AS stddev_labor_cost_index
    FROM staging.fulfillment_centers
)

SELECT
    'Minimum' AS statistic,
    min_daily_capacity AS daily_order_capacity,
    min_handling_cost AS standard_handling_cost_per_item,
    min_labor_cost_index AS labor_cost_index
FROM fulfillment_center_stats

UNION ALL

SELECT
    'Maximum',
    max_daily_capacity,
    max_handling_cost,
    max_labor_cost_index
FROM fulfillment_center_stats

UNION ALL

SELECT
    'Average',
    avg_daily_capacity,
    avg_handling_cost,
    avg_labor_cost_index
FROM fulfillment_center_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_daily_capacity,
    stddev_handling_cost,
    stddev_labor_cost_index
FROM fulfillment_center_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE daily_order_capacity <= 0
    ) AS invalid_daily_order_capacity,

    COUNT(*) FILTER (
        WHERE standard_handling_cost_per_item < 0
    ) AS negative_handling_cost,

    COUNT(*) FILTER (
        WHERE labor_cost_index <= 0
    ) AS invalid_labor_cost_index
FROM staging.fulfillment_centers;
-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
-- No cross-column numeric query was present for this table in the source script.
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.fulfillment_center_id,
        measure_values.measure,
        measure_values.value
    FROM staging.fulfillment_centers AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('daily_order_capacity', source_row.daily_order_capacity::numeric),
            ('standard_handling_cost_per_item', source_row.standard_handling_cost_per_item::numeric),
            ('labor_cost_index', source_row.labor_cost_index::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Fulfillment Centers extreme value review' AS check_name,
    fulfillment_center_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, fulfillment_center_id;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- No prior result counts were recorded in this source section.
-- #endregion
-- #endregion

-- #region TASK 14 | STORES | Numeric anomalies
-- Table: staging.stores
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.

-- #region STEP 1 | Summarize numeric measures
WITH store_stats AS (
    SELECT
        MIN(standard_handling_cost_per_item) AS min_handling_cost,
        MAX(standard_handling_cost_per_item) AS max_handling_cost,
        AVG(standard_handling_cost_per_item) AS avg_handling_cost,
        STDDEV(standard_handling_cost_per_item) AS stddev_handling_cost,

        MIN(labor_cost_index) AS min_labor_cost_index,
        MAX(labor_cost_index) AS max_labor_cost_index,
        AVG(labor_cost_index) AS avg_labor_cost_index,
        STDDEV(labor_cost_index) AS stddev_labor_cost_index
    FROM staging.stores
)

SELECT
    'Minimum' AS statistic,
    min_handling_cost AS standard_handling_cost_per_item,
    min_labor_cost_index AS labor_cost_index
FROM store_stats

UNION ALL

SELECT
    'Maximum',
    max_handling_cost,
    max_labor_cost_index
FROM store_stats

UNION ALL

SELECT
    'Average',
    avg_handling_cost,
    avg_labor_cost_index
FROM store_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_handling_cost,
    stddev_labor_cost_index
FROM store_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE standard_handling_cost_per_item < 0
    ) AS negative_handling_cost,

    COUNT(*) FILTER (
        WHERE labor_cost_index <= 0
    ) AS invalid_labor_cost_index
FROM staging.stores;
-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
-- No cross-column numeric query was present for this table in the source script.
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.store_id,
        measure_values.measure,
        measure_values.value
    FROM staging.stores AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('standard_handling_cost_per_item', source_row.standard_handling_cost_per_item::numeric),
            ('labor_cost_index', source_row.labor_cost_index::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Stores extreme value review' AS check_name,
    store_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, store_id;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- No prior result counts were recorded in this source section.
-- #endregion
-- #endregion

-- #region TASK 14 | ORDERS | Numeric anomalies
-- Table: staging.orders
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.

-- #region STEP 1 | Summarize numeric measures
WITH order_stats AS (
    SELECT
        MIN(customer_shipping_fee) AS min_shipping_fee,
        MAX(customer_shipping_fee) AS max_shipping_fee,
        AVG(customer_shipping_fee) AS avg_shipping_fee,
        STDDEV(customer_shipping_fee) AS stddev_shipping_fee
    FROM staging.orders
)

SELECT
    'Minimum' AS statistic,
    min_shipping_fee AS customer_shipping_fee
FROM order_stats

UNION ALL

SELECT
    'Maximum',
    max_shipping_fee
FROM order_stats

UNION ALL

SELECT
    'Average',
    avg_shipping_fee
FROM order_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_shipping_fee
FROM order_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE customer_shipping_fee < 0
    ) AS negative_customer_shipping_fee
FROM staging.orders;
-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
-- No cross-column numeric query was present for this table in the source script.
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.order_id,
        measure_values.measure,
        measure_values.value
    FROM staging.orders AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('customer_shipping_fee', source_row.customer_shipping_fee::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Orders extreme value review' AS check_name,
    order_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, order_id;

---------------------------------------------------------------

--Summarize the distinct fee values and how often each occurs

WITH fee_counts AS (
    SELECT
        customer_shipping_fee AS value,
        COUNT(*) AS order_count
    FROM staging.orders
    WHERE customer_shipping_fee IS NOT NULL
    GROUP BY customer_shipping_fee
),
ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY value
        ) AS lowest_rank,
        DENSE_RANK() OVER (
            ORDER BY value DESC
        ) AS highest_rank
    FROM fee_counts
)
SELECT
    value AS customer_shipping_fee,
    order_count,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY value;

----------------------------------

SELECT
    customer_shipping_fee,
    sales_channel,
    requested_service_level,
    COUNT(*) AS order_count
FROM staging.orders
WHERE customer_shipping_fee IN (
    0.00,
    149.00,
    179.00,
    199.00,
    249.00,
    299.00
)
GROUP BY
    customer_shipping_fee,
    sales_channel,
    requested_service_level
ORDER BY
    customer_shipping_fee,
    order_count DESC;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- No prior result counts were recorded in this source section.
-- #endregion
-- #endregion

-- #region TASK 14 | SHIPMENTS | Numeric anomalies
-- Table: staging.shipments
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.
-- Cross-table results depend on unique parent IDs and complete matching rows.
-- Resolve duplicate-key and missing-match findings before treating these counts as final.
-- DISTINCT removes exact copies only within this query; staging data is unchanged.
-- Conflicting rows with the same ID are not resolved by DISTINCT.

-- #region STEP 1 | Summarize numeric measures
WITH shipment_stats AS (
    SELECT
        MIN(shipping_distance_miles) AS min_shipping_distance,
        MAX(shipping_distance_miles) AS max_shipping_distance,
        AVG(shipping_distance_miles) AS avg_shipping_distance,
        STDDEV(shipping_distance_miles) AS stddev_shipping_distance,

        MIN(shipment_weight_lbs) AS min_shipment_weight,
        MAX(shipment_weight_lbs) AS max_shipment_weight,
        AVG(shipment_weight_lbs) AS avg_shipment_weight,
        STDDEV(shipment_weight_lbs) AS stddev_shipment_weight,

        MIN(package_count) AS min_package_count,
        MAX(package_count) AS max_package_count,
        AVG(package_count) AS avg_package_count,
        STDDEV(package_count) AS stddev_package_count,

        MIN(outbound_shipping_cost) AS min_shipping_cost,
        MAX(outbound_shipping_cost) AS max_shipping_cost,
        AVG(outbound_shipping_cost) AS avg_shipping_cost,
        STDDEV(outbound_shipping_cost) AS stddev_shipping_cost,

        MIN(fulfillment_handling_cost) AS min_fulfillment_cost,
        MAX(fulfillment_handling_cost) AS max_fulfillment_cost,
        AVG(fulfillment_handling_cost) AS avg_fulfillment_cost,
        STDDEV(fulfillment_handling_cost) AS stddev_fulfillment_cost
    FROM staging.shipments
)

SELECT
    'Minimum' AS statistic,
    min_shipping_distance AS shipping_distance_miles,
    min_shipment_weight AS shipment_weight_lbs,
    min_package_count AS package_count,
    min_shipping_cost AS outbound_shipping_cost,
    min_fulfillment_cost AS fulfillment_handling_cost
FROM shipment_stats

UNION ALL

SELECT
    'Maximum',
    max_shipping_distance,
    max_shipment_weight,
    max_package_count,
    max_shipping_cost,
    max_fulfillment_cost
FROM shipment_stats

UNION ALL

SELECT
    'Average',
    avg_shipping_distance,
    avg_shipment_weight,
    avg_package_count,
    avg_shipping_cost,
    avg_fulfillment_cost
FROM shipment_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_shipping_distance,
    stddev_shipment_weight,
    stddev_package_count,
    stddev_shipping_cost,
    stddev_fulfillment_cost
FROM shipment_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE shipping_distance_miles <= 0
    ) AS invalid_shipping_distance,

    COUNT(*) FILTER (
        WHERE shipment_weight_lbs <= 0
    ) AS invalid_shipment_weight,

    COUNT(*) FILTER (
        WHERE package_count < 1
    ) AS invalid_package_count,

    COUNT(*) FILTER (
        WHERE outbound_shipping_cost < 0
    ) AS negative_outbound_shipping_cost,

    COUNT(*) FILTER (
        WHERE fulfillment_handling_cost < 0
    ) AS negative_fulfillment_handling_cost
FROM staging.shipments;

--Run Summary query to understand the 216 bad weights

SELECT
    shipment_weight_lbs,
    COUNT(*) AS shipment_count
FROM staging.shipments
WHERE shipment_weight_lbs <= 0
GROUP BY shipment_weight_lbs
ORDER BY shipment_weight_lbs;


-- #endregion




-- #region STEP 3 | Test cross-column and cross-table rules
--Reconcile weight and package count with Order Items
WITH deduplicated_shipments AS (
    SELECT DISTINCT *
    FROM staging.shipments
),

expected_shipment_values AS (
    SELECT
        order_item.shipment_id,

        SUM(
            order_item.quantity * product.unit_weight_lbs
        ) AS expected_shipment_weight_lbs,

        SUM(
            order_item.quantity * product.package_count
        ) AS expected_package_count
    FROM staging.order_items AS order_item
    INNER JOIN staging.products AS product
        ON order_item.product_id = product.product_id
    WHERE order_item.shipment_id IS NOT NULL
    GROUP BY order_item.shipment_id
),

shipment_reconciliation AS (
    SELECT
        shipment.shipment_id,
        shipment.shipment_weight_lbs AS recorded_weight_lbs,
        expected_shipment.expected_shipment_weight_lbs,
        shipment.shipment_weight_lbs
            - expected_shipment.expected_shipment_weight_lbs
            AS weight_difference_lbs,

        shipment.package_count AS recorded_package_count,
        expected_shipment.expected_package_count,
        shipment.package_count
            - expected_shipment.expected_package_count
            AS package_count_difference
    FROM deduplicated_shipments AS shipment
    INNER JOIN expected_shipment_values AS expected_shipment
        ON shipment.shipment_id = expected_shipment.shipment_id
)

SELECT
    COUNT(*) FILTER (
        WHERE weight_difference_lbs <> 0
    ) AS shipments_with_weight_difference,

    COUNT(*) FILTER (
        WHERE package_count_difference <> 0
    ) AS shipments_with_package_count_difference
FROM shipment_reconciliation;

-- Inspect shipment weight and package differences
WITH deduplicated_shipments AS (
    SELECT DISTINCT *
    FROM staging.shipments
),

expected_shipment_values AS (
    SELECT
        order_item.shipment_id,

        SUM(
            order_item.quantity * product.unit_weight_lbs
        ) AS expected_shipment_weight_lbs,

        SUM(
            order_item.quantity * product.package_count
        ) AS expected_package_count
    FROM staging.order_items AS order_item
    INNER JOIN staging.products AS product
        ON order_item.product_id = product.product_id
    WHERE order_item.shipment_id IS NOT NULL
    GROUP BY order_item.shipment_id
),

shipment_reconciliation AS (
    SELECT
        shipment.shipment_id,
        shipment.shipment_weight_lbs AS recorded_weight_lbs,
        expected_shipment.expected_shipment_weight_lbs,
        shipment.shipment_weight_lbs
            - expected_shipment.expected_shipment_weight_lbs
            AS weight_difference_lbs,

        shipment.package_count AS recorded_package_count,
        expected_shipment.expected_package_count,
        shipment.package_count
            - expected_shipment.expected_package_count
            AS package_count_difference
    FROM deduplicated_shipments AS shipment
    INNER JOIN expected_shipment_values AS expected_shipment
        ON shipment.shipment_id = expected_shipment.shipment_id
)

SELECT *
FROM shipment_reconciliation
WHERE weight_difference_lbs <> 0
OR package_count_difference <> 0
ORDER BY
    ABS(weight_difference_lbs) DESC,
    ABS(package_count_difference) DESC;


--Simply
WITH deduplicated_shipments AS (
    SELECT DISTINCT *
    FROM staging.shipments
),

expected_shipment_values AS (
    SELECT
        order_item.shipment_id,
        SUM(
            order_item.quantity * product.unit_weight_lbs
        ) AS expected_shipment_weight_lbs
    FROM staging.order_items AS order_item
    INNER JOIN staging.products AS product
        ON order_item.product_id = product.product_id
    WHERE order_item.shipment_id IS NOT NULL
    GROUP BY order_item.shipment_id
)

SELECT
    COUNT(*) AS invalid_weight_shipments,
    
    COUNT(*) FILTER (
        WHERE expected_shipment.shipment_id IS NOT NULL
    ) AS invalid_with_expected_weight,

    COUNT(*) FILTER (
        WHERE expected_shipment.shipment_id IS NULL
    ) AS invalid_without_expected_weight
FROM deduplicated_shipments AS shipment
LEFT JOIN expected_shipment_values AS expected_shipment
    ON shipment.shipment_id = expected_shipment.shipment_id
WHERE shipment.shipment_weight_lbs <= 0;

---

SELECT
    COUNT(*) AS raw_invalid_rows,
    COUNT(DISTINCT shipment_id) AS distinct_invalid_shipment_ids
FROM staging.shipments
WHERE shipment_weight_lbs <= 0;


-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.shipment_id,
        measure_values.measure,
        measure_values.value
    FROM staging.shipments AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('shipping_distance_miles', source_row.shipping_distance_miles::numeric),
            ('shipment_weight_lbs', source_row.shipment_weight_lbs::numeric),
            ('package_count', source_row.package_count::numeric),
            ('outbound_shipping_cost', source_row.outbound_shipping_cost::numeric),
            ('fulfillment_handling_cost', source_row.fulfillment_handling_cost::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Shipments extreme value review' AS check_name,
    shipment_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, shipment_id;

--------------------

--Summerized
WITH numeric_values AS (
    SELECT
        measure_values.measure,
        measure_values.value
    FROM staging.shipments AS shipment
    CROSS JOIN LATERAL (
        VALUES
            ('shipping_distance_miles', shipment.shipping_distance_miles::numeric),
            ('shipment_weight_lbs', shipment.shipment_weight_lbs::numeric),
            ('package_count', shipment.package_count::numeric),
            ('outbound_shipping_cost', shipment.outbound_shipping_cost::numeric),
            ('fulfillment_handling_cost', shipment.fulfillment_handling_cost::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),

value_counts AS (
    SELECT
        measure,
        value,
        COUNT(*) AS shipment_count
    FROM numeric_values
    GROUP BY
        measure,
        value
),

ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value
        ) AS lowest_rank,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value DESC
        ) AS highest_rank
    FROM value_counts
)

SELECT
    measure,
    value,
    shipment_count,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY
    measure,
    value;

-------

--connect the extreme values to shipping_method

SELECT
    shipping_method,

    COUNT(*) AS shipment_count,

    MIN(shipping_distance_miles) AS min_distance,
    MAX(shipping_distance_miles) AS max_distance,

    MIN(shipment_weight_lbs) AS min_weight,
    MAX(shipment_weight_lbs) AS max_weight,

    MIN(package_count) AS min_packages,
    MAX(package_count) AS max_packages,

    MIN(outbound_shipping_cost) AS min_shipping_cost,
    MAX(outbound_shipping_cost) AS max_shipping_cost,

    MIN(fulfillment_handling_cost) AS min_handling_cost,
    MAX(fulfillment_handling_cost) AS max_handling_cost

FROM staging.shipments
WHERE
       shipping_distance_miles >= 2928.80
    OR shipment_weight_lbs >= 1217.90
    OR package_count >= 12
    OR outbound_shipping_cost >= 855.14
    OR fulfillment_handling_cost >= 89.27
GROUP BY shipping_method
ORDER BY shipment_count DESC;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- Previously recorded results (retained, not rerun or verified):
-- invalid_shipment_weight = 216
-- shipments_with_weight_difference = 215
-- #endregion
-- #endregion

-- #region TASK 14 | ORDER ITEMS | Numeric anomalies
-- Table: staging.order_items
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.

-- #region STEP 1 | Summarize numeric measures
WITH order_item_stats AS (
    SELECT
        MIN(quantity) AS min_quantity,
        MAX(quantity) AS max_quantity,
        AVG(quantity) AS avg_quantity,
        STDDEV(quantity) AS stddev_quantity,

        MIN(unit_list_price) AS min_list_price,
        MAX(unit_list_price) AS max_list_price,
        AVG(unit_list_price) AS avg_list_price,
        STDDEV(unit_list_price) AS stddev_list_price,

        MIN(unit_discount_amount) AS min_discount_amount,
        MAX(unit_discount_amount) AS max_discount_amount,
        AVG(unit_discount_amount) AS avg_discount_amount,
        STDDEV(unit_discount_amount) AS stddev_discount_amount,

        MIN(unit_product_cost) AS min_product_cost,
        MAX(unit_product_cost) AS max_product_cost,
        AVG(unit_product_cost) AS avg_product_cost,
        STDDEV(unit_product_cost) AS stddev_product_cost,

        MIN(store_handling_cost) AS min_store_handling_cost,
        MAX(store_handling_cost) AS max_store_handling_cost,
        AVG(store_handling_cost) AS avg_store_handling_cost,
        STDDEV(store_handling_cost) AS stddev_store_handling_cost
    FROM staging.order_items
)

SELECT
    'Minimum' AS statistic,
    min_quantity AS quantity,
    min_list_price AS unit_list_price,
    min_discount_amount AS unit_discount_amount,
    min_product_cost AS unit_product_cost,
    min_store_handling_cost AS store_handling_cost
FROM order_item_stats

UNION ALL

SELECT
    'Maximum',
    max_quantity,
    max_list_price,
    max_discount_amount,
    max_product_cost,
    max_store_handling_cost
FROM order_item_stats

UNION ALL

SELECT
    'Average',
    avg_quantity,
    avg_list_price,
    avg_discount_amount,
    avg_product_cost,
    avg_store_handling_cost
FROM order_item_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_quantity,
    stddev_list_price,
    stddev_discount_amount,
    stddev_product_cost,
    stddev_store_handling_cost
FROM order_item_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE unit_list_price < 0
    ) AS negative_unit_list_price,

    COUNT(*) FILTER (
        WHERE unit_discount_amount < 0
    ) AS negative_unit_discount_amount,

    COUNT(*) FILTER (
        WHERE unit_product_cost < 0
    ) AS negative_unit_product_cost,

    COUNT(*) FILTER (
        WHERE store_handling_cost < 0
    ) AS negative_store_handling_cost
FROM staging.order_items;
-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
-- Compare discounts and fulfillment handling rules
SELECT
    COUNT(*) FILTER (
        WHERE unit_discount_amount > unit_list_price
    ) AS discount_exceeds_list_price,

    COUNT(*) FILTER (
        WHERE fulfillment_method = 'Home Delivery'
          AND store_handling_cost <> 0
    ) AS home_delivery_has_store_handling_cost
FROM staging.order_items;
-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.order_item_id,
        measure_values.measure,
        measure_values.value
    FROM staging.order_items AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('quantity', source_row.quantity::numeric),
            ('unit_list_price', source_row.unit_list_price::numeric),
            ('unit_discount_amount', source_row.unit_discount_amount::numeric),
            ('unit_product_cost', source_row.unit_product_cost::numeric),
            ('store_handling_cost', source_row.store_handling_cost::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Order Items extreme value review' AS check_name,
    order_item_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, order_item_id;

--------------------------------

--simplified for returning less records

WITH numeric_values AS (
    SELECT
        measure_values.measure,
        measure_values.value
    FROM staging.order_items AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('quantity', source_row.quantity::numeric),
            ('unit_list_price', source_row.unit_list_price::numeric),
            ('unit_discount_amount', source_row.unit_discount_amount::numeric),
            ('unit_product_cost', source_row.unit_product_cost::numeric),
            ('store_handling_cost', source_row.store_handling_cost::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),

value_counts AS (
    SELECT
        measure,
        value,
        COUNT(*) AS order_item_count
    FROM numeric_values
    GROUP BY
        measure,
        value
),

ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value
        ) AS lowest_rank,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value DESC
        ) AS highest_rank
    FROM value_counts
)

SELECT
    measure,
    value,
    order_item_count,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY
    measure,
    value;

--------------------------

--run is a summary of just the 656 invalid discount rows

SELECT
    COUNT(*) AS affected_rows,

    MIN(unit_list_price) AS min_list_price,
    MAX(unit_list_price) AS max_list_price,

    MIN(unit_discount_amount) AS min_invalid_discount,
    MAX(unit_discount_amount) AS max_invalid_discount,

    MIN(unit_discount_amount - unit_list_price) AS min_excess_amount,
    MAX(unit_discount_amount - unit_list_price) AS max_excess_amount,

    MIN(unit_list_price - unit_discount_amount) AS min_net_unit_price

FROM staging.order_items
WHERE unit_discount_amount > unit_list_price;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- Previously recorded results (retained, not rerun or verified):
-- discount_exceeds_list_price = 656
-- #endregion
-- #endregion

-- #region TASK 14 | RETURNS | Numeric anomalies
-- Table: staging.returns
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.
-- Cross-table results depend on unique parent IDs and complete matching rows.
-- Resolve duplicate-key and missing-match findings before treating these counts as final.
-- DISTINCT removes exact copies only within this query; staging data is unchanged.
-- Conflicting rows with the same ID are not resolved by DISTINCT.

-- #region STEP 1 | Summarize numeric measures
WITH return_stats AS (
    SELECT
        MIN(return_quantity) AS min_return_quantity,
        MAX(return_quantity) AS max_return_quantity,
        AVG(return_quantity) AS avg_return_quantity,
        STDDEV(return_quantity) AS stddev_return_quantity,

        MIN(refund_amount) AS min_refund_amount,
        MAX(refund_amount) AS max_refund_amount,
        AVG(refund_amount) AS avg_refund_amount,
        STDDEV(refund_amount) AS stddev_refund_amount,

        MIN(return_processing_cost) AS min_processing_cost,
        MAX(return_processing_cost) AS max_processing_cost,
        AVG(return_processing_cost) AS avg_processing_cost,
        STDDEV(return_processing_cost) AS stddev_processing_cost,

        MIN(reverse_shipping_cost) AS min_reverse_shipping_cost,
        MAX(reverse_shipping_cost) AS max_reverse_shipping_cost,
        AVG(reverse_shipping_cost) AS avg_reverse_shipping_cost,
        STDDEV(reverse_shipping_cost) AS stddev_reverse_shipping_cost,

        MIN(restocking_fee) AS min_restocking_fee,
        MAX(restocking_fee) AS max_restocking_fee,
        AVG(restocking_fee) AS avg_restocking_fee,
        STDDEV(restocking_fee) AS stddev_restocking_fee
    FROM staging.returns
)

SELECT
    'Minimum' AS statistic,
    min_return_quantity AS return_quantity,
    min_refund_amount AS refund_amount,
    min_processing_cost AS return_processing_cost,
    min_reverse_shipping_cost AS reverse_shipping_cost,
    min_restocking_fee AS restocking_fee
FROM return_stats

UNION ALL

SELECT
    'Maximum',
    max_return_quantity,
    max_refund_amount,
    max_processing_cost,
    max_reverse_shipping_cost,
    max_restocking_fee
FROM return_stats

UNION ALL

SELECT
    'Average',
    avg_return_quantity,
    avg_refund_amount,
    avg_processing_cost,
    avg_reverse_shipping_cost,
    avg_restocking_fee
FROM return_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_return_quantity,
    stddev_refund_amount,
    stddev_processing_cost,
    stddev_reverse_shipping_cost,
    stddev_restocking_fee
FROM return_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE return_quantity <= 0
    ) AS invalid_return_quantity,

    COUNT(*) FILTER (
        WHERE refund_amount < 0
    ) AS negative_refund_amount,

    COUNT(*) FILTER (
        WHERE return_processing_cost < 0
    ) AS negative_return_processing_cost,

    COUNT(*) FILTER (
        WHERE reverse_shipping_cost < 0
    ) AS negative_reverse_shipping_cost,

    COUNT(*) FILTER (
        WHERE restocking_fee < 0
    ) AS negative_restocking_fee
FROM staging.returns;

-----------------
--compare each return quantity to the quantity originally purchased
SELECT
    COUNT(*) AS return_quantity_exceeds_order_item_quantity
FROM staging.returns AS r
INNER JOIN staging.order_items AS oi
    ON r.order_item_id = oi.order_item_id
WHERE r.return_quantity > oi.quantity;

-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
--Test cumulative return quantity against purchased quantity
WITH deduplicated_returns AS (
    SELECT DISTINCT *
    FROM staging.returns
),

return_totals AS (
    SELECT
        order_item_id,
        SUM(return_quantity) AS total_return_quantity
    FROM deduplicated_returns
    GROUP BY order_item_id
)

SELECT
    COUNT(*) AS order_items_over_returned
FROM return_totals AS return_total
INNER JOIN staging.order_items AS order_item
    ON return_total.order_item_id = order_item.order_item_id
WHERE return_total.total_return_quantity > order_item.quantity;

-- Inspect order items with excessive cumulative returns
WITH deduplicated_returns AS (
    SELECT DISTINCT *
    FROM staging.returns
),

return_totals AS (
    SELECT
        order_item_id,
        SUM(return_quantity) AS total_return_quantity
    FROM deduplicated_returns
    GROUP BY order_item_id
)

SELECT
    return_total.order_item_id,
    order_item.quantity AS purchased_quantity,
    return_total.total_return_quantity,
    return_total.total_return_quantity - order_item.quantity AS excess_return_quantity
FROM return_totals AS return_total
INNER JOIN staging.order_items AS order_item
    ON return_total.order_item_id = order_item.order_item_id
WHERE return_total.total_return_quantity > order_item.quantity
ORDER BY excess_return_quantity DESC, return_total.order_item_id;



--Test refund and return-cost rules
WITH deduplicated_returns AS (
    SELECT DISTINCT *
    FROM staging.returns
),

return_values AS (
    SELECT
        return_record.return_id,
        return_record.return_channel,
        return_record.refund_amount,
        return_record.restocking_fee,
        return_record.reverse_shipping_cost,
        return_record.return_quantity
            * (order_item.unit_list_price - order_item.unit_discount_amount)
            AS refundable_merchandise_amount
    FROM deduplicated_returns AS return_record
    INNER JOIN staging.order_items AS order_item
        ON return_record.order_item_id = order_item.order_item_id
)

SELECT
    COUNT(*) FILTER (
        WHERE restocking_fee > refundable_merchandise_amount
    ) AS restocking_fee_exceeds_merchandise_amount,

    COUNT(*) FILTER (
        WHERE refund_amount > refundable_merchandise_amount
    ) AS refund_exceeds_merchandise_amount,

    COUNT(*) FILTER (
        WHERE return_channel = 'Store'
          AND reverse_shipping_cost <> 0
    ) AS store_returns_have_reverse_shipping_cost
FROM return_values;


--------

WITH deduplicated_returns AS (
    SELECT DISTINCT *
    FROM staging.returns
),

return_values AS (
    SELECT
        return_record.return_id,
        return_record.order_item_id,

        return_record.return_quantity,
        order_item.quantity AS purchased_quantity,

        order_item.unit_list_price,
        order_item.unit_discount_amount,

        return_record.refund_amount,
        return_record.restocking_fee,

        return_record.return_quantity
            * (order_item.unit_list_price - order_item.unit_discount_amount)
            AS refundable_merchandise_amount

    FROM deduplicated_returns AS return_record

    INNER JOIN staging.order_items AS order_item
        ON return_record.order_item_id = order_item.order_item_id
)

SELECT
    COUNT(*) FILTER (
        WHERE restocking_fee > refundable_merchandise_amount
           OR refund_amount > refundable_merchandise_amount
    ) AS rows_with_refund_or_fee_violation,

    COUNT(*) FILTER (
        WHERE (
                restocking_fee > refundable_merchandise_amount
             OR refund_amount > refundable_merchandise_amount
              )
          AND unit_discount_amount > unit_list_price
    ) AS affected_by_invalid_discount,

    COUNT(*) FILTER (
        WHERE (
                restocking_fee > refundable_merchandise_amount
             OR refund_amount > refundable_merchandise_amount
              )
          AND return_quantity > purchased_quantity
    ) AS affected_by_invalid_return_quantity,

    COUNT(*) FILTER (
        WHERE (
                restocking_fee > refundable_merchandise_amount
             OR refund_amount > refundable_merchandise_amount
              )
          AND unit_discount_amount <= unit_list_price
          AND return_quantity <= purchased_quantity
    ) AS potential_new_returns_violations

FROM return_values;


-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.return_id,
        measure_values.measure,
        measure_values.value
    FROM staging.returns AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('return_quantity', source_row.return_quantity::numeric),
            ('refund_amount', source_row.refund_amount::numeric),
            ('return_processing_cost', source_row.return_processing_cost::numeric),
            ('reverse_shipping_cost', source_row.reverse_shipping_cost::numeric),
            ('restocking_fee', source_row.restocking_fee::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Returns extreme value review' AS check_name,
    return_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, return_id;

-------

--Simplified for less records

WITH numeric_values AS (
    SELECT
        measure_values.measure,
        measure_values.value
    FROM staging.returns AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('return_quantity', source_row.return_quantity::numeric),
            ('refund_amount', source_row.refund_amount::numeric),
            ('return_processing_cost', source_row.return_processing_cost::numeric),
            ('reverse_shipping_cost', source_row.reverse_shipping_cost::numeric),
            ('restocking_fee', source_row.restocking_fee::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),

value_counts AS (
    SELECT
        measure,
        value,
        COUNT(*) AS return_count
    FROM numeric_values
    GROUP BY
        measure,
        value
),

ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value
        ) AS lowest_rank,

        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value DESC
        ) AS highest_rank

    FROM value_counts
)

SELECT
    measure,
    value,
    return_count,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY
    measure,
    value;

--------------

--extreme-value check
WITH deduplicated_returns AS (
    SELECT DISTINCT *
    FROM staging.returns
)

SELECT
    return_record.return_id,
    return_record.return_channel,
    return_record.return_quantity,

    order_item.quantity AS purchased_quantity,
    order_item.unit_list_price,
    order_item.unit_discount_amount,

    return_record.return_quantity
        * (order_item.unit_list_price - order_item.unit_discount_amount)
        AS refundable_merchandise_amount,

    return_record.refund_amount,
    return_record.restocking_fee,
    return_record.return_processing_cost,
    return_record.reverse_shipping_cost

FROM deduplicated_returns AS return_record

INNER JOIN staging.order_items AS order_item
    ON return_record.order_item_id = order_item.order_item_id

WHERE
       return_record.refund_amount >= 4053.52
    OR return_record.restocking_fee >= 339.06
    OR return_record.return_processing_cost >= 75.46
    OR return_record.reverse_shipping_cost >= 395.15

ORDER BY
    return_record.refund_amount DESC,
    return_record.reverse_shipping_cost DESC,
    return_record.return_processing_cost DESC,
    return_record.restocking_fee DESC;

--------------------

SELECT
    COUNT(*) AS extreme_return_rows,

    COUNT(*) FILTER (
        WHERE order_item.order_item_id IS NOT NULL
    ) AS linked_extreme_returns,

    COUNT(*) FILTER (
        WHERE order_item.order_item_id IS NULL
    ) AS orphan_extreme_returns,

    COUNT(DISTINCT return_record.return_id)
        AS distinct_extreme_return_ids

FROM staging.returns AS return_record

LEFT JOIN staging.order_items AS order_item
    ON return_record.order_item_id = order_item.order_item_id

WHERE return_record.return_quantity > 3;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- Previously recorded results (retained, not rerun or verified):
-- order_items_over_returned = 56
-- restocking_fee_exceeds_merchandise_amount = 49
-- refund_exceeds_merchandise_amount = 49
-- #endregion
-- #endregion

-- #region TASK 14 | INVENTORY ACTIVITY | Numeric anomalies
-- Table: staging.inventory_activity
-- Summary aggregates exclude NULLs. Boundary counts below do not count NULLs.
-- Use Task 10 for required-field NULL checks.
-- DISTINCT removes exact copies only within this query; staging data is unchanged.
-- Conflicting rows with the same ID are not resolved by DISTINCT.
-- Balance sequencing assumes datetime then inventory_activity_id gives event order.
-- First events and missing previous balances cannot be reconciled by this check.

-- #region STEP 1 | Summarize numeric measures
WITH inventory_activity_stats AS (
    SELECT
        MIN(quantity_change) AS min_quantity_change,
        MAX(quantity_change) AS max_quantity_change,
        AVG(quantity_change) AS avg_quantity_change,
        STDDEV(quantity_change) AS stddev_quantity_change,

        MIN(quantity_on_hand_after) AS min_quantity_on_hand,
        MAX(quantity_on_hand_after) AS max_quantity_on_hand,
        AVG(quantity_on_hand_after) AS avg_quantity_on_hand,
        STDDEV(quantity_on_hand_after) AS stddev_quantity_on_hand,

        MIN(reorder_point_at_event) AS min_reorder_point,
        MAX(reorder_point_at_event) AS max_reorder_point,
        AVG(reorder_point_at_event) AS avg_reorder_point,
        STDDEV(reorder_point_at_event) AS stddev_reorder_point
    FROM staging.inventory_activity
)

SELECT
    'Minimum' AS statistic,
    min_quantity_change AS quantity_change,
    min_quantity_on_hand AS quantity_on_hand_after,
    min_reorder_point AS reorder_point_at_event
FROM inventory_activity_stats

UNION ALL

SELECT
    'Maximum',
    max_quantity_change,
    max_quantity_on_hand,
    max_reorder_point
FROM inventory_activity_stats

UNION ALL

SELECT
    'Average',
    avg_quantity_change,
    avg_quantity_on_hand,
    avg_reorder_point
FROM inventory_activity_stats

UNION ALL

SELECT
    'Standard Deviation',
    stddev_quantity_change,
    stddev_quantity_on_hand,
    stddev_reorder_point
FROM inventory_activity_stats;
-- #endregion

-- #region STEP 2 | Test known boundaries
SELECT
    COUNT(*) FILTER (
        WHERE quantity_change = 0
    ) AS zero_quantity_change,

    COUNT(*) FILTER (
        WHERE quantity_on_hand_after < 0
    ) AS negative_quantity_on_hand,

    COUNT(*) FILTER (
        WHERE reorder_point_at_event < 0
    ) AS negative_reorder_point
FROM staging.inventory_activity;

-- Does the 931 raw negative-balance rows include exact duplicates?
WITH negative_inventory AS (
    SELECT *
    FROM staging.inventory_activity
    WHERE quantity_on_hand_after < 0
),

deduplicated_negative_inventory AS (
    SELECT DISTINCT *
    FROM negative_inventory
)

SELECT
    (SELECT COUNT(*)
     FROM negative_inventory) AS raw_negative_rows,

    (SELECT COUNT(*)
     FROM deduplicated_negative_inventory) AS deduplicated_negative_rows,

    (SELECT COUNT(DISTINCT inventory_activity_id)
     FROM negative_inventory) AS distinct_activity_ids;


-- #endregion

-- #region STEP 3 | Test cross-column and cross-table rules
--Test quantity-change signs against activity types
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
)

SELECT
    COUNT(*) FILTER (
        WHERE activity_type IN (
            'Supplier Receipt',
            'Transfer In',
            'Return Restock'
        )
        AND quantity_change <= 0
    ) AS inventory_increases_with_wrong_sign,

    COUNT(*) FILTER (
        WHERE activity_type IN (
            'Sale Fulfillment',
            'Transfer Out',
            'Damage Write-Off'
        )
        AND quantity_change >= 0
    ) AS inventory_decreases_with_wrong_sign
FROM deduplicated_activity;

--Reconcile each balance with the preceding balance
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

sequenced_activity AS (
    SELECT
        inventory_activity_id,
        product_id,
        fulfillment_center_id,
        store_id,
        activity_datetime,
        quantity_change,
        quantity_on_hand_after,

        LAG(quantity_on_hand_after) OVER (
            PARTITION BY
                product_id,
                fulfillment_center_id,
                store_id
            ORDER BY
                activity_datetime,
                inventory_activity_id
        ) AS previous_quantity_on_hand
    FROM deduplicated_activity
)

SELECT
    COUNT(*) AS balance_reconciliation_failures
FROM sequenced_activity
WHERE previous_quantity_on_hand IS NOT NULL
  AND quantity_on_hand_after
      <> previous_quantity_on_hand + quantity_change;


-------------------------
--break down the 2617 failures into categories
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

sequenced_activity AS (
    SELECT
        inventory_activity_id,
        product_id,
        fulfillment_center_id,
        store_id,
        activity_datetime,
        quantity_change,
        quantity_on_hand_after,

        LAG(quantity_on_hand_after) OVER (
            PARTITION BY
                product_id,
                fulfillment_center_id,
                store_id
            ORDER BY
                activity_datetime,
                inventory_activity_id
        ) AS previous_quantity_on_hand

    FROM deduplicated_activity
),

reconciliation_failures AS (
    SELECT *
    FROM sequenced_activity
    WHERE previous_quantity_on_hand IS NOT NULL
      AND quantity_on_hand_after
          <> previous_quantity_on_hand + quantity_change
)

SELECT
    COUNT(*) AS total_reconciliation_failures,

    COUNT(*) FILTER (
        WHERE quantity_on_hand_after < 0
    ) AS failures_with_current_negative_balance,

    COUNT(*) FILTER (
        WHERE previous_quantity_on_hand < 0
    ) AS failures_following_negative_balance,

    COUNT(*) FILTER (
        WHERE quantity_on_hand_after >= 0
          AND previous_quantity_on_hand >= 0
    ) AS failures_with_nonnegative_balances

FROM reconciliation_failures;


--Reconcile Transfer Out and Transfer In quantities
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

transfer_summary AS (
    SELECT
        transfer_reference_id,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_rows,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_rows,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_quantity,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_quantity
    FROM deduplicated_activity
    WHERE activity_type IN ('Transfer Out', 'Transfer In')
      AND transfer_reference_id IS NOT NULL
    GROUP BY transfer_reference_id
)

SELECT
    COUNT(*) AS invalid_transfer_pairs
FROM transfer_summary
WHERE transfer_out_rows <> 1
   OR transfer_in_rows <> 1
   OR COALESCE(transfer_out_quantity, 0)
      + COALESCE(transfer_in_quantity, 0) <> 0;

-- Inspect invalid transfer pairs
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

transfer_summary AS (
    SELECT
        transfer_reference_id,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_rows,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_rows,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_quantity,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_quantity
    FROM deduplicated_activity
    WHERE activity_type IN ('Transfer Out', 'Transfer In')
      AND transfer_reference_id IS NOT NULL
    GROUP BY transfer_reference_id
)

SELECT *
FROM transfer_summary
WHERE transfer_out_rows <> 1
    OR transfer_in_rows <> 1
    OR COALESCE(transfer_out_quantity, 0)
        + COALESCE(transfer_in_quantity, 0) <> 0
ORDER BY transfer_reference_id;

-----
--Summarize

WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

transfer_summary AS (
    SELECT
        transfer_reference_id,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_rows,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_rows,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_quantity,

        SUM(quantity_change) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_quantity

    FROM deduplicated_activity
    WHERE activity_type IN ('Transfer Out', 'Transfer In')
      AND transfer_reference_id IS NOT NULL
    GROUP BY transfer_reference_id
)

SELECT
    COUNT(*) AS invalid_transfer_pairs,

    COUNT(*) FILTER (
        WHERE transfer_out_rows <> 1
    ) AS invalid_transfer_out_count,

    COUNT(*) FILTER (
        WHERE transfer_in_rows <> 1
    ) AS invalid_transfer_in_count,

    COUNT(*) FILTER (
        WHERE transfer_out_rows = 1
          AND transfer_in_rows = 1
          AND transfer_out_quantity + transfer_in_quantity <> 0
    ) AS quantity_mismatch_only

FROM transfer_summary

WHERE transfer_out_rows <> 1
   OR transfer_in_rows <> 1
   OR COALESCE(transfer_out_quantity, 0)
      + COALESCE(transfer_in_quantity, 0) <> 0;


--------------------
--missing halves or multiple rows for the same transfer reference?

WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

transfer_summary AS (
    SELECT
        transfer_reference_id,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer Out'
        ) AS transfer_out_rows,

        COUNT(*) FILTER (
            WHERE activity_type = 'Transfer In'
        ) AS transfer_in_rows

    FROM deduplicated_activity
    WHERE activity_type IN ('Transfer Out', 'Transfer In')
      AND transfer_reference_id IS NOT NULL
    GROUP BY transfer_reference_id
)

SELECT
    COUNT(*) FILTER (
        WHERE transfer_out_rows = 0
    ) AS missing_transfer_out,

    COUNT(*) FILTER (
        WHERE transfer_out_rows > 1
    ) AS multiple_transfer_out,

    COUNT(*) FILTER (
        WHERE transfer_in_rows = 0
    ) AS missing_transfer_in,

    COUNT(*) FILTER (
        WHERE transfer_in_rows > 1
    ) AS multiple_transfer_in

FROM transfer_summary
WHERE transfer_out_rows <> 1
   OR transfer_in_rows <> 1;


----------

WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
)

SELECT
    activity_type,
    COUNT(*) AS row_count
FROM deduplicated_activity
WHERE transfer_reference_id IS NOT NULL
GROUP BY activity_type
ORDER BY row_count DESC, activity_type;

-----------------
--real transfer-pair violations after accounting for the known activity-type formatting issue


WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
),

normalized_activity AS (
    SELECT
        *,
        CASE
            WHEN LOWER(TRIM(activity_type)) IN (
                'transfer in',
                'legacy:transfer in'
            ) THEN 'Transfer In'

            WHEN LOWER(TRIM(activity_type)) IN (
                'transfer out',
                'legacy:transfer out'
            ) THEN 'Transfer Out'

            ELSE TRIM(activity_type)
        END AS normalized_activity_type
    FROM deduplicated_activity
),

transfer_summary AS (
    SELECT
        transfer_reference_id,

        COUNT(*) FILTER (
            WHERE normalized_activity_type = 'Transfer Out'
        ) AS transfer_out_rows,

        COUNT(*) FILTER (
            WHERE normalized_activity_type = 'Transfer In'
        ) AS transfer_in_rows,

        SUM(quantity_change) FILTER (
            WHERE normalized_activity_type = 'Transfer Out'
        ) AS transfer_out_quantity,

        SUM(quantity_change) FILTER (
            WHERE normalized_activity_type = 'Transfer In'
        ) AS transfer_in_quantity

    FROM normalized_activity
    WHERE normalized_activity_type IN ('Transfer Out', 'Transfer In')
      AND transfer_reference_id IS NOT NULL
    GROUP BY transfer_reference_id
)

SELECT
    COUNT(*) AS invalid_transfer_pairs,

    COUNT(*) FILTER (
        WHERE transfer_out_rows = 0
    ) AS missing_transfer_out,

    COUNT(*) FILTER (
        WHERE transfer_in_rows = 0
    ) AS missing_transfer_in,

    COUNT(*) FILTER (
        WHERE transfer_out_rows > 1
    ) AS multiple_transfer_out,

    COUNT(*) FILTER (
        WHERE transfer_in_rows > 1
    ) AS multiple_transfer_in,

    COUNT(*) FILTER (
        WHERE transfer_out_rows = 1
          AND transfer_in_rows = 1
          AND transfer_out_quantity + transfer_in_quantity <> 0
    ) AS quantity_mismatch_only

FROM transfer_summary
WHERE transfer_out_rows <> 1
   OR transfer_in_rows <> 1
   OR COALESCE(transfer_out_quantity, 0)
        + COALESCE(transfer_in_quantity, 0) <> 0;

-- #endregion

-- #region STEP 4 | Inspect extremes and document findings
-- Lowest/highest 5 distinct values per measure, including ties.
-- NULLs are excluded. Extreme values require review; they are not automatically errors.
WITH numeric_values AS (
    SELECT
        source_row.inventory_activity_id,
        measure_values.measure,
        measure_values.value
    FROM staging.inventory_activity AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('quantity_change', source_row.quantity_change::numeric),
            ('quantity_on_hand_after', source_row.quantity_on_hand_after::numeric),
            ('reorder_point_at_event', source_row.reorder_point_at_event::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),
ranked_values AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value) AS lowest_rank,
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY value DESC) AS highest_rank
    FROM numeric_values
)
SELECT
    'Inventory Activity extreme value review' AS check_name,
    inventory_activity_id,
    measure,
    value,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5 OR highest_rank <= 5
ORDER BY measure, value, inventory_activity_id;

------
--Simplified

WITH numeric_values AS (
    SELECT
        measure_values.measure,
        measure_values.value
    FROM staging.inventory_activity AS source_row
    CROSS JOIN LATERAL (
        VALUES
            ('quantity_change', source_row.quantity_change::numeric),
            ('quantity_on_hand_after', source_row.quantity_on_hand_after::numeric),
            ('reorder_point_at_event', source_row.reorder_point_at_event::numeric)
    ) AS measure_values(measure, value)
    WHERE measure_values.value IS NOT NULL
),

value_counts AS (
    SELECT
        measure,
        value,
        COUNT(*) AS row_count
    FROM numeric_values
    GROUP BY
        measure,
        value
),

ranked_values AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value
        ) AS lowest_rank,

        DENSE_RANK() OVER (
            PARTITION BY measure
            ORDER BY value DESC
        ) AS highest_rank

    FROM value_counts
)

SELECT
    measure,
    value,
    row_count,
    lowest_rank,
    highest_rank
FROM ranked_values
WHERE lowest_rank <= 5
   OR highest_rank <= 5
ORDER BY
    measure,
    value;

------------------
--contextualize the extreme trails
WITH deduplicated_activity AS (
    SELECT DISTINCT *
    FROM staging.inventory_activity
)

SELECT
    activity_type,

    COUNT(*) FILTER (
        WHERE quantity_change <= -9
    ) AS large_inventory_decreases,

    COUNT(*) FILTER (
        WHERE quantity_change >= 37
    ) AS large_inventory_increases,

    COUNT(*) FILTER (
        WHERE quantity_on_hand_after >= 88
    ) AS high_on_hand_balances,

    COUNT(*) FILTER (
        WHERE reorder_point_at_event >= 36
    ) AS high_reorder_points

FROM deduplicated_activity
GROUP BY activity_type
ORDER BY activity_type;

-- Findings worksheet:
-- Measure / rule:
-- Observed range / average / standard deviation:
-- Affected rows / percentage and denominator:
-- Example record ID and value:
-- Classification: valid / suspicious / confirmed error
-- Evidence / proposed Phase 3 action:
-- Previously recorded results (retained, not rerun or verified):
-- negative_quantity_on_hand 931
-- #endregion
-- #endregion

