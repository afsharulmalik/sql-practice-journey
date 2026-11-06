# SQL CASE with Aggregate Functions and GROUP BY --- Complete Notes

**Level:** Beginner to Intermediate\
**Database:** PostgreSQL\
**Purpose:** Placement preparation, SQL interviews, and practical
reporting queries

------------------------------------------------------------------------

## 1. Learning Objectives

After completing these notes, you should be able to:

-   Explain `CASE`, aggregate functions, and `GROUP BY`.
-   Use `CASE` inside `SUM()`, `COUNT()`, and `AVG()` patterns.
-   Calculate conditional totals and counts.
-   Categorize rows first, then summarize each category.
-   Use `CASE` in a `SELECT` list alongside grouped results.
-   Understand common mistakes and solve practical SQL questions.

------------------------------------------------------------------------

## 2. Quick Revision: CASE Expression

A `CASE` expression evaluates conditions in order and returns the result
for the first matching condition.

### Syntax: searched CASE

``` sql
CASE
    WHEN condition_1 THEN result_1
    WHEN condition_2 THEN result_2
    ELSE default_result
END
```

-   `WHEN`: condition to check.
-   `THEN`: value to return if that condition is true.
-   `ELSE`: fallback value if no condition matches. It is optional;
    without it, the result is `NULL`.
-   `END`: closes the expression.

Example:

``` sql
SELECT
    employee_name,
    salary,
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;
```

**Important:** Conditions are checked from top to bottom. Put more
specific or higher thresholds first when needed.

------------------------------------------------------------------------

## 3. Aggregate Functions

Aggregate functions calculate one result from multiple rows.

  -----------------------------------------------------------------------
  Function                Meaning                 Example
  ----------------------- ----------------------- -----------------------
  `COUNT(*)`              Counts rows             `COUNT(*)`

  `COUNT(column)`         Counts non-NULL values  `COUNT(salary)`
                          in a column             

  `SUM(column)`           Adds non-NULL numeric   `SUM(salary)`
                          values                  

  `AVG(column)`           Calculates the average  `AVG(salary)`
                          of non-NULL numeric     
                          values                  

  `MIN(column)`           Finds the minimum       `MIN(salary)`
                          non-NULL value          

  `MAX(column)`           Finds the maximum       `MAX(salary)`
                          non-NULL value          
  -----------------------------------------------------------------------

### `COUNT(*)` vs `COUNT(column)`

-   `COUNT(*)` counts every row.
-   `COUNT(salary)` counts only rows where `salary` is not `NULL`.
-   `COUNT(CASE WHEN condition THEN 1 END)` counts rows where the
    condition is true, because non-matching rows return `NULL`.

------------------------------------------------------------------------

## 4. What is GROUP BY?

`GROUP BY` combines rows that share the same value(s), so aggregate
functions can calculate a result for each group.

Example:

``` sql
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
```

This returns one row per `department_id`, with the number of employees
in each department.

### Key rule

When a query uses `GROUP BY`, a selected expression generally must
be: 1. included in `GROUP BY`, or 2. wrapped in an aggregate function,
or 3. otherwise valid under PostgreSQL's functional-dependency rules.

For beginner practice, follow the simple rule: every selected
non-aggregated column should appear in `GROUP BY`.

------------------------------------------------------------------------

## 5. Why combine CASE with Aggregate Functions?

A normal aggregate calculates a value for all rows in a group. A
conditional aggregate calculates a value only for rows matching a
condition.

Common uses: - Count employees earning at least ₹50,000. - Count active
and inactive users. - Sum completed orders only. - Compare high-salary
and low-salary employees by department. - Calculate pass/fail counts. -
Build business reports in a single query.

The core pattern is:

``` sql
SUM(
    CASE
        WHEN condition THEN value
        ELSE 0
    END
)
```

Or for counting matching rows:

``` sql
COUNT(
    CASE
        WHEN condition THEN 1
    END
)
```

------------------------------------------------------------------------

## 6. Conditional COUNT

### Example 1: Count employees earning at least ₹50,000

``` sql
SELECT
    COUNT(
        CASE
            WHEN salary >= 50000 THEN 1
        END
    ) AS employees_earning_50000_or_more
FROM employees;
```

**How it works:** - If `salary >= 50000`, `CASE` returns `1`. -
Otherwise, it returns `NULL` because there is no `ELSE`. -
`COUNT(expression)` counts only non-NULL values.

### Alternative using SUM

``` sql
SELECT
    SUM(
        CASE
            WHEN salary >= 50000 THEN 1
            ELSE 0
        END
    ) AS employees_earning_50000_or_more
FROM employees;
```

Both patterns are common. With `SUM`, the `ELSE 0` makes the intended
counting logic explicit.

### PostgreSQL-specific shortcut: FILTER

PostgreSQL also supports:

``` sql
SELECT
    COUNT(*) FILTER (WHERE salary >= 50000) AS employees_earning_50000_or_more
FROM employees;
```

For learning CASE expressions, practice the `CASE` patterns first.
`FILTER` is a useful PostgreSQL alternative.

------------------------------------------------------------------------

## 7. Conditional SUM

### Example 2: Sum salary for employees earning at least ₹50,000

``` sql
SELECT
    SUM(
        CASE
            WHEN salary >= 50000 THEN salary
            ELSE 0
        END
    ) AS total_salary_50000_or_more
FROM employees;
```

Only salaries meeting the condition contribute to the sum. Other rows
contribute zero.

### Example 3: Sum salaries by department, split into high and lower salary totals

``` sql
SELECT
    department_id,
    SUM(
        CASE
            WHEN salary >= 50000 THEN salary
            ELSE 0
        END
    ) AS high_salary_total,
    SUM(
        CASE
            WHEN salary < 50000 THEN salary
            ELSE 0
        END
    ) AS lower_salary_total
FROM employees
GROUP BY department_id;
```

This returns one row per department.

------------------------------------------------------------------------

## 8. Conditional AVG

There are two useful patterns, and they behave differently.

### Pattern A: Average only the matching rows

``` sql
SELECT
    AVG(
        CASE
            WHEN salary >= 50000 THEN salary
        END
    ) AS avg_salary_for_eligible_employees
FROM employees;
```

When the condition is false, the `CASE` returns `NULL`. `AVG()` ignores
`NULL`, so only matching salaries are averaged.

### Pattern B: Include non-matching rows as zero

``` sql
SELECT
    AVG(
        CASE
            WHEN salary >= 50000 THEN salary
            ELSE 0
        END
    ) AS average_with_nonmatching_rows_as_zero
FROM employees;
```

This averages every row, treating non-matching salaries as zero. It is
**not** the same calculation as Pattern A.

**Rule of thumb:** If the question asks for the average salary among
employees meeting a condition, omit `ELSE 0` inside `AVG()`.

------------------------------------------------------------------------

## 9. CASE + GROUP BY: Categorize rows and count each category

Suppose employees need to be grouped into salary bands.

``` sql
SELECT
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category,
    COUNT(*) AS employee_count
FROM employees
GROUP BY
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END
ORDER BY employee_count DESC;
```

The `CASE` expression is repeated in `GROUP BY` because PostgreSQL does
not generally allow a `SELECT` alias to be referenced in `GROUP BY` at
the same query level.

### Alternative: use a CTE for readability

``` sql
WITH categorized_employees AS (
    SELECT
        employee_id,
        salary,
        CASE
            WHEN salary >= 70000 THEN 'High'
            WHEN salary >= 40000 THEN 'Medium'
            ELSE 'Low'
        END AS salary_category
    FROM employees
)
SELECT
    salary_category,
    COUNT(*) AS employee_count
FROM categorized_employees
GROUP BY salary_category
ORDER BY employee_count DESC;
```

This avoids repeating the `CASE` expression.

------------------------------------------------------------------------

## 10. CASE + GROUP BY department

### Example 4: Count salary bands in each department

``` sql
SELECT
    department_id,
    COUNT(
        CASE WHEN salary >= 70000 THEN 1 END
    ) AS high_salary_count,
    COUNT(
        CASE WHEN salary >= 40000 AND salary < 70000 THEN 1 END
    ) AS medium_salary_count,
    COUNT(
        CASE WHEN salary < 40000 THEN 1 END
    ) AS low_salary_count
FROM employees
GROUP BY department_id
ORDER BY department_id;
```

**Interpretation:** Each department appears once. Its columns show how
many employees fall into each salary band.

Notice that the salary bands do not overlap: - High: salary ≥ 70,000 -
Medium: salary ≥ 40,000 and \< 70,000 - Low: salary \< 40,000

If `salary` is `NULL`, none of these conditions is true, so that row is
not counted in any band.

------------------------------------------------------------------------

## 11. CASE + SUM for order/payment reports

Assume an `orders` table contains: - `order_id` - `customer_id` -
`amount` - `status`

### Example 5: Total completed-order revenue

``` sql
SELECT
    SUM(
        CASE
            WHEN status = 'Completed' THEN amount
            ELSE 0
        END
    ) AS completed_revenue
FROM orders;
```

### Example 6: Completed and pending totals for each customer

``` sql
SELECT
    customer_id,
    SUM(
        CASE WHEN status = 'Completed' THEN amount ELSE 0 END
    ) AS completed_amount,
    SUM(
        CASE WHEN status = 'Pending' THEN amount ELSE 0 END
    ) AS pending_amount
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
```

This is called **conditional aggregation**: multiple metrics are
calculated from the same set of rows by applying different conditions.

------------------------------------------------------------------------

## 12. CASE with COUNT and percentages

### Example 7: Count passed and failed students

Assume a `students` table contains `student_id` and `marks`. Passing
marks are 40.

``` sql
SELECT
    COUNT(*) AS total_students,
    COUNT(CASE WHEN marks >= 40 THEN 1 END) AS passed_students,
    COUNT(CASE WHEN marks < 40 THEN 1 END) AS failed_students
FROM students;
```

### Example 8: Percentage of completed orders

``` sql
SELECT
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_orders,
    ROUND(
        100.0 * COUNT(CASE WHEN status = 'Completed' THEN 1 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS completed_percentage
FROM orders;
```

`NULLIF(COUNT(*), 0)` prevents division by zero. `100.0` ensures decimal
arithmetic rather than integer-only arithmetic.

------------------------------------------------------------------------

## 13. WHERE vs CASE vs HAVING

These clauses have different jobs.

-   `WHERE`: filters individual rows **before** grouping.
-   `CASE`: returns a value based on conditions; it can be used inside
    aggregates.
-   `HAVING`: filters groups **after** aggregation.

### Example 9: Show only departments with at least 3 employees earning ₹50,000 or more

``` sql
SELECT
    department_id,
    COUNT(CASE WHEN salary >= 50000 THEN 1 END) AS eligible_count
FROM employees
GROUP BY department_id
HAVING COUNT(CASE WHEN salary >= 50000 THEN 1 END) >= 3;
```

Do not use `WHERE COUNT(...) >= 3`; aggregate conditions belong in
`HAVING`.

------------------------------------------------------------------------

## 14. Important NULL behaviour

1.  `COUNT(*)` counts rows, even when some columns contain `NULL`.
2.  `COUNT(column)` ignores `NULL` values.
3.  `SUM()` and `AVG()` ignore `NULL` inputs.
4.  `CASE WHEN salary >= 50000 THEN 1 END` returns `NULL` for rows that
    do not match.
5.  `CASE WHEN salary >= 50000 THEN salary ELSE 0 END` returns zero for
    non-matching rows.
6.  A comparison such as `salary < 50000` is not true when `salary` is
    `NULL`; the condition is unknown.

If every value passed to `SUM()` is `NULL`, `SUM()` returns `NULL`, not
zero. If you need a zero result in that case, use `COALESCE`, for
example:

``` sql
COALESCE(SUM(CASE WHEN status = 'Completed' THEN amount END), 0)
```

------------------------------------------------------------------------

## 15. Common mistakes

### Mistake 1: Missing ELSE in conditional SUM

``` sql
-- Can return NULL when no rows match
SUM(CASE WHEN status = 'Completed' THEN amount END)
```

Safer when you want a zero for non-matching rows:

``` sql
SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END)
```

If the whole table has zero rows, the aggregate can still return `NULL`;
use `COALESCE` if zero is required.

### Mistake 2: Putting ELSE 0 inside AVG without understanding it

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary ELSE 0 END)
```

This includes non-matching rows as zero and can lower the average. To
average only matching salaries, use:

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary END)
```

### Mistake 3: Selecting a non-grouped column

Incorrect in a typical grouped query:

``` sql
SELECT department_id, employee_name, COUNT(*)
FROM employees
GROUP BY department_id;
```

`employee_name` is neither grouped nor aggregated. Remove it, group by
it too (which changes the grouping), or aggregate it appropriately.

### Mistake 4: Using WHERE for an aggregate condition

Use `HAVING` for conditions on aggregate results.

### Mistake 5: Overlapping CASE categories

Write boundaries carefully so that each row belongs to the intended
category. Remember that `BETWEEN` includes both endpoints.

### Mistake 6: Forgetting the expression in GROUP BY

When grouping by a `CASE` expression, repeat the expression in
`GROUP BY` or calculate it in a subquery/CTE and group by its alias in
the outer query.

------------------------------------------------------------------------

## 16. Practice Dataset

Use this sample table for the practice questions. The table is
illustrative; adapt column names to your own database.

``` sql
CREATE TABLE employees_practice (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department_id INT,
    salary NUMERIC(10, 2),
    experience INT
);

INSERT INTO employees_practice
    (employee_id, employee_name, department_id, salary, experience)
VALUES
    (1, 'Aman', 1, 75000, 5),
    (2, 'Riya', 1, 45000, 2),
    (3, 'Kabir', 1, 35000, 1),
    (4, 'Sara', 2, 82000, 6),
    (5, 'Dev', 2, 52000, 3),
    (6, 'Nisha', 2, 38000, 2),
    (7, 'Ishaan', 3, 60000, 4),
    (8, 'Meera', 3, 42000, 2),
    (9, 'Zoya', 3, 30000, 1),
    (10, 'Arjun', 1, 90000, 7);
```

### Verify the dataset

``` sql
SELECT *
FROM employees_practice
ORDER BY employee_id;
```

------------------------------------------------------------------------

## 17. Practical Questions --- Try First

Write each query yourself before checking the answer key.

### Beginner

**Q1.** Count how many employees earn ₹50,000 or more.

**Q2.** Calculate the total salary paid to employees earning ₹50,000 or
more.

**Q3.** Count how many employees fall into each salary category: - High:
salary ≥ ₹70,000 - Medium: ₹40,000 ≤ salary \< ₹70,000 - Low: salary \<
₹40,000

**Q4.** Show the number of employees in each department.

### Intermediate

**Q5.** For every department, show: - total employees - employees
earning at least ₹50,000 - employees earning below ₹50,000

**Q6.** For every department, calculate the sum of salaries for
employees earning at least ₹50,000 and the sum for employees earning
below ₹50,000.

**Q7.** For every department, calculate the average salary among
employees earning at least ₹50,000. Do not treat lower salaries as zero.

**Q8.** Show each department's number of High, Medium, and Low salary
employees in separate columns.

**Q9.** Show only departments with at least two employees earning
₹50,000 or more.

### Advanced / Interview-style

**Q10.** Calculate the percentage of employees earning at least ₹50,000
out of all employees.

**Q11.** For each department, show total employees, High-salary
employees (≥ ₹70,000), and the percentage of High-salary employees.
Round the percentage to two decimal places.

**Q12.** Create a report with one row per department containing: -
`department_id` - `total_employees` - `total_salary` -
`high_salary_total` for salary ≥ ₹70,000 - `average_salary`

**Q13.** Using a CTE, categorize employees into High, Medium, and Low
salary groups, then return each category's employee count and average
salary.

**Q14.** For the `orders` table with `customer_id`, `amount`, and
`status`, write a query that shows each customer's completed-order total
and pending-order total.

**Q15.** Explain the difference between these expressions:

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary END)
```

and

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary ELSE 0 END)
```

------------------------------------------------------------------------

## 18. Answer Key

### A1. Count employees earning ₹50,000 or more

``` sql
SELECT
    COUNT(CASE WHEN salary >= 50000 THEN 1 END) AS eligible_employees
FROM employees_practice;
```

Expected count: **6**.

### A2. Total salary for employees earning ₹50,000 or more

``` sql
SELECT
    SUM(CASE WHEN salary >= 50000 THEN salary ELSE 0 END) AS eligible_salary_total
FROM employees_practice;
```

Expected total: **414000.00**.

### A3. Count each salary category

``` sql
SELECT
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category,
    COUNT(*) AS employee_count
FROM employees_practice
GROUP BY
    CASE
        WHEN salary >= 70000 THEN 'High'
        WHEN salary >= 40000 THEN 'Medium'
        ELSE 'Low'
    END
ORDER BY salary_category;
```

Expected counts: - High: 3 - Medium: 4 - Low: 3

### A4. Number of employees in each department

``` sql
SELECT department_id, COUNT(*) AS total_employees
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

Expected counts: Department 1 = 4, Department 2 = 3, Department 3 = 3.

### A5. Department-level counts by salary threshold

``` sql
SELECT
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary >= 50000 THEN 1 END) AS salary_50000_or_more,
    COUNT(CASE WHEN salary < 50000 THEN 1 END) AS salary_below_50000
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

Expected counts: - Department 1: total 4, ≥ 50,000 is 2, below 50,000 is
2 - Department 2: total 3, ≥ 50,000 is 2, below 50,000 is 1 - Department
3: total 3, ≥ 50,000 is 1, below 50,000 is 2

### A6. Department-level conditional salary sums

``` sql
SELECT
    department_id,
    SUM(CASE WHEN salary >= 50000 THEN salary ELSE 0 END) AS salary_50000_or_more_total,
    SUM(CASE WHEN salary < 50000 THEN salary ELSE 0 END) AS salary_below_50000_total
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

### A7. Average salary among matching employees only

``` sql
SELECT
    department_id,
    AVG(CASE WHEN salary >= 50000 THEN salary END) AS avg_salary_50000_or_more
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

The missing `ELSE` means non-matching rows return `NULL`, which `AVG()`
ignores.

### A8. High, Medium, and Low counts by department

``` sql
SELECT
    department_id,
    COUNT(CASE WHEN salary >= 70000 THEN 1 END) AS high_count,
    COUNT(CASE WHEN salary >= 40000 AND salary < 70000 THEN 1 END) AS medium_count,
    COUNT(CASE WHEN salary < 40000 THEN 1 END) AS low_count
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

### A9. Departments with at least two employees earning ₹50,000 or more

``` sql
SELECT
    department_id,
    COUNT(CASE WHEN salary >= 50000 THEN 1 END) AS eligible_count
FROM employees_practice
GROUP BY department_id
HAVING COUNT(CASE WHEN salary >= 50000 THEN 1 END) >= 2
ORDER BY department_id;
```

Expected departments: **1 and 2**.

### A10. Percentage of employees earning ₹50,000 or more

``` sql
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN salary >= 50000 THEN 1 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS eligible_percentage
FROM employees_practice;
```

Expected result: **60.00%**.

### A11. High-salary percentage by department

``` sql
SELECT
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary >= 70000 THEN 1 END) AS high_salary_employees,
    ROUND(
        100.0 * COUNT(CASE WHEN salary >= 70000 THEN 1 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS high_salary_percentage
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

### A12. Department summary report

``` sql
SELECT
    department_id,
    COUNT(*) AS total_employees,
    SUM(salary) AS total_salary,
    SUM(CASE WHEN salary >= 70000 THEN salary ELSE 0 END) AS high_salary_total,
    AVG(salary) AS average_salary
FROM employees_practice
GROUP BY department_id
ORDER BY department_id;
```

### A13. CTE salary-category report

``` sql
WITH categorized_employees AS (
    SELECT
        employee_id,
        salary,
        CASE
            WHEN salary >= 70000 THEN 'High'
            WHEN salary >= 40000 THEN 'Medium'
            ELSE 'Low'
        END AS salary_category
    FROM employees_practice
)
SELECT
    salary_category,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary
FROM categorized_employees
GROUP BY salary_category
ORDER BY salary_category;
```

### A14. Completed and pending totals by customer

``` sql
SELECT
    customer_id,
    SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) AS completed_total,
    SUM(CASE WHEN status = 'Pending' THEN amount ELSE 0 END) AS pending_total
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
```

### A15. Difference between the two AVG expressions

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary END)
```

Averages only salaries of employees earning at least ₹50,000 because
non-matching rows return `NULL` and `AVG()` ignores `NULL`.

``` sql
AVG(CASE WHEN salary >= 50000 THEN salary ELSE 0 END)
```

Averages over all rows, treating salaries below ₹50,000 as zero. This
produces a different, usually lower, result.

------------------------------------------------------------------------

## 19. Interview Questions

1.  What is conditional aggregation?
2.  How can `CASE` be used with `COUNT()`?
3.  What is the difference between `COUNT(*)` and
    `COUNT(CASE WHEN ... THEN 1 END)`?
4.  Why is `ELSE 0` often used with `SUM()`?
5.  Why should you usually omit `ELSE 0` when calculating an average
    only for matching rows?
6.  What is the difference between `WHERE` and `HAVING`?
7.  Why must non-aggregated selected columns usually appear in
    `GROUP BY`?
8.  How can you calculate a percentage using conditional aggregation?
9.  What does `NULLIF(COUNT(*), 0)` prevent?
10. How can a CTE make a grouped `CASE` query easier to read?

### Short answers

1.  **Conditional aggregation:** calculating multiple metrics from
    selected rows using conditions inside aggregate expressions.
2.  Put `CASE` inside `COUNT`, for example
    `COUNT(CASE WHEN status = 'Completed' THEN 1 END)`.
3.  `COUNT(*)` counts every row; conditional `COUNT` counts only rows
    where the CASE result is non-NULL.
4.  `ELSE 0` ensures non-matching rows contribute zero to the sum.
5.  `ELSE 0` would include non-matching rows as zeros in the average.
6.  `WHERE` filters rows before grouping; `HAVING` filters groups after
    aggregation.
7.  SQL needs a defined value for each output group; an ungrouped,
    non-aggregated column may have multiple values in one group.
8.  Divide conditional count by total count, multiply by `100.0`, and
    protect against zero with `NULLIF`.
9.  It returns `NULL` instead of zero for a zero denominator, avoiding
    division by zero.
10. A CTE lets you calculate a category once and group by its alias in
    the outer query.

------------------------------------------------------------------------

## 20. Revision Cheat Sheet

``` sql
-- Count matching rows
COUNT(CASE WHEN condition THEN 1 END)

-- Sum matching values; non-matches contribute zero
SUM(CASE WHEN condition THEN numeric_value ELSE 0 END)

-- Average matching values only
AVG(CASE WHEN condition THEN numeric_value END)

-- Group by a CASE category (repeat CASE expression or use a CTE)
SELECT CASE WHEN condition THEN 'A' ELSE 'B' END AS category,
       COUNT(*) AS total
FROM table_name
GROUP BY CASE WHEN condition THEN 'A' ELSE 'B' END;

-- Filter groups after aggregation
HAVING COUNT(CASE WHEN condition THEN 1 END) >= 2

-- Safe percentage calculation
ROUND(
    100.0 * COUNT(CASE WHEN condition THEN 1 END)
    / NULLIF(COUNT(*), 0),
    2
)
```

------------------------------------------------------------------------

## 21. Completion Checklist

Mark each item after you can do it without looking at the answer key:

-   [ ] Explain `CASE`, aggregate functions, and `GROUP BY`.
-   [ ] Count rows matching a condition with `COUNT(CASE ...)`.
-   [ ] Sum matching values with `SUM(CASE ...)`.
-   [ ] Average only matching values with `AVG(CASE ...)`.
-   [ ] Produce salary-category counts.
-   [ ] Produce multiple conditional metrics per department.
-   [ ] Use `HAVING` to filter aggregate results.
-   [ ] Calculate percentages safely.
-   [ ] Explain how `NULL` and `ELSE 0` affect results.
-   [ ] Solve at least 10 of the 15 practice questions independently.

**Recommended GitHub path:**
`case-expressions/SQL_CASE_Aggregates_GroupBy_Notes.md`
