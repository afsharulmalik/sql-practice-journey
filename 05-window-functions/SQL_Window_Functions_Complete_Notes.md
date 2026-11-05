# SQL Window Functions — Complete Notes
**Level:** Beginner to Interview Preparation  
**Database:** PostgreSQL  
**Practice completed:** 24 Questions

---

## 1. What is a Window Function?

A Window Function calculates a result using a set of related rows while keeping each original row in the output.

Unlike `GROUP BY`, it does not combine multiple employees into a single row.

### Example: Company Average Salary

```sql
SELECT
    emp_name,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;
```

**Explanation:**
- `AVG(salary)` calculates average salary.
- `OVER()` makes it a window function.
- Every employee remains in the output, along with the company average.

---

## 2. OVER() Clause

The `OVER()` clause defines the window of rows on which a window function operates.

```sql
SELECT
    emp_name,
    salary,
    SUM(salary) OVER () AS company_total_salary
FROM employees;
```

Here, every row displays the total salary of all employees.

**Remember:** `OVER()` without partitioning or ordering uses the entire result set as its window.

---

## 3. PARTITION BY

`PARTITION BY` divides rows into groups for window calculations without removing individual rows.

### Department-wise Average Salary

```sql
SELECT
    emp_name,
    dept_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS department_avg_salary
FROM employees;
```

Each employee gets the average salary of their own department.

### Department-wise Total Salary

```sql
SELECT
    emp_name,
    dept_id,
    salary,
    SUM(salary) OVER (
        PARTITION BY dept_id
    ) AS department_total_salary
FROM employees;
```

**Difference:**
- `GROUP BY dept_id` generally returns one row per department.
- `PARTITION BY dept_id` keeps every employee row.

---

## 4. ORDER BY Inside OVER()

`ORDER BY` determines the order in which rows are processed for an ordered window calculation.

### Running Total

```sql
SELECT
    employee_id,
    emp_name,
    salary,
    SUM(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_total
FROM employees;
```

The running total increases as each employee is processed.

### Department-wise Running Total

```sql
SELECT
    employee_id,
    emp_name,
    dept_id,
    salary,
    SUM(salary) OVER (
        PARTITION BY dept_id
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS department_running_total
FROM employees;
```

The running total starts again for each department.

### Important: Window Frame

```sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

- `UNBOUNDED PRECEDING`: start from the first row in the window partition.
- `CURRENT ROW`: end at the current row.
- `ROWS`: process the frame row by row.

In PostgreSQL, an ordered aggregate window normally defaults to a `RANGE` frame. Use an explicit `ROWS` frame when you want a row-by-row cumulative calculation.

---

## 5. ROW_NUMBER()

`ROW_NUMBER()` assigns a unique sequential number to every row.

### Example

```sql
SELECT
    emp_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num
FROM employees;
```

The highest-paid employee gets row number 1.

Even when salaries are equal, `ROW_NUMBER()` assigns different numbers. To make the ordering deterministic for tied salaries, add a unique tie-breaker such as `employee_id`.

```sql
ROW_NUMBER() OVER (
    ORDER BY salary DESC, employee_id ASC
)
```

### Department-wise Row Number

```sql
SELECT
    emp_name,
    dept_id,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY dept_id
        ORDER BY salary DESC, employee_id ASC
    ) AS row_num
FROM employees;
```

Numbering starts again within each department.

---

## 6. RANK()

`RANK()` assigns the same rank to tied values and skips subsequent ranks.

```sql
SELECT
    emp_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

Example:

| Salary | RANK |
|---:|---:|
| 80000 | 1 |
| 70000 | 2 |
| 70000 | 2 |
| 60000 | 4 |

Rank 3 is skipped because two employees share rank 2.

---

## 7. DENSE_RANK()

`DENSE_RANK()` also assigns the same rank to tied values, but it does not skip ranks.

```sql
SELECT
    emp_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

Example:

| Salary | DENSE_RANK |
|---:|---:|
| 80000 | 1 |
| 70000 | 2 |
| 70000 | 2 |
| 60000 | 3 |

### Difference Between Ranking Functions

| Function | Unique row numbers? | Same rank for ties? | Skips ranks? |
|---|---|---|---|
| `ROW_NUMBER()` | Yes | No | No |
| `RANK()` | No | Yes | Yes |
| `DENSE_RANK()` | No | Yes | No |

---

## 8. Top N Employees Per Department

To get the two highest-paid employees per department using `ROW_NUMBER()`:

```sql
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

This returns at most two employees per department.

**Important:** If salaries are tied, `ROW_NUMBER()` still selects at most two rows. Use `RANK()` or `DENSE_RANK()` if tied employees must all be included.

---

## 9. Top 3 Distinct Salary Levels Per Department

```sql
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
WHERE salary_rank <= 3
ORDER BY dept_id, salary_rank;
```

This returns employees whose salaries belong to the top three distinct salary levels in their department.

The result may contain more than three employees per department because of ties.

---

## 10. Third-Highest Distinct Salary

```sql
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

This returns all employees earning the third-highest distinct salary.

**Why use `DENSE_RANK()`?** It ranks distinct salary levels without gaps caused by ties.

---

## 11. LAG()

`LAG()` accesses a value from a preceding row without requiring a self-join.

### Previous Employee's Salary

```sql
SELECT
    employee_id,
    emp_name,
    salary,
    LAG(salary) OVER (
        ORDER BY employee_id
    ) AS previous_salary
FROM employees;
```

The first row has `NULL` for `previous_salary` because no preceding row exists.

### Salary Difference from Previous Employee

```sql
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

A positive difference means the current salary is higher than the previous employee's salary.

### Employees Earning More Than the Previous Employee

```sql
WITH salary_comparison AS (
    SELECT
        employee_id,
        emp_name,
        salary,
        LAG(salary) OVER (
            ORDER BY employee_id
        ) AS previous_salary
    FROM employees
)
SELECT *
FROM salary_comparison
WHERE salary > previous_salary;
```

The first row is excluded because its previous salary is `NULL`.

---

## 12. LEAD()

`LEAD()` accesses a value from a following row.

### Next Employee's Salary

```sql
SELECT
    employee_id,
    emp_name,
    salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) AS next_salary
FROM employees;
```

The last row has `NULL` for `next_salary` because no following row exists.

### Difference Between Next and Current Salary

```sql
SELECT
    employee_id,
    emp_name,
    salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) AS next_salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) - salary AS salary_difference
FROM employees;
```

- Positive difference: next employee's salary is higher.
- Negative difference: next employee's salary is lower.
- `NULL`: there is no next employee.

**Remember:** `LAG()` looks backward; `LEAD()` looks forward.

---

## 13. Running Average

A running average calculates the average from the first row up to the current row.

```sql
SELECT
    employee_id,
    emp_name,
    salary,
    AVG(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_avg_salary
FROM employees;
```

### Department-wise Salary Difference from Average

```sql
SELECT
    emp_name,
    dept_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS department_avg_salary,
    salary - AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS salary_difference
FROM employees;
```

- Positive difference: salary is above the department average.
- Negative difference: salary is below the department average.
- Zero: salary equals the department average.

---

## 14. Highest-Paid Employee in Each Department

Use `DENSE_RANK()` when every employee tied for the highest salary must be included.

```sql
WITH department_salaries AS (
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
SELECT
    employee_id,
    emp_name,
    dept_id,
    salary
FROM department_salaries
WHERE salary_rank = 1
ORDER BY dept_id;
```

This returns all employees tied for the highest salary in their department.

---

## 15. Why Use a CTE with Window Functions?

A window function's result generally cannot be referenced directly in the `WHERE` clause of the same query level.

Incorrect:

```sql
SELECT
    emp_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees
WHERE salary_rank = 3;
```

Correct approach:

```sql
WITH ranked_employees AS (
    SELECT
        emp_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE salary_rank = 3;
```

The CTE calculates the ranking first. The outer query then filters the calculated result.

---

## 16. Aggregate Window Functions

You can use aggregate functions as window functions.

| Function | Purpose |
|---|---|
| `SUM() OVER()` | Total sum across the window |
| `AVG() OVER()` | Average across the window |
| `COUNT() OVER()` | Count rows in the window |
| `MIN() OVER()` | Minimum value in the window |
| `MAX() OVER()` | Maximum value in the window |

Example:

```sql
SELECT
    emp_name,
    dept_id,
    salary,
    COUNT(*) OVER (
        PARTITION BY dept_id
    ) AS department_employee_count,
    MAX(salary) OVER (
        PARTITION BY dept_id
    ) AS department_max_salary
FROM employees;
```

---

## 17. Common Mistakes to Avoid

1. **Using a window alias directly in `WHERE`:** Use a CTE or subquery.
2. **Confusing `RANK()` and `DENSE_RANK()`:** `RANK()` skips ranks after ties; `DENSE_RANK()` does not.
3. **Using `ROW_NUMBER()` when ties must all be included:** Use `RANK()` or `DENSE_RANK()` according to the requirement.
4. **Forgetting `PARTITION BY`:** Without it, ranking or calculations may apply across the entire result set.
5. **Forgetting `ORDER BY`:** Row-sensitive calculations need a defined order.
6. **Ignoring the window frame:** Specify `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` for explicit row-by-row running totals and averages.
7. **Using inconsistent column names:** Confirm whether your table uses `emp_name` or `employee_name`, and `dept_id` or `department_id`.
8. **Ignoring `NULL`:** The first `LAG()` and last `LEAD()` results are normally `NULL`.
9. **Assuming top N always means exactly N rows:** Ties can return additional rows with `RANK()` or `DENSE_RANK()`.

---

## 18. Interview Quick Revision

**Q1. What is a Window Function?**  
A function that calculates a result across related rows while preserving individual rows.

**Q2. `GROUP BY` vs `PARTITION BY`?**  
`GROUP BY` aggregates rows into groups; `PARTITION BY` divides the window calculation into groups without collapsing the rows.

**Q3. `ROW_NUMBER()` vs `RANK()`?**  
`ROW_NUMBER()` assigns unique sequential numbers; `RANK()` gives tied rows the same rank and skips the next rank.

**Q4. `RANK()` vs `DENSE_RANK()`?**  
`RANK()` leaves gaps after ties; `DENSE_RANK()` does not.

**Q5. `LAG()` vs `LEAD()`?**  
`LAG()` accesses a preceding row; `LEAD()` accesses a following row.

**Q6. How do you find the third-highest distinct salary?**  
Use `DENSE_RANK() OVER (ORDER BY salary DESC)` and filter for rank 3 in an outer query.

**Q7. How do you find the top two employees per department?**  
Use `ROW_NUMBER()` partitioned by department and filter for row numbers less than or equal to 2.

**Q8. Why use a CTE?**  
To calculate the window result in one query level and filter it in the next.

**Q9. What does `UNBOUNDED PRECEDING` mean?**  
The frame starts from the first row of the current window partition.

**Q10. Can window functions be used with aggregate functions?**  
Yes. For example, `SUM(salary) OVER (...)` and `AVG(salary) OVER (...)`.

---

## Final Checklist

- [ ] Understand `OVER()`.
- [ ] Understand `PARTITION BY` and `ORDER BY`.
- [ ] Differentiate `ROW_NUMBER()`, `RANK()` and `DENSE_RANK()`.
- [ ] Use `LAG()` and `LEAD()`.
- [ ] Calculate running totals and running averages.
- [ ] Find top N employees per department.
- [ ] Find the third-highest distinct salary.
- [ ] Use CTEs to filter window results.
- [ ] Understand ties, `NULL` values and window frames.

**Status:** 24 practice questions completed. Revise these notes and try writing the queries again without looking at the solutions.
