-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 6: AUDIT — ETL Log Table & Insert Tracking
-- ============================================================
--  Tracks every ETL run: rows extracted, cleaned, loaded,
--  duplicates removed, nulls fixed, errors encountered.
-- ============================================================

DROP TABLE IF EXISTS etl_audit_log;

CREATE TABLE etl_audit_log (
    log_id              INTEGER PRIMARY KEY AUTOINCREMENT,
    pipeline_run_id     TEXT    NOT NULL,           -- UUID-style run identifier
    stage               TEXT    NOT NULL,           -- EXTRACT / TRANSFORM / LOAD
    table_name          TEXT    NOT NULL,
    rows_processed      INTEGER DEFAULT 0,
    rows_inserted       INTEGER DEFAULT 0,
    rows_skipped        INTEGER DEFAULT 0,
    duplicates_removed  INTEGER DEFAULT 0,
    nulls_fixed         INTEGER DEFAULT 0,
    dates_fixed         INTEGER DEFAULT 0,
    errors              INTEGER DEFAULT 0,
    notes               TEXT,
    run_at              TEXT    DEFAULT (datetime('now'))
);

-- ── Insert audit records for this ETL run ─────────────────────────────────────
-- (Values come from verification queries in earlier steps)

INSERT INTO etl_audit_log
    (pipeline_run_id, stage, table_name, rows_processed, rows_inserted,
     rows_skipped, duplicates_removed, nulls_fixed, dates_fixed, errors, notes)
VALUES
    -- EXTRACT stage
    ('RUN-2024-ETL-001', 'EXTRACT', 'stg_raw_sales',
     (SELECT COUNT(*) FROM stg_raw_sales),
     (SELECT COUNT(*) FROM stg_raw_sales),
     0, 0, 0, 0, 0,
     'Raw CSV loaded into staging. All columns stored as TEXT.'),

    -- TRANSFORM stage
    ('RUN-2024-ETL-001', 'TRANSFORM', 'stg_cleaned_sales',
     (SELECT COUNT(*) FROM stg_raw_sales),
     (SELECT COUNT(*) FROM stg_cleaned_sales),
     (SELECT COUNT(*) FROM stg_raw_sales) - (SELECT COUNT(*) FROM stg_cleaned_sales),
     -- duplicates = difference
     (SELECT COUNT(*) FROM stg_raw_sales
      WHERE order_id IN (SELECT order_id FROM stg_raw_sales GROUP BY order_id HAVING COUNT(*) > 1)) / 2,
     -- nulls fixed: missing name + missing price
     (SELECT COUNT(*) FROM stg_cleaned_sales WHERE customer_name = 'Unknown Customer') +
     (SELECT COUNT(*) FROM stg_cleaned_sales WHERE unit_price = 0.00),
     -- date fixes
     (SELECT COUNT(*) FROM stg_raw_sales WHERE order_date LIKE '____/___'),
     0,
     'Deduplication, null filling, date normalisation, type casting, total_amount derivation.'),

    -- LOAD: dim_cities
    ('RUN-2024-ETL-001', 'LOAD', 'dim_cities',
     (SELECT COUNT(DISTINCT city) FROM stg_cleaned_sales),
     (SELECT COUNT(*) FROM dim_cities),
     0, 0, 0, 0, 0,
     'Distinct city-country combinations loaded.'),

    -- LOAD: dim_customers
    ('RUN-2024-ETL-001', 'LOAD', 'dim_customers',
     (SELECT COUNT(DISTINCT customer_email) FROM stg_cleaned_sales),
     (SELECT COUNT(*) FROM dim_customers),
     0, 0, 0, 0, 0,
     'Distinct customers loaded by unique email.'),

    -- LOAD: dim_products
    ('RUN-2024-ETL-001', 'LOAD', 'dim_products',
     (SELECT COUNT(DISTINCT product_name) FROM stg_cleaned_sales),
     (SELECT COUNT(*) FROM dim_products),
     0, 0, 0, 0, 0,
     'Distinct products with max unit_price loaded.'),

    -- LOAD: fact_orders
    ('RUN-2024-ETL-001', 'LOAD', 'fact_orders',
     (SELECT COUNT(*) FROM stg_cleaned_sales),
     (SELECT COUNT(*) FROM fact_orders),
     0, 0, 0, 0, 0,
     'Full fact table loaded with FK references to all dimensions.');

-- ── View audit log ────────────────────────────────────────────────────────────
SELECT
    log_id,
    stage,
    table_name,
    rows_processed,
    rows_inserted,
    duplicates_removed,
    nulls_fixed,
    dates_fixed,
    notes,
    run_at
FROM etl_audit_log
ORDER BY log_id;
