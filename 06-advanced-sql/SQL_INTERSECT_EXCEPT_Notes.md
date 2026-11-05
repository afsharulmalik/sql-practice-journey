# SQL INTERSECT & EXCEPT --- Complete Notes

## 1. INTERSECT

`INTERSECT` returns rows that are present in both query results. By
default, duplicate rows are removed.

``` sql
SELECT name FROM A
INTERSECT
SELECT name FROM B;
```

Example: - Table A: Aman, Rahul, Priya - Table B: Rahul, Neha, Aman

Result: Aman, Rahul (2 common rows).

## 2. EXCEPT

In PostgreSQL, `EXCEPT` returns rows from the first query that are not
present in the second query. By default, duplicate rows are removed.

``` sql
SELECT name FROM A
EXCEPT
SELECT name FROM B;
```

With the example above, the result is Priya.

Reversing the query order changes the result:

``` sql
SELECT name FROM B
EXCEPT
SELECT name FROM A;
```

Result: Neha.

**Remember:** `EXCEPT` is directional; the first query matters.

## 3. Rules

1.  Both queries must return the same number of columns.
2.  Corresponding columns must have compatible data types.
3.  Columns are matched by position, not by column name.
4.  `INTERSECT` returns common rows.
5.  `EXCEPT` returns rows in the first result that are absent from the
    second.
6.  `INTERSECT` and `EXCEPT` remove duplicate rows by default.
7.  Use `ORDER BY` at the end to sort the combined result. Without it,
    row order is not guaranteed.

## 4. Comparison of SQL set operators

  Operator      Result
  ------------- ---------------------------------------------
  `UNION`       Combines results and removes duplicate rows
  `UNION ALL`   Combines results and keeps duplicates
  `INTERSECT`   Rows common to both results
  `EXCEPT`      Rows in the first result but not the second

## 5. Practice Questions with Answers

### Q1

A = Aman, Rahul, Priya; B = Rahul, Neha, Aman. How many rows does
`INTERSECT` return?

**Answer:** 2 rows --- Aman and Rahul.

### Q2

What does `SELECT name FROM A EXCEPT SELECT name FROM B` return?

**Answer:** Priya.

### Q3

What does `SELECT name FROM B EXCEPT SELECT name FROM A` return?

**Answer:** Neha.

### Q4

Is this valid?

``` sql
SELECT emp_name, salary FROM employees
INTERSECT
SELECT customer_name FROM customers;
```

**Answer:** No. The first query returns two columns, while the second
returns one.

### Q5

Which operator returns only names common to both tables?

**Answer:** `INTERSECT`.

## 6. Quick revision

-   `INTERSECT` = common rows.
-   `EXCEPT` = first query minus rows present in the second query.
-   Order matters for `EXCEPT`.
-   Both queries need the same number of columns and compatible data
    types.
-   Use `ORDER BY` at the end when a particular output order is needed.

## 7. Next topic

**Indexes & Query Optimization** --- learn how indexes work and how to
inspect query performance with PostgreSQL's `EXPLAIN` and
`EXPLAIN ANALYZE`.
