-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 03_triggers.sql
--  Description: 5 Triggers for automation and data integrity
-- ================================================================

-- ================================================================
--  TRIGGER 1: Auto-update employees.updated_at on any row change
-- ================================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_employees_updated_at ON employees;
CREATE TRIGGER trg_employees_updated_at
    BEFORE UPDATE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_updated_at();

-- ================================================================
--  TRIGGER 2: Auto-log salary changes to salary_history
--             Fires whenever employees.salary is updated
-- ================================================================
CREATE OR REPLACE FUNCTION fn_log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.salary IS DISTINCT FROM NEW.salary THEN
        INSERT INTO salary_history
            (emp_id, old_salary, new_salary, change_reason, effective_date)
        VALUES
            (NEW.emp_id, OLD.salary, NEW.salary,
             'Auto-logged by system trigger',
             CURRENT_DATE);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_salary_change ON employees;
CREATE TRIGGER trg_salary_change
    AFTER UPDATE OF salary ON employees
    FOR EACH ROW
    EXECUTE FUNCTION fn_log_salary_change();

-- ================================================================
--  TRIGGER 3: Audit log — capture INSERT / UPDATE / DELETE
--             on employees table into audit_log
-- ================================================================
CREATE OR REPLACE FUNCTION fn_audit_employees()
RETURNS TRIGGER AS $$
DECLARE
    v_old JSONB;
    v_new JSONB;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_old := row_to_json(OLD)::JSONB;
        v_new := NULL;
        INSERT INTO audit_log (table_name, operation, record_id, old_values, new_values)
        VALUES ('employees', TG_OP, OLD.emp_id, v_old, v_new);
        RETURN OLD;
    ELSIF TG_OP = 'INSERT' THEN
        v_old := NULL;
        v_new := row_to_json(NEW)::JSONB;
        INSERT INTO audit_log (table_name, operation, record_id, old_values, new_values)
        VALUES ('employees', TG_OP, NEW.emp_id, v_old, v_new);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        v_old := row_to_json(OLD)::JSONB;
        v_new := row_to_json(NEW)::JSONB;
        INSERT INTO audit_log (table_name, operation, record_id, old_values, new_values)
        VALUES ('employees', TG_OP, NEW.emp_id, v_old, v_new);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_employees ON employees;
CREATE TRIGGER trg_audit_employees
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW
    EXECUTE FUNCTION fn_audit_employees();

-- ================================================================
--  TRIGGER 4: Validate attendance check-in/check-out
--             • Reject check_out before check_in
--             • Auto-set status = 'Late' if check_in > 09:15
--             • Auto-set status = 'Present' if check_in <= 09:15
--               and status was not explicitly set to something else
-- ================================================================
CREATE OR REPLACE FUNCTION fn_validate_attendance()
RETURNS TRIGGER AS $$
BEGIN
    -- Rule 1: check_out must be after check_in
    IF NEW.check_in IS NOT NULL AND NEW.check_out IS NOT NULL THEN
        IF NEW.check_out <= NEW.check_in THEN
            RAISE EXCEPTION
                'Attendance error for emp_id=%: check_out (%) must be after check_in (%)',
                NEW.emp_id, NEW.check_out, NEW.check_in;
        END IF;
    END IF;

    -- Rule 2: auto-status based on check_in time
    IF NEW.check_in IS NOT NULL AND NEW.status IN ('Present','Late') THEN
        IF NEW.check_in > '09:15:00'::TIME THEN
            NEW.status := 'Late';
        ELSE
            NEW.status := 'Present';
        END IF;
    END IF;

    -- Rule 3: if Absent/On-Leave, nullify times
    IF NEW.status IN ('Absent','On-Leave','Holiday') THEN
        NEW.check_in  := NULL;
        NEW.check_out := NULL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_attendance ON attendance;
CREATE TRIGGER trg_validate_attendance
    BEFORE INSERT OR UPDATE ON attendance
    FOR EACH ROW
    EXECUTE FUNCTION fn_validate_attendance();

-- ================================================================
--  TRIGGER 5: When a leave request is APPROVED, insert
--             On-Leave attendance rows for each leave day
--             (weekdays only; skips weekends)
-- ================================================================
CREATE OR REPLACE FUNCTION fn_auto_attendance_on_leave()
RETURNS TRIGGER AS $$
DECLARE
    v_date DATE;
BEGIN
    -- Only fire when status changes TO 'Approved'
    IF NEW.status = 'Approved' AND
       (OLD.status IS DISTINCT FROM 'Approved') THEN

        v_date := NEW.from_date;
        WHILE v_date <= NEW.to_date LOOP
            -- Skip weekends (6 = Saturday, 0 = Sunday in PostgreSQL DOW)
            IF EXTRACT(DOW FROM v_date) NOT IN (0, 6) THEN
                INSERT INTO attendance (emp_id, work_date, status, notes)
                VALUES (NEW.emp_id, v_date, 'On-Leave',
                        CONCAT('Auto from leave_request #', NEW.leave_id))
                ON CONFLICT (emp_id, work_date) DO UPDATE
                    SET status = 'On-Leave',
                        notes  = CONCAT('Auto from leave_request #', NEW.leave_id);
            END IF;
            v_date := v_date + INTERVAL '1 day';
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_leave_to_attendance ON leave_requests;
CREATE TRIGGER trg_leave_to_attendance
    AFTER UPDATE OF status ON leave_requests
    FOR EACH ROW
    EXECUTE FUNCTION fn_auto_attendance_on_leave();

-- ================================================================
--  VERIFY TRIGGERS
-- ================================================================
SELECT
    trigger_name,
    event_manipulation AS event,
    event_object_table AS table_name,
    action_timing      AS timing,
    action_orientation AS per
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
