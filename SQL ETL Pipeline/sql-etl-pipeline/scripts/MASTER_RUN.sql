-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  MASTER RUN SCRIPT — Execute in this exact order
-- ============================================================
--  Paste each file's content or use DB Browser's "Execute SQL"
--  tab to run files one by one in the order listed below.
-- ============================================================

-- ─── ORDER OF EXECUTION ───────────────────────────────────────────────────────
--
--  STEP 1 │ sql/staging/01_create_staging.sql
--          │ → Create stg_raw_sales, import CSV, verify row count
--          │
--  STEP 2 │ sql/staging/02_profile_data.sql
--          │ → Profile data quality issues (run but don't fix yet)
--          │
--  STEP 3 │ sql/transform/03_clean_transform.sql
--          │ → Create stg_cleaned_sales with all fixes applied
--          │
--  STEP 4 │ sql/production/04_create_production_schema.sql
--          │ → Create dim_* tables + fact_orders + indexes
--          │
--  STEP 5 │ sql/production/05_load_production.sql
--          │ → Populate all production tables from cleaned staging
--          │
--  STEP 6 │ sql/audit/06_audit_log.sql
--          │ → Create etl_audit_log, insert ETL run summary
--          │
--  STEP 7 │ sql/triggers/07_triggers.sql
--          │ → Create 4 triggers: insert log, validation, status history, staging audit
--          │
--  STEP 8 │ sql/production/08_analytical_reports.sql
--          │ → Run all 10 analytical report queries
--          │
--  STEP 9 │ sql/production/09_views.sql
--          │ → Create 5 reusable views for ongoing reporting
--
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Quick health check (run after full pipeline completes) ────────────────────
SELECT '=== ETL PIPELINE HEALTH CHECK ===' AS section;

SELECT 'stg_raw_sales (raw)'       AS layer, COUNT(*) AS rows FROM stg_raw_sales    UNION ALL
SELECT 'stg_cleaned_sales (clean)',           COUNT(*)         FROM stg_cleaned_sales UNION ALL
SELECT 'dim_customers',                       COUNT(*)         FROM dim_customers     UNION ALL
SELECT 'dim_products',                        COUNT(*)         FROM dim_products      UNION ALL
SELECT 'dim_cities',                          COUNT(*)         FROM dim_cities        UNION ALL
SELECT 'fact_orders (production)',            COUNT(*)         FROM fact_orders       UNION ALL
SELECT 'etl_audit_log entries',               COUNT(*)         FROM etl_audit_log     UNION ALL
SELECT 'fact_orders_insert_log',              COUNT(*)         FROM fact_orders_insert_log UNION ALL
SELECT 'order_status_history',                COUNT(*)         FROM order_status_history;

SELECT '=== PIPELINE COMPLETE ===' AS status;
