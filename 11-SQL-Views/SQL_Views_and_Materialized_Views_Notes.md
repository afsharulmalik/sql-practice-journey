
# SQL Views and Materialized Views — Complete Notes

## 1. Introduction

In SQL, Views and Materialized Views help us save query logic and access query results conveniently.

- **View:** Stores a SQL query definition. The result is generally calculated when the View is queried.
- **Materialized View:** Stores the result of a SQL query physically. The stored result must be refreshed to reflect changes in the underlying tables.

These concepts are useful for database management, backend development, reporting, analytics, and SQL interviews.

---

## 2. What Is a View?

A View is a virtual table based on the result of a SQL query.

A regular View generally does not store its result data separately. Instead, the database stores the query definition.

### Syntax

```sql
CREATE VIEW view_name AS
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Example

Suppose we have an `employees` table containing:

- `employee_id`
- `name`
- `department`
- `salary`

Create a View for employees earning more than ₹40,000:

```sql
CREATE VIEW high_salary_employees AS
SELECT employee_id, name, salary
FROM employees
WHERE salary > 40000;
```

### Retrieve Data from a View

```sql
SELECT *
FROM high_salary_employees;
```

### Select Specific Columns

```sql
SELECT name, salary
FROM high_salary_employees;
```

### Filter the View Further

```sql
SELECT *
FROM high_salary_employees
WHERE salary > 60000;
```

A View can be queried like a table, and additional filters can be applied to its results.

---

## 3. Why Do We Use Views?

### A. Simplify Complex Queries

Suppose a query involving multiple tables is used frequently. We can save the query as a View and use a simpler `SELECT` statement later.

```sql
CREATE VIEW employee_department_details AS
SELECT
    e.employee_id,
    e.name,
    e.salary,
    d.department_name
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id;
```

Use the View:

```sql
SELECT *
FROM employee_department_details;
```

### B. Restrict Data Exposure

A View can expose only selected columns instead of the entire table.

```sql
CREATE VIEW employee_public_details AS
SELECT employee_id, name, department
FROM employees;
```

This View does not expose the salary column.

**Important:** Creating a View alone is not a complete security mechanism. Proper table privileges and View permissions must also be configured.

### C. Reuse Query Logic

Frequently used filtering and joining logic can be defined once and reused.

### D. Improve Maintainability

Changes to a query definition can be managed centrally through the View, subject to compatibility and dependency considerations.

---

## 4. Create or Replace a View

In PostgreSQL, `CREATE OR REPLACE VIEW` can update an existing View's query definition.

```sql
CREATE OR REPLACE VIEW high_salary_employees AS
SELECT employee_id, name, department, salary
FROM employees
WHERE salary > 40000;
```

The existing View is updated rather than requiring a separate View name.

**Note:** PostgreSQL requires existing output columns to remain compatible. New columns can generally be added at the end, but existing columns cannot simply be reordered or changed incompatibly using this command.

---

## 5. Rename and Drop a View

### Rename a View

```sql
ALTER VIEW high_salary_employees
RENAME TO well_paid_employees;
```

### Drop a View

```sql
DROP VIEW well_paid_employees;
```

### Drop Only If It Exists

```sql
DROP VIEW IF EXISTS well_paid_employees;
```

`DROP VIEW` removes the View definition, not the underlying table data.

---

## 6. What Is a Materialized View?

A Materialized View stores the result of a SQL query physically.

Unlike a regular View, it can return previously calculated results without recalculating the complete underlying query for every read.

This can be useful for expensive joins, aggregations, reports, and dashboards.

### Syntax

```sql
CREATE MATERIALIZED VIEW materialized_view_name AS
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Example: Department Salary Summary

```sql
CREATE MATERIALIZED VIEW department_salary_summary AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department;
```

This stores a summary of employee salaries by department.

### Read the Stored Results

```sql
SELECT *
FROM department_salary_summary;
```

The query reads the currently stored results of the Materialized View.

---

## 7. Refresh a Materialized View

A Materialized View does not automatically update its stored results when the underlying tables change.

Suppose a new employee is added or an employee's salary changes. The stored summary can become outdated.

To recalculate its contents:

```sql
REFRESH MATERIALIZED VIEW department_salary_summary;
```

This refreshes the stored results using the current underlying data visible to the refresh operation.

### Important Difference

- Regular View: Query the View to obtain results based on the underlying tables.
- Materialized View: Refresh it to update its stored results.

---

## 8. Concurrent Refresh in PostgreSQL

PostgreSQL supports refreshing a Materialized View concurrently:

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY department_salary_summary;
```

This can allow other sessions to continue reading the Materialized View while it is refreshed, rather than blocking those reads in the same way as a regular refresh.

### Requirement

A Materialized View must have an appropriate qualifying `UNIQUE` index that:

- Uses only column names, not expressions.
- Does not have a `WHERE` clause.
- Covers all rows of the Materialized View.

Example:

```sql
CREATE UNIQUE INDEX department_salary_summary_unique_idx
ON department_salary_summary (department);
```

Then:

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY
department_salary_summary;
```

The example assumes `department` uniquely identifies each row in the summary.

**Note:** `CONCURRENTLY` cannot be used for a Materialized View that has not yet been populated. It also cannot be combined with `WITH NO DATA`.

---

## 9. Create a Materialized View Without Populating It

PostgreSQL allows the query definition to be created without immediately storing its results.

```sql
CREATE MATERIALIZED VIEW department_salary_summary AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
WITH NO DATA;
```

The Materialized View is initially unpopulated and cannot be queried normally until it is refreshed.

Populate it:

```sql
REFRESH MATERIALIZED VIEW department_salary_summary;
```

This can be useful when the initial calculation is intentionally deferred.

---

## 10. Drop a Materialized View

```sql
DROP MATERIALIZED VIEW department_salary_summary;
```

Safer form:

```sql
DROP MATERIALIZED VIEW IF EXISTS department_salary_summary;
```

Dropping a Materialized View removes its stored results and definition. It does not delete the original tables.

---

## 11. View vs Materialized View

| Feature | View | Materialized View |
|---|---|---|
| What is stored? | Query definition | Query result and definition |
| Result data stored separately? | Generally no | Yes |
| Data freshness | Reflects underlying data when queried | Can become stale until refreshed |
| Refresh required? | No | Yes, when updated results are needed |
| Read performance | Depends on underlying query and execution plan | Can be faster for expensive queries |
| Storage required for results | Generally no separate result storage | Yes |
| Suitable for | Reusable queries and logical data access | Reports, analytics, expensive aggregations |
| PostgreSQL support | Yes | Yes |

**Remember:**

- View = Saved query definition.
- Materialized View = Saved query result.

---

## 12. Real-World Examples

### Example A: E-commerce Sales Report

An e-commerce system may have millions of order items. Calculating total sales for every department on every dashboard request can be expensive.

A Materialized View can store a precomputed summary:

```sql
CREATE MATERIALIZED VIEW department_sales_summary AS
SELECT
    p.department_id,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.department_id;
```

Read the report:

```sql
SELECT *
FROM department_sales_summary;
```

Refresh it after the underlying data changes:

```sql
REFRESH MATERIALIZED VIEW department_sales_summary;
```

This example assumes the specified tables and columns exist in the database.

### Example B: Employee Data Access

A View can expose selected employee information:

```sql
CREATE VIEW employee_directory AS
SELECT employee_id, name, department
FROM employees;
```

Users who need only directory information can work with the View instead of querying all employee columns directly, provided permissions are configured appropriately.

---

## 13. Performance Considerations

### Views

- A View does not automatically make a query faster.
- The database generally executes the underlying query when the View is queried.
- Indexes on underlying tables may help, depending on the query plan.
- Views can simplify code and improve maintainability.

### Materialized Views

- Can speed up repeated reads of expensive calculations.
- Require additional storage.
- Need refreshing to update stored results.
- Refreshing can consume CPU, memory, disk I/O, and database resources.
- A stale Materialized View may be unsuitable when real-time accuracy is required.

**Best practice:** Choose a Materialized View when faster reads justify the storage and refresh cost.

---

## 14. Common Mistakes

### Mistake 1: Expecting a Materialized View to Update Automatically

Incorrect assumption:

```sql
INSERT INTO employees (name, department, salary)
VALUES ('Aman', 'IT', 50000);
```

The stored results of a Materialized View based on `employees` do not automatically refresh after this insert.

Correct approach:

```sql
REFRESH MATERIALIZED VIEW department_salary_summary;
```

### Mistake 2: Thinking a View Stores a Separate Copy of the Rows

A regular View stores a query definition, not a separate materialized copy of its result.

### Mistake 3: Assuming a View Is Always Faster

A View may still require an expensive join, filter, or aggregation.

### Mistake 4: Forgetting the Cost of Refreshing

Materialized Views are not free performance improvements. Their refresh frequency and resource cost should be planned.

### Mistake 5: Confusing Dropping a View with Dropping a Table

```sql
DROP VIEW employee_directory;
```

This removes the View, not the underlying `employees` table.

---

## 15. Practice Questions

### Beginner

**Q1.** What is a SQL View?

**Q2.** Does a regular View normally store its query result separately?

**Q3.** What is the main difference between a View and a Materialized View?

**Q4.** Which PostgreSQL command refreshes a Materialized View?

### Intermediate

**Q5.** Create a View named `it_employees` that shows `name` and `department` for employees in the IT department.

**Q6.** Create a View named `high_salary_employees` for employees whose salary is greater than 40,000.

**Q7.** Create a Materialized View named `department_salary_summary` that shows the employee count and average salary for each department.

**Q8.** An employee's salary changes. What should you do if a Materialized View stores the average salary by department and needs current results?

### Advanced

**Q9.** What is the purpose of `REFRESH MATERIALIZED VIEW CONCURRENTLY` in PostgreSQL?

**Q10.** What kind of unique index is required for a concurrent refresh?

**Q11.** Why might a Materialized View be useful for an analytics dashboard?

**Q12.** What are the trade-offs of using a Materialized View?

---

## 16. Practice Answers

### Answer 1

A View is a virtual table based on a saved SQL query.

### Answer 2

No. A regular View generally stores its query definition rather than a separate copy of the result data.

### Answer 3

A View calculates its result when queried, while a Materialized View stores query results that must be refreshed when updated data is needed.

### Answer 4

```sql
REFRESH MATERIALIZED VIEW view_name;
```

### Answer 5

```sql
CREATE VIEW it_employees AS
SELECT name, department
FROM employees
WHERE department = 'IT';
```

### Answer 6

```sql
CREATE VIEW high_salary_employees AS
SELECT employee_id, name, salary
FROM employees
WHERE salary > 40000;
```

### Answer 7

```sql
CREATE MATERIALIZED VIEW department_salary_summary AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;
```

### Answer 8

Refresh the Materialized View:

```sql
REFRESH MATERIALIZED VIEW department_salary_summary;
```

### Answer 9

It refreshes a Materialized View while allowing concurrent readers to continue accessing it during the refresh, subject to PostgreSQL's requirements.

### Answer 10

A qualifying `UNIQUE` index using only column names, without a `WHERE` clause, that covers all rows.

### Answer 11

It can store precomputed aggregates and reduce repeated expensive calculations.

### Answer 12

Benefits include faster reads for expensive queries. Costs include extra storage, refresh overhead, and potentially stale results.

---

## 17. Quick Interview Revision

**Q. What is a View?**

A virtual table based on a saved SQL query.

**Q. What is a Materialized View?**

A database object that stores the result of a query physically.

**Q. Does a Materialized View automatically update?**

No. Its stored results need to be refreshed.

**Q. Can a View simplify complex joins?**

Yes. It can save a reusable query definition containing joins.

**Q. Is a Materialized View always faster?**

No. It can improve repeated reads of expensive queries, but refresh costs and storage must be considered.

**Q. What is the difference between `REFRESH MATERIALIZED VIEW` and `REFRESH MATERIALIZED VIEW CONCURRENTLY`?**

The concurrent form allows concurrent readers to continue accessing the Materialized View during refresh, but it requires a suitable unique index and an already populated Materialized View.

---

## 18. Final Summary

- A View stores a query definition.
- A Materialized View stores query results.
- Views are useful for query reuse and controlled data access.
- Materialized Views are useful for reporting and expensive repeated calculations.
- Use `CREATE VIEW` to create a View.
- Use `CREATE MATERIALIZED VIEW` to create a Materialized View.
- Use `CREATE OR REPLACE VIEW` to update a compatible View definition.
- Use `REFRESH MATERIALIZED VIEW` to update stored results.
- Use `DROP VIEW` and `DROP MATERIALIZED VIEW` to remove these objects.
- Choose the appropriate object based on freshness, performance, storage, and maintenance requirements.

**Notes complete — SQL Views and Materialized Views.**
