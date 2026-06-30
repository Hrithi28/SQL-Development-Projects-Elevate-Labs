-- ============================================================
--  SQL ETL PIPELINE SIMULATION
--  Step 7: TRIGGERS — Automated ETL Integrity & Logging
-- ============================================================
--  Trigger 1: Auto-log every new row inserted into fact_orders
--  Trigger 2: Prevent inserts with zero/negative total_amount
--  Trigger 3: Auto-update audit log on new ETL batch insert
--  Trigger 4: Cascade status change log on fact_orders UPDATE
-- ============================================================

-- ── Supporting table: row-level insert log ────────────────────────────────────
DROP TABLE IF EXISTS fact_orders_insert_log;
CREATE TABLE fact_orders_insert_log (
    insert_log_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        INTEGER,
    customer_id     INTEGER,
    product_id      INTEGER,
    total_amount    REAL,
    status          TEXT,
    inserted_at     TEXT DEFAULT (datetime('now')),
    notes           TEXT
);

-- ── Supporting table: status change history ───────────────────────────────────
DROP TABLE IF EXISTS order_status_history;
CREATE TABLE order_status_history (
    history_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        INTEGER NOT NULL,
    old_status      TEXT,
    new_status      TEXT,
    changed_at      TEXT DEFAULT (datetime('now'))
);

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER 1: After each INSERT into fact_orders → write to insert log
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_after_insert_fact_orders;

CREATE TRIGGER trg_after_insert_fact_orders
AFTER INSERT ON fact_orders
FOR EACH ROW
BEGIN
    INSERT INTO fact_orders_insert_log
        (order_id, customer_id, product_id, total_amount, status, notes)
    VALUES
        (NEW.order_id, NEW.customer_id, NEW.product_id, NEW.total_amount,
         NEW.status,
         'Auto-logged by trg_after_insert_fact_orders');
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER 2: Before INSERT on fact_orders — reject zero total if qty > 0
--            (SQLite uses RAISE(ABORT,...) to reject the row)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_validate_fact_orders;

CREATE TRIGGER trg_validate_fact_orders
BEFORE INSERT ON fact_orders
FOR EACH ROW
WHEN NEW.quantity > 0 AND NEW.total_amount <= 0 AND NEW.status != 'returned'
BEGIN
    SELECT RAISE(ABORT,
        'ETL Validation Error: total_amount must be > 0 for non-returned orders with quantity > 0');
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER 3: After UPDATE on fact_orders status → record status history
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_order_status_change;

CREATE TRIGGER trg_order_status_change
AFTER UPDATE OF status ON fact_orders
FOR EACH ROW
WHEN OLD.status != NEW.status
BEGIN
    INSERT INTO order_status_history (order_id, old_status, new_status)
    VALUES (NEW.order_id, OLD.status, NEW.status);
END;

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER 4: After INSERT on stg_raw_sales → update audit log row count
-- ─────────────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_staging_insert_audit;

CREATE TRIGGER trg_staging_insert_audit
AFTER INSERT ON stg_raw_sales
FOR EACH ROW
BEGIN
    -- Increment rows_processed for the latest EXTRACT stage log
    UPDATE etl_audit_log
    SET rows_processed = rows_processed + 1,
        rows_inserted  = rows_inserted  + 1
    WHERE stage = 'EXTRACT'
      AND table_name = 'stg_raw_sales'
      AND log_id = (SELECT MAX(log_id) FROM etl_audit_log WHERE stage='EXTRACT');
END;

-- ── Verify triggers created ───────────────────────────────────────────────────
SELECT name AS trigger_name, tbl_name AS on_table
FROM sqlite_master
WHERE type = 'trigger'
ORDER BY tbl_name, name;

-- ── Demo: Test status-change trigger ─────────────────────────────────────────
-- Simulate a status update (order 1014 returned → completed for test)
UPDATE fact_orders SET status = 'completed' WHERE order_id = 1014;

-- View history table
SELECT * FROM order_status_history;
