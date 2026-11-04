# SQL CTE (Common Table Expression) — Complete Notes

**Database:** PostgreSQL  
**Level:** Beginner to Advanced  
**Purpose:** SQL Learning, Interview Preparation & Backend Development

---

## 1. What is a CTE?

CTE stands for **Common Table Expression**. It is a temporary, named result set that you define using the `WITH` keyword and use inside a single SQL statement.

CTEs help make complex SQL queries easier to read, understand, maintain, and debug.

### Basic Syntax

```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT *
FROM cte_name;
```

### Example

Find employees whose salary is greater than ₹50,000.

```sql
WITH high_salary AS (
    SELECT *
    FROM employees
    WHERE salary > 50000
)
SELECT *
FROM high_salary;
```

**Explanation:**
- `WITH` starts the CTE definition.
- `high_salary` is the CTE name.
- The query inside parentheses defines the result set.
- The outer query reads the result from the CTE.

**Important:** A normal CTE exists only for the duration of the SQL statement in which it is defined. It does not create a permanent database table.

---

## 2. Why Do We Use CTEs?

CTEs are useful for:

1. Breaking complex queries into smaller steps.
2. Reusing a named result within the same SQL statement.
3. Performing aggregations before joining data.
4. Filtering records based on aggregate calculations.
5. Combining multiple query stages.
6. Improving query readability and maintainability.
7. Writing recursive queries, such as hierarchical employee relationships.

### Without a CTE

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

### Using a CTE

```sql
WITH salary_stats AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
)
SELECT e.*
FROM employees AS e
CROSS JOIN salary_stats AS s
WHERE e.salary > s.avg_salary;
```

Both queries return employees whose salary is greater than the overall average salary. The CTE version gives the aggregate calculation a meaningful name.

---

## 3. CTE with WHERE and ORDER BY

A CTE can filter records, while the outer query can sort the result.

```sql
WITH high_salary_employees AS (
    SELECT *
    FROM employees
    WHERE salary > 40000
)
SELECT *
FROM high_salary_employees
ORDER BY salary DESC;
```

**Key points:**
- `WHERE` filters individual employee records.
- `ORDER BY salary DESC` sorts salaries from highest to lowest.
- Put `ORDER BY` in the outer query when you need to guarantee the final result order.

---

## 4. CTE with Aggregate Functions

CTEs can calculate values using aggregate functions such as:

- `COUNT()` — counts rows or non-NULL values, depending on its argument.
- `SUM()` — calculates a total.
- `AVG()` — calculates an average.
- `MAX()` — returns the maximum value.
- `MIN()` — returns the minimum value.

### Example: Average salary by department

```sql
WITH department_salary AS (
    SELECT
        department_id,
        ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_salary;
```

Each department appears once in the result, assuming `department_id` identifies a department.

### Example: Maximum salary by department

```sql
WITH department_max AS (
    SELECT
        department_id,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_max;
```

### Example: Departments with average salary greater than ₹50,000

```sql
WITH high_avg_departments AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > 50000
)
SELECT *
FROM high_avg_departments;
```

**Important distinction:**

- `WHERE` filters rows before grouping and aggregation.
- `HAVING` filters groups after aggregation.

---

## 5. Multiple CTEs in One Query

You can define multiple CTEs in a single `WITH` clause. Separate the definitions using commas.

### Syntax

```sql
WITH cte_one AS (
    SELECT ...
),
cte_two AS (
    SELECT ...
),
cte_three AS (
    SELECT ...
)
SELECT *
FROM cte_three;
```

A later CTE can refer to an earlier CTE in the same `WITH` clause.

### Example: Employees earning above their department's average

```sql
WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
above_avg_employees AS (
    SELECT e.*
    FROM employees AS e
    JOIN department_avg AS da
        ON e.department_id = da.department_id
    WHERE e.salary > da.avg_salary
)
SELECT *
FROM above_avg_employees;
```

**How it works:**
1. `department_avg` calculates each department's average salary.
2. `above_avg_employees` joins employees to their department average.
3. The `WHERE` condition keeps employees earning above that average.
4. The final query displays the matching employees.

---

## 6. CTE with JOIN

CTEs are useful when you want to calculate information first and join it to another table afterward.

### Example: Find employees with the highest salary in each department

```sql
WITH department_max AS (
    SELECT
        department_id,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.*
FROM employees AS e
INNER JOIN department_max AS dm
    ON e.department_id = dm.department_id
WHERE e.salary = dm.max_salary;
```

**Why use `=` instead of `>`?**

The goal is to find employees whose salary equals the department maximum. If multiple employees tie for the highest salary, this query returns all of them.

### Example: Departments with at least three employees

```sql
WITH department_counts AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) >= 3
)
SELECT e.*
FROM employees AS e
JOIN department_counts AS dc
    ON e.department_id = dc.department_id;
```

The CTE identifies departments meeting the employee-count condition. The outer query then displays all employees belonging to those departments.

---

## 7. CTE with LEFT JOIN and COALESCE()

Suppose the database contains these tables:

- `departments(department_id, department_name)`
- `employees(employee_id, employee_name, department_id, salary)`

You want to show every department, including departments without employees.

### Example: Employee count for every department

```sql
WITH department_counts AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(dc.total_employees, 0) AS total_employees
FROM departments AS d
LEFT JOIN department_counts AS dc
    ON d.department_id = dc.department_id;
```

### Why use LEFT JOIN?

`LEFT JOIN` retains all rows from the left table, which is `departments` here. If a department has no matching employees, the joined CTE columns return `NULL`.

### Why use COALESCE()?

`COALESCE(value, 0)` returns the value if it is not `NULL`; otherwise, it returns `0`.

For example:

```sql
SELECT COALESCE(NULL, 0);  -- Returns 0
SELECT COALESCE(25, 0);    -- Returns 25
```

### Example: Average salary for every department

```sql
WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(da.avg_salary, 0) AS avg_salary
FROM departments AS d
LEFT JOIN department_avg AS da
    ON d.department_id = da.department_id;
```

**Note:** A displayed average of `0` here means there was no matching employee group, not that the actual average salary was zero. If the distinction matters, retain `NULL` instead.

---

## 8. CTE with CASE

The `CASE` expression categorizes rows based on conditions.

### Example: Categorize employees by salary

```sql
WITH salary_categories AS (
    SELECT
        employee_id,
        employee_name,
        salary,
        CASE
            WHEN salary >= 80000 THEN 'High'
            WHEN salary >= 50000 THEN 'Medium'
            ELSE 'Low'
        END AS salary_category
    FROM employees
)
SELECT *
FROM salary_categories
ORDER BY salary DESC;
```

**Important:** `CASE` evaluates conditions from top to bottom and returns the result for the first matching condition.

For this example:
- Salary ₹80,000 or above → `High`
- Salary ₹50,000 or above but below ₹80,000 → `Medium`
- Salary below ₹50,000 → `Low`

Using `>=` in the second condition works because the first condition has already captured salaries of ₹80,000 or more.

### Example: Categorize departments by average salary

```sql
WITH department_salary_stats AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary,
        CASE
            WHEN AVG(salary) >= 60000 THEN 'High Paying'
            WHEN AVG(salary) >= 40000 THEN 'Medium Paying'
            ELSE 'Low Paying'
        END AS salary_category
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_salary_stats
ORDER BY avg_salary DESC;
```

This query calculates each department's average salary and assigns a category.

---

## 9. CTE with Multiple Conditions

You can combine CTE results with multiple filtering conditions.

### Example: Employees in departments with at least three employees and salary above ₹40,000

```sql
WITH department_counts AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) >= 3
),
eligible_employees AS (
    SELECT e.*
    FROM employees AS e
    JOIN department_counts AS dc
        ON e.department_id = dc.department_id
    WHERE e.salary > 40000
)
SELECT *
FROM eligible_employees;
```

The conditions serve different purposes:
- `HAVING COUNT(*) >= 3` selects qualifying departments.
- `WHERE e.salary > 40000` selects employees whose salaries exceed the threshold.

---

## 10. CTE vs Subquery vs Temporary Table

| Feature | CTE | Subquery | Temporary table |
|---|---|---|---|
| Definition | `WITH` | Nested `SELECT` | `CREATE TEMP TABLE` |
| Lifetime | One SQL statement | Part of its containing statement | Session or transaction, depending on configuration |
| Naming | Named result set | Usually nested or aliased | Named database object |
| Best use | Breaking complex queries into steps | Simple nested calculations | Reusing stored intermediate data across statements |
| Stores permanent data? | No | No | No; temporary storage only |

**Important:** A CTE is not automatically faster than a subquery. Performance depends on the database, query structure, optimizer, and execution plan. PostgreSQL may inline a CTE or materialize it depending on the query and options.

---

## 11. Recursive CTE — Introduction

A recursive CTE references itself. It is useful for hierarchical data, such as organizational structures, category trees, or sequences.

### Example: Generate numbers from 1 to 5

```sql
WITH RECURSIVE number_series AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM number_series
    WHERE n < 5
)
SELECT *
FROM number_series;
```

Expected output:

```text
n
--
1
2
3
4
5
```

**How it works:**
1. The anchor query starts with `1`.
2. The recursive query adds `1` to the previous value.
3. The condition `WHERE n < 5` stops the recursion after generating `5`.

A recursive query needs a valid stopping condition to avoid unbounded recursion.

---

## 12. Common Mistakes in CTEs

### Mistake 1: Missing comma between CTEs

Incorrect:

```sql
WITH first_cte AS (
    SELECT ...
)
second_cte AS (
    SELECT ...
)
SELECT * FROM second_cte;
```

Correct:

```sql
WITH first_cte AS (
    SELECT ...
),
second_cte AS (
    SELECT ...
)
SELECT * FROM second_cte;
```

### Mistake 2: Using the wrong column alias

Incorrect:

```sql
WITH department_max AS (
    SELECT department_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_max
WHERE salary = max_salary;
```

Correct:

```sql
WITH department_max AS (
    SELECT department_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_max
WHERE max_salary > 50000;
```

The CTE exposes `department_id` and `max_salary`, not the original `salary` column.

### Mistake 3: Selecting every employee column with an incomplete GROUP BY

Incorrect:

```sql
SELECT e.*, AVG(e.salary)
FROM employees AS e
GROUP BY e.department_id;
```

In PostgreSQL, this is invalid because the selected employee columns are neither grouped nor aggregated.

Correct:

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;
```

### Mistake 4: Using WHERE instead of HAVING

Incorrect for filtering departments by average salary:

```sql
SELECT department_id, AVG(salary)
FROM employees
WHERE AVG(salary) > 50000
GROUP BY department_id;
```

Correct:

```sql
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 50000;
```

### Mistake 5: Forgetting the LEFT JOIN requirement

If you start with `employees`, departments with no employees cannot appear in the result. Start with `departments` and use `LEFT JOIN` when every department must be displayed.

### Mistake 6: Incorrect maximum-salary comparison

To find the employees earning the maximum salary in each department, use:

```sql
WHERE e.salary = dm.max_salary
```

Using `>` would not find employees whose salary equals the maximum.

### Mistake 7: Assuming CTE output is automatically sorted

If the final output must be sorted, put `ORDER BY` in the final query.

---

## 13. Interview Questions and Answers

### Q1. What is a CTE?

A CTE is a named result set defined using `WITH`, available within a single SQL statement.

### Q2. What is the main advantage of a CTE?

It improves readability by dividing a complex query into logical steps.

### Q3. Can we use multiple CTEs in one query?

Yes. Separate each CTE definition with a comma.

### Q4. Can one CTE reference another CTE?

Yes. A later CTE can reference a previously defined CTE in the same `WITH` clause.

### Q5. Is a CTE a permanent table?

No. A normal CTE exists only for the SQL statement in which it is defined.

### Q6. Can we use JOIN inside a CTE?

Yes. A CTE can contain joins, filters, aggregate functions, and other supported SQL operations.

### Q7. What is a recursive CTE?

A CTE that references itself, often used for hierarchical data or iterative sequences.

### Q8. What is the difference between WHERE and HAVING?

`WHERE` filters rows before grouping. `HAVING` filters groups after aggregation.

### Q9. Is a CTE always faster than a subquery?

No. A CTE primarily improves query organization. Actual performance depends on the database optimizer and execution plan.

### Q10. Why use LEFT JOIN with a CTE?

It allows the query to retain every row from the left table even when the CTE has no matching result.

### Q11. What is the purpose of COALESCE()?

It returns the first non-NULL value from its arguments, often replacing `NULL` with a default value.

### Q12. What is the difference between a CTE and a temporary table?

A CTE is scoped to one statement. A temporary table can be reused across multiple statements during its lifetime.

---

## 14. Practice Questions

Try solving these independently before checking the solutions.

1. Use a CTE to find employees earning more than ₹50,000.
2. Use a CTE to show employees earning more than ₹40,000, ordered by salary descending.
3. Calculate the average salary of each department.
4. Find departments whose average salary is above ₹50,000.
5. Find employees whose salary is greater than their department's average salary.
6. Find employees receiving the maximum salary in their department.
7. Display employees working in departments with at least three employees.
8. Display all employees working in departments whose average salary is above ₹40,000.
9. Display every department and its employee count, including departments with zero employees.
10. Display every department and its average salary, including departments with zero employees.
11. Find employees whose salary is greater than their department average and greater than ₹40,000.
12. Use multiple CTEs to find employees in departments with at least three employees and salaries above ₹40,000.
13. Use `CASE` in a CTE to categorize employee salaries.
14. Use `CASE` to categorize departments based on average salary.
15. Use a CTE and `LEFT JOIN` to show department names, employee counts, and average salaries for every department.
16. Write a recursive CTE to generate numbers from 1 to 10.
17. Use a CTE to find each department's highest-paid employee or employees.

---

## 15. Quick Revision Cheat Sheet

| Requirement | SQL technique |
|---|---|
| Define a CTE | `WITH name AS (...)` |
| Define multiple CTEs | Separate them with commas |
| Filter individual rows | `WHERE` |
| Filter aggregated groups | `HAVING` |
| Calculate average salary | `AVG(salary)` |
| Calculate highest salary | `MAX(salary)` |
| Count employees | `COUNT(*)` |
| Categorize results | `CASE WHEN ... THEN ... ELSE ... END` |
| Retain unmatched departments | `LEFT JOIN` |
| Replace NULL with zero | `COALESCE(value, 0)` |
| Find employees above department average | CTE + JOIN + `WHERE` |
| Find highest-paid employees per department | CTE with `MAX()` + JOIN |
| Generate a sequence recursively | `WITH RECURSIVE` |
| Guarantee final sorting | `ORDER BY` in the outer query |

---

## Final Summary

The basic CTE pattern to remember is:

```sql
WITH cte_name AS (
    SELECT ...
    FROM ...
    WHERE ...
)
SELECT ...
FROM cte_name;
```

For advanced SQL problems, build the solution in logical stages:

1. Calculate the required intermediate result.
2. Give that result a clear CTE name.
3. Use another CTE if a second processing step is necessary.
4. JOIN the result to the original tables when required.
5. Apply final filters and sorting in the outer query.

**Recommended next topic:** SQL Window Functions, including `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, and aggregate window functions.
