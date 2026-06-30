-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 3: TRANSFORM — Clean, Deduplicate, Standardise
-- ============================================================
--  Creates: stg_cleaned_sales (intermediate transform layer)
--  All cleaning rules documented inline.
-- ============================================================

DROP TABLE IF EXISTS stg_cleaned_sales;

CREATE TABLE stg_cleaned_sales (
    order_id        INTEGER,
    customer_name   TEXT,
    customer_email  TEXT,
    product_name    TEXT,
    category        TEXT,
    quantity        INTEGER,
    unit_price      REAL,
    total_amount    REAL,           -- derived column
    order_date      TEXT,           -- ISO YYYY-MM-DD
    order_month     TEXT,           -- YYYY-MM  (for GROUP BY reports)
    city            TEXT,
    country         TEXT,
    status          TEXT,
    payment_method  TEXT,
    is_revenue      INTEGER,        -- 1 = counts toward revenue, 0 = returned/cancelled
    cleaned_at      TEXT DEFAULT (datetime('now'))
);

-- ── Insert only first occurrence of each order_id (deduplicate) ──────────────
-- ── Fix date format 2024/01/12 → 2024-01-12 ──────────────────────────────────
-- ── Trim & title-case customer names ─────────────────────────────────────────
-- ── Set missing customer_name to 'Unknown Customer' ──────────────────────────
-- ── Set missing unit_price to 0.00 (flagged separately) ──────────────────────
-- ── Cast quantity and unit_price to their correct numeric types ───────────────
-- ── Derive total_amount = quantity * unit_price ───────────────────────────────
-- ── Derive order_month for time-series reporting ──────────────────────────────
-- ── Flag is_revenue: 0 for 'returned' and 'cancelled', 1 for everything else ─

INSERT INTO stg_cleaned_sales
    (order_id, customer_name, customer_email, product_name, category,
     quantity, unit_price, total_amount, order_date, order_month,
     city, country, status, payment_method, is_revenue)
SELECT
    CAST(order_id AS INTEGER)                                              AS order_id,

    -- Fix missing / blank names
    CASE
        WHEN TRIM(customer_name) = '' OR customer_name IS NULL
        THEN 'Unknown Customer'
        ELSE TRIM(customer_name)
    END                                                                    AS customer_name,

    LOWER(TRIM(customer_email))                                            AS customer_email,
    TRIM(product_name)                                                     AS product_name,
    TRIM(category)                                                         AS category,
    CAST(TRIM(quantity) AS INTEGER)                                        AS quantity,

    -- Fix missing prices → 0.00
    CASE
        WHEN TRIM(unit_price) = '' OR unit_price IS NULL
        THEN 0.00
        ELSE CAST(TRIM(unit_price) AS REAL)
    END                                                                    AS unit_price,

    -- Derived: total_amount
    CAST(TRIM(quantity) AS INTEGER) *
    CASE
        WHEN TRIM(unit_price) = '' OR unit_price IS NULL THEN 0.00
        ELSE CAST(TRIM(unit_price) AS REAL)
    END                                                                    AS total_amount,

    -- Fix date format: replace '/' with '-'
    REPLACE(TRIM(order_date), '/', '-')                                    AS order_date,

    -- Derive order_month (first 7 chars of normalised date = YYYY-MM)
    SUBSTR(REPLACE(TRIM(order_date), '/', '-'), 1, 7)                     AS order_month,

    TRIM(city)                                                             AS city,
    TRIM(country)                                                          AS country,
    LOWER(TRIM(status))                                                    AS status,
    TRIM(payment_method)                                                   AS payment_method,

    -- Revenue flag
    CASE WHEN LOWER(TRIM(status)) IN ('returned','cancelled') THEN 0 ELSE 1 END AS is_revenue

FROM stg_raw_sales
WHERE order_id IS NOT NULL AND TRIM(order_id) != ''

-- Deduplicate: keep the first-loaded row per order_id
GROUP BY order_id
HAVING rowid = MIN(rowid);      -- SQLite rowid trick for deduplication

-- ── Verification queries ──────────────────────────────────────────────────────
SELECT 'Cleaned rows (after dedup)' AS check_name, COUNT(*) AS value FROM stg_cleaned_sales
UNION ALL
SELECT 'Rows with zero unit_price (flagged)', COUNT(*) FROM stg_cleaned_sales WHERE unit_price = 0.00
UNION ALL
SELECT 'Rows with Unknown Customer name', COUNT(*) FROM stg_cleaned_sales WHERE customer_name = 'Unknown Customer'
UNION ALL
SELECT 'Returned / cancelled orders', COUNT(*) FROM stg_cleaned_sales WHERE is_revenue = 0;

-- Preview cleaned data
SELECT * FROM stg_cleaned_sales ORDER BY order_id LIMIT 15;
