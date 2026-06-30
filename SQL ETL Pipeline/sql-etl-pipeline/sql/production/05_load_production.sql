-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 5: LOAD — Populate Production from Cleaned Staging
-- ============================================================
--  Inserts flow: cleaned staging → dims → fact (FK-safe order)
-- ============================================================

-- ── 1. Load dim_cities ────────────────────────────────────────────────────────
INSERT OR IGNORE INTO dim_cities (city_name, country)
SELECT DISTINCT city, country
FROM stg_cleaned_sales
ORDER BY city;

-- ── 2. Load dim_customers ─────────────────────────────────────────────────────
INSERT OR IGNORE INTO dim_customers (customer_name, customer_email)
SELECT DISTINCT customer_name, customer_email
FROM stg_cleaned_sales
ORDER BY customer_name;

-- ── 3. Load dim_products ──────────────────────────────────────────────────────
-- Use the max unit_price per product (in case same product appeared at diff price)
INSERT OR IGNORE INTO dim_products (product_name, category, unit_price)
SELECT
    product_name,
    category,
    MAX(unit_price) AS unit_price
FROM stg_cleaned_sales
GROUP BY product_name, category
ORDER BY product_name;

-- ── 4. Load fact_orders ───────────────────────────────────────────────────────
INSERT OR IGNORE INTO fact_orders
    (order_id, customer_id, product_id, city_id,
     quantity, unit_price, total_amount,
     order_date, order_month, status, payment_method, is_revenue)
SELECT
    c.order_id,
    cu.customer_id,
    p.product_id,
    ci.city_id,
    c.quantity,
    c.unit_price,
    c.total_amount,
    c.order_date,
    c.order_month,
    c.status,
    c.payment_method,
    c.is_revenue
FROM stg_cleaned_sales c
JOIN dim_customers cu ON cu.customer_email = c.customer_email
JOIN dim_products  p  ON p.product_name    = c.product_name
JOIN dim_cities    ci ON ci.city_name      = c.city;

-- ── Verification ──────────────────────────────────────────────────────────────
SELECT 'dim_cities rows'    AS table_name, COUNT(*) AS rows FROM dim_cities    UNION ALL
SELECT 'dim_customers rows',               COUNT(*)          FROM dim_customers UNION ALL
SELECT 'dim_products rows',                COUNT(*)          FROM dim_products  UNION ALL
SELECT 'fact_orders rows',                 COUNT(*)          FROM fact_orders;

-- Row count must match stg_cleaned_sales
SELECT 'Staging cleaned rows', COUNT(*) FROM stg_cleaned_sales
UNION ALL
SELECT 'Production fact rows',  COUNT(*) FROM fact_orders;
