-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 2: PROFILE — Identify Data Quality Issues
-- ============================================================
--  Run these queries BEFORE cleaning to document all issues.
-- ============================================================

-- ── 1. Total row count ────────────────────────────────────────────────────────
SELECT 'Total rows (incl. duplicates)' AS metric, COUNT(*) AS value FROM stg_raw_sales
UNION ALL
-- ── 2. Duplicate order_ids ────────────────────────────────────────────────────
SELECT 'Duplicate order_id rows', COUNT(*) FROM stg_raw_sales
WHERE order_id IN (
    SELECT order_id FROM stg_raw_sales GROUP BY order_id HAVING COUNT(*) > 1
)
UNION ALL
-- ── 3. Missing customer_name ──────────────────────────────────────────────────
SELECT 'Missing customer_name', COUNT(*) FROM stg_raw_sales
WHERE customer_name IS NULL OR TRIM(customer_name) = ''
UNION ALL
-- ── 4. Missing unit_price ─────────────────────────────────────────────────────
SELECT 'Missing unit_price', COUNT(*) FROM stg_raw_sales
WHERE unit_price IS NULL OR TRIM(unit_price) = ''
UNION ALL
-- ── 5. Non-standard date format (not YYYY-MM-DD) ──────────────────────────────
SELECT 'Non-standard date format', COUNT(*) FROM stg_raw_sales
WHERE order_date NOT LIKE '____-__-__'
UNION ALL
-- ── 6. Invalid status values ─────────────────────────────────────────────────
SELECT 'Invalid status values', COUNT(*) FROM stg_raw_sales
WHERE LOWER(status) NOT IN ('completed','pending','shipped','returned','cancelled');

-- ── 7. Show all distinct status values ───────────────────────────────────────
SELECT 'Distinct status values:' AS note;
SELECT DISTINCT status, COUNT(*) AS cnt FROM stg_raw_sales GROUP BY status ORDER BY cnt DESC;

-- ── 8. Show all distinct categories ──────────────────────────────────────────
SELECT 'Distinct categories:' AS note;
SELECT DISTINCT category, COUNT(*) AS cnt FROM stg_raw_sales GROUP BY category ORDER BY cnt DESC;

-- ── 9. Show rows with issues ──────────────────────────────────────────────────
SELECT 'Problematic rows:' AS note;
SELECT order_id, customer_name, unit_price, order_date, status
FROM stg_raw_sales
WHERE (customer_name IS NULL OR TRIM(customer_name) = '')
   OR (unit_price IS NULL OR TRIM(unit_price) = '')
   OR order_date NOT LIKE '____-__-__';
