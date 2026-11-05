# SQL Indexes & Query Optimization --- Day 1 Notes

## 1. What is an index?

An index is a data structure that can help PostgreSQL find rows without
scanning the entire table. It is similar to the index at the back of a
book.

-   Indexes can speed up suitable searches and filters.
-   Indexes use additional storage.
-   `INSERT`, `UPDATE`, and `DELETE` may require index maintenance.
-   PostgreSQL decides whether to use an index; creating one does not
    guarantee it will be used.

## 2. Create an index

``` sql
CREATE INDEX idx_employees_salary
ON employees(salary);
```

General syntax:

``` sql
CREATE INDEX index_name
ON table_name (column_name);
```

## 3. Drop an index

``` sql
DROP INDEX idx_employees_salary;
```

This removes the index, not the table or its rows.

## 4. Single-column and composite indexes

Single-column index:

``` sql
CREATE INDEX idx_employees_salary
ON employees(salary);
```

Composite index:

``` sql
CREATE INDEX idx_employees_dept_salary
ON employees(dept_id, salary);
```

Column order matters. An index on `(dept_id, salary)` is generally
useful for filters starting with `dept_id`, and may help queries that
filter by both columns. It is not usually as effective for filtering by
`salary` alone. Choose column order based on real query patterns and
validate with the execution plan.

For this query:

``` sql
SELECT *
FROM employees
WHERE dept_id = 2
  AND salary > 50000;
```

`(dept_id, salary)` is a reasonable starting point because it puts the
equality-filter column first, followed by the range-filter column.
Actual performance depends on the data and query plan.

## 5. EXPLAIN vs EXPLAIN ANALYZE

Estimated plan:

``` sql
EXPLAIN
SELECT *
FROM employees
WHERE salary > 50000;
```

Actual plan and runtime statistics:

``` sql
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 50000;
```

-   `EXPLAIN` displays the planned execution strategy without executing
    the query.
-   `EXPLAIN ANALYZE` executes the query and reports actual timing and
    row statistics.
-   `EXPLAIN ANALYZE` with `UPDATE` or `DELETE` actually performs the
    change, so use care.

Look for scan types such as `Seq Scan`, `Index Scan`, or
`Bitmap Index Scan`, estimated/actual rows, and execution time.

## 6. Why might PostgreSQL use Seq Scan when an index exists?

That is not necessarily an error. PostgreSQL may estimate a sequential
scan to be cheaper, for example: - the table is small; - a large
proportion of rows match the condition; - using the index would add
unnecessary overhead.

The planner uses statistics and estimated costs to choose a plan. Do not
force an index without measuring.

## 7. Practice questions and answers

### Q1. Which command creates an index on `salary`?

**Answer:**

``` sql
CREATE INDEX idx_salary ON employees(salary);
```

### Q2. Which command drops only the index?

**Answer:**

``` sql
DROP INDEX idx_salary;
```

### Q3. For filtering by `dept_id = 2` and `salary > 50000`, which composite index is a reasonable starting choice?

**Answer:**

``` sql
CREATE INDEX idx_dept_salary ON employees(dept_id, salary);
```

Validate with `EXPLAIN ANALYZE` on representative data.

### Q4. Which command shows the actual execution plan and runtime statistics?

**Answer:**

``` sql
EXPLAIN ANALYZE SELECT * FROM employees;
```

### Q5. Why can PostgreSQL choose `Seq Scan` even when an index exists?

**Answer:** The planner estimates that a sequential scan will be more
efficient for that query.

## 8. Quick revision

-   `CREATE INDEX` creates an index.
-   `DROP INDEX` removes an index, not table data.
-   Composite index column order matters.
-   `EXPLAIN` shows the planned strategy.
-   `EXPLAIN ANALYZE` runs the query and shows actual statistics.
-   `Seq Scan` is not automatically bad; compare plans and timing.

## 9. Next topics

Continue with deeper query optimization: - B-tree index behavior and
index selectivity - Partial and expression indexes - Reading execution
plans in more detail - Practical `EXPLAIN ANALYZE` comparisons
