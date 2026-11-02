
# SQL Subqueries — Day 01 Notes

## 1. What is a Subquery?

A subquery is a SQL query written inside another SQL query.
It is also called a nested query.

## 2. Basic Syntax

```sql
SELECT column_name
FROM table_name
WHERE column_name operator (
    SELECT column_name
    FROM table_name
);
```

## 3. How Does a Subquery Work?

Example: Find employees whose salary is greater than the company's average salary.

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

- Inner query calculates the average salary.
- Outer query compares each employee's salary with that average.
- Only matching employees are returned.

## 4. Aggregate Functions in Subqueries

- `AVG(salary)` — calculates average salary.
- `MAX(salary)` — returns the maximum salary.
- `MIN(salary)` — returns the minimum salary.

## 5. Practice Questions and Solutions

### Q1. Find employees earning less than the average salary.

```sql
SELECT *
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);
```

**Logic:** The inner query calculates the average salary. The outer query returns employees earning less than that value.

### Q2. Find employees earning less than the maximum salary minus 10,000.

```sql
SELECT *
FROM employees
WHERE salary < (
    SELECT MAX(salary) - 10000
    FROM employees
);
```

**Logic:** Subtract 10,000 from the maximum salary and find employees earning less than the result.

### Q3. Display the names of employees earning more than the minimum salary.

```sql
SELECT name
FROM employees
WHERE salary > (
    SELECT MIN(salary)
    FROM employees
);
```

**Logic:** The inner query finds the minimum salary. The outer query returns names of employees earning more than that amount.

### Q4. Find employees whose salary equals the average salary.

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT AVG(salary)
    FROM employees
);
```

**Logic:** Returns employees whose salary exactly equals the calculated average. The query may return no rows if no salary matches the average exactly.

### Q5. Find employees earning more than the average salary plus 5,000.

```sql
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary) + 5000
    FROM employees
);
```

**Logic:** Calculate the average salary, add 5,000, and return employees earning more than the result.

## 6. Important Concepts

- A subquery is enclosed in parentheses in these examples.
- The inner query provides a value used by the outer query.
- Use `AVG()`, `MAX()`, and `MIN()` for salary calculations.
- Use `<`, `>`, and `=` to compare salaries with the subquery result.
- `salary > AVG(salary) + 5000` means salary must be strictly greater than the average plus 5,000.
- If no employee matches the condition, the query returns zero rows.

## 7. Common Mistakes

### Mistake 1: Unnecessary MIN() around a subquery

Incorrect:

```sql
WHERE salary < MIN(SELECT AVG(salary) FROM employees);
```

Correct:

```sql
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);
```

### Mistake 2: Incorrect arithmetic syntax

Incorrect:

```sql
WHERE salary < 1000(SELECT MAX(salary) FROM employees);
```

Correct:

```sql
WHERE salary < (
    SELECT MAX(salary) - 10000
    FROM employees
);
```

## 8. Day 01 Summary

Topics covered:
- Subquery definition
- Inner query and outer query
- Subqueries with `WHERE`
- Subqueries using `AVG()`, `MAX()`, and `MIN()`
- Arithmetic operations inside subqueries
- Five practice questions

**Next:** SQL Subqueries — Day 02 (single-row and multiple-row subqueries).
