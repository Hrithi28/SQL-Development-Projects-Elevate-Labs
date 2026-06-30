-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 4: LOAD — Production Tables (Normalised to 3NF)
-- ============================================================
--  Schema: dim_customers, dim_products, dim_cities,
--          fact_orders (production fact table)
-- ============================================================

-- ── Drop in reverse FK order ──────────────────────────────────────────────────
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_cities;

-- ── Dimension: Cities ─────────────────────────────────────────────────────────
CREATE TABLE dim_cities (
    city_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    city_name   TEXT    NOT NULL,
    country     TEXT    NOT NULL DEFAULT 'India',
    UNIQUE (city_name, country)
);

-- ── Dimension: Customers ──────────────────────────────────────────────────────
CREATE TABLE dim_customers (
    customer_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name   TEXT    NOT NULL,
    customer_email  TEXT    NOT NULL UNIQUE,
    created_at      TEXT    DEFAULT (datetime('now'))
);

-- ── Dimension: Products ───────────────────────────────────────────────────────
CREATE TABLE dim_products (
    product_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name    TEXT    NOT NULL UNIQUE,
    category        TEXT    NOT NULL,
    unit_price      REAL    NOT NULL CHECK (unit_price >= 0)
);

-- ── Fact: Orders ──────────────────────────────────────────────────────────────
CREATE TABLE fact_orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES dim_customers(customer_id),
    product_id      INTEGER NOT NULL REFERENCES dim_products(product_id),
    city_id         INTEGER NOT NULL REFERENCES dim_cities(city_id),
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      REAL    NOT NULL,
    total_amount    REAL    NOT NULL,
    order_date      TEXT    NOT NULL,
    order_month     TEXT    NOT NULL,
    status          TEXT    NOT NULL CHECK (status IN ('completed','pending','shipped','returned','cancelled')),
    payment_method  TEXT    NOT NULL,
    is_revenue      INTEGER NOT NULL DEFAULT 1 CHECK (is_revenue IN (0,1)),
    loaded_at       TEXT    DEFAULT (datetime('now'))
);

-- Indexes for common query patterns
CREATE INDEX idx_fact_orders_date       ON fact_orders(order_date);
CREATE INDEX idx_fact_orders_month      ON fact_orders(order_month);
CREATE INDEX idx_fact_orders_customer   ON fact_orders(customer_id);
CREATE INDEX idx_fact_orders_product    ON fact_orders(product_id);
CREATE INDEX idx_fact_orders_status     ON fact_orders(status);

SELECT 'Production schema created successfully.' AS result;
