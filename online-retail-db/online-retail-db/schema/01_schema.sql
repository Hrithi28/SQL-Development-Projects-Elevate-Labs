-- ============================================================
--  ONLINE RETAIL SALES DATABASE
--  Schema: Normalized to 3NF
--  Database: PostgreSQL / MySQL compatible
--  Author: Internship Project - Elevate Labs
-- ============================================================

-- Drop tables in reverse dependency order (safe re-run)
DROP TABLE IF EXISTS order_items       CASCADE;
DROP TABLE IF EXISTS payments          CASCADE;
DROP TABLE IF EXISTS orders            CASCADE;
DROP TABLE IF EXISTS product_reviews   CASCADE;
DROP TABLE IF EXISTS products          CASCADE;
DROP TABLE IF EXISTS categories        CASCADE;
DROP TABLE IF EXISTS suppliers         CASCADE;
DROP TABLE IF EXISTS customers         CASCADE;
DROP TABLE IF EXISTS addresses         CASCADE;
DROP TABLE IF EXISTS cities            CASCADE;
DROP TABLE IF EXISTS states            CASCADE;
DROP TABLE IF EXISTS countries         CASCADE;

-- ============================================================
--  LOOKUP / REFERENCE TABLES
-- ============================================================

CREATE TABLE countries (
    country_id      SERIAL PRIMARY KEY,
    country_name    VARCHAR(100) NOT NULL UNIQUE,
    country_code    CHAR(2)      NOT NULL UNIQUE   -- ISO 3166-1 alpha-2
);

CREATE TABLE states (
    state_id        SERIAL PRIMARY KEY,
    state_name      VARCHAR(100) NOT NULL,
    country_id      INT          NOT NULL REFERENCES countries(country_id),
    UNIQUE (state_name, country_id)
);

CREATE TABLE cities (
    city_id         SERIAL PRIMARY KEY,
    city_name       VARCHAR(100) NOT NULL,
    state_id        INT          NOT NULL REFERENCES states(state_id),
    pincode         VARCHAR(20),
    UNIQUE (city_name, state_id)
);

-- ============================================================
--  CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(60)  NOT NULL,
    last_name       VARCHAR(60)  NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    gender          CHAR(1)      CHECK (gender IN ('M', 'F', 'O')),
    date_of_birth   DATE,
    loyalty_points  INT          NOT NULL DEFAULT 0 CHECK (loyalty_points >= 0),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id      SERIAL PRIMARY KEY,
    customer_id     INT          NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    address_line1   VARCHAR(200) NOT NULL,
    address_line2   VARCHAR(200),
    city_id         INT          NOT NULL REFERENCES cities(city_id),
    address_type    VARCHAR(20)  NOT NULL DEFAULT 'HOME' CHECK (address_type IN ('HOME','WORK','OTHER')),
    is_default      BOOLEAN      NOT NULL DEFAULT FALSE
);

-- ============================================================
--  PRODUCT CATALOG
-- ============================================================

CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(100) NOT NULL UNIQUE,
    parent_id       INT          REFERENCES categories(category_id),  -- self-referencing for sub-categories
    description     TEXT
);

CREATE TABLE suppliers (
    supplier_id     SERIAL PRIMARY KEY,
    supplier_name   VARCHAR(150) NOT NULL,
    contact_email   VARCHAR(150),
    contact_phone   VARCHAR(20),
    city_id         INT          REFERENCES cities(city_id),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(200) NOT NULL,
    sku             VARCHAR(50)  NOT NULL UNIQUE,    -- Stock Keeping Unit
    category_id     INT          NOT NULL REFERENCES categories(category_id),
    supplier_id     INT          REFERENCES suppliers(supplier_id),
    unit_price      NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    cost_price      NUMERIC(12,2)           CHECK (cost_price >= 0),
    stock_quantity  INT          NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level   INT          NOT NULL DEFAULT 10,
    discount_pct    NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  ORDERS
-- ============================================================

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT          NOT NULL REFERENCES customers(customer_id),
    shipping_address_id INT      REFERENCES addresses(address_id),
    order_date      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expected_delivery DATE,
    delivered_date  DATE,
    order_status    VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                    CHECK (order_status IN ('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED','RETURNED')),
    shipping_fee    NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (shipping_fee >= 0),
    coupon_code     VARCHAR(30),
    discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    notes           TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT          NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT          NOT NULL REFERENCES products(product_id),
    quantity        INT          NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),  -- price at time of order
    discount_pct    NUMERIC(5,2) NOT NULL DEFAULT 0,
    UNIQUE (order_id, product_id)
);

-- ============================================================
--  PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    order_id        INT          NOT NULL REFERENCES orders(order_id),
    payment_date    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount          NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method  VARCHAR(30)  NOT NULL CHECK (payment_method IN ('CREDIT_CARD','DEBIT_CARD','UPI','NET_BANKING','COD','WALLET')),
    payment_status  VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                    CHECK (payment_status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    transaction_ref VARCHAR(100) UNIQUE
);

-- ============================================================
--  PRODUCT REVIEWS
-- ============================================================

CREATE TABLE product_reviews (
    review_id       SERIAL PRIMARY KEY,
    product_id      INT          NOT NULL REFERENCES products(product_id),
    customer_id     INT          NOT NULL REFERENCES customers(customer_id),
    order_id        INT          REFERENCES orders(order_id),
    rating          SMALLINT     NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,
    reviewed_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id, order_id)  -- one review per product per order
);

-- ============================================================
--  INDEXES (for query performance)
-- ============================================================

CREATE INDEX idx_orders_customer       ON orders(customer_id);
CREATE INDEX idx_orders_date           ON orders(order_date);
CREATE INDEX idx_orders_status         ON orders(order_status);
CREATE INDEX idx_order_items_order     ON order_items(order_id);
CREATE INDEX idx_order_items_product   ON order_items(product_id);
CREATE INDEX idx_products_category     ON products(category_id);
CREATE INDEX idx_products_sku          ON products(sku);
CREATE INDEX idx_payments_order        ON payments(order_id);
CREATE INDEX idx_payments_status       ON payments(payment_status);
CREATE INDEX idx_customers_email       ON customers(email);
CREATE INDEX idx_reviews_product       ON product_reviews(product_id);
