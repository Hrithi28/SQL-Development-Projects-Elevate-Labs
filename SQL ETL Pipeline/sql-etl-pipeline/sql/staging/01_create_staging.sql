-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 1: EXTRACT — Create Staging Tables & Load Raw Data
-- ============================================================
--  Tool: SQLite
--  Purpose: Import raw CSV into a staging table exactly as-is
--           (no cleaning yet — preserve original dirty data)
-- ============================================================

-- Drop if re-running
DROP TABLE IF EXISTS stg_raw_sales;

-- Staging table mirrors CSV columns exactly (all TEXT to accept dirty values)
CREATE TABLE stg_raw_sales (
    order_id        TEXT,
    customer_name   TEXT,
    customer_email  TEXT,
    product_name    TEXT,
    category        TEXT,
    quantity        TEXT,
    unit_price      TEXT,
    order_date      TEXT,
    city            TEXT,
    country         TEXT,
    status          TEXT,
    payment_method  TEXT,
    loaded_at       TEXT DEFAULT (datetime('now'))   -- ETL timestamp
);

-- ── In DB Browser for SQLite ─────────────────────────────────────────────────
-- File → Import → Table from CSV file → select raw_sales_data.csv
-- Table name: stg_raw_sales  |  First row = column names ✓
-- After import, the loaded_at column won't be auto-filled via CSV import;
-- run the UPDATE below to backfill it.

UPDATE stg_raw_sales SET loaded_at = datetime('now') WHERE loaded_at IS NULL;

-- ── Quick row count sanity check ─────────────────────────────────────────────
SELECT 'Rows loaded into staging' AS check_name, COUNT(*) AS row_count
FROM stg_raw_sales;

-- ── Preview first 10 rows ────────────────────────────────────────────────────
SELECT * FROM stg_raw_sales LIMIT 10;
