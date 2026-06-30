# Normalization to 3NF — Online Retail Sales Database

## What is Normalization?

Normalization is the process of organizing a relational database to reduce data redundancy and improve data integrity. Each "Normal Form" (NF) adds additional constraints.

---

## First Normal Form (1NF)

**Rule:** Every column must contain atomic (indivisible) values. No repeating groups. Every table must have a primary key.

### ❌ Violation Example (Unnormalized)

| order_id | customer_name | products_ordered          | city        |
|----------|--------------|--------------------------|-------------|
| 101      | Aarav Sharma  | iPhone 15, AirPods Pro   | Chennai     |
| 102      | Priya Patel   | Anarkali Kurta           | Mumbai      |

**Problems:**
- `products_ordered` contains multiple values in one column (not atomic)
- Cannot query "find all orders containing iPhone 15" efficiently

### ✅ After 1NF

Split into `orders` and `order_items`:

| order_id | customer_name | city    |
|----------|--------------|---------|
| 101      | Aarav Sharma  | Chennai |
| 101      | Aarav Sharma  | Chennai |
| 102      | Priya Patel   | Mumbai  |

| order_id | product_name |
|----------|-------------|
| 101      | iPhone 15   |
| 101      | AirPods Pro |
| 102      | Anarkali Kurta |

**In our schema:** Every table has a single-column primary key. `order_items` stores one product per row. No arrays or comma-separated values anywhere.

---

## Second Normal Form (2NF)

**Rule:** Must be in 1NF. Every non-key attribute must depend on the **entire** primary key, not just part of it. (Eliminates partial dependencies — only relevant when PK is composite.)

### ❌ Violation Example

Suppose `order_items` had a composite PK of `(order_id, product_id)`:

| order_id | product_id | quantity | product_name   | category_name |
|----------|-----------|----------|----------------|---------------|
| 101      | 2         | 1        | iPhone 15      | Mobiles       |
| 101      | 11        | 1        | Sony XM5       | Audio         |

**Problem:**
- `product_name` depends only on `product_id` — not on the full `(order_id, product_id)` PK
- `category_name` depends only on `product_id`
- This is a **partial dependency**

### ✅ After 2NF

Move product details to a separate `products` table:

**order_items:** `(order_id, product_id, quantity, unit_price, discount_pct)`  
**products:** `(product_id, product_name, category_id, unit_price, ...)`

**In our schema:** `order_items` only stores `quantity`, `unit_price` (snapshot), and `discount_pct` — all of which genuinely depend on the combination of `(order_id, product_id)`. All product info lives in `products`.

---

## Third Normal Form (3NF)

**Rule:** Must be in 2NF. No non-key attribute should depend on another non-key attribute. (Eliminates transitive dependencies.)

### ❌ Violation Example

| customer_id | customer_name | city_name | state_name   | country_name |
|-------------|--------------|-----------|--------------|-------------|
| 1           | Aarav Sharma  | Chennai   | Tamil Nadu   | India       |
| 2           | Priya Patel   | Mumbai    | Maharashtra  | India       |

**Problem:**
- `state_name` depends on `city_name`, not directly on `customer_id`
- `country_name` depends on `state_name`, not directly on `customer_id`
- These are **transitive dependencies**: `customer_id → city_name → state_name → country_name`
- If we rename "Tamil Nadu" to something else, we'd update hundreds of customer rows

### ✅ After 3NF

Split into separate reference tables:

**countries:** `(country_id, country_name, country_code)`  
**states:** `(state_id, state_name, country_id)`  
**cities:** `(city_id, city_name, state_id, pincode)`  
**addresses:** `(address_id, customer_id, address_line1, city_id, ...)`

**In our schema:** This is exactly what we did. `customers` has no city/state/country columns. All location data is normalized into `countries → states → cities`, and linked via `addresses.city_id`.

---

## Other 3NF Decisions in This Schema

### Snapshot Pricing in order_items
```sql
order_items.unit_price  -- stored at time of purchase
```
If we only stored `product_id` and derived price from `products.unit_price`, the order total would change every time the product price changes. Storing price at order time ensures historical accuracy and removes a transitive dependency.

### Self-Referencing categories
```sql
categories.parent_id REFERENCES categories(category_id)
```
Instead of storing `parent_category_name` as a column (which would be a transitive dependency), we store `parent_id` and join to the same table. This supports unlimited nesting depth cleanly.

### Addresses Separated from Customers
A customer can have multiple addresses (home, work, etc.). Storing address columns directly on `customers` would:
- Limit to one address per customer
- Create NULL columns for unused address types
- Violate 1NF if we tried to store multiple addresses in one field

---

## Summary Table

| Normal Form | Rule | Violation Fixed |
|-------------|------|----------------|
| 1NF | Atomic values, no repeating groups, PK defined | Removed `products_ordered` multi-value column |
| 2NF | No partial dependencies on composite PK | Moved `product_name`, `category_name` out of `order_items` |
| 3NF | No transitive dependencies | Split location into `countries → states → cities` |

---

## Benefits Achieved

- **No redundancy:** "Tamil Nadu" stored once in `states`, not 50 times in `customers`
- **Update anomaly prevented:** Changing a city name requires one UPDATE in `cities`
- **Insert anomaly prevented:** Can add a new city without needing a customer
- **Delete anomaly prevented:** Deleting a customer doesn't lose city data
- **Query performance:** Indexes on all FK columns, normalized lookups are fast

---

*Part of Online Retail Sales Database Design — Elevate Labs Internship*
