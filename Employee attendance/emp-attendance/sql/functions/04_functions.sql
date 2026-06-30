-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 04_functions.sql
--  Description: Stored functions for business logic
-- ================================================================

-- ================================================================
--  FUNCTION 1: fn_total_work_hours(emp_id, year, month)
--  Returns total hours worked by an employee in a given month
-- ================================================================
CREATE OR REPLACE FUNCTION fn_total_work_hours(
    p_emp_id    INT,
    p_year      INT,
    p_month     INT
)
RETURNS NUMERIC AS $$
DECLARE
    v_hours NUMERIC(8,2);
BEGIN
    SELECT COALESCE(SUM(work_hours), 0)
    INTO v_hours
    FROM attendance
    WHERE emp_id    = p_emp_id
      AND EXTRACT(YEAR  FROM work_date) = p_year
      AND EXTRACT(MONTH FROM work_date) = p_month
      AND status NOT IN ('Absent','Holiday');

    RETURN ROUND(v_hours, 2);
END;
$$ LANGUAGE plpgsql;

-- ================================================================
--  FUNCTION 2: fn_attendance_percentage(emp_id, year, month)
--  Returns attendance % = present_days / working_days * 100
-- ================================================================
CREATE OR REPLACE FUNCTION fn_attendance_percentage(
    p_emp_id    INT,
    p_year      INT,
    p_month     INT
)
RETURNS NUMERIC AS $$
DECLARE
    v_working_days  INT;
    v_present_days  NUMERIC;
    v_pct           NUMERIC(5,2);
BEGIN
    -- Total working days recorded for this employee in the month
    SELECT COUNT(*)
    INTO v_working_days
    FROM attendance
    WHERE emp_id    = p_emp_id
      AND EXTRACT(YEAR  FROM work_date) = p_year
      AND EXTRACT(MONTH FROM work_date) = p_month
      AND status != 'Holiday';

    IF v_working_days = 0 THEN
        RETURN 0;
    END IF;

    -- Present / Late / Half-Day all count as attendance (Half-Day = 0.5)
    SELECT SUM(
        CASE status
            WHEN 'Present'  THEN 1
            WHEN 'Late'     THEN 1
            WHEN 'Half-Day' THEN 0.5
            ELSE 0
        END
    )
    INTO v_present_days
    FROM attendance
    WHERE emp_id    = p_emp_id
      AND EXTRACT(YEAR  FROM work_date) = p_year
      AND EXTRACT(MONTH FROM work_date) = p_month;

    v_pct := ROUND((v_present_days::NUMERIC / v_working_days) * 100, 2);
    RETURN v_pct;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
--  FUNCTION 3: fn_monthly_attendance_summary(emp_id, year, month)
--  Returns a table with full monthly breakdown
-- ================================================================
CREATE OR REPLACE FUNCTION fn_monthly_attendance_summary(
    p_emp_id    INT,
    p_year      INT,
    p_month     INT
)
RETURNS TABLE (
    employee_name   TEXT,
    dept_name       TEXT,
    year_month      TEXT,
    total_days      INT,
    present_days    INT,
    late_days       INT,
    absent_days     INT,
    half_days       INT,
    leave_days      INT,
    holiday_days    INT,
    total_hours     NUMERIC,
    overtime_hours  NUMERIC,
    attendance_pct  NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CONCAT(e.first_name, ' ', e.last_name)::TEXT,
        d.dept_name::TEXT,
        TO_CHAR(MAKE_DATE(p_year, p_month, 1), 'YYYY-MM')::TEXT,
        COUNT(a.attendance_id)::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'Present')::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'Late')::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'Absent')::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'Half-Day')::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'On-Leave')::INT,
        COUNT(a.attendance_id) FILTER (WHERE a.status = 'Holiday')::INT,
        ROUND(COALESCE(SUM(a.work_hours), 0), 2),
        ROUND(COALESCE(SUM(a.overtime_hours), 0), 2),
        fn_attendance_percentage(p_emp_id, p_year, p_month)
    FROM employees e
    JOIN departments d   ON d.dept_id = e.dept_id
    LEFT JOIN attendance a ON a.emp_id = e.emp_id
        AND EXTRACT(YEAR  FROM a.work_date) = p_year
        AND EXTRACT(MONTH FROM a.work_date) = p_month
    WHERE e.emp_id = p_emp_id
    GROUP BY e.first_name, e.last_name, d.dept_name;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
--  FUNCTION 4: fn_late_arrivals_report(year, month)
--  Returns all late arrivals for a department/month with rank
-- ================================================================
CREATE OR REPLACE FUNCTION fn_late_arrivals_report(
    p_year  INT,
    p_month INT
)
RETURNS TABLE (
    emp_id          INT,
    employee_name   TEXT,
    dept_name       TEXT,
    late_count      INT,
    late_rank       BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.emp_id,
        CONCAT(e.first_name, ' ', e.last_name)::TEXT,
        d.dept_name::TEXT,
        COUNT(a.attendance_id)::INT AS late_count,
        RANK() OVER (ORDER BY COUNT(a.attendance_id) DESC) AS late_rank
    FROM attendance a
    JOIN employees   e ON e.emp_id  = a.emp_id
    JOIN departments d ON d.dept_id = e.dept_id
    WHERE a.status = 'Late'
      AND EXTRACT(YEAR  FROM a.work_date) = p_year
      AND EXTRACT(MONTH FROM a.work_date) = p_month
    GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
    ORDER BY late_count DESC;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
--  FUNCTION 5: fn_department_attendance_summary(year, month)
--  Returns department-level attendance rollup using GROUP BY/HAVING
-- ================================================================
CREATE OR REPLACE FUNCTION fn_department_attendance_summary(
    p_year  INT,
    p_month INT
)
RETURNS TABLE (
    dept_name           TEXT,
    total_employees     BIGINT,
    avg_attendance_pct  NUMERIC,
    total_absent_days   BIGINT,
    total_late_days     BIGINT,
    total_overtime_hrs  NUMERIC,
    flag                TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.dept_name::TEXT,
        COUNT(DISTINCT e.emp_id),
        ROUND(AVG(fn_attendance_percentage(e.emp_id, p_year, p_month)), 2),
        COUNT(*) FILTER (WHERE a.status = 'Absent'),
        COUNT(*) FILTER (WHERE a.status = 'Late'),
        ROUND(COALESCE(SUM(a.overtime_hours), 0), 2),
        CASE
            WHEN AVG(fn_attendance_percentage(e.emp_id, p_year, p_month)) >= 95 THEN '✅ Excellent'
            WHEN AVG(fn_attendance_percentage(e.emp_id, p_year, p_month)) >= 85 THEN '🟡 Good'
            ELSE '🔴 Needs Attention'
        END::TEXT
    FROM employees e
    JOIN departments d   ON d.dept_id  = e.dept_id
    LEFT JOIN attendance a ON a.emp_id = e.emp_id
        AND EXTRACT(YEAR  FROM a.work_date) = p_year
        AND EXTRACT(MONTH FROM a.work_date) = p_month
    WHERE e.status = 'Active'
    GROUP BY d.dept_name
    ORDER BY avg_attendance_pct DESC;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
--  QUICK TESTS
-- ================================================================
-- Total hours for emp 1001, Jan 2024
SELECT fn_total_work_hours(1001, 2024, 1) AS total_hours_jan;

-- Attendance % for emp 1001, Jan 2024
SELECT fn_attendance_percentage(1001, 2024, 1) AS attendance_pct_jan;

-- Monthly summary for emp 1001, Jan 2024
SELECT * FROM fn_monthly_attendance_summary(1001, 2024, 1);

-- Late arrivals for Jan 2024
SELECT * FROM fn_late_arrivals_report(2024, 1);

-- Department summary for Jan 2024
SELECT * FROM fn_department_attendance_summary(2024, 1);
