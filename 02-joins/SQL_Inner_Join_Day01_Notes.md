# SQL INNER JOIN — Day 1 Notes

## 1. What is INNER JOIN?

`INNER JOIN` combines rows from two tables when the rows satisfy the join condition. Only matching rows are returned; rows without a match in either table are excluded.

**Basic syntax**

```sql
SELECT column1, column2
FROM table1 AS t1
INNER JOIN table2 AS t2
    ON t1.common_column = t2.common_column;
```

- `SELECT`: columns to display in the result.
- `FROM`: the first table.
- `INNER JOIN`: the second table to combine with the first.
- `ON`: the condition used to match related rows.
- `AS`: gives a table a short alias, such as `customers AS c` and `orders AS o`.

In PostgreSQL, writing `JOIN` without a join type means `INNER JOIN`.

## 2. Example tables

### `customers`

| customer_id | name |
|---:|---|
| 1 | Rahul |
| 2 | Aman |
| 3 | Priya |

### `orders`

| order_id | customer_id | amount |
|---:|---:|---:|
| 101 | 1 | 500 |
| 102 | 2 | 800 |
| 103 | 1 | 300 |
| 104 | 4 | 900 |

The two tables are related through `customer_id`. For example, customer ID `1` belongs to Rahul, so orders with `customer_id = 1` match Rahul.

### Example INNER JOIN

```sql
SELECT
    c.name,
    o.order_id,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

**Expected output**

| name | order_id | amount |
|---|---:|---:|
| Rahul | 101 | 500 |
| Aman | 102 | 800 |
| Rahul | 103 | 300 |

Priya is not returned because she has no matching order. Order `104` is not returned because its `customer_id` (`4`) has no matching customer in the example `customers` table.

## 3. Practice questions and correct solutions

These are the five INNER JOIN questions practiced today. Each solution includes only the columns requested in that question.

### Q1. Customer names and orders with amount above 500

**Task:** Display the customer name and order amount for orders greater than 500.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 500;
```

### Q2. Rahul's orders

**Task:** Display Rahul's customer name, order ID, and order amount.

```sql
SELECT
    c.name,
    o.order_id,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.name = 'Rahul';
```

### Q3. Orders above 500, excluding Rahul

**Task:** Display customer name, order ID, and amount when the amount is greater than 500 and the customer is not Rahul.

```sql
SELECT
    c.name,
    o.order_id,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 500
  AND c.name <> 'Rahul';
```

### Q4. Rahul's orders between 300 and 1000

**Task:** Display Rahul's name and order amount when the amount is between 300 and 1000, inclusive.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount BETWEEN 300 AND 1000
  AND c.name = 'Rahul';
```

### Q5. Rahul or Aman, with order amount above 500

**Task:** Display customer name and order amount for Rahul or Aman when the order amount is greater than 500.

```sql
SELECT
    c.name,
    o.amount
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 500
  AND c.name IN ('Rahul', 'Aman');
```

## 4. Key points to remember

- Use `ON` to match related columns from the two tables.
- Match `customers.customer_id` with `orders.customer_id` here, not with `orders.order_id`.
- Use `WHERE` to filter the joined rows.
- `AND` means both conditions must be true.
- `BETWEEN 300 AND 1000` includes both endpoints.
- `IN ('Rahul', 'Aman')` matches either name.
- `<> 'Rahul'` means “not Rahul”.
