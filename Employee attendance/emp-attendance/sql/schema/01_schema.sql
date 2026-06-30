-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 01_schema.sql
--  Database: PostgreSQL 15+
--  Description: Full DDL — tables, constraints, indexes
-- ================================================================

-- ── Enable UUID extension (PostgreSQL) ──────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Drop existing objects (safe re-run) ─────────────────────────────────────
DROP TABLE IF EXISTS attendance          CASCADE;
DROP TABLE IF EXISTS salary_history      CASCADE;
DROP TABLE IF EXISTS employees           CASCADE;
DROP TABLE IF EXISTS roles               CASCADE;
DROP TABLE IF EXISTS departments         CASCADE;
DROP TABLE IF EXISTS leave_requests      CASCADE;
DROP TABLE IF EXISTS audit_log           CASCADE;

DROP SEQUENCE IF EXISTS emp_id_seq;

-- ================================================================
--  TABLE: departments
-- ================================================================
CREATE TABLE departments (
    dept_id     SERIAL          PRIMARY KEY,
    dept_name   VARCHAR(100)    NOT NULL UNIQUE,
    location    VARCHAR(100)    NOT NULL DEFAULT 'Head Office',
    manager_id  INT             DEFAULT NULL,   -- FK set after employees created
    created_at  TIMESTAMP       DEFAULT NOW()
);

-- ================================================================
--  TABLE: roles
-- ================================================================
CREATE TABLE roles (
    role_id         SERIAL          PRIMARY KEY,
    role_title      VARCHAR(100)    NOT NULL UNIQUE,
    min_salary      NUMERIC(12,2)   NOT NULL CHECK (min_salary >= 0),
    max_salary      NUMERIC(12,2)   NOT NULL CHECK (max_salary >= min_salary),
    dept_id         INT             NOT NULL REFERENCES departments(dept_id) ON DELETE RESTRICT,
    created_at      TIMESTAMP       DEFAULT NOW()
);

-- ================================================================
--  TABLE: employees
-- ================================================================
CREATE SEQUENCE emp_id_seq START 1001 INCREMENT 1;

CREATE TABLE employees (
    emp_id          INT             PRIMARY KEY DEFAULT nextval('emp_id_seq'),
    first_name      VARCHAR(60)     NOT NULL,
    last_name       VARCHAR(60)     NOT NULL,
    email           VARCHAR(150)    NOT NULL UNIQUE,
    phone           VARCHAR(20),
    date_of_birth   DATE            NOT NULL,
    gender          CHAR(1)         NOT NULL CHECK (gender IN ('M','F','O')),
    hire_date       DATE            NOT NULL DEFAULT CURRENT_DATE,
    dept_id         INT             NOT NULL REFERENCES departments(dept_id) ON DELETE RESTRICT,
    role_id         INT             NOT NULL REFERENCES roles(role_id) ON DELETE RESTRICT,
    salary          NUMERIC(12,2)   NOT NULL CHECK (salary >= 0),
    employment_type VARCHAR(20)     NOT NULL DEFAULT 'Full-Time'
                                    CHECK (employment_type IN ('Full-Time','Part-Time','Contract','Intern')),
    status          VARCHAR(20)     NOT NULL DEFAULT 'Active'
                                    CHECK (status IN ('Active','On-Leave','Resigned','Terminated')),
    created_at      TIMESTAMP       DEFAULT NOW(),
    updated_at      TIMESTAMP       DEFAULT NOW()
);

-- Add self-referencing manager_id after table creation
ALTER TABLE employees
    ADD COLUMN manager_id INT REFERENCES employees(emp_id) ON DELETE SET NULL;

-- Set department manager FK now that employees table exists
ALTER TABLE departments
    ADD CONSTRAINT fk_dept_manager
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id) ON DELETE SET NULL;

-- ================================================================
--  TABLE: attendance
-- ================================================================
CREATE TABLE attendance (
    attendance_id   SERIAL          PRIMARY KEY,
    emp_id          INT             NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
    work_date       DATE            NOT NULL,
    check_in        TIME,
    check_out       TIME,
    status          VARCHAR(20)     NOT NULL DEFAULT 'Present'
                                    CHECK (status IN ('Present','Absent','Half-Day','Late','On-Leave','Holiday')),
    work_hours      NUMERIC(5,2)    GENERATED ALWAYS AS (
                        CASE
                            WHEN check_in IS NOT NULL AND check_out IS NOT NULL
                            THEN EXTRACT(EPOCH FROM (check_out - check_in)) / 3600.0
                            ELSE 0
                        END
                    ) STORED,
    is_late         BOOLEAN         GENERATED ALWAYS AS (
                        CASE WHEN check_in > '09:15:00' THEN TRUE ELSE FALSE END
                    ) STORED,
    overtime_hours  NUMERIC(5,2)    GENERATED ALWAYS AS (
                        CASE
                            WHEN check_in IS NOT NULL AND check_out IS NOT NULL
                            AND EXTRACT(EPOCH FROM (check_out - check_in)) / 3600.0 > 9.0
                            THEN EXTRACT(EPOCH FROM (check_out - check_in)) / 3600.0 - 9.0
                            ELSE 0
                        END
                    ) STORED,
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT NOW(),
    UNIQUE (emp_id, work_date)
);

-- ================================================================
--  TABLE: leave_requests
-- ================================================================
CREATE TABLE leave_requests (
    leave_id        SERIAL          PRIMARY KEY,
    emp_id          INT             NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
    leave_type      VARCHAR(30)     NOT NULL
                                    CHECK (leave_type IN ('Casual','Sick','Earned','Maternity','Paternity','Unpaid')),
    from_date       DATE            NOT NULL,
    to_date         DATE            NOT NULL CHECK (to_date >= from_date),
    total_days      INT             GENERATED ALWAYS AS (to_date - from_date + 1) STORED,
    reason          TEXT,
    status          VARCHAR(20)     NOT NULL DEFAULT 'Pending'
                                    CHECK (status IN ('Pending','Approved','Rejected')),
    approved_by     INT             REFERENCES employees(emp_id) ON DELETE SET NULL,
    applied_at      TIMESTAMP       DEFAULT NOW(),
    decided_at      TIMESTAMP
);

-- ================================================================
--  TABLE: salary_history  (tracks every raise/change)
-- ================================================================
CREATE TABLE salary_history (
    history_id      SERIAL          PRIMARY KEY,
    emp_id          INT             NOT NULL REFERENCES employees(emp_id) ON DELETE CASCADE,
    old_salary      NUMERIC(12,2)   NOT NULL,
    new_salary      NUMERIC(12,2)   NOT NULL,
    change_reason   VARCHAR(200),
    effective_date  DATE            NOT NULL DEFAULT CURRENT_DATE,
    changed_by      INT             REFERENCES employees(emp_id) ON DELETE SET NULL,
    created_at      TIMESTAMP       DEFAULT NOW()
);

-- ================================================================
--  TABLE: audit_log  (auto-populated by triggers)
-- ================================================================
CREATE TABLE audit_log (
    log_id          SERIAL          PRIMARY KEY,
    table_name      VARCHAR(60)     NOT NULL,
    operation       VARCHAR(10)     NOT NULL,   -- INSERT / UPDATE / DELETE
    record_id       INT,
    old_values      JSONB,
    new_values      JSONB,
    performed_by    VARCHAR(100)    DEFAULT current_user,
    performed_at    TIMESTAMP       DEFAULT NOW()
);

-- ================================================================
--  INDEXES  (for report query performance)
-- ================================================================
CREATE INDEX idx_att_emp_date   ON attendance(emp_id, work_date);
CREATE INDEX idx_att_date       ON attendance(work_date);
CREATE INDEX idx_att_status     ON attendance(status);
CREATE INDEX idx_emp_dept       ON employees(dept_id);
CREATE INDEX idx_emp_role       ON employees(role_id);
CREATE INDEX idx_emp_status     ON employees(status);
CREATE INDEX idx_leave_emp      ON leave_requests(emp_id);
CREATE INDEX idx_leave_status   ON leave_requests(status);
CREATE INDEX idx_sal_emp        ON salary_history(emp_id);

-- ================================================================
--  SCHEMA VERIFICATION
-- ================================================================
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns c
     WHERE c.table_name = t.table_name AND c.table_schema = 'public') AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
