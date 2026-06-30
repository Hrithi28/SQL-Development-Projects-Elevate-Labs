-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 9: VIEWS — Reusable Report Views
-- ============================================================

-- ── View 1: Full order detail (flat, denormalised) ────────────────────────────
DROP VIEW IF EXISTS vw_order_detail;
CREATE VIEW vw_order_detail AS
SELECT
    f.order_id,
    cu.customer_name,
    cu.customer_email,
    p.product_name,
    p.category,
    f.quantity,
    f.unit_price,
    f.total_amount,
    f.order_date,
    f.order_month,
    ci.city_name     AS city,
    f.status,
    f.payment_method,
    f.is_revenue
FROM fact_orders f
JOIN dim_customers cu ON cu.customer_id = f.customer_id
JOIN dim_products  p  ON p.product_id   = f.product_id
JOIN dim_cities    ci ON ci.city_id     = f.city_id;

-- ── View 2: Monthly revenue summary ──────────────────────────────────────────
DROP VIEW IF EXISTS vw_monthly_revenue;
CREATE VIEW vw_monthly_revenue AS
SELECT
    order_month,
    COUNT(order_id)                                  AS total_orders,
    ROUND(SUM(total_amount), 2)                     AS gross_revenue,
    ROUND(SUM(CASE WHEN is_revenue = 1
                   THEN total_amount ELSE 0 END), 2) AS net_revenue,
    COUNT(CASE WHEN status = 'returned' THEN 1 END) AS returns
FROM fact_orders
GROUP BY order_month
ORDER BY order_month;

-- ── View 3: Category performance ─────────────────────────────────────────────
DROP VIEW IF EXISTS vw_category_performance;
CREATE VIEW vw_category_performance AS
SELECT
    p.category,
    COUNT(f.order_id)              AS total_orders,
    SUM(f.quantity)                AS units_sold,
    ROUND(SUM(f.total_amount), 2) AS revenue
FROM fact_orders f
JOIN dim_products p ON p.product_id = f.product_id
WHERE f.is_revenue = 1
GROUP BY p.category
ORDER BY revenue DESC;

-- ── View 4: City revenue leaderboard ─────────────────────────────────────────
DROP VIEW IF EXISTS vw_city_revenue;
CREATE VIEW vw_city_revenue AS
SELECT
    ci.city_name,
    COUNT(f.order_id)              AS orders,
    ROUND(SUM(f.total_amount), 2) AS revenue
FROM fact_orders f
JOIN dim_cities ci ON ci.city_id = f.city_id
WHERE f.is_revenue = 1
GROUP BY ci.city_id
ORDER BY revenue DESC;

-- ── View 5: ETL pipeline health ───────────────────────────────────────────────
DROP VIEW IF EXISTS vw_etl_health;
CREATE VIEW vw_etl_health AS
SELECT
    pipeline_run_id,
    stage,
    table_name,
    rows_processed,
    rows_inserted,
    duplicates_removed,
    nulls_fixed,
    dates_fixed,
    CASE WHEN errors = 0 THEN 'PASS' ELSE 'FAIL' END AS health_status,
    run_at
FROM etl_audit_log;

-- ── Confirm views ─────────────────────────────────────────────────────────────
SELECT name AS view_name FROM sqlite_master WHERE type = 'view' ORDER BY name;

-- ── Quick test queries ────────────────────────────────────────────────────────
SELECT * FROM vw_monthly_revenue;
SELECT * FROM vw_category_performance;
SELECT * FROM vw_city_revenue;
SELECT * FROM vw_etl_health;
