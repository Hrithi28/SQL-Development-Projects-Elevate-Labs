-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 05_views.sql
--  Description: Reusable views for HR dashboards and reporting
-- ================================================================

-- ================================================================
--  VIEW 1: vw_employee_directory — full employee info flat view
-- ================================================================
DROP VIEW IF EXISTS vw_employee_directory CASCADE;
CREATE VIEW vw_employee_directory AS
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)     AS full_name,
    e.email,
    e.phone,
    e.gender,
    e.date_of_birth,
    DATE_PART('year', AGE(e.date_of_birth))::INT AS age,
    e.hire_date,
    DATE_PART('year', AGE(e.hire_date))::INT     AS years_of_service,
    d.dept_name,
    d.location,
    r.role_title,
    e.employment_type,
    e.salary,
    e.status,
    CONCAT(m.first_name, ' ', m.last_name)      AS manager_name
FROM employees e
JOIN departments d ON d.dept_id  = e.dept_id
JOIN roles       r ON r.role_id  = e.role_id
LEFT JOIN employees m ON m.emp_id = e.manager_id;

-- ================================================================
--  VIEW 2: vw_attendance_detail — per-row attendance with names
-- ================================================================
DROP VIEW IF EXISTS vw_attendance_detail CASCADE;
CREATE VIEW vw_attendance_detail AS
SELECT
    a.attendance_id,
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    d.dept_name,
    a.work_date,
    TO_CHAR(a.work_date, 'Day')             AS day_of_week,
    a.check_in,
    a.check_out,
    a.status,
    ROUND(a.work_hours, 2)                  AS work_hours,
    a.is_late,
    ROUND(a.overtime_hours, 2)              AS overtime_hours,
    a.notes
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id;

-- ================================================================
--  VIEW 3: vw_monthly_attendance — GROUP BY employee + month
-- ================================================================
DROP VIEW IF EXISTS vw_monthly_attendance CASCADE;
CREATE VIEW vw_monthly_attendance AS
SELECT
    TO_CHAR(a.work_date, 'YYYY-MM')         AS year_month,
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
    d.dept_name,
    COUNT(*)                                 AS total_days_recorded,
    COUNT(*) FILTER (WHERE a.status = 'Present')   AS present,
    COUNT(*) FILTER (WHERE a.status = 'Late')      AS late,
    COUNT(*) FILTER (WHERE a.status = 'Absent')    AS absent,
    COUNT(*) FILTER (WHERE a.status = 'Half-Day')  AS half_day,
    COUNT(*) FILTER (WHERE a.status = 'On-Leave')  AS on_leave,
    COUNT(*) FILTER (WHERE a.status = 'Holiday')   AS holiday,
    ROUND(SUM(a.work_hours), 2)             AS total_work_hours,
    ROUND(SUM(a.overtime_hours), 2)         AS total_overtime_hrs,
    ROUND(
        SUM(CASE a.status
            WHEN 'Present'  THEN 1
            WHEN 'Late'     THEN 1
            WHEN 'Half-Day' THEN 0.5
            ELSE 0 END
        )::NUMERIC /
        NULLIF(COUNT(*) FILTER (WHERE a.status != 'Holiday'), 0) * 100,
    2)                                      AS attendance_pct
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id
GROUP BY TO_CHAR(a.work_date, 'YYYY-MM'), e.emp_id, e.first_name, e.last_name, d.dept_name;

-- ================================================================
--  VIEW 4: vw_department_headcount — live headcount per dept
-- ================================================================
DROP VIEW IF EXISTS vw_department_headcount CASCADE;
CREATE VIEW vw_department_headcount AS
SELECT
    d.dept_id,
    d.dept_name,
    d.location,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    COUNT(e.emp_id)                         AS total_employees,
    COUNT(*) FILTER (WHERE e.status = 'Active')     AS active,
    COUNT(*) FILTER (WHERE e.status = 'On-Leave')   AS on_leave,
    COUNT(*) FILTER (WHERE e.status = 'Resigned')   AS resigned,
    COUNT(*) FILTER (WHERE e.status = 'Terminated') AS terminated,
    ROUND(AVG(e.salary), 0)                AS avg_salary,
    SUM(e.salary)                          AS total_payroll
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
LEFT JOIN employees m ON m.emp_id  = d.manager_id
GROUP BY d.dept_id, d.dept_name, d.location, m.first_name, m.last_name
ORDER BY total_employees DESC;

-- ================================================================
--  VIEW 5: vw_leave_status — leave requests with approver info
-- ================================================================
DROP VIEW IF EXISTS vw_leave_status CASCADE;
CREATE VIEW vw_leave_status AS
SELECT
    lr.leave_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS employee_name,
    d.dept_name,
    lr.leave_type,
    lr.from_date,
    lr.to_date,
    lr.total_days,
    lr.reason,
    lr.status,
    CONCAT(a.first_name, ' ', a.last_name)  AS approved_by_name,
    lr.applied_at,
    lr.decided_at
FROM leave_requests lr
JOIN employees   e ON e.emp_id  = lr.emp_id
JOIN departments d ON d.dept_id = e.dept_id
LEFT JOIN employees a ON a.emp_id = lr.approved_by
ORDER BY lr.applied_at DESC;

-- ================================================================
--  VIEW 6: vw_salary_overview — salary bands and history
-- ================================================================
DROP VIEW IF EXISTS vw_salary_overview CASCADE;
CREATE VIEW vw_salary_overview AS
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)  AS full_name,
    d.dept_name,
    r.role_title,
    e.salary                                AS current_salary,
    r.min_salary,
    r.max_salary,
    ROUND(
        (e.salary - r.min_salary)::NUMERIC /
        NULLIF(r.max_salary - r.min_salary, 0) * 100,
    1)                                      AS position_in_band_pct,
    (SELECT sh.old_salary
     FROM salary_history sh
     WHERE sh.emp_id = e.emp_id
     ORDER BY sh.created_at DESC LIMIT 1)  AS previous_salary,
    (SELECT sh.new_salary - sh.old_salary
     FROM salary_history sh
     WHERE sh.emp_id = e.emp_id
     ORDER BY sh.created_at DESC LIMIT 1)  AS last_increment
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
JOIN roles       r ON r.role_id = e.role_id
WHERE e.status = 'Active'
ORDER BY e.salary DESC;

-- ================================================================
--  VERIFY VIEWS
-- ================================================================
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

-- Quick test
SELECT * FROM vw_department_headcount;
SELECT * FROM vw_monthly_attendance LIMIT 10;
