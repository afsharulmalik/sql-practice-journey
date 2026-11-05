# SQL Window Functions --- Complete Notes (Q1--Q24)

**Database:** PostgreSQL\
**Level:** Beginner to interview preparation\
**Practice:** 24 questions with solutions\
**Table used in examples:**
`employees(employee_id, emp_name, salary, dept_id)`

> If your actual column names are `employee_name` or `department_id`,
> replace `emp_name` or `dept_id` accordingly.

------------------------------------------------------------------------

## Core concepts

A **window function** calculates a value across related rows while
keeping each row in the result. `OVER()` defines the window,
`PARTITION BY` splits it into groups, and `ORDER BY` defines the order
used by ordered calculations.

-   `GROUP BY` usually combines rows into groups.
-   `PARTITION BY` groups rows for the window calculation but preserves
    individual rows.
-   `ROW_NUMBER()` gives each row a unique number.
-   `RANK()` gives ties the same rank and skips subsequent ranks.
-   `DENSE_RANK()` gives ties the same rank without skipping ranks.
-   `LAG()` reads a preceding row's value.
-   `LEAD()` reads a following row's value.
-   A window result generally cannot be filtered in `WHERE` at the same
    query level; use a CTE or subquery.

For row-by-row running calculations in PostgreSQL, explicitly use:

``` sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

------------------------------------------------------------------------

# Practice Questions and Solutions

## Q1. Display each employee's salary and company average salary

``` sql
SELECT
    emp_name,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;
```

**Explanation:** `OVER()` without partitioning applies the average
across the whole result set and repeats it on each employee row.

## Q2. Display each employee's salary and department average salary

``` sql
SELECT
    emp_name,
    dept_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS department_avg_salary
FROM employees;
```

**Explanation:** `PARTITION BY dept_id` calculates a separate average
for each department.

## Q3. Display the total salary of each employee's department

``` sql
SELECT
    *,
    SUM(salary) OVER (
        PARTITION BY dept_id
    ) AS department_total_salary
FROM employees;
```

**Explanation:** The department total appears on every employee row in
that department.

## Q4. Calculate a running salary total by employee ID

``` sql
SELECT
    employee_id,
    emp_name,
    salary,
    SUM(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM employees;
```

**Explanation:** Adds salary from the first employee row through the
current row.

## Q5. Assign a row number to employees ordered by salary

``` sql
SELECT
    *,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num
FROM employees;
```

**Explanation:** The highest salary receives row number 1. Ties still
receive different row numbers; add `employee_id` as a tie-breaker for
deterministic order.

## Q6. Assign row numbers separately within each department

``` sql
SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY dept_id
        ORDER BY salary DESC
    ) AS row_num
FROM employees;
```

**Explanation:** Numbering restarts for each department.

## Q7. Rank employees by salary using RANK()

``` sql
SELECT
    *,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

**Explanation:** Equal salaries share a rank. Following ranks can be
skipped.

## Q8. Rank employees by salary using DENSE_RANK()

``` sql
SELECT
    *,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

**Explanation:** Equal salaries share a rank, but the next rank is not
skipped.

## Q9. Find the highest-paid employee(s) in each department

``` sql
WITH employee_ranks AS (
    SELECT
        employee_id,
        emp_name,
        dept_id,
        salary,
        RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE salary_rank = 1;
```

**Explanation:** `RANK() = 1` returns every employee tied for the
highest salary in a department.

## Q10. Find employees in the top three distinct salary levels per department

``` sql
WITH employee_ranks AS (
    SELECT
        employee_id,
        emp_name,
        dept_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE salary_rank <= 3;
```

**Explanation:** Returns the top three distinct salary levels in every
department. More than three employees can appear because of ties.

## Q11. Display each employee's previous employee salary using LAG()

``` sql
SELECT
    employee_id,
    emp_name,
    salary,
    LAG(salary) OVER (
        ORDER BY employee_id
    ) AS previous_salary
FROM employees;
```

**Explanation:** The first row has `NULL` because it has no previous
row.

## Q12. Display each employee's next employee salary using LEAD()

``` sql
SELECT
    employee_id,
    emp_name,
    salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) AS next_salary
FROM employees;
```

**Explanation:** The last row has `NULL` because it has no next row.

## Q13. Calculate the difference between current and previous salary

``` sql
SELECT
    employee_id,
    emp_name,
    salary,
    LAG(salary) OVER (
        ORDER BY employee_id
    ) AS previous_salary,
    salary - LAG(salary) OVER (
        ORDER BY employee_id
    ) AS salary_difference
FROM employees;
```

**Explanation:** `salary_difference = current salary - previous salary`.
The first employee's difference is `NULL`.

## Q14. Calculate each employee's difference from department average salary

``` sql
SELECT
    emp_name,
    salary,
    dept_id,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS department_avg_salary,
    salary - AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS salary_difference
FROM employees;
```

**Explanation:** Positive means above the department average; negative
means below it.

## Q15. Compare ROW_NUMBER() and RANK()

``` sql
SELECT
    emp_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

**Explanation:** `ROW_NUMBER()` gives every row a different number.
`RANK()` assigns the same rank to ties and skips the next rank.

## Q16. Find the top two highest-paid employees per department

``` sql
WITH employee_ranks AS (
    SELECT
        employee_id,
        emp_name,
        dept_id,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC, employee_id ASC
        ) AS row_num
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE row_num <= 2;
```

**Explanation:** Returns at most two employees per department. Because
`ROW_NUMBER()` is used, ties do not increase the row count beyond two.

## Q17. Find the third-highest distinct salary in the company

``` sql
WITH employee_ranks AS (
    SELECT
        employee_id,
        emp_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT
    employee_id,
    emp_name,
    salary,
    salary_rank
FROM employee_ranks
WHERE salary_rank = 3;
```

**Explanation:** Returns all employees whose salary is the third-highest
distinct value. If fewer than three distinct salaries exist, no rows are
returned.

## Q18. Calculate running average salary by employee ID

``` sql
SELECT
    employee_id,
    emp_name,
    salary,
    AVG(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_avg_salary
FROM employees;
```

**Explanation:** For each row, calculates the average salary from the
first row up to that row.

## Q19. Find employees whose salary is greater than the previous employee's salary

``` sql
WITH salary_comparison AS (
    SELECT
        employee_id,
        emp_name,
        salary,
        LAG(salary) OVER (
            ORDER BY employee_id
        ) AS previous_employee_salary
    FROM employees
)
SELECT
    employee_id,
    emp_name,
    salary,
    previous_employee_salary
FROM salary_comparison
WHERE salary > previous_employee_salary;
```

**Explanation:** The first employee is naturally excluded because their
previous salary is `NULL`.

## Q20. Display the next salary and the difference from the current salary

``` sql
SELECT
    employee_id,
    emp_name,
    salary AS current_salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) AS next_salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) - salary AS salary_difference
FROM employees;
```

**Explanation:** `salary_difference = next salary - current salary`. The
final row has `NULL` for both next salary and the difference.

## Q21. Rank employees within each department using DENSE_RANK()

``` sql
SELECT
    employee_id,
    emp_name,
    dept_id,
    salary,
    DENSE_RANK() OVER (
        PARTITION BY dept_id
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

**Explanation:** Salary ranks restart for each department. Tied salaries
share the same rank without gaps.

## Q22. Find employees in the top three distinct salary levels per department

``` sql
WITH ranked_department_salaries AS (
    SELECT
        employee_id,
        dept_id,
        emp_name,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS dept_salary_rank
    FROM employees
)
SELECT
    employee_id,
    dept_id,
    emp_name,
    salary,
    dept_salary_rank
FROM ranked_department_salaries
WHERE dept_salary_rank <= 3
ORDER BY dept_id, dept_salary_rank;
```

**Explanation:** Same core pattern as Q10, now with an explicit result
ordering.

## Q23. Calculate cumulative salary separately for each department

``` sql
SELECT
    dept_id,
    employee_id,
    emp_name,
    salary,
    SUM(salary) OVER (
        PARTITION BY dept_id
        ORDER BY employee_id ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_salary
FROM employees;
```

**Explanation:** The cumulative sum restarts for each department and
grows in employee ID order.

## Q24. Find the highest-paid employee(s) in every department, including ties

``` sql
WITH department_salaries AS (
    SELECT
        dept_id,
        employee_id,
        emp_name,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT
    dept_id,
    employee_id,
    emp_name,
    salary
FROM department_salaries
WHERE salary_rank = 1
ORDER BY dept_id;
```

**Explanation:** All employees tied for the highest salary in each
department are returned.

------------------------------------------------------------------------

# Quick Interview Revision

  ------------------------------------------------------------------------------------
  Requirement                         Recommended function/pattern
  ----------------------------------- ------------------------------------------------
  Company average on each row         `AVG(salary) OVER()`

  Department average on each row      `AVG(salary) OVER(PARTITION BY dept_id)`

  Running total                       `SUM(...) OVER(ORDER BY ... ROWS BETWEEN ...)`

  Unique row numbering                `ROW_NUMBER()`

  Ranking with gaps after ties        `RANK()`

  Ranking without gaps after ties     `DENSE_RANK()`

  Previous row value                  `LAG()`

  Next row value                      `LEAD()`

  Top N rows per department           `ROW_NUMBER()` + CTE

  Top N distinct salary levels        `DENSE_RANK()` + CTE

  Filter a window-function result     CTE or subquery
  ------------------------------------------------------------------------------------

## Common mistakes

1.  Do not use a window alias directly in `WHERE` at the same query
    level; use a CTE or subquery.
2.  Use `DENSE_RANK()` for distinct salary levels.
3.  Use `RANK()` or `DENSE_RANK()` when all ties must be included.
4.  Use `ROW_NUMBER()` when you need at most N rows and want unique row
    numbers.
5.  Use an explicit `ROWS` frame for row-by-row running totals or
    averages.
6.  Check actual column names: this document uses `emp_name` and
    `dept_id`.
7.  `LAG()` on the first row and `LEAD()` on the last row usually return
    `NULL`.

## Completion Checklist

-   [ ] Understand `OVER()` and `PARTITION BY`.
-   [ ] Understand `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.
-   [ ] Use `LAG()` and `LEAD()`.
-   [ ] Calculate running totals and running averages.
-   [ ] Solve top-N-per-department problems.
-   [ ] Filter window results with a CTE.
-   [ ] Reattempt all 24 questions without looking at solutions.
