-- ============================================================
--  MASTER RUN SCRIPT — Online Retail Sales Database
--  Run this file to set up the entire database at once.
--  Or run each file individually in the order shown below.
--
--  Prerequisites: PostgreSQL 13+
--
--  Option A — Run via psql CLI:
--    psql -U postgres -d online_retail_db -f 00_run_all.sql
--
--  Option B — Run files individually in pgAdmin:
--    1. schema/01_schema.sql
--    2. data/02_sample_data.sql
--    3. queries/03_analytical_queries.sql
--    4. views/04_views.sql
--    5. schema/05_triggers_functions.sql
--    6. reports/06_query_report.sql
-- ============================================================

-- STEP 0: Create and connect to database
-- Run this manually first:
-- CREATE DATABASE online_retail_db;
-- \c online_retail_db

-- STEP 1: Schema (tables, constraints, indexes)
\echo '>>> Step 1: Creating schema...'
\i schema/01_schema.sql

-- STEP 2: Sample data
\echo '>>> Step 2: Inserting sample data...'
\i data/02_sample_data.sql

-- STEP 3: Views
\echo '>>> Step 3: Creating views...'
\i views/04_views.sql

-- STEP 4: Triggers and functions
\echo '>>> Step 4: Creating triggers and functions...'
\i schema/05_triggers_functions.sql

-- STEP 5: Verify with report queries
\echo '>>> Step 5: Running report queries...'
\i reports/06_query_report.sql

\echo ''
\echo '============================================='
\echo ' Database setup complete!'
\echo ' Run queries/03_analytical_queries.sql next'
\echo ' for the full analytical query set.'
\echo '============================================='
