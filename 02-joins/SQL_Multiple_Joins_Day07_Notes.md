
# SQL Multiple JOINs — Practice Questions with Solutions

**Folder:** `02-joins`  
**File:** `SQL_Multiple_Joins_Day07_Notes.md`

## Sample Schema

- `customers(customer_id, name)`
- `orders(order_id, customer_id, product_id, amount)`
- `products(product_id, product_name)`

### Sample Data

**customers**

| customer_id | name |
|---:|---|
| 1 | Rahul |
| 2 | Aman |
| 3 | Priya |

**orders**

| order_id | customer_id | product_id | amount |
|---:|---:|---:|---:|
| 101 | 1 | 201 | 50000 |
| 102 | 2 | 202 | 20000 |
| 103 | 1 | 203 | 1500 |

**products**

| product_id | product_name |
|---:|---|
| 201 | Laptop |
| 202 | Mobile |
| 203 | Keyboard |
| 204 | Mouse |

Note: `amount` column is assumed for SUM, AVG and amount-filter questions.

---

## Q1. Display Customer Names and Order IDs

```sql
SELECT
    c.name AS customer_name,
    o.order_id
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

**Logic:** `INNER JOIN` returns customers who have matching orders. The `ON` condition matches records using `customer_id`.

## Q2. Display Customer Names and Product Names

```sql
SELECT
    c.name AS customer_name,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id;
```

**Logic:**
1. Join customers with orders.
2. Join orders with products.
3. Select the customer name and product name.

Each JOIN needs its own correct `ON` condition.

## Q3. Display Customer, Order ID and Product Name

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

**Logic:** This is the standard three-table JOIN. It connects customer → order → product.

## Q4. Show Only Rahul's Orders and Products

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

**Logic:** JOINs connect the tables. `WHERE` filters the resulting rows to Rahul.

## Q5. Sort Joined Results by Customer Name

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

**Logic:** `ORDER BY c.name ASC` sorts names alphabetically. `o.order_id ASC` sorts orders within the same customer.

## Q6. Count Orders for Each Customer

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

**Logic:**
- `COUNT(o.order_id)` counts matching order IDs.
- `GROUP BY` calculates a separate count for each customer.
- `INNER JOIN` excludes customers without orders.

## Q7. Show Customers With at Least Two Orders

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

**Logic:** `HAVING` filters grouped results after calculating `COUNT()`. Use `HAVING`, not `WHERE`, for aggregate conditions.

## Q8. Count Orders for Every Customer, Including Zero Orders

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

**Logic:**
- `LEFT JOIN` keeps every customer.
- `COUNT(o.order_id)` ignores NULL order IDs.
- Customers without orders get a count of `0`.

## Q9. Find Customers Who Have Never Placed an Order

```sql
SELECT
    c.name AS customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

**Logic:** A customer with no matching order has `NULL` in `o.order_id`. `IS NULL` filters those customers. No `GROUP BY` is needed.

## Q10. Count Products Per Customer, Including All Customers

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

**Logic:**
1. Start from `customers` because all customers must be included.
2. Join orders.
3. Join products.
4. Count matching product IDs.

**Important:** This counts product-linked order rows. For distinct product types, use `COUNT(DISTINCT p.product_id)`.

## Q11. Count Orders Per Product, Including Products With No Orders

```sql
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;
```

**Logic:**
- Start from `products` so every product appears.
- `LEFT JOIN` keeps products without orders.
- `COUNT(o.order_id)` returns `0` for products with no orders.
- `ORDER BY ... DESC` sorts from most orders to fewest.

## Q12. Count Product-Linked Rows for Each Customer

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

**Logic:** Both joins are `LEFT JOIN`, so customers without orders remain. `COUNT(p.product_id)` counts non-NULL product IDs.

## Q13. Total Order Amount Per Customer

```sql
SELECT
    c.name AS customer_name,
    COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

**Logic:**
- `SUM(o.amount)` adds order amounts per customer.
- When there are no matching values, `SUM()` returns `NULL`.
- `COALESCE(..., 0)` displays zero instead of NULL.

## Q14. Average Order Amount Per Customer

```sql
SELECT
    c.name AS customer_name,
    COALESCE(AVG(o.amount), 0) AS average_order_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;
```

**Logic:**
- `AVG(o.amount)` calculates the average of non-NULL amounts.
- `COALESCE()` displays `0` if there is no average to calculate.
- `average_order_amount` is a descriptive alias.

## Q15. Count Orders Above 1000 for Every Customer

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
    AND o.amount > 1000
GROUP BY c.customer_id, c.name;
```

**Logic:** The condition `o.amount > 1000` is in `ON`. This matches only qualifying orders while preserving every customer.

If the condition were in `WHERE`, customers without qualifying orders could be removed from the result.

## Q16. Find Customers With at Least Two Orders Using Multiple JOINs

```sql
SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;
```

**Logic:**
1. Join customers to orders.
2. Join orders to products.
3. Group rows by customer.
4. Count orders.
5. `HAVING` keeps customers with at least two orders.

**Note:** The products JOIN is included for three-table practice. If only customer names and order counts are needed, it is unnecessary.

## Q17. Show Every Product and Order Count, Sorted Highest to Lowest

```sql
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;
```

**Logic:** Starting from products preserves products with no orders. `COUNT(o.order_id)` counts matching orders and `ORDER BY ... DESC` sorts highest to lowest.

---

## Key Concepts to Remember

| Concept | Meaning |
|---|---|
| `INNER JOIN` | Returns only matching rows from joined tables. |
| `LEFT JOIN` | Keeps all rows from the left table, even without a right-side match. |
| `ON` | Defines how rows match between tables. |
| `WHERE` | Filters rows before grouping and aggregation. |
| `GROUP BY` | Groups rows for calculations such as COUNT, SUM and AVG. |
| `HAVING` | Filters groups after aggregation. |
| `COUNT(column)` | Counts non-NULL values. |
| `SUM(column)` | Adds non-NULL numeric values. |
| `AVG(column)` | Averages non-NULL numeric values. |
| `COALESCE(value, 0)` | Replaces NULL with zero. |
| `ORDER BY ... DESC` | Sorts from highest to lowest. |
| `IS NULL` | Checks whether a value is NULL. |

## Common Mistakes

1. **Using `WHERE COUNT(...)`:** Use `HAVING COUNT(...)` for aggregate conditions.
2. **Forgetting `GROUP BY`:** Group non-aggregated selected columns when using aggregate calculations.
3. **Using `COUNT(*)` for unmatched LEFT JOIN rows:** `COUNT(*)` can count the preserved row as 1. Use `COUNT(o.order_id)` to get 0 when no order matches.
4. **Starting from the wrong table:** Start from `customers` if all customers must appear; start from `products` if all products must appear.
5. **Filtering a LEFT JOIN in `WHERE` accidentally:** A right-table condition in `WHERE` can remove unmatched left-side rows. Put the condition in `ON` when unmatched left-side rows must remain.
6. **Comparing NULL with `=`:** Use `IS NULL`, not `= NULL`.
7. **Joining tables unnecessarily:** Join tables needed for the output or filter, unless practising multiple JOINs is the goal.

## Final Revision Checklist

- [ ] Can I explain why each table is joined?
- [ ] Is each `ON` condition using the correct key?
- [ ] Do I need `INNER JOIN` or `LEFT JOIN`?
- [ ] Which table's complete set of rows must be preserved?
- [ ] If I use aggregates, have I added the correct `GROUP BY`?
- [ ] Should my filter be in `WHERE`, `ON`, or `HAVING`?
- [ ] Am I using `COUNT(right_table.id)` when unmatched rows should count as zero?
- [ ] Are my column aliases clear and accurate?
