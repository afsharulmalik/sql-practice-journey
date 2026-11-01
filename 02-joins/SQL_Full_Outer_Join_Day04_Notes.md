# SQL FULL OUTER JOIN — Day 04 Notes

## 1. Definition

`FULL OUTER JOIN` returns all rows from both tables. Matching rows are combined, while unmatched rows from either table are also included with `NULL` values for the missing side.

## 2. Syntax

```sql
SELECT columns
FROM table1 AS t1
FULL OUTER JOIN table2 AS t2
    ON t1.id = t2.id;
```

- `SELECT`: selects the columns to display.
- `FROM`: specifies the left table.
- `FULL OUTER JOIN`: preserves matched and unmatched rows from both tables.
- `ON`: defines the matching condition.
- `NULL`: appears when a row has no match in the other table.

## 3. Example Tables

### customers

| customer_id | name |
|---:|---|
| 1 | Rahul |
| 2 | Aman |
| 3 | Priya |

### orders

| order_id | customer_id | amount |
|---:|---:|---:|
| 101 | 1 | 500 |
| 102 | 2 | 800 |
| 103 | 1 | 300 |
| 104 | 4 | 900 |

## 4. Example Query

```sql
SELECT
    c.customer_id,
    c.name,
    o.order_id,
    o.amount
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Expected Output

| customer_id | name | order_id | amount |
|---:|---|---:|---:|
| 1 | Rahul | 101 | 500 |
| 2 | Aman | 102 | 800 |
| 1 | Rahul | 103 | 300 |
| 3 | Priya | NULL | NULL |
| NULL | NULL | 104 | 900 |

Note: Row order is not guaranteed without `ORDER BY`.

## 5. Practice Questions with Solutions

### Q1. Display all customers and their orders, including unmatched records from both tables.

```sql
SELECT *
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q2. Display customer names and order IDs, including unmatched records.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q3. Display customers without orders and orders without matching customers.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
   OR o.customer_id IS NULL;
```

### Q4. Display customer names and order amounts where the amount is greater than 400 or the customer has no order.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 400
   OR o.order_id IS NULL;
```

### Q5. Display customer names and order IDs, sorted alphabetically by customer name.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.name ASC;
```

## 6. Important Points to Remember

1. `FULL OUTER JOIN` preserves all rows from both tables.
2. Matching rows are combined using the `ON` condition.
3. Unmatched rows contain `NULL` values for columns from the other table.
4. Use `IS NULL`, not `= NULL`, to check for NULL values.
5. Use `OR` when either unmatched condition should qualify.
6. Use `ORDER BY` for sorting; `GROUP BY` is for grouping records.

## 7. JOIN Comparison

| JOIN Type | What it returns |
|---|---|
| `INNER JOIN` | Only matching rows |
| `LEFT JOIN` | All left-table rows and matches |
| `RIGHT JOIN` | All right-table rows and matches |
| `FULL OUTER JOIN` | All rows from both tables |
