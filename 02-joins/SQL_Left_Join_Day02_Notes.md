# SQL LEFT JOIN — Day 02 Notes

## 1. Definition

`LEFT JOIN` returns all rows from the left table and matching rows from the right table. If there is no matching row in the right table, its columns contain `NULL`.

## 2. Syntax

```sql
SELECT columns
FROM table1 AS t1
LEFT JOIN table2 AS t2
    ON t1.id = t2.id;
```

- `SELECT`: specifies the columns to display.
- `FROM`: specifies the left table.
- `LEFT JOIN`: keeps all rows from the left table.
- `ON`: specifies the matching condition.
- `NULL`: appears when no matching row exists.

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
    c.name,
    o.order_id,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Expected Output

| name | order_id | amount |
|---|---:|---:|
| Rahul | 101 | 500 |
| Aman | 102 | 800 |
| Rahul | 103 | 300 |
| Priya | NULL | NULL |

Priya appears because `LEFT JOIN` preserves every customer, even when no matching order exists.

## 5. Practice Questions with Solutions

### Q1. Display all customer names and their order IDs, including customers with no orders.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q2. Display all customer names and order amounts.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q3. Display customers who have no orders.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### Q4. Display customer names and order amounts where the amount is greater than 400.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 400;
```

**Note:** Customers without orders are excluded because their `amount` is `NULL`, which does not satisfy `o.amount > 400`.

### Q5. Display all customer names and order IDs, sorted by customer name in ascending order.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.name ASC;
```

## 6. Important Points to Remember

1. `LEFT JOIN` preserves all rows from the left table.
2. Unmatched right-table columns return `NULL`.
3. Use `IS NULL`, not `= NULL`, to check for NULL values.
4. Use `WHERE o.order_id IS NULL` to find customers with no matching orders.
5. Use `ORDER BY c.name ASC` for alphabetical sorting.
6. Always join the correct key columns: `c.customer_id = o.customer_id`.
