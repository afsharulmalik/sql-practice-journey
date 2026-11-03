
# SQL Subqueries — Day 04 Notes
## Topic: Correlated Subqueries

## 1. Correlated Subquery kya hoti hai?

Correlated Subquery woh subquery hoti hai jo outer query ki current row par depend karti hai.

- Normal Subquery: Independently execute ho sakti hai.
- Correlated Subquery: Outer query se value leti hai.

Example:

```sql
SELECT *
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);
```

Explanation:
- `e` outer query ka alias hai.
- `e2` inner query ka alias hai.
- `e2.department_id = e.department_id` dono queries ko connect karta hai.
- Employee ki salary apne department ki average salary se zyada honi chahiye.

## 2. Important Syntax

```sql
SELECT *
FROM employees AS e
WHERE condition (
    SELECT aggregate_function(column)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);
```

Common aggregate functions:
- `AVG()` — Average
- `MAX()` — Maximum
- `MIN()` — Minimum
- `COUNT()` — Number of rows
- `SUM()` — Total

## 3. Salary Average se Kam

Task: Un employees ko find karo jinki salary apne department ki average salary se kam hai.

```sql
SELECT *
FROM employees AS e
WHERE e.salary < (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);
```

## 4. Department ki Highest Salary

Task: Har department ke highest-paid employee ko find karo.

```sql
SELECT *
FROM employees AS e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);
```

Note: Agar highest salary par multiple employees tied hain, toh sabhi return honge.

## 5. Department ki Second-Highest Distinct Salary

Task: Har department mein second-highest distinct salary paane wale employees find karo.

```sql
SELECT *
FROM employees AS e
WHERE 1 = (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > e.salary
);
```

Logic:
- Current employee se higher salaries count karo.
- `DISTINCT` duplicate salary levels ko ek baar count karta hai.
- Exactly ek distinct salary level higher hone par employee second-highest salary par hota hai.
- Tied second-highest salaries wale sabhi employees return hote hain.

## 6. NOT EXISTS ke Saath Correlated Subquery

Task: Un departments ke employees find karo jahan kisi bhi employee ki salary ₹30,000 se kam nahi hai.

```sql
SELECT e1.*
FROM employees AS e1
WHERE NOT EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e1.department_id
      AND e2.salary < 30000
);
```

Explanation:
- `EXISTS` check karta hai ki inner query koi row return karti hai ya nahi.
- `NOT EXISTS` tab true hota hai jab inner query koi row return nahi karti.
- Agar department mein ek bhi employee ki salary ₹30,000 se kam hai, toh us department ke employees exclude ho jayenge.
- `SELECT 1` yahan sirf row existence check karne ke liye hai.

## 7. AVG() aur COUNT() Dono ka Use

Task: Un employees ko find karo jinki salary department average se zyada hai aur department mein kam se kam 3 employees hain.

```sql
SELECT *
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
AND (
    SELECT COUNT(*)
    FROM employees AS e3
    WHERE e3.department_id = e.department_id
) >= 3;
```

Logic:
1. First subquery department ki average salary calculate karti hai.
2. Second subquery department ke employees count karti hai.
3. `AND` dono conditions ko satisfy karna zaroori banata hai.

## 8. Important Operators

| Operator | Meaning |
|---|---|
| `>` | Greater than |
| `<` | Less than |
| `=` | Equal to |
| `>=` | Greater than or equal to |
| `EXISTS` | Inner query mein row exist karti hai |
| `NOT EXISTS` | Inner query mein koi row exist nahi karti |

## 9. Common Mistakes

### Mistake 1: Alias define nahi karna

Incorrect:

```sql
SELECT e2.salary
FROM employees;
```

Correct:

```sql
SELECT e2.salary
FROM employees AS e2;
```

### Mistake 2: Department condition bhool jaana

Agar department-wise comparison chahiye, toh correlated condition lagao:

```sql
WHERE e2.department_id = e.department_id
```

Iske bina query poori company ka average ya maximum nikal sakti hai.

### Mistake 3: Galat comparison operator

- Average se kam: `< AVG(...)`
- Average se zyada: `> AVG(...)`
- Highest salary: `= MAX(...)`

### Mistake 4: DISTINCT bhool jaana

Second-highest distinct salary ke liye:

```sql
COUNT(DISTINCT e2.salary)
```

Use karo, taaki same salary ko multiple salary levels na gina jaaye.

## 10. Performance Notes

- Correlated subquery outer query ki values par depend karti hai.
- Large tables par performance inspect karne ke liye `EXPLAIN ANALYZE` useful hai.
- Database optimizer subquery ko rewrite ya optimize kar sakta hai.
- Zaroorat ke hisaab se joins, window functions aur indexes alternatives ho sakte hain.

## 11. Quick Revision

1. Correlated subquery outer query ki row par depend karti hai.
2. Different aliases use karna readability aur correct references ke liye important hai.
3. `AVG()` average salary calculate karta hai.
4. `MAX()` highest salary return karta hai.
5. `COUNT(DISTINCT ...)` unique values count karta hai.
6. `EXISTS` aur `NOT EXISTS` row existence check karte hain.
7. Department-wise comparison ke liye department IDs correlate karo.
8. Tied highest ya second-highest salaries par multiple employees return ho sakte hain.

## 12. Practice Questions Completed

- Q1: Department average se kam salary.
- Q2: Department ki highest salary.
- Q3: Department ki second-highest distinct salary.
- Q4: Aise departments jahan salary ₹30,000 se kam kisi ki nahi.
- Q5: Average se zyada salary aur department mein at least 3 employees.

---
End of SQL Subqueries Day 04 Notes
