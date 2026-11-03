
# SQL Subqueries — Day 05 Notes
## Topic: Advanced Subqueries in PostgreSQL

## 1. IN
`IN` check karta hai ki koi value subquery ke result mein present hai ya nahi.

```sql
SELECT *
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE salary > 70000
);
```

## 2. EXISTS
`EXISTS` check karta hai ki subquery kam se kam ek row return karti hai ya nahi.

```sql
SELECT *
FROM employees AS e
WHERE EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > 80000
);
```

## 3. NOT EXISTS
`NOT EXISTS` tab true hota hai jab subquery koi matching row return nahi karti.

```sql
SELECT *
FROM employees AS e
WHERE e.salary > 40000
  AND NOT EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.department_id = e.department_id
        AND e2.salary < 30000
  );
```

## 4. ANY
`ANY` ka matlab hai ki comparison kam se kam ek value ke liye true hona chahiye.

```sql
-- Salary department 101 ke kam se kam ek employee
-- ki salary se zyada honi chahiye.
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);
```

## 5. ALL
`ALL` ka matlab hai ki comparison subquery ki har value ke liye true hona chahiye.

```sql
-- Salary department 101 ke har employee ki salary
-- se zyada honi chahiye.
SELECT *
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);
```

## 6. Correlated Subquery
Correlated subquery outer query ke current row par depend karti hai.

```sql
SELECT *
FROM employees AS e
WHERE EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > 80000
);
```

Yahan `e2.department_id = e.department_id` outer query ke employee ke department se comparison karta hai.

## 7. AVG() with EXISTS

```sql
SELECT *
FROM employees AS e
WHERE EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
    HAVING AVG(e2.salary) < e.salary
);
```

`HAVING` aggregate function `AVG()` ki result condition check karne ke liye use hua hai.

## 8. Maximum Salary in Each Department

```sql
SELECT *
FROM employees AS e
WHERE EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
    HAVING MAX(e2.salary) = e.salary
);
```

Ye har department ke maximum salary wale employee ko return karta hai. Agar multiple employees ki salary maximum ke equal hai, sab return honge.

## 9. Practice: Salary > ₹40,000 and Department Average

```sql
SELECT *
FROM employees AS e
WHERE e.salary > 40000
  AND EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.department_id = e.department_id
      HAVING AVG(e2.salary) < e.salary
  );
```

## Important Rules

1. `IN` — matching values check karta hai.
2. `EXISTS` — matching row ki existence check karta hai.
3. `NOT EXISTS` — matching row ki absence check karta hai.
4. `ANY` — kam se kam ek value ke saath condition true.
5. `ALL` — har value ke saath condition true.
6. `AVG()` — average calculate karta hai.
7. `MAX()` — maximum value calculate karta hai.
8. `WHERE` individual rows ko filter karta hai.
9. `HAVING` aggregate results ko filter karta hai.
10. Correlated subquery outer query ke column ko reference karti hai.

## Important Caution

`NOT IN` ke saath subquery mein `NULL` aane par unexpected results mil sakte hain. Aise cases mein `NOT EXISTS` aksar safer choice hoti hai.

## Day 05 Summary

Advanced subqueries mein `IN`, `EXISTS`, `NOT EXISTS`, `ANY`, `ALL`, correlated subqueries aur aggregate functions ka use seekha.
