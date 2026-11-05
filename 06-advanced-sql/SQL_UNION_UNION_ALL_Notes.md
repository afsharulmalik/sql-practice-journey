# SQL UNION & UNION ALL --- Complete Notes

## 1. What are set operators?

`UNION` and `UNION ALL` combine the results of two or more `SELECT`
queries into one result set.

## 2. UNION

`UNION` combines results and removes duplicate rows.

``` sql
SELECT emp_name AS name
FROM employees
UNION
SELECT customer_name AS name
FROM customers;
```

Example inputs:

**employees:** Rahul, Aman, Priya\
**customers:** Aman, Neha, Rahul

The combined unique result contains: Aman, Neha, Priya, Rahul. Without
`ORDER BY`, the output order is not guaranteed.

## 3. UNION ALL

`UNION ALL` combines results and keeps duplicate rows.

``` sql
SELECT emp_name AS name
FROM employees
UNION ALL
SELECT customer_name AS name
FROM customers;
```

With the same example data, the result has 6 rows: Rahul, Aman, Priya,
Aman, Neha, Rahul. Without `ORDER BY`, the output order is not
guaranteed.

## 4. UNION vs UNION ALL

  -----------------------------------------------------------------------
  Feature                 UNION                   UNION ALL
  ----------------------- ----------------------- -----------------------
  Combines query results  Yes                     Yes

  Removes duplicate rows  Yes                     No

  Keeps all rows from     No, duplicate rows are  Yes
  both inputs             removed                 

  Typical processing      Often more work because Often less work
                          duplicates must be      
                          removed                 

  Best when               Only distinct combined  Every row, including
                          rows are needed         duplicates, is needed
  -----------------------------------------------------------------------

## 5. Rules to remember

1.  Each `SELECT` must return the **same number of columns**.
2.  Corresponding columns must have **compatible data types**.
3.  Corresponding columns are matched by **position**, not by column
    name.
4.  Output column names generally come from the first `SELECT`.
5.  To sort the combined result, put one `ORDER BY` at the end.
6.  Without `ORDER BY`, result order is not guaranteed.
7.  `UNION` removes duplicate **rows** based on all selected columns
    together.
8.  Use `UNION ALL` when duplicates are meaningful or you want to keep
    all input rows.

## 6. ORDER BY with a set operator

``` sql
SELECT emp_name AS name
FROM employees
UNION ALL
SELECT customer_name AS name
FROM customers
ORDER BY name;
```

This keeps duplicates and sorts the combined output by `name`.

## 7. Invalid example: different number of columns

``` sql
SELECT emp_name, salary
FROM employees
UNION
SELECT customer_name
FROM customers;
```

This is invalid because the first query returns two columns and the
second returns one.

## 8. Practice questions and answers

### Q1. Table A contains `Aman`, `Rahul`. Table B contains `Rahul`, `Neha`. How many rows does `UNION` return?

**Answer:** 3 rows --- `Aman`, `Rahul`, `Neha`.

### Q2. With the same tables, how many rows does `UNION ALL` return?

**Answer:** 4 rows --- `Aman`, `Rahul`, `Rahul`, `Neha`.

### Q3. Is this valid?

``` sql
SELECT emp_name, salary
FROM employees
UNION
SELECT customer_name
FROM customers;
```

**Answer:** No. The queries return different numbers of columns.

### Q4. Is `ORDER BY` allowed after a `UNION`?

**Answer:** Yes. Put it at the end of the complete set operation. Using
a shared output alias is clear:

``` sql
SELECT emp_name AS name FROM employees
UNION
SELECT customer_name AS name FROM customers
ORDER BY name;
```

### Q5. Keep duplicates and sort alphabetically. Which operator?

**Answer:** `UNION ALL`, followed by `ORDER BY name`.

## 9. Quick revision

-   `UNION` = combine results and remove duplicate rows.
-   `UNION ALL` = combine results and keep duplicates.
-   Same number of columns; compatible data types.
-   Columns are matched by position.
-   `ORDER BY` goes at the end of the combined query.
-   Output order is not guaranteed unless you use `ORDER BY`.

## 10. What to learn next

-   `INTERSECT`: returns rows common to both query results.
-   `EXCEPT` (PostgreSQL): returns rows from the first query that are
    not in the second.
