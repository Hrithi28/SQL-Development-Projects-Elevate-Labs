# Online Retail Sales Database Design
**Internship Project — Elevate Labs | SQL Domain**

---

## Project Overview

A fully normalized (3NF) relational database for an e-commerce platform, built with PostgreSQL. Covers the complete data model for products, customers, orders, payments, and reviews — with analytical queries, views, triggers, and stored functions.

---

## Project Structure

```
online-retail-db/
├── schema/
│   ├── 01_schema.sql            ← DDL: all tables, constraints, indexes
│   └── 05_triggers_functions.sql← Triggers + stored functions
├── data/
│   └── 02_sample_data.sql       ← 300+ records across all tables
├── queries/
│   └── 03_analytical_queries.sql← 32 queries: JOINs, CTEs, window functions
├── views/
│   └── 04_views.sql             ← 10 reusable views for reporting
├── reports/
│   └── 06_query_report.sql      ← 15 report queries using all views
├── docs/
│   ├── 07_er_diagram.dbml       ← ER diagram (paste at dbdiagram.io)
│   └── 08_normalization.md      ← 3NF explanation with examples
└── README.md
```

---

## Database Schema (11 Tables)

| Table | Description | Records |
|-------|-------------|---------|
| `countries` | Country master | 3 |
| `states` | State master | 10 |
| `cities` | City master | 16 |
| `categories` | Product categories (self-referencing) | 19 |
| `suppliers` | Product suppliers | 8 |
| `products` | Product catalog | 50 |
| `customers` | Customer accounts | 50 |
| `addresses` | Customer shipping addresses | 50 |
| `orders` | Purchase orders | 80 |
| `order_items` | Line items per order | 150+ |
| `payments` | Payment transactions | 50 |
| `product_reviews` | Customer reviews & ratings | 20 |

---

## Entity Relationships

```
countries ──< states ──< cities ──< addresses >── customers
                                                       │
                                                    orders ──< order_items >── products >── categories
                                                       │                                        │
                                                    payments                               suppliers
                                                       
customers ──< product_reviews >── products
categories ──< categories (self-ref: parent_id)
```

---

## Key Features

### Normalization (3NF)
- **1NF**: All columns atomic, primary keys defined on every table
- **2NF**: No partial dependencies — all non-key attributes depend on the full primary key
- **3NF**: No transitive dependencies — location data split into `countries → states → cities`; `unit_price` stored in `order_items` as a snapshot (not derived from `products`)

### Constraints Used
- `PRIMARY KEY`, `FOREIGN KEY` with `ON DELETE CASCADE`
- `UNIQUE` (email, SKU, transaction_ref)
- `CHECK` (rating 1–5, order_status enum, price ≥ 0)
- `DEFAULT` values (timestamps, status, flags)
- `NOT NULL` on all critical columns

### Indexes
- On all foreign key columns for JOIN performance
- On `order_date`, `order_status`, `payment_status` for filter queries
- On `sku` and `email` for lookup queries

### Triggers (5)
| Trigger | Event | Action |
|---------|-------|--------|
| `trg_customers_updated_at` | BEFORE UPDATE on customers | Sets `updated_at` timestamp |
| `trg_products_updated_at` | BEFORE UPDATE on products | Sets `updated_at` timestamp |
| `trg_decrease_stock` | AFTER INSERT on order_items | Deducts stock, raises error if insufficient |
| `trg_restore_stock_on_cancel` | AFTER UPDATE on orders | Restores stock when CANCELLED/RETURNED |
| `trg_award_loyalty_points` | AFTER UPDATE on orders | Awards 1 point per ₹100 on DELIVERED |
| `trg_validate_review` | BEFORE INSERT on product_reviews | Blocks review without delivered order |

### Stored Functions (3)
| Function | Description |
|----------|-------------|
| `fn_get_order_total(order_id)` | Returns subtotal, discount, shipping, net total |
| `fn_customer_history(customer_id)` | Full order history for a customer |
| `fn_monthly_revenue_report(year)` | Month-wise revenue report for given year |

### Views (10)
| View | Purpose |
|------|---------|
| `vw_order_details` | Full order info with customer, city, payment |
| `vw_product_performance` | Sales metrics + rating per product |
| `vw_customer_summary` | Purchase history + loyalty + status per customer |
| `vw_monthly_revenue` | Month-wise KPIs |
| `vw_category_revenue` | Revenue breakdown by category |
| `vw_top_products` | Revenue-ranked product leaderboard |
| `vw_low_stock_alert` | Products below reorder level |
| `vw_payment_summary` | Payment method & status breakdown |
| `vw_sales_summary` | Top-level dashboard KPIs |
| `vw_product_ratings` | Star rating distribution per product |

---

## How to Run

### Prerequisites
- PostgreSQL 13+ (or use [ElephantSQL](https://www.elephantsql.com/) free tier)
- pgAdmin 4 or psql CLI

### Step 1 — Create database
```sql
CREATE DATABASE online_retail_db;
\c online_retail_db
```

### Step 2 — Run files in order
```bash
psql -U postgres -d online_retail_db -f schema/01_schema.sql
psql -U postgres -d online_retail_db -f data/02_sample_data.sql
psql -U postgres -d online_retail_db -f queries/03_analytical_queries.sql
psql -U postgres -d online_retail_db -f views/04_views.sql
psql -U postgres -d online_retail_db -f schema/05_triggers_functions.sql
psql -U postgres -d online_retail_db -f reports/06_query_report.sql
```

Or open each file in **pgAdmin → Query Tool** and run them one by one.

### Step 3 — View ER Diagram
1. Open [https://dbdiagram.io](https://dbdiagram.io)
2. Paste the contents of `docs/07_er_diagram.dbml`
3. The diagram renders automatically

---

## Sample Query Results

### Top 5 Products by Revenue
```
product_name                    | category      | units_sold | revenue
--------------------------------|---------------|------------|----------
Apple MacBook Air M2            | Laptops       | 3          | 335247
Dell XPS 15                     | Laptops       | 3          | 427497
Apple iPhone 15                 | Mobiles       | 2          | 174598
Sony Alpha A7 III               | Cameras       | 1          | 143999
Samsung Galaxy S24              | Mobiles       | 4          | 303996
```

### Order Status Distribution
```
order_status | order_count | percentage
-------------|-------------|----------
DELIVERED    | 69          | 86.25%
CANCELLED    | 4           | 5.00%
SHIPPED      | 4           | 5.00%
PENDING      | 1           | 1.25%
RETURNED     | 2           | 2.50%
```

### Payment Method Share
```
payment_method | transactions | total_amount   | share%
---------------|--------------|----------------|-------
CREDIT_CARD    | 14           | 1,847,239      | 31.1%
UPI            | 18           | 284,612        | 40.0%
DEBIT_CARD     | 8            | 312,458        | 17.8%
NET_BANKING    | 6            | 598,712        | 13.3%
COD            | 3            | 7,760          | 6.7%
```

---

## SQL Concepts Covered

| Concept | Where Used |
|---------|-----------|
| DDL (CREATE, ALTER, DROP) | `01_schema.sql` |
| DML (INSERT, UPDATE) | `02_sample_data.sql` |
| INNER / LEFT JOIN | Q15, Q16, Q17, Q18 |
| GROUP BY + HAVING | Q6, Q7, Q8, Q9, Q10 |
| Subqueries | Q19, Q20, Q21 |
| Correlated Subquery | Q21 |
| WINDOW FUNCTIONS | Q22–Q26 (RANK, DENSE_RANK, ROW_NUMBER, LAG, NTILE, PERCENT_RANK) |
| CTE (WITH clause) | Q27, Q28, Q29 |
| Triggers | `05_triggers_functions.sql` |
| Stored Functions | `05_triggers_functions.sql` |
| Views | `04_views.sql` |
| Indexes | `01_schema.sql` |
| Constraints | `01_schema.sql` |
| Self-referencing FK | categories.parent_id |
| Aggregate Functions | SUM, COUNT, AVG, MAX, MIN |
| Date Functions | TO_CHAR, EXTRACT, DATE_TRUNC, AGE |

---

## Interview Questions Answered by This Project

This project directly covers questions 1–32 from the Top 50 SQL Interview Questions list:
- Q6: Normalization → `docs/08_normalization.md` + schema design
- Q10: All JOIN types → `03_analytical_queries.sql` Q15–Q18
- Q21–22: Window functions → Q22–Q26
- Q23: CTEs → Q27–Q29
- Q24: Stored procedures → `fn_monthly_revenue_report`
- Q25: Triggers → all 6 triggers in `05_triggers_functions.sql`
- Q26: Views → all 10 views in `04_views.sql`
- Q27: Indexes → `01_schema.sql` index section

---

*Built for Elevate Labs Internship — SQL Domain Project Phase*
