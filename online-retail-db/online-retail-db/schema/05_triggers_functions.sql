-- ============================================================
--  TRIGGERS & FUNCTIONS — Online Retail Sales Database
--  PostgreSQL syntax
-- ============================================================

-- ============================================================
--  FUNCTION 1: Update updated_at timestamp automatically
-- ============================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach to customers
CREATE TRIGGER trg_customers_updated_at
BEFORE UPDATE ON customers
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- Attach to products
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ============================================================
--  FUNCTION 2: Decrease stock when order item is inserted
-- ============================================================
CREATE OR REPLACE FUNCTION fn_decrease_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Check stock availability
    IF (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id) < NEW.quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product_id %. Available: %, Requested: %',
            NEW.product_id,
            (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id),
            NEW.quantity;
    END IF;

    -- Deduct stock
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_decrease_stock
AFTER INSERT ON order_items
FOR EACH ROW EXECUTE FUNCTION fn_decrease_stock();

-- ============================================================
--  FUNCTION 3: Restore stock on order cancellation / return
-- ============================================================
CREATE OR REPLACE FUNCTION fn_restore_stock_on_cancel()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_status IN ('CANCELLED', 'RETURNED')
       AND OLD.order_status NOT IN ('CANCELLED', 'RETURNED') THEN
        -- Restore stock for all items in this order
        UPDATE products p
        SET stock_quantity = stock_quantity + oi.quantity
        FROM order_items oi
        WHERE oi.order_id = NEW.order_id
          AND oi.product_id = p.product_id;

        RAISE NOTICE 'Stock restored for order_id %', NEW.order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_restore_stock_on_cancel
AFTER UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION fn_restore_stock_on_cancel();

-- ============================================================
--  FUNCTION 4: Award loyalty points on delivered order
--  Rule: 1 point per ₹100 spent
-- ============================================================
CREATE OR REPLACE FUNCTION fn_award_loyalty_points()
RETURNS TRIGGER AS $$
DECLARE
    v_order_value NUMERIC;
    v_points INT;
BEGIN
    IF NEW.order_status = 'DELIVERED'
       AND OLD.order_status != 'DELIVERED' THEN

        -- Calculate order value
        SELECT SUM(quantity * unit_price * (1 - discount_pct / 100))
        INTO v_order_value
        FROM order_items
        WHERE order_id = NEW.order_id;

        -- 1 point per ₹100
        v_points := FLOOR(v_order_value / 100);

        -- Update customer loyalty points
        UPDATE customers
        SET loyalty_points = loyalty_points + v_points
        WHERE customer_id = NEW.customer_id;

        RAISE NOTICE 'Awarded % loyalty points to customer_id % for order %',
            v_points, NEW.customer_id, NEW.order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_award_loyalty_points
AFTER UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION fn_award_loyalty_points();

-- ============================================================
--  FUNCTION 5: Prevent review without a delivered order
-- ============================================================
CREATE OR REPLACE FUNCTION fn_validate_review()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure the customer actually ordered and received this product
    IF NOT EXISTS (
        SELECT 1 FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = NEW.customer_id
          AND oi.product_id = NEW.product_id
          AND o.order_status = 'DELIVERED'
    ) THEN
        RAISE EXCEPTION 'Customer % cannot review product % — no delivered order found.',
            NEW.customer_id, NEW.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_review
BEFORE INSERT ON product_reviews
FOR EACH ROW EXECUTE FUNCTION fn_validate_review();

-- ============================================================
--  STORED FUNCTION 1: Calculate order total
-- ============================================================
CREATE OR REPLACE FUNCTION fn_get_order_total(p_order_id INT)
RETURNS TABLE (
    order_id        INT,
    subtotal        NUMERIC,
    discount        NUMERIC,
    shipping        NUMERIC,
    net_total       NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS subtotal,
        o.discount_amount                                                          AS discount,
        o.shipping_fee                                                             AS shipping,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100))
              - o.discount_amount + o.shipping_fee, 2)                            AS net_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_id = p_order_id
    GROUP BY o.order_id, o.discount_amount, o.shipping_fee;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM fn_get_order_total(5);

-- ============================================================
--  STORED FUNCTION 2: Customer purchase history
-- ============================================================
CREATE OR REPLACE FUNCTION fn_customer_history(p_customer_id INT)
RETURNS TABLE (
    order_id        INT,
    order_date      TIMESTAMP,
    order_status    VARCHAR,
    order_value     NUMERIC,
    payment_method  VARCHAR,
    payment_status  VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS order_value,
        COALESCE(p.payment_method, 'UNPAID')  AS payment_method,
        COALESCE(p.payment_status, 'PENDING') AS payment_status
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN payments p ON o.order_id = p.order_id
    WHERE o.customer_id = p_customer_id
    GROUP BY o.order_id, o.order_date, o.order_status, p.payment_method, p.payment_status
    ORDER BY o.order_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM fn_customer_history(5);

-- ============================================================
--  STORED FUNCTION 3: Monthly revenue report
-- ============================================================
CREATE OR REPLACE FUNCTION fn_monthly_revenue_report(
    p_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INT
)
RETURNS TABLE (
    month           TEXT,
    total_orders    BIGINT,
    units_sold      BIGINT,
    gross_revenue   NUMERIC,
    discounts       NUMERIC,
    net_revenue     NUMERIC,
    avg_order_value NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(o.order_date, 'Month')                                           AS month,
        COUNT(DISTINCT o.order_id)::BIGINT                                       AS total_orders,
        SUM(oi.quantity)::BIGINT                                                 AS units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2)  AS gross_revenue,
        ROUND(SUM(o.discount_amount), 2)                                         AS discounts,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100))
              - SUM(o.discount_amount), 2)                                       AS net_revenue,
        ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount_pct/100)), 2)  AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = p_year
      AND o.order_status NOT IN ('CANCELLED', 'RETURNED')
    GROUP BY TO_CHAR(o.order_date, 'Month'), EXTRACT(MONTH FROM o.order_date)
    ORDER BY EXTRACT(MONTH FROM o.order_date);
END;
$$ LANGUAGE plpgsql;

-- Usage: SELECT * FROM fn_monthly_revenue_report(2024);
