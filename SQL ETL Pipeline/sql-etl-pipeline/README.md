# 🗄️ SQL ETL Pipeline Simulation

A complete **Extract → Transform → Load** pipeline built entirely in **SQLite**, simulating a real-world data engineering workflow on a retail e-commerce dataset.

---

## 📁 Project Structure

```
sql-etl-pipeline/
├── data/
│   └── raw_sales_data.csv          ← Dirty input dataset (52 rows, intentional issues)
├── sql/
│   ├── staging/
│   │   ├── 01_create_staging.sql   ← EXTRACT: Create staging table + import
│   │   └── 02_profile_data.sql     ← PROFILE: Document data quality issues
│   ├── transform/
│   │   └── 03_clean_transform.sql  ← TRANSFORM: Dedup, null-fill, date fix, type cast
│   ├── production/
│   │   ├── 04_create_production_schema.sql  ← Star-schema DDL + indexes
│   │   ├── 05_load_production.sql           ← Load dims + fact from cleaned staging
│   │   ├── 08_analytical_reports.sql        ← 10 analytical queries
│   │   └── 09_views.sql                     ← 5 reusable report views
│   ├── audit/
│   │   └── 06_audit_log.sql        ← ETL run metadata & row counts
│   └── triggers/
│       └── 07_triggers.sql         ← 4 automation triggers
├── scripts/
│   └── MASTER_RUN.sql              ← Execution order + health check
├── reports/
│   ├── ETL_Report.txt              ← Plain-text analytical report output
│   └── Project_Report_SQL_ETL.pdf  ← 2-page internship submission report
├── etl_pipeline.db                 ← Final SQLite database (generated)
└── README.md
```

---

## 🚀 How to Run

### Option A — DB Browser for SQLite (GUI) — Recommended

1. Install **DB Browser for SQLite**: https://sqlitebrowser.org/dl/
2. Open DB Browser → **New Database** → Save as `etl_pipeline.db`
3. Go to **File → Import → Table from CSV file** → select `data/raw_sales_data.csv`
   - Table name: `stg_raw_sales`
   - First row = column names ✓
   - Click OK
4. Open each SQL file in the **Execute SQL** tab in this order:

| Order | File |
|---|---|
| 1 | `sql/staging/01_create_staging.sql` |
| 2 | `sql/staging/02_profile_data.sql` |
| 3 | `sql/transform/03_clean_transform.sql` |
| 4 | `sql/production/04_create_production_schema.sql` |
| 5 | `sql/production/05_load_production.sql` |
| 6 | `sql/audit/06_audit_log.sql` |
| 7 | `sql/triggers/07_triggers.sql` |
| 8 | `sql/production/08_analytical_reports.sql` |
| 9 | `sql/production/09_views.sql` |

5. Run `scripts/MASTER_RUN.sql` as a final health check.

### Option B — Python Script (auto-run)

```bash
pip install reportlab
python3 run_etl.py     # runs full pipeline, generates DB + reports
```

---

## 🔁 ETL Pipeline Flow

```
raw_sales_data.csv
        ↓  [EXTRACT]
  stg_raw_sales            ← all TEXT, 52 rows (incl. duplicates, nulls, bad dates)
        ↓  [PROFILE]
  Data Quality Report      ← 2 dups, 1 missing name, 1 missing price, 1 bad date
        ↓  [TRANSFORM]
  stg_cleaned_sales        ← 50 rows, typed, deduped, normalised
        ↓  [LOAD]
  ┌────────────────────────────────────────┐
  │  dim_cities      (7 cities)            │
  │  dim_customers   (50 customers)        │  ← Star Schema
  │  dim_products    (50 products)         │
  │  fact_orders     (50 rows)             │
  └────────────────────────────────────────┘
        ↓  [AUDIT]
  etl_audit_log            ← 6 stage entries, full pipeline metadata
        ↓  [TRIGGERS]
  - trg_after_insert_fact_orders   → fact_orders_insert_log
  - trg_validate_fact_orders       → RAISE on invalid total_amount
  - trg_order_status_change        → order_status_history
  - trg_staging_insert_audit       → updates audit counter
        ↓  [VIEWS]
  vw_order_detail / vw_monthly_revenue / vw_category_performance
  vw_city_revenue / vw_etl_health
```

---

## 🧹 Data Quality Issues Fixed

| Issue | Count | Fix Applied |
|---|---|---|
| Duplicate order rows | 2 | `GROUP BY order_id HAVING rowid = MIN(rowid)` |
| Missing customer name | 1 | `'Unknown Customer'` default |
| Missing unit price | 1 | `0.00` default + flagged in audit |
| Non-standard date (YYYY/MM/DD) | 1 | `REPLACE(order_date, '/', '-')` |
| Mixed TEXT types for numbers | All | `CAST(quantity AS INTEGER)`, `CAST(unit_price AS REAL)` |

---

## 📊 Key Results

- **Raw rows extracted:** 52
- **Clean rows after transform:** 50
- **Production fact rows loaded:** 50
- **Top revenue category:** Electronics (Rs 1,675.80)
- **Top city by revenue:** Mumbai
- **Most popular payment:** UPI

---

## 🛠 Tech Stack

- **Database:** SQLite 3
- **GUI Tool:** DB Browser for SQLite
- **SQL Features used:** DDL, DML, JOINs, GROUP BY, HAVING, Window Functions (RANK, SUM OVER), CTEs, Triggers, Views, Indexes, CHECK constraints, FOREIGN KEY references

---

## 📝 Top 50 Interview Questions

See `sql/` folder — all 9 SQL files together cover the following interview topics from the Elevate Labs list:

- Normalization (Q6), ACID (Q9), JOINs (Q10), Subqueries (Q18), Window Functions (Q21-22), Stored Procedures / Triggers (Q24-25), VIEWs (Q26), Indexes (Q27), ETL/Dirty data (Q46), and more.
