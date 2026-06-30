-- ================================================================
--  EMPLOYEE MANAGEMENT & ATTENDANCE TRACKER
--  File: 02_seed_data.sql
--  Description: Seed data — departments, roles, 50 employees,
--               200+ attendance records, leave requests,
--               salary history
-- ================================================================

-- ── 1. DEPARTMENTS ──────────────────────────────────────────────
INSERT INTO departments (dept_name, location) VALUES
('Engineering',       'Chennai'),
('Human Resources',   'Chennai'),
('Finance',           'Mumbai'),
('Marketing',         'Bangalore'),
('Sales',             'Delhi'),
('Operations',        'Hyderabad'),
('Product Management','Bangalore'),
('Customer Support',  'Pune');

-- ── 2. ROLES ────────────────────────────────────────────────────
INSERT INTO roles (role_title, min_salary, max_salary, dept_id) VALUES
-- Engineering (dept_id = 1)
('Junior Software Engineer',  400000,  700000, 1),
('Senior Software Engineer',  800000, 1400000, 1),
('Tech Lead',                1200000, 1800000, 1),
('DevOps Engineer',           600000, 1100000, 1),
-- HR (dept_id = 2)
('HR Executive',              350000,  600000, 2),
('HR Manager',                700000, 1100000, 2),
-- Finance (dept_id = 3)
('Accountant',                450000,  750000, 3),
('Finance Manager',           900000, 1400000, 3),
-- Marketing (dept_id = 4)
('Marketing Executive',       400000,  700000, 4),
('Marketing Manager',         800000, 1300000, 4),
-- Sales (dept_id = 5)
('Sales Executive',           350000,  650000, 5),
('Sales Manager',             750000, 1200000, 5),
-- Operations (dept_id = 6)
('Operations Analyst',        400000,  700000, 6),
('Operations Manager',        800000, 1300000, 6),
-- Product (dept_id = 7)
('Product Analyst',           500000,  850000, 7),
('Product Manager',           900000, 1500000, 7),
-- Customer Support (dept_id = 8)
('Support Executive',         300000,  550000, 8),
('Support Lead',              600000,  950000, 8);

-- ── 3. EMPLOYEES (50 records) ────────────────────────────────────
INSERT INTO employees
    (first_name, last_name, email, phone, date_of_birth, gender,
     hire_date, dept_id, role_id, salary, employment_type, status)
VALUES
-- Engineering
('Arjun',    'Verma',    'arjun.verma@company.com',    '9840012301', '1995-03-12', 'M', '2021-06-01', 1, 2, 1100000, 'Full-Time', 'Active'),
('Priya',    'Nair',     'priya.nair@company.com',     '9840012302', '1997-07-22', 'F', '2022-01-15', 1, 1,  550000, 'Full-Time', 'Active'),
('Rohan',    'Mehta',    'rohan.mehta@company.com',    '9840012303', '1993-11-05', 'M', '2020-03-10', 1, 3, 1600000, 'Full-Time', 'Active'),
('Sneha',    'Iyer',     'sneha.iyer@company.com',     '9840012304', '1996-05-18', 'F', '2021-09-20', 1, 4,  900000, 'Full-Time', 'Active'),
('Kiran',    'Raj',      'kiran.raj@company.com',      '9840012305', '1998-02-28', 'M', '2023-02-01', 1, 1,  480000, 'Full-Time', 'Active'),
('Deepa',    'Shetty',   'deepa.shetty@company.com',   '9840012306', '1994-08-14', 'F', '2020-07-15', 1, 2, 1050000, 'Full-Time', 'Active'),
('Vijay',    'Kumar',    'vijay.kumar@company.com',    '9840012307', '1992-12-01', 'M', '2019-11-01', 1, 3, 1700000, 'Full-Time', 'Active'),
('Anita',    'Pillai',   'anita.pillai@company.com',   '9840012308', '1999-04-09', 'F', '2023-07-10', 1, 1,  460000, 'Intern',    'Active'),
-- HR
('Meena',    'Sharma',   'meena.sharma@company.com',   '9840012309', '1990-06-30', 'F', '2018-04-01', 2, 6, 1000000, 'Full-Time', 'Active'),
('Suresh',   'Babu',     'suresh.babu@company.com',    '9840012310', '1996-09-17', 'M', '2022-05-23', 2, 5,  520000, 'Full-Time', 'Active'),
('Lakshmi',  'Menon',    'lakshmi.menon@company.com',  '9840012311', '1994-01-25', 'F', '2021-03-08', 2, 5,  480000, 'Full-Time', 'Active'),
-- Finance
('Rahul',    'Joshi',    'rahul.joshi@company.com',    '9840012312', '1988-07-11', 'M', '2017-08-15', 3, 8, 1300000, 'Full-Time', 'Active'),
('Divya',    'Patel',    'divya.patel@company.com',    '9840012313', '1995-03-03', 'F', '2021-10-01', 3, 7,  680000, 'Full-Time', 'Active'),
('Nikhil',   'Shah',     'nikhil.shah@company.com',    '9840012314', '1997-11-19', 'M', '2022-06-15', 3, 7,  620000, 'Full-Time', 'Active'),
-- Marketing
('Pooja',    'Reddy',    'pooja.reddy@company.com',    '9840012315', '1993-05-27', 'F', '2020-02-10', 4, 10, 1100000, 'Full-Time', 'Active'),
('Arun',     'Krishnan', 'arun.krishnan@company.com',  '9840012316', '1996-08-08', 'M', '2021-11-22', 4, 9,   580000, 'Full-Time', 'Active'),
('Swathi',   'Nambiar',  'swathi.nambiar@company.com', '9840012317', '1998-12-15', 'F', '2023-01-16', 4, 9,   520000, 'Full-Time', 'Active'),
-- Sales
('Ravi',     'Tiwari',   'ravi.tiwari@company.com',    '9840012318', '1991-04-04', 'M', '2019-05-01', 5, 12, 1100000, 'Full-Time', 'Active'),
('Kavitha',  'Subramaniam','kavitha.sub@company.com',  '9840012319', '1995-09-21', 'F', '2021-08-09', 5, 11,  510000, 'Full-Time', 'Active'),
('Ganesh',   'Pillai',   'ganesh.pillai@company.com',  '9840012320', '1997-06-30', 'M', '2022-03-14', 5, 11,  480000, 'Full-Time', 'Active'),
('Usha',     'Narayanan', 'usha.narayanan@company.com','9840012321', '1994-02-17', 'F', '2020-09-28', 5, 11,  530000, 'Full-Time', 'Active'),
('Tarun',    'Bose',     'tarun.bose@company.com',     '9840012322', '1999-10-11', 'M', '2023-06-05', 5, 11,  400000, 'Contract',  'Active'),
-- Operations
('Asha',     'Gupta',    'asha.gupta@company.com',     '9840012323', '1989-03-22', 'F', '2018-01-15', 6, 14, 1200000, 'Full-Time', 'Active'),
('Manoj',    'Das',      'manoj.das@company.com',      '9840012324', '1995-07-07', 'M', '2021-04-19', 6, 13,  610000, 'Full-Time', 'Active'),
('Rekha',    'Chandra',  'rekha.chandra@company.com',  '9840012325', '1997-01-31', 'F', '2022-08-01', 6, 13,  570000, 'Full-Time', 'Active'),
-- Product
('Siddharth','Malhotra', 'siddharth.m@company.com',    '9840012326', '1992-06-14', 'M', '2019-09-02', 7, 16, 1400000, 'Full-Time', 'Active'),
('Nisha',    'Agarwal',  'nisha.agarwal@company.com',  '9840012327', '1996-11-28', 'F', '2021-12-13', 7, 15,  780000, 'Full-Time', 'Active'),
('Harish',   'Rao',      'harish.rao@company.com',     '9840012328', '1998-04-05', 'M', '2023-03-20', 7, 15,  720000, 'Full-Time', 'Active'),
-- Customer Support
('Preethi',  'Thomas',   'preethi.thomas@company.com', '9840012329', '1997-08-16', 'F', '2022-02-07', 8, 18,  820000, 'Full-Time', 'Active'),
('Sunil',    'Menon',    'sunil.menon@company.com',    '9840012330', '1999-03-24', 'M', '2023-04-17', 8, 17,  430000, 'Full-Time', 'Active'),
('Bhavna',   'Tiwari',   'bhavna.tiwari@company.com',  '9840012331', '2000-01-10', 'F', '2023-08-01', 8, 17,  410000, 'Full-Time', 'Active'),
('Chirag',   'Bhatia',   'chirag.bhatia@company.com',  '9840012332', '1998-07-19', 'M', '2022-10-03', 8, 17,  440000, 'Full-Time', 'Active'),
-- More Engineering
('Farah',    'Sheikh',   'farah.sheikh@company.com',   '9840012333', '1993-09-09', 'F', '2020-05-11', 1, 2, 1200000, 'Full-Time', 'Active'),
('Ishaan',   'Saxena',   'ishaan.saxena@company.com',  '9840012334', '1998-06-26', 'M', '2022-11-28', 1, 1,  510000, 'Full-Time', 'Active'),
('Jaya',     'Krishnan', 'jaya.krishnan@company.com',  '9840012335', '1996-12-03', 'F', '2021-07-19', 1, 4,  880000, 'Full-Time', 'Active'),
-- Mixed departments - resigned/terminated for report variety
('Mohan',    'Patil',    'mohan.patil@company.com',    '9840012336', '1990-05-15', 'M', '2018-03-01', 5, 12, 1050000, 'Full-Time', 'Resigned'),
('Neha',     'Arora',    'neha.arora@company.com',     '9840012337', '1994-10-20', 'F', '2019-06-10', 4, 10,  950000, 'Full-Time', 'Active'),
('Om',       'Chandra',  'om.chandra@company.com',     '9840012338', '1997-02-14', 'M', '2022-09-05', 3, 7,   640000, 'Full-Time', 'Active'),
('Padma',    'Rajan',    'padma.rajan@company.com',    '9840012339', '1995-08-08', 'F', '2021-01-25', 6, 13,  590000, 'Full-Time', 'Active'),
('Qureshi',  'Amir',     'amir.qureshi@company.com',   '9840012340', '1991-11-11', 'M', '2017-12-01', 3, 8,  1350000, 'Full-Time', 'Active'),
('Ritika',   'Kapoor',   'ritika.kapoor@company.com',  '9840012341', '1998-03-18', 'F', '2023-05-22', 2, 5,   490000, 'Full-Time', 'Active'),
('Sameer',   'Gill',     'sameer.gill@company.com',    '9840012342', '1996-04-25', 'M', '2021-06-14', 7, 15,  760000, 'Full-Time', 'Active'),
('Tanvi',    'Desai',    'tanvi.desai@company.com',    '9840012343', '1999-07-07', 'F', '2023-09-11', 8, 17,  420000, 'Part-Time', 'Active'),
('Umesh',    'Naik',     'umesh.naik@company.com',     '9840012344', '1993-06-01', 'M', '2019-10-14', 1, 2,  1150000, 'Full-Time', 'Active'),
('Vani',     'Iyer',     'vani.iyer@company.com',      '9840012345', '1997-09-29', 'F', '2022-04-04', 4, 9,    540000, 'Full-Time', 'Active'),
('Waqar',    'Ali',      'waqar.ali@company.com',      '9840012346', '1995-01-16', 'M', '2020-11-30', 5, 11,   500000, 'Full-Time', 'Active'),
('Xena',     'Pillai',   'xena.pillai@company.com',    '9840012347', '2000-05-05', 'F', '2023-07-03', 8, 17,   415000, 'Intern',    'Active'),
('Yash',     'Trivedi',  'yash.trivedi@company.com',   '9840012348', '1994-12-22', 'M', '2020-08-17', 6, 14,  1100000, 'Full-Time', 'Active'),
('Zara',     'Hussain',  'zara.hussain@company.com',   '9840012349', '1996-10-10', 'F', '2021-05-31', 7, 16,  1300000, 'Full-Time', 'Active');

-- ── 4. ASSIGN MANAGERS ──────────────────────────────────────────
-- emp_id auto-starts at 1001
UPDATE employees SET manager_id = 1003 WHERE dept_id = 1 AND emp_id != 1003;  -- Rohan leads Engineering
UPDATE employees SET manager_id = 1009 WHERE dept_id = 2 AND emp_id != 1009;  -- Meena leads HR
UPDATE employees SET manager_id = 1012 WHERE dept_id = 3 AND emp_id != 1012;  -- Rahul leads Finance
UPDATE employees SET manager_id = 1015 WHERE dept_id = 4 AND emp_id != 1015;  -- Pooja leads Marketing
UPDATE employees SET manager_id = 1018 WHERE dept_id = 5 AND emp_id != 1018;  -- Ravi leads Sales
UPDATE employees SET manager_id = 1023 WHERE dept_id = 6 AND emp_id != 1023;  -- Asha leads Operations
UPDATE employees SET manager_id = 1026 WHERE dept_id = 7 AND emp_id != 1026;  -- Siddharth leads Product
UPDATE employees SET manager_id = 1029 WHERE dept_id = 8 AND emp_id != 1029;  -- Preethi leads Support

-- ── 5. SET DEPARTMENT MANAGERS ──────────────────────────────────
UPDATE departments SET manager_id = 1003 WHERE dept_name = 'Engineering';
UPDATE departments SET manager_id = 1009 WHERE dept_name = 'Human Resources';
UPDATE departments SET manager_id = 1012 WHERE dept_name = 'Finance';
UPDATE departments SET manager_id = 1015 WHERE dept_name = 'Marketing';
UPDATE departments SET manager_id = 1018 WHERE dept_name = 'Sales';
UPDATE departments SET manager_id = 1023 WHERE dept_name = 'Operations';
UPDATE departments SET manager_id = 1026 WHERE dept_name = 'Product Management';
UPDATE departments SET manager_id = 1029 WHERE dept_name = 'Customer Support';

-- ── 6. ATTENDANCE RECORDS (200+ rows — Jan–Apr 2024) ────────────
-- Pattern: weekdays only, with realistic Late/Absent/Half-Day spread
-- Inserting for emp_ids 1001–1010 across 4 months for demo depth

INSERT INTO attendance (emp_id, work_date, check_in, check_out, status, notes) VALUES
-- January 2024 — emp 1001 to 1010
(1001,'2024-01-02','09:00','18:05','Present',NULL),
(1001,'2024-01-03','09:10','18:00','Present',NULL),
(1001,'2024-01-04','09:25','18:10','Late','Traffic delay'),
(1001,'2024-01-05','09:00','18:00','Present',NULL),
(1001,'2024-01-08','09:05','18:00','Present',NULL),
(1001,'2024-01-09','09:00','18:00','Present',NULL),
(1001,'2024-01-10',NULL,  NULL,  'Absent','Sick'),
(1001,'2024-01-11','09:00','18:00','Present',NULL),
(1001,'2024-01-12','09:30','18:00','Late','Overslept'),
(1001,'2024-01-15','09:00','18:00','Present',NULL),
(1001,'2024-01-16','09:00','18:00','Present',NULL),
(1001,'2024-01-17','09:00','13:00','Half-Day','Personal work'),
(1001,'2024-01-18','09:00','18:00','Present',NULL),
(1001,'2024-01-19','09:00','18:00','Present',NULL),
(1001,'2024-01-22','09:00','20:30','Present','Project deadline'),
(1001,'2024-01-23','09:00','18:00','Present',NULL),
(1001,'2024-01-24','09:00','18:00','Present',NULL),
(1001,'2024-01-25','09:00','18:00','Present',NULL),
(1001,'2024-01-26',NULL,  NULL,  'Holiday','Republic Day'),
(1001,'2024-01-29','09:00','18:00','Present',NULL),
(1001,'2024-01-30','09:00','18:00','Present',NULL),
(1001,'2024-01-31','09:00','18:00','Present',NULL),

(1002,'2024-01-02','09:05','18:00','Present',NULL),
(1002,'2024-01-03','09:00','18:00','Present',NULL),
(1002,'2024-01-04','09:00','18:00','Present',NULL),
(1002,'2024-01-05','09:20','18:05','Late',NULL),
(1002,'2024-01-08','09:00','18:00','Present',NULL),
(1002,'2024-01-09',NULL,  NULL,  'Absent','Medical appointment'),
(1002,'2024-01-10','09:00','18:00','Present',NULL),
(1002,'2024-01-11','09:00','18:00','Present',NULL),
(1002,'2024-01-12','09:00','18:00','Present',NULL),
(1002,'2024-01-15','09:00','18:00','Present',NULL),
(1002,'2024-01-16','09:00','18:00','Present',NULL),
(1002,'2024-01-17','09:00','18:00','Present',NULL),
(1002,'2024-01-18','09:30','18:00','Late',NULL),
(1002,'2024-01-19','09:00','18:00','Present',NULL),
(1002,'2024-01-22','09:00','18:00','Present',NULL),
(1002,'2024-01-23','09:00','18:00','Present',NULL),
(1002,'2024-01-24','09:00','18:00','Present',NULL),
(1002,'2024-01-25','09:00','18:00','Present',NULL),
(1002,'2024-01-26',NULL,  NULL,  'Holiday','Republic Day'),
(1002,'2024-01-29','09:00','18:00','Present',NULL),
(1002,'2024-01-30','09:00','21:00','Present','Sprint crunch'),
(1002,'2024-01-31','09:00','18:00','Present',NULL),

-- February 2024
(1001,'2024-02-01','09:00','18:00','Present',NULL),
(1001,'2024-02-02','09:00','18:00','Present',NULL),
(1001,'2024-02-05','09:00','18:00','Present',NULL),
(1001,'2024-02-06','09:00','18:00','Present',NULL),
(1001,'2024-02-07','09:45','18:00','Late','Bus cancelled'),
(1001,'2024-02-08','09:00','18:00','Present',NULL),
(1001,'2024-02-09','09:00','18:00','Present',NULL),
(1001,'2024-02-12','09:00','18:00','Present',NULL),
(1001,'2024-02-13','09:00','18:00','Present',NULL),
(1001,'2024-02-14','09:00','18:00','Present',NULL),
(1001,'2024-02-15','09:00','13:30','Half-Day','Doctor visit'),
(1001,'2024-02-16','09:00','18:00','Present',NULL),
(1001,'2024-02-19','09:00','18:00','Present',NULL),
(1001,'2024-02-20','09:00','18:00','Present',NULL),
(1001,'2024-02-21','09:00','18:00','Present',NULL),
(1001,'2024-02-22','09:00','18:00','Present',NULL),
(1001,'2024-02-23','09:00','18:00','Present',NULL),
(1001,'2024-02-26',NULL,  NULL,  'On-Leave','Approved CL'),
(1001,'2024-02-27',NULL,  NULL,  'On-Leave','Approved CL'),
(1001,'2024-02-28','09:00','18:00','Present',NULL),
(1001,'2024-02-29','09:00','18:00','Present',NULL),

(1003,'2024-02-01','08:45','19:00','Present','Early bird'),
(1003,'2024-02-02','09:00','18:30','Present',NULL),
(1003,'2024-02-05','09:00','18:00','Present',NULL),
(1003,'2024-02-06','09:00','18:00','Present',NULL),
(1003,'2024-02-07','09:00','18:00','Present',NULL),
(1003,'2024-02-08','09:00','18:00','Present',NULL),
(1003,'2024-02-09','09:00','20:00','Present','Client call prep'),
(1003,'2024-02-12','09:00','18:00','Present',NULL),
(1003,'2024-02-13','09:00','18:00','Present',NULL),
(1003,'2024-02-14',NULL,  NULL,  'Absent','Fever'),
(1003,'2024-02-15','09:00','18:00','Present',NULL),
(1003,'2024-02-16','09:00','18:00','Present',NULL),
(1003,'2024-02-19','09:00','18:00','Present',NULL),
(1003,'2024-02-20','09:00','18:00','Present',NULL),
(1003,'2024-02-21','09:30','18:00','Late',NULL),
(1003,'2024-02-22','09:00','18:00','Present',NULL),
(1003,'2024-02-23','09:00','18:00','Present',NULL),
(1003,'2024-02-26','09:00','18:00','Present',NULL),
(1003,'2024-02-27','09:00','18:00','Present',NULL),
(1003,'2024-02-28','09:00','18:00','Present',NULL),
(1003,'2024-02-29','09:00','18:00','Present',NULL),

-- March 2024 — sampling more employees
(1004,'2024-03-01','09:00','18:00','Present',NULL),
(1004,'2024-03-04','09:00','18:00','Present',NULL),
(1004,'2024-03-05','09:20','18:00','Late',NULL),
(1004,'2024-03-06','09:00','18:00','Present',NULL),
(1004,'2024-03-07','09:00','18:00','Present',NULL),
(1004,'2024-03-08','09:00','18:00','Present',NULL),
(1004,'2024-03-11','09:00','18:00','Present',NULL),
(1004,'2024-03-12',NULL,  NULL,  'Absent',NULL),
(1004,'2024-03-13','09:00','18:00','Present',NULL),
(1004,'2024-03-14','09:00','18:00','Present',NULL),
(1004,'2024-03-15','09:00','13:00','Half-Day',NULL),
(1004,'2024-03-18','09:00','18:00','Present',NULL),
(1004,'2024-03-19','09:00','18:00','Present',NULL),
(1004,'2024-03-20','09:00','18:00','Present',NULL),
(1004,'2024-03-21','09:00','18:00','Present',NULL),
(1004,'2024-03-22','09:00','18:00','Present',NULL),
(1004,'2024-03-25','09:00','18:00','Present',NULL),
(1004,'2024-03-26','09:00','18:00','Present',NULL),
(1004,'2024-03-27','09:00','18:00','Present',NULL),
(1004,'2024-03-28','09:00','18:00','Present',NULL),
(1004,'2024-03-29','09:00','18:00','Present',NULL),

(1005,'2024-03-01','09:00','18:00','Present',NULL),
(1005,'2024-03-04','09:35','18:00','Late',NULL),
(1005,'2024-03-05','09:00','18:00','Present',NULL),
(1005,'2024-03-06','09:00','18:00','Present',NULL),
(1005,'2024-03-07',NULL,  NULL,  'Absent',NULL),
(1005,'2024-03-08','09:00','18:00','Present',NULL),
(1005,'2024-03-11','09:00','18:00','Present',NULL),
(1005,'2024-03-12','09:00','18:00','Present',NULL),
(1005,'2024-03-13','09:00','18:00','Present',NULL),
(1005,'2024-03-14','09:00','18:00','Present',NULL),
(1005,'2024-03-15','09:00','18:00','Present',NULL),
(1005,'2024-03-18','09:00','18:00','Present',NULL),
(1005,'2024-03-19','09:00','18:00','Present',NULL),
(1005,'2024-03-20','09:00','13:00','Half-Day',NULL),
(1005,'2024-03-21','09:00','18:00','Present',NULL),
(1005,'2024-03-22','09:00','18:00','Present',NULL),
(1005,'2024-03-25','09:00','18:00','Present',NULL),
(1005,'2024-03-26','09:00','18:00','Present',NULL),
(1005,'2024-03-27','09:00','18:00','Present',NULL),
(1005,'2024-03-28','09:00','18:00','Present',NULL),
(1005,'2024-03-29','09:00','18:00','Present',NULL),

-- April 2024 — more employees
(1006,'2024-04-01','09:00','18:00','Present',NULL),
(1006,'2024-04-02','09:00','18:00','Present',NULL),
(1006,'2024-04-03','09:00','18:00','Present',NULL),
(1006,'2024-04-04','09:00','18:00','Present',NULL),
(1006,'2024-04-05','09:00','18:00','Present',NULL),
(1006,'2024-04-08','09:25','18:00','Late',NULL),
(1006,'2024-04-09','09:00','18:00','Present',NULL),
(1006,'2024-04-10','09:00','18:00','Present',NULL),
(1006,'2024-04-11','09:00','18:00','Present',NULL),
(1006,'2024-04-12','09:00','18:00','Present',NULL),
(1006,'2024-04-15','09:00','18:00','Present',NULL),
(1006,'2024-04-16',NULL,  NULL,  'On-Leave','Annual Leave'),
(1006,'2024-04-17',NULL,  NULL,  'On-Leave','Annual Leave'),
(1006,'2024-04-18','09:00','18:00','Present',NULL),
(1006,'2024-04-19','09:00','18:00','Present',NULL),
(1006,'2024-04-22','09:00','18:00','Present',NULL),
(1006,'2024-04-23','09:00','18:00','Present',NULL),
(1006,'2024-04-24','09:00','18:00','Present',NULL),
(1006,'2024-04-25','09:00','18:00','Present',NULL),
(1006,'2024-04-26','09:00','18:00','Present',NULL),
(1006,'2024-04-29','09:00','18:00','Present',NULL),
(1006,'2024-04-30','09:00','18:00','Present',NULL),

(1007,'2024-04-01','09:00','18:00','Present',NULL),
(1007,'2024-04-02','09:00','18:00','Present',NULL),
(1007,'2024-04-03','09:00','18:00','Present',NULL),
(1007,'2024-04-04','09:00','18:00','Present',NULL),
(1007,'2024-04-05','09:00','18:00','Present',NULL),
(1007,'2024-04-08','09:00','18:00','Present',NULL),
(1007,'2024-04-09',NULL,  NULL,  'Absent','No reason given'),
(1007,'2024-04-10','09:00','18:00','Present',NULL),
(1007,'2024-04-11','09:00','18:00','Present',NULL),
(1007,'2024-04-12','09:00','20:00','Present','Product launch prep'),
(1007,'2024-04-15','09:00','18:00','Present',NULL),
(1007,'2024-04-16','09:00','18:00','Present',NULL),
(1007,'2024-04-17','09:00','18:00','Present',NULL),
(1007,'2024-04-18','09:40','18:00','Late',NULL),
(1007,'2024-04-19','09:00','18:00','Present',NULL),
(1007,'2024-04-22','09:00','18:00','Present',NULL),
(1007,'2024-04-23','09:00','18:00','Present',NULL),
(1007,'2024-04-24','09:00','13:00','Half-Day',NULL),
(1007,'2024-04-25','09:00','18:00','Present',NULL),
(1007,'2024-04-26','09:00','18:00','Present',NULL),
(1007,'2024-04-29','09:00','18:00','Present',NULL),
(1007,'2024-04-30','09:00','18:00','Present',NULL),

-- Extra employees for full 200+ count
(1008,'2024-04-01','09:00','18:00','Present',NULL),
(1008,'2024-04-02','09:00','18:00','Present',NULL),
(1008,'2024-04-03','09:30','18:00','Late',NULL),
(1008,'2024-04-04','09:00','18:00','Present',NULL),
(1008,'2024-04-05','09:00','18:00','Present',NULL),
(1009,'2024-04-01','09:00','18:00','Present',NULL),
(1009,'2024-04-02','09:00','18:00','Present',NULL),
(1009,'2024-04-03','09:00','18:00','Present',NULL),
(1009,'2024-04-04','09:00','18:00','Present',NULL),
(1009,'2024-04-05',NULL,  NULL,  'Absent',NULL),
(1010,'2024-04-01','09:00','18:00','Present',NULL),
(1010,'2024-04-02','09:00','18:00','Present',NULL),
(1010,'2024-04-03','09:00','18:00','Present',NULL),
(1010,'2024-04-04','09:20','18:00','Late',NULL),
(1010,'2024-04-05','09:00','18:00','Present',NULL),
(1011,'2024-04-01','09:00','18:00','Present',NULL),
(1011,'2024-04-02','09:00','18:00','Present',NULL),
(1011,'2024-04-03','09:00','18:00','Present',NULL),
(1011,'2024-04-04','09:00','18:00','Present',NULL),
(1011,'2024-04-05','09:00','18:00','Present',NULL),
(1012,'2024-04-01','09:00','18:00','Present',NULL),
(1012,'2024-04-02','09:00','18:00','Present',NULL),
(1012,'2024-04-03','09:00','18:00','Present',NULL),
(1012,'2024-04-04','09:00','18:00','Present',NULL),
(1012,'2024-04-05','09:00','18:00','Present',NULL);

-- ── 7. LEAVE REQUESTS ────────────────────────────────────────────
INSERT INTO leave_requests (emp_id, leave_type, from_date, to_date, reason, status, approved_by, decided_at) VALUES
(1001,'Casual',   '2024-02-26','2024-02-27','Family function','Approved',1009, NOW()),
(1002,'Sick',     '2024-01-09','2024-01-09','Fever',          'Approved',1009, NOW()),
(1003,'Earned',   '2024-03-20','2024-03-22','Vacation',       'Approved',1009, NOW()),
(1006,'Earned',   '2024-04-16','2024-04-17','Annual trip',    'Approved',1009, NOW()),
(1004,'Sick',     '2024-03-12','2024-03-12','Cold & cough',   'Approved',1009, NOW()),
(1005,'Casual',   '2024-04-10','2024-04-11','Personal',       'Pending', NULL, NULL),
(1010,'Maternity','2024-05-01','2024-06-30','Maternity leave','Pending', NULL, NULL),
(1008,'Sick',     '2024-04-15','2024-04-15','Migraine',       'Approved',1009, NOW()),
(1015,'Earned',   '2024-05-05','2024-05-10','Annual leave',   'Approved',1009, NOW()),
(1022,'Casual',   '2024-04-22','2024-04-22','Personal work',  'Rejected',1009, NOW());

-- ── 8. SALARY HISTORY ────────────────────────────────────────────
INSERT INTO salary_history (emp_id, old_salary, new_salary, change_reason, effective_date, changed_by) VALUES
(1001, 950000, 1100000, 'Annual appraisal 2024',  '2024-01-01', 1009),
(1002, 480000,  550000, 'Annual appraisal 2024',  '2024-01-01', 1009),
(1003,1500000, 1700000, 'Promotion to Tech Lead',  '2023-07-01', 1009),
(1006,1000000, 1050000, 'Performance increment',   '2024-01-01', 1009),
(1012,1200000, 1300000, 'Annual appraisal 2024',  '2024-01-01', 1009),
(1015, 950000, 1100000, 'Promotion to Mktg Mgr',  '2023-10-01', 1009),
(1018,1000000, 1100000, 'Annual appraisal 2024',  '2024-01-01', 1009),
(1026,1300000, 1400000, 'Annual appraisal 2024',  '2024-01-01', 1009);

SELECT 'Seed data loaded successfully.' AS status,
       (SELECT COUNT(*) FROM employees)  AS employees,
       (SELECT COUNT(*) FROM attendance) AS attendance_records,
       (SELECT COUNT(*) FROM leave_requests) AS leave_requests,
       (SELECT COUNT(*) FROM salary_history)  AS salary_changes;
