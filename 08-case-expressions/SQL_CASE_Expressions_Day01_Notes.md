# SQL CASE Expressions — Day 01 Notes

## 1. What is a CASE Expression?

A SQL `CASE` expression returns a value based on one or more conditions. It is similar to `if-else` logic in programming.

It can be used in statements such as `SELECT`, `ORDER BY`, and aggregate queries.

## 2. Searched CASE — Syntax

```sql
SELECT column_name,
       CASE
           WHEN condition1 THEN result1
           WHEN condition2 THEN result2
           ELSE default_result
       END AS result_column
FROM table_name;
```

- `CASE`: starts the expression.
- `WHEN`: specifies a condition.
- `THEN`: value returned when that condition is true.
- `ELSE`: optional fallback if no `WHEN` condition matches.
- `END`: closes the expression.
- `AS`: gives the output column an alias.

SQL checks `WHEN` conditions from top to bottom and returns the result for the first matching condition. If `ELSE` is omitted and no condition matches, the result is `NULL`.

## 3. Example: Eligibility

Rules: salary >= 50000 → `Eligible`; otherwise → `Not Eligible`.

```sql
SELECT *,
       CASE
           WHEN salary >= 50000 THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS eligible_salary
FROM employees;
```

`SELECT *` returns all existing columns, and `eligible_salary` is an additional calculated output column.

## 4. Example: Salary Categories

Rules:
- Salary >= 70000 → `High`
- Salary >= 40000 and below 70000 → `Medium`
- Otherwise → `Low`

```sql
SELECT *,
       CASE
           WHEN salary >= 70000 THEN 'High'
           WHEN salary >= 40000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;
```

The first condition catches salaries of 70000 or more. The second condition is reached only when the first condition is false, so it effectively covers salaries from 40000 up to (but not including) 70000.

**Important:** `BETWEEN` includes both endpoints. For example, `salary BETWEEN 40000 AND 70000` includes 70000. Remember to account for overlapping ranges and condition order.

## 5. Example: Bonus Percentage Labels

Rules: salary >= 80000 → `bonus 20%`; salary >= 50000 → `bonus 10%`; otherwise → `bonus 5%`.

```sql
SELECT *,
       CASE
           WHEN salary >= 80000 THEN 'bonus 20%'
           WHEN salary >= 50000 THEN 'bonus 10%'
           ELSE 'bonus 5%'
       END AS bonus_percentage
FROM employees;
```

This query returns **bonus labels**, not a calculated numeric bonus amount.

## 6. Multiple Conditions with AND

Rules:
- Salary >= 50000 AND experience >= 3 → `Senior`
- Salary >= 50000 AND experience < 3 → `Junior`
- Otherwise → `Entry Level`

```sql
SELECT *,
       CASE
           WHEN salary >= 50000 AND experience >= 3 THEN 'Senior'
           WHEN salary >= 50000 AND experience < 3 THEN 'Junior'
           ELSE 'Entry Level'
       END AS employee_level
FROM employees;
```

`AND` requires both conditions to be true. You can also use `OR` when at least one condition should be true.

## 7. Simple CASE

A **Simple CASE** compares one expression with specific values.

```sql
SELECT *,
       CASE department_id
           WHEN 1 THEN 'IT'
           WHEN 2 THEN 'HR'
           WHEN 3 THEN 'Finance'
           ELSE 'Other'
       END AS department_name
FROM employees;
```

Here, `department_id` is compared with 1, 2, and 3.

## 8. Simple CASE vs Searched CASE

| Simple CASE | Searched CASE |
|---|---|
| Starts with an expression, e.g. `CASE department_id` | Starts with `CASE` alone |
| Matches values using `WHEN 1`, `WHEN 2` | Checks conditions using `WHEN salary >= 50000` |
| Best for matching specific values | Best for ranges and complex conditions |

## 9. Common mistakes to avoid

1. **Invalid syntax:** Write `BETWEEN 40000 AND 69999`, not `IN BETWEEN`.
2. **Condition order:** Put higher-threshold conditions first when ranges overlap.
3. **Inclusive boundaries:** `BETWEEN a AND b` includes both `a` and `b`.
4. **Missing END:** Every `CASE` expression must end with `END`.
5. **Missing ELSE:** If no condition matches and there is no `ELSE`, the result is `NULL`.
6. **Output alias:** Use a meaningful alias such as `salary_category` or `employee_level`.
7. **NULL values:** Comparisons with `NULL` do not evaluate to true; consider `WHEN salary IS NULL THEN ...` if needed.

## 10. Practice questions completed

### Q1. Mark salary eligibility

```sql
SELECT *,
       CASE
           WHEN salary >= 50000 THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS eligible_salary
FROM employees;
```

### Q2. Classify salary

```sql
SELECT *,
       CASE
           WHEN salary >= 70000 THEN 'High'
           WHEN salary >= 40000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;
```

### Q3. Assign a bonus label

```sql
SELECT *,
       CASE
           WHEN salary >= 80000 THEN 'bonus 20%'
           WHEN salary >= 50000 THEN 'bonus 10%'
           ELSE 'bonus 5%'
       END AS bonus_percentage
FROM employees;
```

### Q4. Classify employee level

```sql
SELECT *,
       CASE
           WHEN salary >= 50000 AND experience >= 3 THEN 'Senior'
           WHEN salary >= 50000 AND experience < 3 THEN 'Junior'
           ELSE 'Entry Level'
       END AS employee_level
FROM employees;
```

### Q5. Map department IDs to names (Simple CASE)

```sql
SELECT *,
       CASE department_id
           WHEN 1 THEN 'IT'
           WHEN 2 THEN 'HR'
           WHEN 3 THEN 'Finance'
           ELSE 'Other'
       END AS department_name
FROM employees;
```

## 11. Quick revision

- `CASE` is SQL's conditional expression, similar to `if-else`.
- `WHEN` states a condition or value match; `THEN` gives the result.
- `ELSE` is optional; without it, unmatched cases return `NULL`.
- Conditions are evaluated top to bottom; the first match wins.
- **Simple CASE:** compares an expression to values.
- **Searched CASE:** evaluates Boolean conditions.
- CASE can return text, numbers, or other compatible values; result branches should have compatible data types.

## GitHub save location

Recommended file name: `SQL_CASE_Expressions_Day01_Notes.md`

Recommended repository path:

```text
sql-practice-journey/
└── case-expressions/
    └── SQL_CASE_Expressions_Day01_Notes.md
```

This file covers the CASE concepts and five practice questions completed in Day 01.
