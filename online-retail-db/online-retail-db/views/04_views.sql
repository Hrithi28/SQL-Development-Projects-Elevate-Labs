-- ============================================================
--  VIEWS — Online Retail Sales Database
--  Reusable views for dashboards and reports
-- ============================================================

-- Drop views if they exist (safe re-run)
DROP VIEW IF EXISTS vw_sales_summary;
DROP VIEW IF EXISTS vw_product_performance;
DROP VIEW IF EXISTS vw_customer_summary;
DROP VIEW IF EXISTS vw_order_details;
DROP VIEW IF EXISTS vw_category_revenue;
DROP VIEW IF EXISTS vw_top_products;
DROP VIEW IF EXISTS vw_low_stock_alert;
DROP VIEW IF EXISTS vw_payment_summary;
DROP VIEW IF EXISTS vw_monthly_revenue;
DROP VIEW IF EXISTS vw_product_ratings;

-- ============================================================
--  VIEW 1: Full Order Details
--  Purpose: Single view combining orders + customer + payment
-- ============================================================
CREATE VIEW vw_order_details AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.customer_id,
    c.first_name || ' ' || c.last_name          AS customer_name,
    c.email,
    ci.city_name,
    s.state_name,
    COUNT(oi.order_item_id)                     AS line_items,
    SUM(oi.quantity)                            AS total_units,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2) AS order_value,
    o.shipping_fee,
    o.discount_amount,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100))
          + o.shipping_fee - o.discount_amount, 2) AS net_payable,
    COALESCE(p.payment_method, 'UNPAID')        AS payment_method,
    COALESCE(p.payment_status, 'PENDING')       AS payment_status,
    p.transaction_ref,
    o.expected_delivery,
    o.delivered_date
FROM orders o
JOIN customers c     ON o.customer_id = c.customer_id
JOIN order_items oi  ON o.order_id = oi.order_id
LEFT JOIN addresses a   ON o.shipping_address_id = a.address_id
LEFT JOIN cities ci     ON a.city_id = ci.city_id
LEFT JOIN states s      ON ci.state_id = s.state_id
LEFT JOIN payments p    ON o.order_id = p.order_id
GROUP BY
    o.order_id, o.order_date, o.order_status,
    c.customer_id, c.first_name, c.last_name, c.email,
    ci.city_name, s.state_name,
    o.shipping_fee, o.discount_amount,
    p.payment_method, p.payment_status, p.transaction_ref,
    o.expected_delivery, o.delivered_date;

-- ============================================================
--  VIEW 2: Product Performance
--  Purpose: Sales metrics per product
-- ============================================================
CREATE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    s.supplier_name,
    p.unit_price,
    p.cost_price,
    p.stock_quantity,
    p.reorder_level,
    CASE WHEN p.stock_quantity < p.reorder_level THEN 'LOW STOCK' ELSE 'OK' END AS stock_status,
    COALESCE(SUM(oi.quantity), 0)                                                AS units_sold,
    COALESCE(COUNT(DISTINCT oi.order_id), 0)                                    AS orders_count,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price
                       * (1 - oi.discount_pct / 100)), 2), 0)                   AS total_revenue,
    COALESCE(ROUND(AVG(pr.rating), 2), 0)                                       AS avg_rating,
    COALESCE(COUNT(pr.review_id), 0)                                             AS review_count
FROM products p
JOIN categories c      ON p.category_id = c.category_id
LEFT JOIN suppliers s  ON p.supplier_id = s.supplier_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o       ON oi.order_id = o.order_id
    AND o.order_status NOT IN ('CANCELLED','RETURNED')
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
WHERE p.is_active = TRUE
GROUP BY
    p.product_id, p.product_name, p.sku,
    c.category_name, s.supplier_name,
    p.unit_price, p.cost_price, p.stock_quantity, p.reorder_level;

-- ============================================================
--  VIEW 3: Customer Summary
--  Purpose: Customer overview with purchase history
-- ============================================================
CREATE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name              AS customer_name,
    c.email,
    c.phone,
    ci.city_name,
    s.state_name,
    c.loyalty_points,
    c.created_at                                    AS member_since,
    EXTRACT(YEAR FROM AGE(c.date_of_birth))         AS age,
    COALESCE(COUNT(DISTINCT o.order_id), 0)         AS total_orders,
    COALESCE(SUM(oi.quantity), 0)                   AS total_units_purchased,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price
                       * (1 - oi.discount_pct / 100)), 2), 0) AS lifetime_value,
    MAX(o.order_date)                               AS last_order_date,
    CASE
        WHEN MAX(o.order_date) > CURRENT_TIMESTAMP - INTERVAL '30 days' THEN 'Active'
        WHEN MAX(o.order_date) > CURRENT_TIMESTAMP - INTERVAL '90 days' THEN 'Lapsing'
        ELSE 'Inactive'
    END AS customer_status
FROM customers c
LEFT JOIN addresses a   ON c.customer_id = a.customer_id AND a.is_default = TRUE
LEFT JOIN cities ci     ON a.city_id = ci.city_id
LEFT JOIN states s      ON ci.state_id = s.state_id
LEFT JOIN orders o      ON c.customer_id = o.customer_id
    AND o.order_status NOT IN ('CANCELLED','RETURNED')
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email,
    c.phone, ci.city_name, s.state_name,
    c.loyalty_points, c.created_at, c.date_of_birth;

-- ============================================================
--  VIEW 4: Monthly Revenue
--  Purpose: Month-wise revenue KPIs
-- ============================================================
CREATE VIEW vw_monthly_revenue AS
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')                                 AS year_month,
    DATE_TRUNC('month', o.order_date)                                AS month_start,
    COUNT(DISTINCT o.order_id)                                       AS total_orders,
    COUNT(DISTINCT o.customer_id)                                    AS unique_customers,
    SUM(oi.quantity)                                                 AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)                     AS gross_revenue,
    ROUND(SUM(o.discount_amount), 2)                                 AS discount_given,
    ROUND(SUM(o.shipping_fee), 2)                                    AS shipping_fee_collected,
    ROUND(AVG(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)                     AS avg_order_value,
    COUNT(DISTINCT CASE WHEN o.order_status = 'CANCELLED'
                        THEN o.order_id END)                         AS cancellations
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY
    TO_CHAR(o.order_date, 'YYYY-MM'),
    DATE_TRUNC('month', o.order_date)
ORDER BY month_start;

-- ============================================================
--  VIEW 5: Category Revenue
--  Purpose: Revenue breakdown by category
-- ============================================================
CREATE VIEW vw_category_revenue AS
SELECT
    c.category_id,
    c.category_name,
    COALESCE(parent.category_name, 'Top Level')                      AS parent_category,
    COUNT(DISTINCT p.product_id)                                     AS product_count,
    COALESCE(SUM(oi.quantity), 0)                                    AS units_sold,
    COALESCE(ROUND(SUM(oi.quantity * oi.unit_price
                       * (1 - oi.discount_pct / 100)), 2), 0)        AS total_revenue,
    COALESCE(ROUND(AVG(pr.rating), 2), 0)                            AS avg_rating
FROM categories c
LEFT JOIN categories parent ON c.parent_id = parent.category_id
LEFT JOIN products p        ON c.category_id = p.category_id AND p.is_active = TRUE
LEFT JOIN order_items oi    ON p.product_id = oi.product_id
LEFT JOIN orders o          ON oi.order_id = o.order_id
    AND o.order_status NOT IN ('CANCELLED','RETURNED')
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
GROUP BY c.category_id, c.category_name, parent.category_name;

-- ============================================================
--  VIEW 6: Top Products (by revenue, this month)
--  Purpose: Quick leaderboard for dashboard
-- ============================================================
CREATE VIEW vw_top_products AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity)                                                  AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)                      AS revenue,
    ROUND(AVG(pr.rating), 2)                                          AS avg_rating,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price
                               * (1 - oi.discount_pct / 100)) DESC)   AS revenue_rank
FROM products p
JOIN categories c      ON p.category_id = c.category_id
JOIN order_items oi    ON p.product_id = oi.product_id
JOIN orders o          ON oi.order_id = o.order_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
WHERE o.order_status NOT IN ('CANCELLED','RETURNED')
GROUP BY p.product_id, p.product_name, c.category_name;

-- ============================================================
--  VIEW 7: Low Stock Alert
--  Purpose: Products needing restock
-- ============================================================
CREATE VIEW vw_low_stock_alert AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    s.supplier_name,
    s.contact_email                           AS supplier_email,
    p.stock_quantity                          AS current_stock,
    p.reorder_level,
    (p.reorder_level - p.stock_quantity)      AS units_to_reorder,
    CASE
        WHEN p.stock_quantity = 0             THEN 'OUT OF STOCK'
        WHEN p.stock_quantity < p.reorder_level THEN 'LOW STOCK'
        ELSE 'ADEQUATE'
    END AS alert_level
FROM products p
JOIN categories c     ON p.category_id = c.category_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
WHERE p.stock_quantity <= p.reorder_level
AND p.is_active = TRUE
ORDER BY alert_level, units_to_reorder DESC;

-- ============================================================
--  VIEW 8: Payment Summary
-- ============================================================
CREATE VIEW vw_payment_summary AS
SELECT
    payment_method,
    payment_status,
    COUNT(*)                      AS transaction_count,
    ROUND(SUM(amount), 2)         AS total_amount,
    ROUND(AVG(amount), 2)         AS avg_transaction
FROM payments
GROUP BY payment_method, payment_status;

-- ============================================================
--  VIEW 9: Sales Summary KPIs (top-level dashboard)
-- ============================================================
CREATE VIEW vw_sales_summary AS
SELECT
    COUNT(DISTINCT o.order_id)                                       AS total_orders,
    COUNT(DISTINCT o.customer_id)                                    AS total_customers,
    COUNT(DISTINCT p.product_id)                                     AS products_sold,
    SUM(oi.quantity)                                                 AS total_units,
    ROUND(SUM(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)                     AS gross_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price
              * (1 - oi.discount_pct / 100)), 2)                     AS avg_order_value,
    COUNT(DISTINCT CASE WHEN o.order_status = 'DELIVERED'
                        THEN o.order_id END)                         AS delivered_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'CANCELLED'
                        THEN o.order_id END)                         AS cancelled_orders,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.order_status = 'CANCELLED'
                        THEN o.order_id END) /
          COUNT(DISTINCT o.order_id), 2)                             AS cancellation_rate_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id;

-- ============================================================
--  VIEW 10: Product Ratings Summary
-- ============================================================
CREATE VIEW vw_product_ratings AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(pr.review_id)                           AS review_count,
    ROUND(AVG(pr.rating), 2)                      AS avg_rating,
    SUM(CASE WHEN pr.rating = 5 THEN 1 ELSE 0 END) AS five_star,
    SUM(CASE WHEN pr.rating = 4 THEN 1 ELSE 0 END) AS four_star,
    SUM(CASE WHEN pr.rating = 3 THEN 1 ELSE 0 END) AS three_star,
    SUM(CASE WHEN pr.rating = 2 THEN 1 ELSE 0 END) AS two_star,
    SUM(CASE WHEN pr.rating = 1 THEN 1 ELSE 0 END) AS one_star
FROM product_reviews pr
JOIN products p   ON pr.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY avg_rating DESC, review_count DESC;
