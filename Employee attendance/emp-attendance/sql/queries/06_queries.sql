-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 06_queries.sql
--  Description: 15 Analytical queries for HR reporting
-- ================================================================

-- ════════════════════════════════════════════════════════════════
--  QUERY 1: Monthly Attendance Summary — all employees, Jan 2024
-- ════════════════════════════════════════════════════════════════
SELECT
    year_month,
    full_name,
    dept_name,
    present,
    late,
    absent,
    half_day,
    on_leave,
    total_work_hours,
    total_overtime_hrs,
    attendance_pct
FROM vw_monthly_attendance
WHERE year_month = '2024-01'
ORDER BY attendance_pct DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 2: Late Arrivals per employee (GROUP BY + HAVING)
--           Show only employees with 2+ late days in any month
-- ════════════════════════════════════════════════════════════════
SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name)      AS full_name,
    d.dept_name,
    TO_CHAR(a.work_date, 'YYYY-MM')             AS year_month,
    COUNT(*)                                     AS late_days,
    ARRAY_AGG(a.work_date ORDER BY a.work_date) AS late_dates
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id
WHERE a.status = 'Late'
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name,
         TO_CHAR(a.work_date, 'YYYY-MM')
HAVING COUNT(*) >= 2
ORDER BY late_days DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 3: Department-wise headcount and payroll summary
-- ════════════════════════════════════════════════════════════════
SELECT
    dept_name,
    location,
    manager_name,
    total_employees,
    active,
    on_leave,
    TO_CHAR(avg_salary,  '₹FM99,99,999') AS avg_salary,
    TO_CHAR(total_payroll,'₹FM99,99,99,999') AS monthly_payroll
FROM vw_department_headcount
ORDER BY total_employees DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 4: Top 5 employees by total overtime hours (all time)
-- ════════════════════════════════════════════════════════════════
SELECT
    e.emp_id,
    CONCAT(e.first_name,' ',e.last_name)    AS full_name,
    d.dept_name,
    ROUND(SUM(a.overtime_hours), 2)         AS total_overtime_hrs,
    RANK() OVER (ORDER BY SUM(a.overtime_hours) DESC) AS ot_rank
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
HAVING SUM(a.overtime_hours) > 0
ORDER BY total_overtime_hrs DESC
LIMIT 5;

-- ════════════════════════════════════════════════════════════════
--  QUERY 5: Absenteeism report — employees with >1 absence
-- ════════════════════════════════════════════════════════════════
SELECT
    e.emp_id,
    CONCAT(e.first_name,' ',e.last_name)    AS full_name,
    d.dept_name,
    COUNT(*)                                 AS total_absences,
    ARRAY_AGG(a.work_date ORDER BY a.work_date) AS absent_dates
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id
WHERE a.status = 'Absent'
GROUP BY e.emp_id, e.first_name, e.last_name, d.dept_name
HAVING COUNT(*) > 1
ORDER BY total_absences DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 6: Salary comparison — employee vs role band (WINDOW)
-- ════════════════════════════════════════════════════════════════
SELECT
    full_name,
    dept_name,
    role_title,
    TO_CHAR(current_salary,'₹FM99,99,999')  AS salary,
    TO_CHAR(min_salary,    '₹FM99,99,999')  AS band_min,
    TO_CHAR(max_salary,    '₹FM99,99,999')  AS band_max,
    position_in_band_pct                     AS "% in band",
    RANK() OVER (PARTITION BY dept_name ORDER BY current_salary DESC) AS salary_rank_in_dept
FROM vw_salary_overview
ORDER BY dept_name, current_salary DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 7: Leave balance summary — approved leaves per employee
-- ════════════════════════════════════════════════════════════════
SELECT
    employee_name,
    dept_name,
    SUM(total_days) FILTER (WHERE leave_type = 'Casual')  AS casual_used,
    SUM(total_days) FILTER (WHERE leave_type = 'Sick')    AS sick_used,
    SUM(total_days) FILTER (WHERE leave_type = 'Earned')  AS earned_used,
    SUM(total_days)                                        AS total_leaves_taken
FROM vw_leave_status
WHERE status = 'Approved'
GROUP BY employee_name, dept_name
ORDER BY total_leaves_taken DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 8: Running total of work hours per employee (WINDOW)
-- ════════════════════════════════════════════════════════════════
SELECT
    CONCAT(e.first_name,' ',e.last_name)    AS full_name,
    a.work_date,
    ROUND(a.work_hours, 2)                  AS daily_hours,
    ROUND(SUM(a.work_hours) OVER (
        PARTITION BY a.emp_id
        ORDER BY a.work_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2)                                   AS running_total_hours
FROM attendance a
JOIN employees e ON e.emp_id = a.emp_id
WHERE a.emp_id = 1001
  AND a.work_date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY a.work_date;

-- ════════════════════════════════════════════════════════════════
--  QUERY 9: Monthly attendance trend — department level
-- ════════════════════════════════════════════════════════════════
SELECT
    TO_CHAR(a.work_date, 'YYYY-MM')         AS year_month,
    d.dept_name,
    COUNT(*) FILTER (WHERE a.status = 'Present')  AS present,
    COUNT(*) FILTER (WHERE a.status = 'Late')     AS late,
    COUNT(*) FILTER (WHERE a.status = 'Absent')   AS absent,
    ROUND(
        COUNT(*) FILTER (WHERE a.status IN ('Present','Late'))::NUMERIC /
        NULLIF(COUNT(*) FILTER (WHERE a.status != 'Holiday'), 0) * 100
    , 2)                                    AS attendance_pct
FROM attendance a
JOIN employees   e ON e.emp_id  = a.emp_id
JOIN departments d ON d.dept_id = e.dept_id
GROUP BY TO_CHAR(a.work_date, 'YYYY-MM'), d.dept_name
ORDER BY year_month, dept_name;

-- ════════════════════════════════════════════════════════════════
--  QUERY 10: Employees hired in the last 2 years (tenure report)
-- ════════════════════════════════════════════════════════════════
SELECT
    emp_id,
    full_name,
    dept_name,
    role_title,
    hire_date,
    years_of_service,
    CASE
        WHEN years_of_service < 1 THEN 'Probation'
        WHEN years_of_service < 3 THEN 'Junior'
        WHEN years_of_service < 6 THEN 'Mid-Level'
        ELSE 'Senior'
    END AS tenure_band
FROM vw_employee_directory
WHERE hire_date >= CURRENT_DATE - INTERVAL '2 years'
ORDER BY hire_date DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 11: Pending leave requests awaiting approval
-- ════════════════════════════════════════════════════════════════
SELECT
    leave_id,
    employee_name,
    dept_name,
    leave_type,
    from_date,
    to_date,
    total_days,
    reason,
    applied_at
FROM vw_leave_status
WHERE status = 'Pending'
ORDER BY applied_at ASC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 12: Gender diversity report per department
-- ════════════════════════════════════════════════════════════════
SELECT
    d.dept_name,
    COUNT(*) FILTER (WHERE e.gender = 'M')  AS male,
    COUNT(*) FILTER (WHERE e.gender = 'F')  AS female,
    COUNT(*) FILTER (WHERE e.gender = 'O')  AS other,
    COUNT(*)                                 AS total,
    ROUND(
        COUNT(*) FILTER (WHERE e.gender = 'F')::NUMERIC / COUNT(*) * 100
    , 1)                                     AS female_pct
FROM employees e
JOIN departments d ON d.dept_id = e.dept_id
WHERE e.status = 'Active'
GROUP BY d.dept_name
ORDER BY female_pct DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 13: Salary history — increments over time (CTE)
-- ════════════════════════════════════════════════════════════════
WITH salary_changes AS (
    SELECT
        sh.emp_id,
        CONCAT(e.first_name,' ',e.last_name)    AS full_name,
        d.dept_name,
        sh.old_salary,
        sh.new_salary,
        sh.new_salary - sh.old_salary           AS increment,
        ROUND((sh.new_salary - sh.old_salary)::NUMERIC
              / sh.old_salary * 100, 2)          AS increment_pct,
        sh.change_reason,
        sh.effective_date,
        ROW_NUMBER() OVER (
            PARTITION BY sh.emp_id
            ORDER BY sh.created_at DESC)         AS rn
    FROM salary_history sh
    JOIN employees   e ON e.emp_id  = sh.emp_id
    JOIN departments d ON d.dept_id = e.dept_id
)
SELECT
    emp_id, full_name, dept_name,
    TO_CHAR(old_salary,'₹FM99,99,999') AS old_salary,
    TO_CHAR(new_salary,'₹FM99,99,999') AS new_salary,
    TO_CHAR(increment, '₹FM99,99,999') AS increment,
    increment_pct                       AS "% raise",
    change_reason,
    effective_date
FROM salary_changes
ORDER BY increment_pct DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 14: Employment type breakdown
-- ════════════════════════════════════════════════════════════════
SELECT
    employment_type,
    COUNT(*)                             AS employee_count,
    ROUND(AVG(salary), 0)               AS avg_salary,
    COUNT(*) * 100 / SUM(COUNT(*)) OVER() AS pct_of_workforce
FROM employees
WHERE status = 'Active'
GROUP BY employment_type
ORDER BY employee_count DESC;

-- ════════════════════════════════════════════════════════════════
--  QUERY 15: Full employee + attendance + leave joined report
-- ════════════════════════════════════════════════════════════════
SELECT
    ed.emp_id,
    ed.full_name,
    ed.dept_name,
    ed.role_title,
    ed.employment_type,
    TO_CHAR(ed.salary,'₹FM99,99,999')  AS salary,
    ma.year_month,
    ma.present,
    ma.late,
    ma.absent,
    ma.total_work_hours,
    ma.attendance_pct,
    COALESCE(
        (SELECT SUM(lr.total_days)
         FROM leave_requests lr
         WHERE lr.emp_id = ed.emp_id AND lr.status = 'Approved'),
        0
    )                                   AS total_leave_days_approved
FROM vw_employee_directory ed
LEFT JOIN vw_monthly_attendance ma ON ma.emp_id = ed.emp_id
    AND ma.year_month = '2024-01'
WHERE ed.status = 'Active'
ORDER BY ed.dept_name, ma.attendance_pct DESC NULLS LAST;
