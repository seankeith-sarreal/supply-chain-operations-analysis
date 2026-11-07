# Supply Chain Operations Analysis

## Project Overview

This portfolio project analyzes supply chain and order-fulfillment data for a large national home-furnishings retailer.

The primary business question is:

**Which products or product categories generate strong revenue but become less profitable after shipping, returns, discounts, and fulfillment costs are considered?**

The project is designed to demonstrate an end-to-end data analytics workflow using SQL, Excel, Power BI, and business-focused analytical reasoning.

## Project Status

**Current Stage: Phase 2 Complete — SQL Data Profiling**

Completed:

- Phase 1 — SQL Environment & Data Import
- Phase 2 — SQL Data Profiling & Data-Quality Assessment

Next:

- Phase 3 — SQL Data Cleaning

Future stages will include SQL business analysis, Excel analysis, Power BI dashboard development, and an executive presentation.

## Tools

- PostgreSQL
- SQL
- Visual Studio Code
- Excel
- Power BI
- Git / GitHub

## Dataset Structure

The project contains 10 relational tables:

- Suppliers
- Products
- Customers
- Fulfillment Centers
- Stores
- Orders
- Order Items
- Shipments
- Returns
- Inventory Activity

The raw dataset is intentionally excluded from this repository. The repository focuses on the SQL workflow, analytical methodology, and project deliverables.

## SQL Workflow

The current SQL files demonstrate the progression from database setup through data-quality analysis:

### Phase 1 — Environment & Data Import

- Database and schema creation
- Staging table creation
- Import validation and row-count reconciliation

### Phase 2 — Data Profiling

Profiling was performed across the full relational dataset for:

- Table structure and row counts
- NULL values
- Categorical inconsistencies
- Duplicate records and identifiers
- Date and chronology issues
- Numeric anomalies
- Broken relationships and foreign-key issues

The final Phase 2 assessment is consolidated in:

`sql/17_data_quality_summary.sql`

## Data-Quality Summary

The final Phase 2 summary contains **28 documented findings and validation checks**:

- **20 Confirmed Issues**
- **4 Passed Checks**
- **2 Legitimate Exceptions / False Positives**
- **2 Unresolved Findings**

The assessment distinguishes confirmed defects from valid business exceptions and unresolved patterns rather than treating every unusual value as an error.

Examples of issues investigated include:

- Duplicate transaction identifiers
- Invalid discounts
- Missing required operational values
- Impossible shipment and return chronology
- Nonpositive shipment weights
- Inventory balance inconsistencies
- Broken foreign-key relationships
- Categorical formatting and legacy-value inconsistencies

## Analytical Approach

The project follows several data-quality principles:

- Preserve the raw staging layer.
- Validate business rules before modifying data.
- Normalize categorical values before applying conditional checks.
- Avoid inventing replacement values when authoritative evidence is unavailable.
- Control duplicate and join grain before interpreting downstream results.
- Separate confirmed issues from legitimate exceptions and unresolved findings.
- Keep SQL transformations rerunnable and auditable.

## Repository Structure

```text
supply-chain-operations-analysis/
│
├── README.md
├── .gitignore
└── sql/
    ├── 00_connection_test.sql
    ├── 01_create_database.sql
    ├── 02_create_schemas.sql
    ├── ...
    ├── 16_profile_relationships.sql
    └── 17_data_quality_summary.sql
```

## Project Goal

The completed project will identify products or product categories where strong revenue does not translate into strong profitability after accounting for operational costs and profit leakage.

Final deliverables are planned to include:

- Clean and validated SQL data layer
- SQL profitability analysis
- Excel business-analysis workbook
- Power BI dashboard
- Evidence-based management recommendation
- Executive presentation

## Progress

This repository is being updated as the project progresses so that the analytical workflow, decisions, and technical development remain visible throughout the project lifecycle.