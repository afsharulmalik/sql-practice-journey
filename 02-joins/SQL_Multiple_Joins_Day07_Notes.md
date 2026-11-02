# SQL Notes — Multiple JOINs (PostgreSQL)

## 1. What Are Multiple JOINs?

**Multiple JOINs** means joining three or more tables in one SQL query. This is useful when the information needed for a result is stored across related tables.

Example:
- `customers` stores customer details.
- `orders` stores orders placed by customers.
- `products` stores product details.

To show a customer's name and the product they ordered, join all three tables.

## 2. Example Tables

### `customers`

| customer_id | name |
|---:|---|
| 1 | Rahul |
| 2 | Aman |
| 3 | Priya |

### `orders`

| order_id | customer_id | product_id | amount |
|---:|---:|---:|---:|
| 101 | 1 | 201 | 50000 |
| 102 | 2 | 202 | 20000 |
| 103 | 1 | 203 | 1500 |

### `products`

| product_id | product_name |
|---:|---|
| 201 | Laptop |
| 202 | Mobile |
| 203 | Keyboard |
| 204 | Mouse |

`orders.product_id` links an order to a product. `orders.customer_id` links an order to a customer. Product 204 has no order, which is useful for understanding `LEFT JOIN`.

> The `amount` column is included for the aggregate examples later in these notes.

---

## 3. Basic Multiple JOIN — Three Tables

**Question:** Show each customer's name, order ID, and product name.

```sql
SELECT
    c.name AS customer_name,
    o.order_id,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id;
```

### Logic
1. Start with `customers`.
2. Join `orders` where customer IDs match.
3. Join `products` where product IDs match.
4. Return the requested columns.

**Expected result with the sample data:**

| customer_name | order_id | product_name |
|---|---:|---|
| Rahul | 101 | Laptop |
| Aman | 102 | Mobile |
| Rahul | 103 | Keyboard |

`INNER JOIN` returns only rows with matches in the joined tables.

---

## 4. Multiple JOIN with `WHERE`

**Question:** Show Rahul's orders and the products associated with those orders.

```sql
SELECT
    c.name AS customer_name,
    o.order_id,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
WHERE c.name = 'Rahul';
```

### Logic
- The JOINs connect customer, order, and product rows.
- `WHERE c.name = 'Rahul'` filters the joined rows to Rahul.
- `WHERE` filters rows before grouping/aggregation.

---

## 5. Multiple JOIN with `ORDER BY`

**Question:** Show customers and their products, ordered by customer name alphabetically.

```sql
SELECT
    c.name AS customer_name,
    o.order_id,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
ORDER BY c.name ASC, o.order_id ASC;
```

### Logic
- `ORDER BY c.name ASC` sorts customer names A to Z.
- `o.order_id ASC` is a secondary sort for rows with the same customer name.
- `ASC` means ascending; `DESC` means descending.

---

## 6. Multiple JOIN with `COUNT()` and `GROUP BY`

**Question:** Count each customer's orders.

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

### Logic
- `COUNT(o.order_id)` counts each customer's matching orders.
- `GROUP BY c.customer_id, c.name` creates one group per customer.
- Because this uses `INNER JOIN`, customers with no orders do not appear.

**PostgreSQL tip:** Group by the non-aggregated selected columns. Including the primary key and name, as shown here, is explicit and clear.

---

## 7. Multiple JOIN with `HAVING`

**Question:** Show customers who have placed at least two orders.

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;
```

### Logic
1. JOIN customers to orders.
2. Group the rows by customer.
3. Count each group's orders.
4. `HAVING` keeps only groups with a count of at least two.

**Remember:** `WHERE` filters individual rows; `HAVING` filters groups after aggregation.

If the output needs only customer names and order counts, joining `products` is unnecessary. Add a product JOIN only when product data is needed or the query specifically requires practicing multiple joins.

---

## 8. `LEFT JOIN` — Include Customers With No Orders

**Question:** Display all customers and their order counts, including customers who have no orders.

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_orders DESC, c.name ASC;
```

### Logic
- `LEFT JOIN` preserves every row from `customers`.
- For customers with no matching order, order columns are `NULL`.
- `COUNT(o.order_id)` ignores `NULL`, so the count is `0`.
- `COUNT(*)` would count the preserved unmatched customer row as 1, so it is not the right expression for this task.

---

## 9. Find Customers With No Orders

**Question:** Display only customers who have never placed an order.

```sql
SELECT
    c.name AS customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

### Logic
- The `LEFT JOIN` preserves customers without matches.
- For a customer with no order, `o.order_id` is `NULL`.
- `WHERE o.order_id IS NULL` filters the result to those customers.

No `GROUP BY` is needed because this query does not aggregate.

---

## 10. Count Products Ordered by Each Customer — Include All Customers

**Question:** Show every customer and the number of product-linked orders associated with them, including customers with no orders.

```sql
SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name;
```

### Logic
- Start from `customers` because every customer must be included.
- The first `LEFT JOIN` finds each customer's orders.
- The second `LEFT JOIN` matches each order to a product.
- `COUNT(p.product_id)` counts non-`NULL` matched products.
- Both joins are `LEFT JOIN`, so customers without orders remain in the result.

**Important distinction:** This query counts joined order-product rows, not necessarily distinct product types. If the task asks for unique product types, use `COUNT(DISTINCT p.product_id)`.

---

## 11. Count Orders Per Product — Include Products With No Orders

**Question:** Display every product and its order count, including products never ordered.

```sql
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC, p.product_name ASC;
```

### Logic
- Start with `products`, since every product must appear.
- `LEFT JOIN` finds matching orders but keeps products without orders.
- `COUNT(o.order_id)` returns 0 for a product with no matching order.
- `GROUP BY` calculates one count per product.
- `ORDER BY` sorts from most ordered to least ordered.

---

## 12. `SUM()` — Total Order Amount Per Customer

**Question:** Show every customer and their total order amount; display 0 if there are no orders.

```sql
SELECT
    c.name AS customer_name,
    COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

### Logic
- `SUM(o.amount)` adds each customer's order amounts.
- For a customer with no matching orders, `SUM()` returns `NULL`.
- `COALESCE(..., 0)` displays 0 instead of `NULL`.
- `LEFT JOIN` preserves customers with no orders.

---

## 13. `AVG()` — Average Order Amount Per Customer

**Question:** Show every customer and their average order amount; display 0 if there are no orders.

```sql
SELECT
    c.name AS customer_name,
    COALESCE(AVG(o.amount), 0) AS average_order_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

### Logic
- `AVG(o.amount)` calculates the average of non-`NULL` order amounts.
- `COALESCE(..., 0)` changes a `NULL` average to 0.
- A descriptive alias like `average_order_amount` makes the output clear.

---

## 14. Conditional Matching With `LEFT JOIN` — Orders Above 1000

**Question:** Count orders above 1000 for each customer while keeping every customer in the result.

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS orders_over_1000
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
    AND o.amount > 1000
GROUP BY c.customer_id, c.name;
```

### Logic
- The customer-to-order match requires both a matching customer ID and `amount > 1000`.
- The amount condition is in `ON`, not `WHERE`, so customers with no qualifying order remain.
- `COUNT(o.order_id)` returns 0 when no order meets the condition.

**Key lesson:** For a `LEFT JOIN`, a right-table condition in `WHERE` can remove unmatched left-side rows. Put the condition in `ON` when unmatched left-side rows must remain.

---

## 15. Common Mistakes

### Mistake 1: Missing `GROUP BY`

Incorrect:
```sql
SELECT c.name, COUNT(o.order_id)
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

Correct:
```sql
SELECT c.name, COUNT(o.order_id)
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

When selecting a non-aggregated column alongside an aggregate, group the non-aggregated columns.

### Mistake 2: Using `WHERE` for aggregate conditions

Incorrect:
```sql
WHERE COUNT(o.order_id) >= 2
```

Correct:
```sql
HAVING COUNT(o.order_id) >= 2
```

### Mistake 3: Using `COUNT(*)` for unmatched rows after `LEFT JOIN`

If a customer has no order, `LEFT JOIN` still produces a row for that customer with `NULL` order columns. `COUNT(*)` counts that row as 1, while `COUNT(o.order_id)` returns 0.

### Mistake 4: Starting from the wrong table

- Need all customers? Start from `customers` and use `LEFT JOIN`.
- Need all products? Start from `products` and use `LEFT JOIN`.
- Need only records that match across tables? Use `INNER JOIN`.

### Mistake 5: Joining tables unnecessarily

If the output needs only customer name and order count, the `customers` and `orders` tables are sufficient. Join `products` only if product information or a product-related condition is needed.

### Mistake 6: Incorrect `NULL` comparison

Incorrect:
```sql
WHERE o.order_id = NULL
```

Correct:
```sql
WHERE o.order_id IS NULL
```

Use `IS NULL` / `IS NOT NULL` to test for `NULL`.

---

## 16. Quick JOIN Decision Guide

| Requirement | Recommended approach |
|---|---|
| Only matching records from both tables | `INNER JOIN` |
| All customers, whether ordered or not | `customers LEFT JOIN orders` |
| All products, whether ordered or not | `products LEFT JOIN orders` |
| Customers who never ordered | `LEFT JOIN` + `WHERE o.order_id IS NULL` |
| Count orders per customer | `COUNT(o.order_id)` + `GROUP BY` |
| Filter groups by their count | `HAVING COUNT(...) ...` |
| Replace a `NULL` total/average with 0 | `COALESCE(aggregate, 0)` |
| Keep all left rows while matching only qualifying right rows | Put the right-table condition in `ON` |

---

## 17. Checklist Before Running a Multiple JOIN Query

- [ ] Have I included every table needed for the requested output?
- [ ] Does each `JOIN` have the correct `ON` condition?
- [ ] Which table's rows must all be preserved?
- [ ] Should this be `INNER JOIN` or `LEFT JOIN`?
- [ ] If using aggregates, have I grouped by the non-aggregated selected columns?
- [ ] Should the filter be in `WHERE`, `ON`, or `HAVING`?
- [ ] Am I counting a real right-table key with `COUNT(column)` when unmatched rows should count as zero?
- [ ] Are output aliases descriptive and accurate?
- [ ] Does `ORDER BY` match the requested sort order?

## Final Takeaway

Multiple JOINs connect related data across tables. Correct results depend on choosing the right join type, matching rows through the correct keys, selecting the right starting table when all rows must be preserved, and applying `WHERE`, `GROUP BY`, `HAVING`, and aggregate functions in the correct roles.
