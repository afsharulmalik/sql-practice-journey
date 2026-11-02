
# SQL Subqueries — Day 02 Notes

## 1. Single-Row Subquery

A single-row subquery returns one row containing a single value.

Example: Find employees with the highest salary.

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

**Logic:**
- `MAX(salary)` returns the highest salary.
- The outer query finds employees whose salary matches that value.

Common operators:
- `=`
- `>`
- `<`
- `>=`
- `<=`
- `<>`

## 2. Multiple-Row Subquery

A multiple-row subquery can return multiple rows.

Example: Find employees working in IT or HR departments.

```sql
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR')
);
```

**Logic:**
- The inner query returns the department IDs for IT and HR.
- `IN` checks whether an employee's department ID matches any returned ID.

## 3. Difference Between = and IN

### Using =

Use `=` when the subquery is expected to return a single value.

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

### Using IN

Use `IN` to check whether a value matches any value in a returned list.

```sql
SELECT name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR')
);
```

**Important:** If a subquery used with `=` returns multiple rows, PostgreSQL raises an error.

## 4. Using MIN() in a Subquery

Question: Find employees earning more than the minimum salary.

```sql
SELECT name
FROM employees
WHERE salary > (
    SELECT MIN(salary)
    FROM employees
);
```

**Logic:**
- `MIN(salary)` returns one value.
- The outer query selects employees earning more than that value.

## 5. Using ALL

`> ALL` means a value must be greater than every value returned by the subquery.

Question: Find employees earning more than every employee in the IT department.

```sql
SELECT *
FROM employees
WHERE salary > ALL (
    SELECT e.salary
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

**Logic:**
- The inner query returns the salaries of IT department employees.
- `> ALL` requires the outer employee's salary to exceed every returned salary.

### Alternative Using MAX()

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT MAX(e.salary)
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

This is equivalent when the IT department has at least one employee and the relevant salaries are non-NULL.

## 6. Using ANY

`> ANY` means a value must be greater than at least one value returned by the subquery.

Example: Find employees earning more than at least one IT employee.

```sql
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT e.salary
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

**Logic:** An employee qualifies if their salary exceeds at least one of the salaries returned by the inner query.

## 7. Difference Between ANY and ALL

Suppose IT salaries are:

| Employee | Salary |
|---|---:|
| Rahul | 30000 |
| Aman | 40000 |
| Priya | 50000 |

| Outer salary | `> ANY` | `> ALL` |
|---:|---|---|
| 25000 | No | No |
| 35000 | Yes | No |
| 45000 | Yes | No |
| 60000 | Yes | Yes |

- `> ANY`: greater than at least one returned value.
- `> ALL`: greater than every returned value.

## 8. Common Mistakes

### Mistake 1: Comparing the wrong columns

Incorrect:

```sql
WHERE employee_id > (
    SELECT MIN(salary)
    FROM employees
);
```

Correct:

```sql
WHERE salary > (
    SELECT MIN(salary)
    FROM employees
);
```

Always compare columns representing the same type of information.

### Mistake 2: Selecting salary from the wrong table

Salary belongs to the employees table in our example, not the departments table.

Correct:

```sql
SELECT e.salary
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id
WHERE d.department_name = 'IT';
```

### Mistake 3: Confusing ANY and ALL

- Use `ANY` when at least one comparison must be true.
- Use `ALL` when every comparison must be true.

## 9. Practice Questions and Solutions

### Q1. Find employees with the highest salary.

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

### Q2. Find employees in IT or HR.

```sql
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR')
);
```

### Q3. Find employees earning more than the minimum salary.

```sql
SELECT name
FROM employees
WHERE salary > (
    SELECT MIN(salary)
    FROM employees
);
```

### Q4. Find employees earning more than every IT employee.

```sql
SELECT *
FROM employees
WHERE salary > ALL (
    SELECT e.salary
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

### Q5. Find employees earning more than at least one IT employee.

```sql
SELECT name, salary
FROM employees
WHERE salary > ANY (
    SELECT e.salary
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

## 10. Day 02 Summary

Topics covered:
- Single-row subqueries
- Multiple-row subqueries
- `=`, `IN`, `ANY`, and `ALL`
- `MIN()` and `MAX()` in subqueries
- Subqueries combined with JOINs
- Common syntax and logic mistakes

**Next Topic:** SQL Subqueries — Day 03: `IN`, `NOT IN`, `ANY`, and `ALL` practice and interview questions.
