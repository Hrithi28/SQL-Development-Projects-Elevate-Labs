-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 8: REPORTS — Analytical Queries on Production Tables
-- ============================================================

-- ════════════════════════════════════════════════════════════
--  REPORT 1: Monthly Revenue Summary
-- ════════════════════════════════════════════════════════════
SELECT
    f.order_month,
    COUNT(f.order_id)                           AS total_orders,
    SUM(f.quantity)                             AS total_units_sold,
    ROUND(SUM(f.total_amount), 2)               AS gross_revenue,
    ROUND(SUM(CASE WHEN f.is_revenue = 1
                   THEN f.total_amount ELSE 0 END), 2) AS net_revenue,
    COUNT(CASE WHEN f.status = 'returned'  THEN 1 END) AS returns,
    COUNT(CASE WHEN f.status = 'pending'   THEN 1 END) AS pending_orders
FROM fact_orders f
GROUP BY f.order_month
ORDER BY f.order_month;

-- ════════════════════════════════════════════════════════════
--  REPORT 2: Category-wise Sales Performance
-- ════════════════════════════════════════════════════════════
SELECT
    p.category,
    COUNT(f.order_id)               AS total_orders,
    SUM(f.quantity)                 AS total_units,
    ROUND(SUM(f.total_amount), 2)  AS total_revenue,
    ROUND(AVG(f.unit_price), 2)    AS avg_unit_price,
    ROUND(AVG(f.total_amount), 2)  AS avg_order_value
FROM fact_orders f
JOIN dim_products p ON p.product_id = f.product_id
WHERE f.is_revenue = 1
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ════════════════════════════════════════════════════════════
--  REPORT 3: Top 10 Best-Selling Products
-- ════════════════════════════════════════════════════════════
SELECT
    p.product_name,
    p.category,
    COUNT(f.order_id)              AS orders,
    SUM(f.quantity)                AS units_sold,
    ROUND(SUM(f.total_amount), 2) AS revenue,
    RANK() OVER (ORDER BY SUM(f.total_amount) DESC) AS revenue_rank
FROM fact_orders f
JOIN dim_products p ON p.product_id = f.product_id
WHERE f.is_revenue = 1
GROUP BY f.product_id
ORDER BY revenue DESC
LIMIT 10;

-- ════════════════════════════════════════════════════════════
--  REPORT 4: City-wise Revenue Distribution
-- ════════════════════════════════════════════════════════════
SELECT
    ci.city_name,
    COUNT(f.order_id)              AS total_orders,
    ROUND(SUM(f.total_amount), 2) AS revenue,
    ROUND(100.0 * SUM(f.total_amount) /
          SUM(SUM(f.total_amount)) OVER (), 2) AS revenue_pct
FROM fact_orders f
JOIN dim_cities ci ON ci.city_id = f.city_id
WHERE f.is_revenue = 1
GROUP BY ci.city_id
ORDER BY revenue DESC;

-- ════════════════════════════════════════════════════════════
--  REPORT 5: Payment Method Breakdown
-- ════════════════════════════════════════════════════════════
SELECT
    payment_method,
    COUNT(*)                        AS transactions,
    ROUND(SUM(total_amount), 2)    AS total_revenue,
    ROUND(AVG(total_amount), 2)    AS avg_order_value,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank
FROM fact_orders
WHERE is_revenue = 1
GROUP BY payment_method
ORDER BY transactions DESC;

-- ════════════════════════════════════════════════════════════
--  REPORT 6: Order Status Distribution
-- ════════════════════════════════════════════════════════════
SELECT
    status,
    COUNT(*)                            AS order_count,
    ROUND(SUM(total_amount), 2)        AS value,
    ROUND(100.0 * COUNT(*) /
          (SELECT COUNT(*) FROM fact_orders), 2) AS pct_of_total
FROM fact_orders
GROUP BY status
ORDER BY order_count DESC;

-- ════════════════════════════════════════════════════════════
--  REPORT 7: Running Revenue Total (Window Function)
-- ════════════════════════════════════════════════════════════
SELECT
    order_month,
    ROUND(SUM(total_amount), 2)  AS monthly_revenue,
    ROUND(SUM(SUM(total_amount))
          OVER (ORDER BY order_month), 2) AS running_total
FROM fact_orders
WHERE is_revenue = 1
GROUP BY order_month
ORDER BY order_month;

-- ════════════════════════════════════════════════════════════
--  REPORT 8: Customer Spend Ranking (Top 10)
-- ════════════════════════════════════════════════════════════
SELECT
    cu.customer_name,
    cu.customer_email,
    COUNT(f.order_id)              AS total_orders,
    ROUND(SUM(f.total_amount), 2) AS total_spent,
    DENSE_RANK() OVER (ORDER BY SUM(f.total_amount) DESC) AS spend_rank
FROM fact_orders f
JOIN dim_customers cu ON cu.customer_id = f.customer_id
WHERE f.is_revenue = 1
GROUP BY f.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- ════════════════════════════════════════════════════════════
--  REPORT 9: ETL Pipeline Summary (from Audit Log)
-- ════════════════════════════════════════════════════════════
SELECT
    stage,
    table_name,
    rows_processed,
    rows_inserted,
    duplicates_removed,
    nulls_fixed,
    dates_fixed,
    run_at
FROM etl_audit_log
ORDER BY log_id;

-- ════════════════════════════════════════════════════════════
--  REPORT 10: Full Order Detail View (joined production tables)
-- ════════════════════════════════════════════════════════════
SELECT
    f.order_id,
    cu.customer_name,
    p.product_name,
    p.category,
    f.quantity,
    f.unit_price,
    f.total_amount,
    f.order_date,
    ci.city_name,
    f.status,
    f.payment_method
FROM fact_orders f
JOIN dim_customers cu ON cu.customer_id = f.customer_id
JOIN dim_products  p  ON p.product_id   = f.product_id
JOIN dim_cities    ci ON ci.city_id     = f.city_id
ORDER BY f.order_date
LIMIT 20;
