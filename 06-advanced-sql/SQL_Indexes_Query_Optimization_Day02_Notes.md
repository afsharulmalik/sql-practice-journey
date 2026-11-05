# SQL Indexes & Query Optimization — Day 2 Notes

## 1. B-tree Index
B-tree is PostgreSQL's default index type when you create an index without specifying a method.

```sql
CREATE INDEX idx_employees_salary
ON employees (salary);
```

Often useful for equality and range comparisons, such as `=`, `<`, `>`, `BETWEEN`, and sometimes `ORDER BY`.

## 2. Partial Index
A partial index stores index entries only for rows that satisfy a condition.

```sql
CREATE INDEX idx_active_salary
ON employees (salary)
WHERE status = 'active';
```

This can reduce index size and help queries whose conditions imply the partial-index predicate. The example assumes the table has a `status` column.

## 3. Expression Index
An expression index indexes the result of an expression or function.

```sql
CREATE INDEX idx_lower_name
ON employees (LOWER(emp_name));
```

Useful for queries such as:

```sql
SELECT *
FROM employees
WHERE LOWER(emp_name) = 'rahul';
```

The query expression should match the indexed expression.

## 4. EXPLAIN vs EXPLAIN ANALYZE
- `EXPLAIN` shows the planner's estimated execution plan.
- `EXPLAIN ANALYZE` executes the query and reports actual execution statistics, including actual rows and timing.

```sql
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE salary > 40000;
```

Caution: `EXPLAIN ANALYZE` actually runs the statement. Use care with `UPDATE`, `DELETE`, and other statements that modify data.

## 5. Index Scan vs Seq Scan
- **Index Scan:** Uses an index to locate relevant rows.
- **Seq Scan:** Reads table rows sequentially.
- PostgreSQL chooses a plan based on estimated cost, table size, data distribution, and other factors.
- A `Seq Scan` is not automatically bad; it can be cheaper for small tables or queries that return a large portion of the table.

## 6. Composite Index
Example query:

```sql
SELECT *
FROM employees
WHERE dept_id = 2
  AND salary > 40000;
```

A reasonable starting index to test is:

```sql
CREATE INDEX idx_emp_dept_salary
ON employees (dept_id, salary);
```

Column order matters. A B-tree composite index is generally most useful when queries filter on its leading column(s). The best index depends on the actual workload and data distribution.

## 7. Selectivity and Low-Cardinality Columns
A column with few distinct values, such as a `gender` column with two values, may be less useful as a standalone index when a query returns many rows. However, PostgreSQL can still use such an index when it is estimated to be beneficial.

## 8. Index Trade-offs
Indexes:
- consume disk space;
- add maintenance work to `INSERT`, `UPDATE`, and `DELETE`;
- can improve suitable reads, but do not guarantee every query will become faster.

Avoid creating indexes on every column without considering the workload.

## 9. Practical checklist
1. Identify a real query that needs improvement.
2. Inspect its plan using `EXPLAIN ANALYZE`.
3. Consider a suitable index.
4. Re-check the plan and timing after creating the index.
5. Compare realistic repeated runs and representative data; timing alone is not proof.
6. Keep only indexes that are useful for the workload.

## Quick revision
- Default index type: **B-tree**
- Selected rows only: **Partial Index**
- Function/expression result: **Expression Index**
- Actual plan and timing: **EXPLAIN ANALYZE**
- Index always used? **No**
- Index trade-off: **Extra storage and write-maintenance overhead**
