-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 07_master_run.sql
--  Description: Master execution order + health check queries
--  Database: PostgreSQL (use pgAdmin or psql CLI)
-- ================================================================

-- ─── ORDER OF EXECUTION ──────────────────────────────────────────────────────
--
--  STEP 1 │ sql/schema/01_schema.sql
--          │ → Creates all 7 tables, constraints, indexes, sequences
--          │
--  STEP 2 │ sql/data/02_seed_data.sql
--          │ → Inserts 8 depts, 18 roles, 50 employees,
--          │   200+ attendance records, leave requests, salary history
--          │
--  STEP 3 │ sql/triggers/03_triggers.sql
--          │ → Creates 5 triggers + their PL/pgSQL handler functions
--          │
--  STEP 4 │ sql/functions/04_functions.sql
--          │ → Creates 5 stored functions for HR analytics
--          │
--  STEP 5 │ sql/views/05_views.sql
--          │ → Creates 6 reusable report views
--          │
--  STEP 6 │ sql/queries/06_queries.sql
--          │ → Run any or all 15 analytical report queries
--
-- ─────────────────────────────────────────────────────────────────────────────

-- ================================================================
--  HEALTH CHECK — Run after all files to verify everything loaded
-- ================================================================

SELECT '=== TABLE ROW COUNTS ===' AS section;

SELECT 'departments'    AS table_name, COUNT(*) AS rows FROM departments    UNION ALL
SELECT 'roles',                         COUNT(*)         FROM roles           UNION ALL
SELECT 'employees',                     COUNT(*)         FROM employees       UNION ALL
SELECT 'attendance',                    COUNT(*)         FROM attendance      UNION ALL
SELECT 'leave_requests',                COUNT(*)         FROM leave_requests  UNION ALL
SELECT 'salary_history',                COUNT(*)         FROM salary_history  UNION ALL
SELECT 'audit_log',                     COUNT(*)         FROM audit_log;

SELECT '=== EMPLOYEE STATUS BREAKDOWN ===' AS section;

SELECT status, COUNT(*) AS count
FROM employees
GROUP BY status
ORDER BY count DESC;

SELECT '=== DEPARTMENT HEADCOUNT ===' AS section;

SELECT d.dept_name, COUNT(e.emp_id) AS employees,
       ROUND(AVG(e.salary)) AS avg_salary
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY employees DESC;

SELECT '=== ATTENDANCE SUMMARY (ALL TIME) ===' AS section;

SELECT status, COUNT(*) AS records,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM attendance
GROUP BY status
ORDER BY records DESC;

SELECT '=== TRIGGER STATUS ===' AS section;

SELECT trigger_name, event_object_table AS tbl, event_manipulation AS event
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

SELECT '=== FUNCTION STATUS ===' AS section;

SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type   = 'FUNCTION'
ORDER BY routine_name;

SELECT '=== VIEW STATUS ===' AS section;

SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT '=== SYSTEM READY ===' AS status;

-- ================================================================
--  QUICK DEMO QUERIES
-- ================================================================

-- Monthly attendance for Jan 2024
SELECT * FROM fn_monthly_attendance_summary(1001, 2024, 1);

-- Dept summary for Jan 2024
SELECT * FROM fn_department_attendance_summary(2024, 1);

-- Late arrivals Jan 2024
SELECT * FROM fn_late_arrivals_report(2024, 1);

-- Employee directory snapshot
SELECT emp_id, full_name, dept_name, role_title, years_of_service, salary
FROM vw_employee_directory
ORDER BY dept_name, salary DESC
LIMIT 15;

-- Pending leave requests
SELECT * FROM vw_leave_status WHERE status = 'Pending';
