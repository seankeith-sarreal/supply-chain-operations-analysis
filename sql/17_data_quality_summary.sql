/*
Purpose: To summarize the findings from profiling the data.
Grain: One row represents one finding or validation check



 Output fields needed:
 Which finding is this, and where did it come from?
 1. Finding ID
 2. Source task
 3. Table name
 What was actually tested and what happened.
 4. Columns tested
 5. Business rule
 6. Affected rows
 How significant is the finding, and what do we conclude from it?
 7. Affected percentage
 8. Classification
 9. Phase 3 action
 How can someone trace or reproduce this finding?
 10. Example key
 11. Source query
*/

WITH data_quality_findings AS (
    SELECT
        'P2-001' AS finding_id,
        'Task 12' AS source_task,
        'Inventory Activity' AS table_name,
        'inventory_activity_id' AS columns_tested,
        'must be unique and non-NULL.' AS business_rule,
        2478 AS affected_rows,
        0.20 AS affected_pct,
        'Confirmed issue' AS classification,
        'Compare complete rows; retain one exact copy and quarantine unresolved conflicts.' AS phase_3_action,
        NULL AS example_key,
        '13_profile_duplicates.sql' AS source_query

    UNION ALL

    SELECT
        'P2-002',
        'Task 12',
        'Orders',
        'order_id',
        'must be unique and non-NULL.',
        1000,
        0.20,
        'Confirmed issue',
        'Preserve the approved row and remove or quarantine redundant/conflicting copies.',
        NULL,
        '13_profile_duplicates.sql'

    UNION ALL

    SELECT
        'P2-003',
        'Task 12',
        'Returns',
        'return_id',
        'must be unique and non-NULL.',
        155,
        0.20,
        'Confirmed issue',
        'Resolve duplicate groups before enforcing the primary key.',
        NULL,
        '13_profile_duplicates.sql'

    UNION ALL

    SELECT
        'P2-004',
        'Task 12',
        'Shipments',
        'shipment_id',
        'must be unique and non-NULL.',
        573,
        0.20,
        'Confirmed issue',
        'Preserve the valid shipment record and resolve redundant/conflicting copies.',
        NULL,
        '13_profile_duplicates.sql'

    UNION ALL

    SELECT
        'P2-005',
        'Task 10',
        'Orders',
        'order_status, cancellation_datetime, cancellation_reason',
        'Cancellation fields are allowed only for Cancelled orders.',
        0,
        0.00,
        'Passed check',
        'Normalize order_status before conditional validation; no cancellation-field remediation is required for this check.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-006',
        'Task 10',
        'Shipments',
        'shipment_status, delivered_datetime',
        'delivered_datetime is allowed only for Delivered shipments.',
        0,
        0.00,
        'Passed check',
        'Normalize shipment_status before status/date validation; no delivery-status remediation is required for this check.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-007',
        'Task 10',
        'Shipments',
        'shipment_status, delivery_exception_reason',
        'delivery_exception_reason is required only when the normalized shipment status indicates an exception.',
        0,
        0.00,
        'Legitimate exception / false positive',
        'Preserve NULL exception reasons for the current Delivered-only population; require a reason only when a future normalized status indicates an exception.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-008',
        'Task 10',
        'Order Items',
        'fulfillment_method, order_item_status, shipment_id',
        'Non-cancelled Home Delivery Order Items require a shipment_id; cancelled lines may legitimately have no Shipment relationship.',
        0,
        0.00,
        'Legitimate exception / false positive',
        'Preserve NULL shipment_id for cancelled Home Delivery lines and normalize categorical values before relationship validation.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-009',
        'Task 14',
        'Order Items',
        'unit_discount_amount, unit_list_price',
        'unit_discount_amount cannot exceed unit_list_price.',
        656,
        0.07,
        'Confirmed issue',
        'Correct or quarantine invalid prices or discounts and validate a nonnegative net unit price.',
        NULL,
        '15_profile_numeric_anomalies.sql'

    UNION ALL

    SELECT
        'P2-010',
        'Task 10',
        'Order Items',
        'order_item_status, cancellation_datetime, cancellation_reason',
        'Cancellation fields are allowed only for Cancelled Order Items.',
        0,
        0.00,
        'Passed check',
        'Normalize order_item_status before conditional validation; no cancellation-field remediation is required for this check.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-011',
        'Task 10',
        'Returns',
        'return_status, product_condition',
        'Processed Returns require an inspected product_condition.',
        486,
        0.63,
        'Confirmed issue',
        'Recover product condition when authoritative evidence exists; otherwise flag the affected Returns for condition-dependent analysis.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-012',
        'Task 10',
        'Inventory Activity',
        'activity_type, transfer_reference_id',
        'transfer_reference_id is allowed only for Transfer In and Transfer Out events.',
        0,
        0.00,
        'Passed check',
        'Normalize activity_type before transfer-reference validation; no reference-field remediation is required for this check.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-013',
        'Task 10',
        'Inventory Activity',
        'reorder_point_at_event',
        'reorder_point_at_event is required and must be nonnegative.',
        15556,
        1.25,
        'Confirmed issue',
        'Recover defensible historical reorder-point values when authoritative evidence exists; otherwise flag or quarantine the affected rows.',
        NULL,
        '11_profile_nulls.sql'

    UNION ALL

    SELECT
        'P2-014',
        'Task 11',
        'Multiple Tables',
        'Multiple categorical columns across seven tables',
        'Categorical values must use approved canonical spellings without unintended capitalization or surrounding-whitespace variants.',
        NULL,
        NULL,
        'Confirmed issue',
        'Trim values and map them case-insensitively to the exact approved canonical spellings.',
        NULL,
        '12_profile_categories.sql'

    UNION ALL

    SELECT
        'P2-015',
        'Task 11',
        'Customers',
        'customer_city, customer_state',
        'Customer geography values must be consistently formatted and must not fragment equivalent locations into separate categories.',
        NULL,
        NULL,
        'Confirmed issue',
        'Trim values, standardize city casing, uppercase two-letter state abbreviations, and rerun the frequency distributions.',
        NULL,
        '12_profile_categories.sql'

    UNION ALL

    SELECT
        'P2-016',
        'Task 11',
        'Returns, Inventory Activity',
        'disposition_outcome, activity_type',
        'Categorical values must resolve to the approved business categories; legacy values require reviewed mappings.',
        NULL,
        NULL,
        'Confirmed issue',
        'Create reviewed legacy-to-canonical mappings and quarantine values whose meanings remain ambiguous.',
        NULL,
        '12_profile_categories.sql'

    UNION ALL

    SELECT
        'P2-017',
        'Task 11',
        'Shipments',
        'carrier_name',
        'Equivalent carrier names should resolve to one canonical carrier category.',
        NULL,
        NULL,
        'Unresolved finding',
        'Group by normalized carrier name and inspect the raw variants before merging any categories.',
        NULL,
        '12_profile_categories.sql'

    UNION ALL

    SELECT
        'P2-018',
        'Task 13',
        'Shipments',
        'shipped_datetime, delivered_datetime',
        'delivered_datetime cannot occur before shipped_datetime.',
        288,
        0.10,
        'Confirmed issue',
        'Inspect the affected Shipment records and reconcile timestamps using an authoritative source; otherwise quarantine or flag them.',
        NULL,
        '14_profile_dates.sql'

    UNION ALL

    SELECT
        'P2-019',
        'Task 13',
        'Returns, Orders',
        'return_datetime, order_datetime',
        'A Return cannot occur before its parent Order.',
        79,
        0.10,
        'Confirmed issue',
        'Review the Return and parent Order dates at the correct grain before correction or quarantine.',
        NULL,
        '14_profile_dates.sql'

    UNION ALL

    SELECT
        'P2-020',
        'Task 13',
        'Returns, Shipments',
        'return_datetime, delivered_datetime',
        'A Return cannot occur before the related Shipment is delivered.',
        52,
        0.07,
        'Confirmed issue',
        'Test overlap with P2-019 before reporting a combined Return total, then reconcile the event chronology.',
        NULL,
        '14_profile_dates.sql'

    UNION ALL

    SELECT
        'P2-021',
        'Task 13',
        'Products, Customers, Fulfillment Centers, Stores',
        'launch_date, loyalty_join_date, opened_date',
        'Business dates should reflect credible record-level event dates rather than unexplained uniform defaults.',
        NULL,
        NULL,
        'Unresolved finding',
        'Preserve the source values and document the probable synthetic or default-date pattern unless authoritative dates become available.',
        NULL,
        '14_profile_dates.sql'

    UNION ALL

    SELECT
        'P2-022',
        'Task 14',
        'Shipments',
        'shipment_weight_lbs',
        'shipment_weight_lbs must be greater than zero.',
        215,
        0.07,
        'Confirmed issue',
        'Correct only under a documented rule supported by Order Item and Product evidence; otherwise quarantine and reconcile expected weight after duplicate control.',
        NULL,
        '15_profile_numeric_anomalies.sql'

    UNION ALL

    SELECT
        'P2-023',
        'Task 14',
        'Returns, Order Items',
        'return_quantity, quantity',
        'A linked Return quantity cannot exceed the purchased Order Item quantity.',
        57,
        0.07,
        'Confirmed issue',
        'Correct or quarantine the linked over-returns using purchased quantity as the governing rule; keep the orphan Return in the Task 15 workflow.',
        'return_id = 2000',
        '15_profile_numeric_anomalies.sql'

    UNION ALL

    SELECT
        'P2-024',
        'Task 14',
        'Inventory Activity',
        'quantity_on_hand_after',
        'quantity_on_hand_after must be nonnegative.',
        929,
        0.07,
        'Confirmed issue',
        'Investigate and correct only under an approved inventory-balance rule; otherwise quarantine and require zero negative balances after cleaning.',
        NULL,
        '15_profile_numeric_anomalies.sql'

    UNION ALL

    SELECT
        'P2-025',
        'Task 14',
        'Inventory Activity',
        'quantity_on_hand_after, quantity_change',
        'Within the same Product and location sequence, the prior quantity_on_hand_after plus the current quantity_change must equal the current quantity_on_hand_after.',
        2617,
        0.21,
        'Confirmed issue',
        'Prioritize the failures not explained by negative-state propagation, then reconcile or quarantine all remaining failures and rerun the sequence test.',
        NULL,
        '15_profile_numeric_anomalies.sql'

        UNION ALL

    SELECT
        'P2-026',
        'Task 15',
        'Shipments',
        'order_id',
        'Every populated Shipment order_id must reference an existing Order.',
        115,
        0.04,
        'Confirmed issue',
        'Preserve staging evidence; resolve only from an authoritative source, otherwise quarantine or exclude the affected Shipment rows from analyses requiring a valid Order relationship. Do not invent a parent Order.',
        '999999999',
        '16_profile_relationships.sql'

        UNION ALL

    SELECT
        'P2-027',
        'Task 15',
        'Inventory Activity',
        'product_id',
        'Every populated Inventory Activity product_id must reference an existing Product.',
        496,
        0.04,
        'Confirmed issue',
        'Preserve staging evidence; resolve only from an authoritative source, otherwise quarantine or exclude the affected Inventory Activity rows from analyses requiring a valid Product relationship. Do not invent a parent Product.',
        '999999999',
        '16_profile_relationships.sql'

        UNION ALL

    SELECT
        'P2-028',
        'Task 15',
        'Returns',
        'order_item_id',
        'Every populated Return order_item_id must reference an existing Order Item.',
        31,
        0.04,
        'Confirmed issue',
        'Preserve staging evidence; resolve only from an authoritative source, otherwise quarantine or exclude the affected Return rows from analyses requiring a valid Order Item relationship. Do not infer purchased quantity for orphan Returns.',
        '999999999',
        '16_profile_relationships.sql'
)

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT finding_id) AS distinct_finding_ids
FROM data_quality_findings;



SELECT
    finding_id,
    source_task,
    table_name,
    columns_tested,
    business_rule,
    affected_rows,
    affected_pct,
    classification,
    phase_3_action,
    example_key,
    source_query
FROM data_quality_findings
ORDER BY finding_id;


--Validate data_quality_findings to see if there are any duplicates
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT finding_id) AS distinct_finding_ids
FROM data_quality_findings;

--Validate that there are no missing critical descriptive information
SELECT *
FROM data_quality_findings
WHERE
    finding_id IS NULL
    OR
    source_task IS NULL
    OR
    table_name IS NULL
    OR
    columns_tested IS NULL
    OR
    business_rule IS NULL
    OR
    classification IS NULL
    OR
    phase_3_action IS NULL
    OR
    source_query IS NULL;

--c heck that none of the numeric summary values are impossible
SELECT *
FROM data_quality_findings
WHERE
    affected_rows < 0
    OR affected_pct < 0
    OR affected_pct > 100;

--check that affected_rows and affected_pct are being used consistently.
SELECT
    finding_id,
    affected_rows,
    affected_pct
FROM data_quality_findings
WHERE
    (affected_rows = 0 AND affected_pct <> 0)
    OR (affected_rows > 0 AND affected_pct IS NULL)
    OR (affected_rows IS NULL AND affected_pct IS NOT NULL);

--verify that every finding points back to the expected profiling SQL file
SELECT
    source_query,
    COUNT(*) AS finding_count
FROM data_quality_findings
GROUP BY source_query
ORDER BY source_query;

--make sure each source_task is paired with the correct SQL file
SELECT
    source_task,
    source_query,
    COUNT(*) AS finding_count
FROM data_quality_findings
GROUP BY
    source_task,
    source_query
ORDER BY
    source_task,
    source_query;

--verify that the finding IDs are continuous from P2-001 through P2-028 with no skipped or malformed IDs
SELECT
    finding_id
FROM data_quality_findings
ORDER BY finding_id;


--check whether your classification values are standardized rather than accidentally fragmented by slightly different wording.
SELECT
    classification,
    COUNT(*) AS finding_count
FROM data_quality_findings
GROUP BY classification
ORDER BY classification;

SELECT
    classification,
    STRING_AGG(finding_id, ', ' ORDER BY finding_id) AS finding_ids
FROM data_quality_findings
GROUP BY classification
ORDER BY classification;

--which finding_id has example_key
SELECT
    finding_id,
    example_key
FROM data_quality_findings
WHERE example_key IS NOT NULL
ORDER BY finding_id;


--make sure findings with affected_rows = 0 are not accidentally classified as confirmed issues.
SELECT
    finding_id,
    affected_rows,
    classification
FROM data_quality_findings
WHERE affected_rows = 0
ORDER BY finding_id;


--verify the two findings intentionally left unresolved:
SELECT
    finding_id,
    affected_rows,
    affected_pct,
    classification
FROM data_quality_findings
WHERE classification = 'Unresolved finding'
ORDER BY finding_id;


--make sure none of the required text fields is blank
SELECT *
FROM data_quality_findings
WHERE
    TRIM(finding_id) = ''
    OR TRIM(source_task) = ''
    OR TRIM(table_name) = ''
    OR TRIM(columns_tested) = ''
    OR TRIM(business_rule) = ''
    OR TRIM(classification) = ''
    OR TRIM(phase_3_action) = ''
    OR TRIM(source_query) = '';



--make sure every confirmed issue actually has a positive affected-row count.
SELECT
    finding_id,
    affected_rows,
    classification
FROM data_quality_findings
WHERE classification = 'Confirmed issue'
  AND (affected_rows IS NULL OR affected_rows <= 0)
ORDER BY finding_id;
--Adjust the validation to catch only a confirmed issue incorrectly recorded with zero affected rows
SELECT
    finding_id,
    affected_rows,
    classification
FROM data_quality_findings
WHERE classification = 'Confirmed issue'
  AND affected_rows = 0
ORDER BY finding_id;


--verify that the only ones doing so are the three expected categorical findings
SELECT
    finding_id,
    affected_rows,
    classification
FROM data_quality_findings
WHERE classification = 'Confirmed issue'
  AND affected_rows IS NULL
ORDER BY finding_id;


--verify all findings where affected_rows is intentionally NULL
SELECT
    finding_id,
    classification,
    affected_rows,
    affected_pct
FROM data_quality_findings
WHERE affected_rows IS NULL
ORDER BY finding_id;
