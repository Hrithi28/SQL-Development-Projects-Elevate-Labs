# 🗄️ Employee Management & Attendance Tracker

A production-grade SQL database system for HR management, built with **PostgreSQL** (primary) and **SQLite** (portable demo). Tracks employees, daily attendance, leave requests, salary history, and generates comprehensive HR analytics through stored functions, triggers, views, and analytical queries.

---

## 📁 Project Structure

```
emp-attendance/
├── sql/
│   ├── schema/
│   │   └── 01_schema.sql           ← 7 tables, constraints, indexes, sequences
│   ├── data/
│   │   └── 02_seed_data.sql        ← 50 employees, 200+ attendance rows, leaves, salaries
│   ├── triggers/
│   │   └── 03_triggers.sql         ← 5 PL/pgSQL triggers
│   ├── functions/
│   │   └── 04_functions.sql        ← 5 stored functions for HR analytics
│   ├── views/
│   │   └── 05_views.sql            ← 6 reusable SQL views
│   ├── queries/
│   │   └── 06_queries.sql          ← 15 analytical HR report queries
│   └── 07_master_run.sql           ← Execution order + health check
├── reports/
│   └── Project_Report_EmpAttendance.pdf  ← 2-page internship submission report
├── employee_attendance.db          ← Ready-to-open SQLite demo database ✅
└── README.md
```

---

## 🚀 Setup — PostgreSQL (Production)

### Prerequisites
- PostgreSQL 15+ installed
- pgAdmin 4 (GUI) or psql (CLI)

### Steps

**1. Create the database**
```sql
-- In pgAdmin Query Tool or psql:
CREATE DATABASE employee_tracker;
\c employee_tracker   -- (psql only)
```

**2. Run SQL files in order**

Open each file in pgAdmin's Query Tool and execute:

| Order | File | What it does |
|---|---|---|
| 1 | `sql/schema/01_schema.sql` | Creates all tables, constraints, indexes |
| 2 | `sql/data/02_seed_data.sql` | Inserts all 50 employees + 200+ records |
| 3 | `sql/triggers/03_triggers.sql` | Creates 5 triggers |
| 4 | `sql/functions/04_functions.sql` | Creates 5 stored functions |
| 5 | `sql/views/05_views.sql` | Creates 6 report views |
| 6 | `sql/queries/06_queries.sql` | Run any of the 15 report queries |

**3. Verify everything loaded**
```sql
\i sql/07_master_run.sql
```

---

## 🗂️ SQLite Demo (No Server Needed)

Open `employee_attendance.db` directly in **DB Browser for SQLite** (https://sqlitebrowser.org) — all 50 employees and 2,175+ attendance records are pre-loaded and ready to query.

---

## 📊 Database Schema

```
departments ──┐
              ├── employees (self-ref manager_id)
roles ────────┘      │
                     ├── attendance
                     ├── leave_requests
                     ├── salary_history
                     └── audit_log (auto via trigger)
```

### Tables

| Table | Rows | Description |
|---|---|---|
| `departments` | 8 | Dept name, location, manager FK |
| `roles` | 18 | Role titles with salary bands per dept |
| `employees` | 50 | Full employee profiles with self-ref manager |
| `attendance` | 2175+ | Daily check-in/out with computed hours |
| `leave_requests` | 10 | Leave workflow with approval tracking |
| `salary_history` | 8 | Every salary change auto-logged |
| `audit_log` | auto | JSONB snapshots of all employee changes |

---

## ⚡ Triggers

| Trigger | Table | Event | Action |
|---|---|---|---|
| `trg_employees_updated_at` | employees | BEFORE UPDATE | Auto-stamp `updated_at` |
| `trg_salary_change` | employees | AFTER UPDATE salary | Insert row into `salary_history` |
| `trg_audit_employees` | employees | AFTER INSERT/UPDATE/DELETE | Write JSONB snapshot to `audit_log` |
| `trg_validate_attendance` | attendance | BEFORE INSERT/UPDATE | Validate times, auto-set Late/Present |
| `trg_leave_to_attendance` | leave_requests | AFTER UPDATE status | Insert On-Leave rows on approval |

---

## 🔧 Stored Functions

```sql
-- Total hours worked by emp 1001 in Jan 2024
SELECT fn_total_work_hours(1001, 2024, 1);

-- Attendance percentage for emp 1001 in Jan 2024
SELECT fn_attendance_percentage(1001, 2024, 1);

-- Full monthly summary table
SELECT * FROM fn_monthly_attendance_summary(1001, 2024, 1);

-- Late arrivals ranked for Jan 2024
SELECT * FROM fn_late_arrivals_report(2024, 1);

-- Department-level summary with performance flag
SELECT * FROM fn_department_attendance_summary(2024, 1);
```

---

## 👁️ Views

```sql
SELECT * FROM vw_employee_directory;       -- Full employee info with age, tenure, manager
SELECT * FROM vw_attendance_detail;        -- Per-row with day-of-week and hours
SELECT * FROM vw_monthly_attendance;       -- Grouped by employee + month
SELECT * FROM vw_department_headcount;     -- Headcount + payroll per dept
SELECT * FROM vw_leave_status;            -- Leave requests with approver name
SELECT * FROM vw_salary_overview;         -- Salary vs role band position
```

---

## 📋 Report Queries (06_queries.sql)

| # | Report | Key SQL Feature |
|---|---|---|
| 1 | Monthly attendance summary | VIEW + ORDER BY |
| 2 | Late arrivals with date list | GROUP BY + HAVING + ARRAY_AGG |
| 3 | Dept headcount and payroll | VIEW + FORMAT |
| 4 | Overtime leaderboard | RANK() OVER() |
| 5 | Absenteeism report | GROUP BY + HAVING |
| 6 | Salary vs role band | RANK() OVER(PARTITION BY dept) |
| 7 | Leave balance by type | FILTER + GROUP BY |
| 8 | Running work-hour total | SUM OVER(ORDER BY date) |
| 9 | Monthly dept attendance trend | GROUP BY month + dept |
| 10 | Tenure bands | CASE + date arithmetic |
| 11 | Pending leave queue | VIEW filter |
| 12 | Gender diversity per dept | FILTER + ROUND |
| 13 | Salary increment history | CTE + ROW_NUMBER() |
| 14 | Employment type breakdown | COUNT OVER() |
| 15 | Full joined HR report | Multi-table JOIN + subquery |

---

## 🛠 Tech Stack

- **Database:** PostgreSQL 15+ (production), SQLite 3 (demo)
- **Stored Logic:** PL/pgSQL (triggers + functions)
- **Advanced SQL:** GENERATED ALWAYS AS, JSONB, Window Functions, CTEs, ARRAY_AGG, FILTER
- **Reporting:** 15 analytical queries, 6 views, 5 functions

---

## 📝 Top SQL Interview Topics Covered

This project directly covers these questions from the Elevate Labs Top 50 list:
- Q3 (WHERE vs HAVING), Q4 (constraints), Q6 (normalization — 3NF), Q9 (ACID),
- Q10 (JOINs), Q21–22 (window functions RANK/DENSE_RANK), Q24 (stored procedures),
- Q25 (triggers), Q26 (views), Q27 (indexes), Q41 (HR schema design), Q42 (attendance storage)
