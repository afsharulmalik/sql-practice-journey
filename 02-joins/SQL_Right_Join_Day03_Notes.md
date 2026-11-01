# SQL RIGHT JOIN — Day 03 Notes

## 1. Definition

`RIGHT JOIN` returns all rows from the right table and matching rows from the left table. If there is no matching row in the left table, its columns contain `NULL`.

## 2. Syntax

```sql
SELECT columns
FROM table1 AS t1
RIGHT JOIN table2 AS t2
    ON t1.id = t2.id;
```

- `SELECT`: selects the columns to display.
- `FROM`: specifies the left table.
- `RIGHT JOIN`: preserves all rows from the right table.
- `ON`: defines the matching condition.
- `NULL`: appears when no matching row exists in the left table.

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
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Expected Output

| name | order_id | amount |
|---|---:|---:|
| Rahul | 101 | 500 |
| Aman | 102 | 800 |
| Rahul | 103 | 300 |
| NULL | 104 | 900 |

Order 104 appears even though customer ID 4 does not exist in the `customers` table, because `orders` is the right table.

## 5. Practice Questions with Solutions

### Q1. Display all order IDs and customer names, including orders without a matching customer.

```sql
SELECT
    o.order_id,
    c.name
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q2. Display all order IDs and amounts, including orders without a matching customer.

```sql
SELECT
    o.order_id,
    o.amount
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

### Q3. Display orders that have no matching customer.

```sql
SELECT
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;
```

### Q4. Display order IDs and customer names for orders where the amount is greater than 400.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 400;
```

### Q5. Display all order IDs and customer names, sorted by order ID in descending order.

```sql
SELECT
    c.name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY o.order_id DESC;
```

## 6. Important Points to Remember

1. `RIGHT JOIN` preserves every row from the right table.
2. Unmatched left-table columns return `NULL`.
3. Use `IS NULL`, not `= NULL`, to check for NULL values.
4. Use `WHERE c.customer_id IS NULL` to find orders without matching customers.
5. `ORDER BY o.order_id DESC` sorts order IDs from highest to lowest.
6. Always match the correct columns: `c.customer_id = o.customer_id`.

## 7. JOIN Comparison

| JOIN Type | What it preserves |
|---|---|
| INNER JOIN | Only matching rows |
| LEFT JOIN | All left-table rows |
| RIGHT JOIN | All right-table rows |
