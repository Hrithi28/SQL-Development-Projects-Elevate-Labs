-- ============================================================
--  ANALYTICAL QUERIES — Online Retail Sales Database
--  Covers: JOINs, subqueries, CTEs, window functions,
--          aggregates, GROUP BY, HAVING, date filters
-- ============================================================

-- ============================================================
--  SECTION 1: BASIC SELECT & FILTER QUERIES
-- ============================================================

-- Q1. List all active products with category name
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.unit_price,
    p.stock_quantity,
    p.discount_pct
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = TRUE
ORDER BY c.category_name, p.product_name;

-- Q2. Get all orders placed in Q1 2024 (Jan–Mar)
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.order_status,
    o.shipping_fee,
    o.discount_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY o.order_date;

-- Q3. Find all customers from Tamil Nadu
SELECT
    cu.customer_id,
    cu.first_name || ' ' || cu.last_name AS customer_name,
    cu.email,
    ci.city_name,
    s.state_name
FROM customers cu
JOIN addresses a  ON cu.customer_id = a.customer_id AND a.is_default = TRUE
JOIN cities ci    ON a.city_id = ci.city_id
JOIN states s     ON ci.state_id = s.state_id
WHERE s.state_name = 'Tamil Nadu';

-- Q4. Products low on stock (below reorder level)
SELECT
    product_id,
    product_name,
    sku,
    stock_quantity,
    reorder_level,
    (reorder_level - stock_quantity) AS units_to_reorder
FROM products
WHERE stock_quantity < reorder_level AND is_active = TRUE
ORDER BY units_to_reorder DESC;

-- Q5. Orders with CANCELLED or RETURNED status
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.order_status,
    p.payment_status
FROM orders o
JOIN customers c  ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE o.order_status IN ('CANCELLED', 'RETURNED')
ORDER BY o.order_date;

-- ============================================================
--  SECTION 2: AGGREGATE & GROUP BY QUERIES
-- ============================================================

-- Q6. Total revenue, orders, and average order value by month
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')              AS month,
    COUNT(DISTINCT o.order_id)                    AS total_orders,
    SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100))            AS gross_revenue,
    SUM(o.discount_amount)                        AS total_discounts,
    SUM(o.shipping_fee)                           AS shipping_collected,
    ROUND(AVG(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100)), 2)        AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'RETURNED')
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

-- Q7. Revenue by product category
SELECT
    c.category_name,
    COUNT(DISTINCT oi.order_id)                           AS orders_count,
    SUM(oi.quantity)                                      AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)          AS total_revenue,
    ROUND(AVG(oi.unit_price), 2)                          AS avg_unit_price
FROM order_items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN categories c   ON p.category_id = c.category_id
JOIN orders o       ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'RETURNED')
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Q8. Top 10 best-selling products by units sold
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    SUM(oi.quantity)                                      AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)          AS revenue_generated
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o     ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'RETURNED')
GROUP BY p.product_id, p.product_name, p.sku, c.category_name
ORDER BY units_sold DESC
LIMIT 10;

-- Q9. Top 10 customers by total spend
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name                   AS customer_name,
    c.email,
    COUNT(DISTINCT o.order_id)                           AS total_orders,
    SUM(oi.quantity * oi.unit_price
        * (1 - oi.discount_pct / 100))                   AS total_spend,
    c.loyalty_points
FROM customers c
JOIN orders o     ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'RETURNED')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.loyalty_points
ORDER BY total_spend DESC
LIMIT 10;

-- Q10. Customers who placed more than 1 order (repeat buyers)
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id)                  AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;

-- Q11. Payment method distribution
SELECT
    payment_method,
    COUNT(*)                                  AS total_transactions,
    ROUND(SUM(amount), 2)                     AS total_amount,
    ROUND(100.0 * COUNT(*) /
          SUM(COUNT(*)) OVER (), 2)           AS percentage_share
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY payment_method
ORDER BY total_transactions DESC;

-- Q12. Average product rating by category
SELECT
    c.category_name,
    COUNT(pr.review_id)           AS total_reviews,
    ROUND(AVG(pr.rating), 2)      AS avg_rating,
    SUM(CASE WHEN pr.rating = 5 THEN 1 ELSE 0 END) AS five_star_reviews
FROM product_reviews pr
JOIN products p   ON pr.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_rating DESC;

-- Q13. Supplier-wise product count and average price
SELECT
    s.supplier_name,
    COUNT(p.product_id)           AS product_count,
    ROUND(AVG(p.unit_price), 2)   AS avg_unit_price,
    SUM(p.stock_quantity)         AS total_stock
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
WHERE p.is_active = TRUE
GROUP BY s.supplier_name
ORDER BY product_count DESC;

-- Q14. Daily order volume trend (last 30 days of data)
SELECT
    DATE(order_date)              AS order_day,
    COUNT(order_id)               AS orders_placed,
    COUNT(CASE WHEN order_status = 'DELIVERED' THEN 1 END) AS delivered,
    COUNT(CASE WHEN order_status = 'CANCELLED' THEN 1 END) AS cancelled
FROM orders
GROUP BY DATE(order_date)
ORDER BY order_day;

-- ============================================================
--  SECTION 3: MULTI-TABLE JOIN QUERIES
-- ============================================================

-- Q15. Complete order summary with all details (3-table join)
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name                       AS customer_name,
    ci.city_name,
    s.state_name,
    o.order_date,
    o.order_status,
    COUNT(oi.order_item_id)                                   AS items_count,
    SUM(oi.quantity)                                          AS total_units,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)              AS order_value,
    o.shipping_fee,
    COALESCE(p.payment_method, 'NOT PAID')                    AS payment_method,
    COALESCE(p.payment_status, 'PENDING')                     AS payment_status
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN addresses a  ON o.shipping_address_id = a.address_id
LEFT JOIN cities ci    ON a.city_id = ci.city_id
LEFT JOIN states s     ON ci.state_id = s.state_id
LEFT JOIN payments p   ON o.order_id = p.order_id
GROUP BY o.order_id, c.first_name, c.last_name, ci.city_name,
         s.state_name, o.order_date, o.order_status,
         o.shipping_fee, p.payment_method, p.payment_status
ORDER BY o.order_date;

-- Q16. Products never ordered
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.unit_price,
    p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.product_id NOT IN (
    SELECT DISTINCT product_id FROM order_items
)
AND p.is_active = TRUE;

-- Q17. Customers who have never ordered
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.created_at
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q18. Items in an order with full product detail
SELECT
    oi.order_id,
    p.product_name,
    p.sku,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct,
    ROUND(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100), 2) AS line_total
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE oi.order_id = 31  -- change order_id as needed
ORDER BY line_total DESC;

-- ============================================================
--  SECTION 4: SUBQUERIES
-- ============================================================

-- Q19. Products priced above category average
SELECT
    p.product_name,
    c.category_name,
    p.unit_price,
    ROUND(cat_avg.avg_price, 2) AS category_avg_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN (
    SELECT category_id, AVG(unit_price) AS avg_price
    FROM products
    WHERE is_active = TRUE
    GROUP BY category_id
) cat_avg ON p.category_id = cat_avg.category_id
WHERE p.unit_price > cat_avg.avg_price
ORDER BY c.category_name, p.unit_price DESC;

-- Q20. Customers whose total spend exceeds the overall average spend
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS total_spend
FROM customers c
JOIN orders o     ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) >
    (
        SELECT AVG(customer_total) FROM (
            SELECT SUM(oi2.quantity * oi2.unit_price * (1 - oi2.discount_pct/100)) AS customer_total
            FROM orders o2
            JOIN order_items oi2 ON o2.order_id = oi2.order_id
            WHERE o2.order_status NOT IN ('CANCELLED','RETURNED')
            GROUP BY o2.customer_id
        ) AS avg_sub
    )
ORDER BY total_spend DESC;

-- Q21. Most expensive product in each category (correlated subquery)
SELECT
    p.product_name,
    c.category_name,
    p.unit_price
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.unit_price = (
    SELECT MAX(p2.unit_price)
    FROM products p2
    WHERE p2.category_id = p.category_id
    AND p2.is_active = TRUE
)
ORDER BY p.unit_price DESC;

-- ============================================================
--  SECTION 5: WINDOW FUNCTIONS
-- ============================================================

-- Q22. Revenue rank of products using RANK()
SELECT
    p.product_name,
    c.category_name,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) DESC) AS row_num
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o     ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
GROUP BY p.product_name, c.category_name;

-- Q23. Top 3 products per category by revenue (PARTITION BY)
SELECT * FROM (
    SELECT
        c.category_name,
        p.product_name,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS revenue,
        RANK() OVER (
            PARTITION BY c.category_name
            ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) DESC
        ) AS rank_in_category
    FROM order_items oi
    JOIN products p   ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    JOIN orders o     ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY c.category_name, p.product_name
) ranked
WHERE rank_in_category <= 3
ORDER BY category_name, rank_in_category;

-- Q24. Running total of revenue by month
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS monthly_revenue,
    ROUND(SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)))
          OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')), 2) AS running_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY month;

-- Q25. Customer purchase frequency and spend percentile
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(DISTINCT o.order_id)         AS order_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS total_spend,
    NTILE(4) OVER (ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100))) AS spend_quartile,
    ROUND(PERCENT_RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100))
    ) * 100, 1) AS spend_percentile
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spend DESC;

-- Q26. Month-over-month revenue growth
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
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS revenue_change,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS growth_pct
FROM monthly
ORDER BY month;

-- ============================================================
--  SECTION 6: CTEs (Common Table Expressions)
-- ============================================================

-- Q27. CTE: RFM (Recency, Frequency, Monetary) Analysis
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
        EXTRACT(DAY FROM CURRENT_TIMESTAMP - last_order_date) AS recency_days,
        NTILE(5) OVER (ORDER BY last_order_date DESC)         AS recency_score,
        NTILE(5) OVER (ORDER BY frequency)                    AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary)                     AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_id,
    customer_name,
    ROUND(recency_days) AS days_since_last_order,
    frequency          AS total_orders,
    ROUND(monetary, 2) AS total_spend,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 13 THEN 'Champions'
        WHEN (recency_score + frequency_score + monetary_score) >= 10 THEN 'Loyal Customers'
        WHEN (recency_score + frequency_score + monetary_score) >= 7  THEN 'Potential Loyalists'
        WHEN recency_score <= 2 THEN 'At Risk'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_scored
ORDER BY rfm_total DESC;

-- Q28. CTE: Category revenue share
WITH category_revenue AS (
    SELECT
        c.category_name,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS revenue
    FROM order_items oi
    JOIN products p   ON oi.product_id = p.product_id
    JOIN categories c ON p.category_id = c.category_id
    JOIN orders o     ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY c.category_name
),
total AS (
    SELECT SUM(revenue) AS grand_total FROM category_revenue
)
SELECT
    cr.category_name,
    ROUND(cr.revenue, 2)                                AS category_revenue,
    ROUND(100.0 * cr.revenue / t.grand_total, 2)        AS revenue_share_pct,
    ROUND(SUM(cr.revenue) OVER (ORDER BY cr.revenue DESC), 2) AS cumulative_revenue
FROM category_revenue cr, total t
ORDER BY cr.revenue DESC;

-- Q29. CTE: Identify high-value orders (above 90th percentile)
WITH order_totals AS (
    SELECT
        o.order_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        o.order_date,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS order_value
    FROM orders o
    JOIN customers c    ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY o.order_id, c.first_name, c.last_name, o.order_date
),
percentile_90 AS (
    SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY order_value) AS p90
    FROM order_totals
)
SELECT
    ot.order_id,
    ot.customer_name,
    ot.order_date,
    ROUND(ot.order_value, 2) AS order_value,
    ROUND(p.p90, 2)          AS p90_threshold
FROM order_totals ot, percentile_90 p
WHERE ot.order_value >= p.p90
ORDER BY ot.order_value DESC;

-- ============================================================
--  SECTION 7: SALES REPORT QUERIES
-- ============================================================

-- Q30. Monthly sales summary dashboard
SELECT
    TO_CHAR(o.order_date, 'Month YYYY')                          AS month,
    COUNT(DISTINCT o.customer_id)                                AS unique_customers,
    COUNT(DISTINCT o.order_id)                                   AS total_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'DELIVERED' THEN o.order_id END) AS delivered_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'CANCELLED' THEN o.order_id END) AS cancelled_orders,
    SUM(oi.quantity)                                             AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS gross_revenue,
    ROUND(SUM(o.discount_amount), 2)                             AS total_discounts,
    ROUND(SUM(o.shipping_fee), 2)                                AS shipping_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_date, 'Month YYYY'), DATE_TRUNC('month', o.order_date)
ORDER BY DATE_TRUNC('month', o.order_date);

-- Q31. Product profitability analysis
SELECT
    p.product_name,
    c.category_name,
    p.unit_price,
    p.cost_price,
    ROUND(p.unit_price - p.cost_price, 2)                     AS unit_margin,
    ROUND(100.0 * (p.unit_price - p.cost_price) / p.unit_price, 1) AS margin_pct,
    SUM(oi.quantity)                                           AS units_sold,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct/100) - p.cost_price)), 2) AS total_profit
FROM products p
JOIN categories c   ON p.category_id = c.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o       ON oi.order_id = o.order_id
    AND o.order_status NOT IN ('CANCELLED','RETURNED')
WHERE p.cost_price IS NOT NULL
GROUP BY p.product_id, p.product_name, c.category_name, p.unit_price, p.cost_price
ORDER BY total_profit DESC NULLS LAST;

-- Q32. Customer lifetime value summary
SELECT
    CASE
        WHEN total_orders = 1               THEN '1 order (one-time)'
        WHEN total_orders BETWEEN 2 AND 3   THEN '2-3 orders (occasional)'
        WHEN total_orders > 3               THEN '4+ orders (loyal)'
    END                                           AS customer_type,
    COUNT(*)                                      AS customer_count,
    ROUND(AVG(total_spend), 2)                    AS avg_lifetime_value,
    ROUND(SUM(total_spend), 2)                    AS segment_revenue
FROM (
    SELECT
        c.customer_id,
        COUNT(DISTINCT o.order_id)               AS total_orders,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)) AS total_spend
    FROM customers c
    JOIN orders o       ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
    GROUP BY c.customer_id
) clt
GROUP BY customer_type
ORDER BY avg_lifetime_value DESC;
