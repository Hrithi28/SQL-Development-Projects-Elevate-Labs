-- ============================================================
--  QUERY REPORT — Online Retail Sales Database
--  Run these queries after loading schema + data + views
--  to validate and view results
-- ============================================================

-- ============================================================
--  REPORT 1: DATABASE OVERVIEW
-- ============================================================

-- Total records in each table
SELECT 'countries'      AS table_name, COUNT(*) AS record_count FROM countries
UNION ALL SELECT 'states',        COUNT(*) FROM states
UNION ALL SELECT 'cities',        COUNT(*) FROM cities
UNION ALL SELECT 'categories',    COUNT(*) FROM categories
UNION ALL SELECT 'suppliers',     COUNT(*) FROM suppliers
UNION ALL SELECT 'products',      COUNT(*) FROM products
UNION ALL SELECT 'customers',     COUNT(*) FROM customers
UNION ALL SELECT 'addresses',     COUNT(*) FROM addresses
UNION ALL SELECT 'orders',        COUNT(*) FROM orders
UNION ALL SELECT 'order_items',   COUNT(*) FROM order_items
UNION ALL SELECT 'payments',      COUNT(*) FROM payments
UNION ALL SELECT 'product_reviews', COUNT(*) FROM product_reviews
ORDER BY table_name;

-- ============================================================
--  REPORT 2: SALES KPI DASHBOARD
-- ============================================================

SELECT * FROM vw_sales_summary;

-- ============================================================
--  REPORT 3: MONTHLY REVENUE BREAKDOWN
-- ============================================================

SELECT * FROM vw_monthly_revenue ORDER BY month_start;

-- ============================================================
--  REPORT 4: TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    revenue_rank,
    product_name,
    category_name,
    units_sold,
    revenue,
    avg_rating
FROM vw_top_products
WHERE revenue_rank <= 10
ORDER BY revenue_rank;

-- ============================================================
--  REPORT 5: CATEGORY REVENUE SHARE
-- ============================================================

SELECT
    category_name,
    parent_category,
    product_count,
    units_sold,
    total_revenue,
    ROUND(100.0 * total_revenue /
          NULLIF(SUM(total_revenue) OVER (), 0), 2) AS revenue_share_pct
FROM vw_category_revenue
ORDER BY total_revenue DESC;

-- ============================================================
--  REPORT 6: TOP 10 CUSTOMERS BY LIFETIME VALUE
-- ============================================================

SELECT
    customer_id,
    customer_name,
    city_name,
    total_orders,
    lifetime_value,
    loyalty_points,
    customer_status
FROM vw_customer_summary
ORDER BY lifetime_value DESC
LIMIT 10;

-- ============================================================
--  REPORT 7: PRODUCT PERFORMANCE OVERVIEW
-- ============================================================

SELECT
    product_name,
    category_name,
    units_sold,
    total_revenue,
    avg_rating,
    stock_status
FROM vw_product_performance
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================================
--  REPORT 8: LOW STOCK ALERTS
-- ============================================================

SELECT * FROM vw_low_stock_alert;

-- ============================================================
--  REPORT 9: PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT * FROM vw_payment_summary
ORDER BY payment_method, payment_status;

-- ============================================================
--  REPORT 10: PRODUCT RATINGS LEADERBOARD
-- ============================================================

SELECT * FROM vw_product_ratings
WHERE review_count > 0
ORDER BY avg_rating DESC, review_count DESC;

-- ============================================================
--  REPORT 11: ORDER STATUS DISTRIBUTION
-- ============================================================

SELECT
    order_status,
    COUNT(*)                                   AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- ============================================================
--  REPORT 12: CITY-WISE CUSTOMER DISTRIBUTION
-- ============================================================

SELECT
    ci.city_name,
    s.state_name,
    COUNT(a.customer_id)    AS customer_count
FROM addresses a
JOIN cities ci ON a.city_id = ci.city_id
JOIN states s  ON ci.state_id = s.state_id
WHERE a.is_default = TRUE
GROUP BY ci.city_name, s.state_name
ORDER BY customer_count DESC;

-- ============================================================
--  REPORT 13: STORED FUNCTION DEMOS
-- ============================================================

-- Get full order total breakdown for order #31
SELECT * FROM fn_get_order_total(31);

-- View all orders for customer #5
SELECT * FROM fn_customer_history(5);

-- Full 2024 monthly revenue report
SELECT * FROM fn_monthly_revenue_report(2024);

-- ============================================================
--  REPORT 14: RFM CUSTOMER SEGMENTS
-- ============================================================

WITH customer_rfm AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        MAX(o.order_date)                   AS last_order_date,
        COUNT(DISTINCT o.order_id)          AS frequency,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS monetary
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY c.customer_id, c.first_name, c.last_name
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY last_order_date DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency)            AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary)             AS monetary_score
    FROM customer_rfm
)
SELECT
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 13 THEN 'Champions'
        WHEN (recency_score + frequency_score + monetary_score) >= 10 THEN 'Loyal Customers'
        WHEN (recency_score + frequency_score + monetary_score) >= 7  THEN 'Potential Loyalists'
        WHEN recency_score <= 2                                        THEN 'At Risk'
        ELSE 'Needs Attention'
    END                           AS segment,
    COUNT(*)                      AS customer_count,
    ROUND(AVG(monetary), 2)       AS avg_spend,
    ROUND(SUM(monetary), 2)       AS segment_revenue
FROM rfm_scored
GROUP BY 1
ORDER BY avg_spend DESC;

-- ============================================================
--  REPORT 15: MONTH-OVER-MONTH GROWTH
-- ============================================================

WITH monthly AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM') AS month,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT
    month,
    ROUND(revenue, 2)                                           AS monthly_revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2)               AS prev_month,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2)     AS change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1)  AS growth_pct
FROM monthly
ORDER BY month;
