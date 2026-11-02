
# SQL Subqueries — Day 03 Notes

## 1. IN Operator

`IN` check karta hai ki koi value subquery se return hui values ki list mein present hai ya nahi.

```sql
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR', 'Sales')
);
```

**Explanation:** IT, HR aur Sales departments ke employees return honge.

## 2. NOT IN Operator

`NOT IN` un values ko select karta hai jo subquery ki returned list mein nahi hain.

```sql
SELECT name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE department_name = 'IT'
);
```

**Explanation:** IT department ko exclude karke employees return honge.

**Important:** Agar subquery `NULL` return karti hai, toh `NOT IN` unexpected results de sakta hai. Aise cases mein `NOT EXISTS` bhi useful hai.

## 3. ANY Operator

`ANY` ka matlab hai ki condition subquery ki **kam-se-kam ek value** ke liye true honi chahiye.

Example: Un employees ko find karna jinki salary kisi bhi IT employee ki salary se zyada hai.

```sql
SELECT e.name, e.salary
FROM employees AS e
WHERE e.salary > ANY (
    SELECT e2.salary
    FROM employees AS e2
    JOIN departments AS d
        ON e2.department_id = d.department_id
    WHERE d.department_name = 'IT'
);
```

**Explanation:** Salary IT department ke kam-se-kam ek employee se zyada honi chahiye.

## 4. ALL Operator

`ALL` ka matlab hai ki condition subquery ki **har value** ke liye true honi chahiye.

Example: HR department ke har employee se kam salary wale employees.

```sql
SELECT e.name, e.salary
FROM employees AS e
WHERE e.salary < ALL (
    SELECT e2.salary
    FROM employees AS e2
    JOIN departments AS d
        ON e2.department_id = d.department_id
    WHERE d.department_name = 'HR'
);
```

**Explanation:** Employee ki salary HR ke sabhi employees ki salaries se kam honi chahiye.

## 5. MIN() with a Subquery

Lowest salary wale employee ko find karna:

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);
```

**Explanation:**
- Inner query minimum salary find karti hai.
- Outer query us salary wale employees return karti hai.
- Agar multiple employees ki salary minimum hai, toh sabhi return honge.

## 6. MAX() with a Department Filter

HR department ki highest salary wale employee ko find karna:

```sql
SELECT e.name, e.salary
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.department_id
WHERE d.department_name = 'HR'
  AND e.salary = (
      SELECT MAX(e2.salary)
      FROM employees AS e2
      JOIN departments AS d2
          ON e2.department_id = d2.department_id
      WHERE d2.department_name = 'HR'
  );
```

**Explanation:**
- HR department filter hota hai.
- `MAX()` HR ki highest salary find karta hai.
- Outer query us salary wale HR employee ko return karti hai.

## 7. Important Differences

| Operator | Meaning |
|---|---|
| `IN` | Value list mein present hai |
| `NOT IN` | Value list mein present nahi hai |
| `> ANY` | Kam-se-kam ek value se greater |
| `< ANY` | Kam-se-kam ek value se smaller |
| `> ALL` | Har value se greater |
| `< ALL` | Har value se smaller |
| `MIN()` | Minimum value |
| `MAX()` | Maximum value |

## 8. Common Mistakes

1. Subquery mein required department filter bhool jaana.
2. `employees` table mein `department_name` assume karna jab woh `departments` table mein ho.
3. `ANY` aur `ALL` ko same samajhna.
4. `NOT IN` ke saath `NULL` ke behaviour ko ignore karna.
5. Table aur column names apne actual database schema ke according verify na karna.

## 9. Practice Questions

1. IT, HR aur Sales departments ke employees display karo.
2. IT department ke employees exclude karo.
3. Un employees ko display karo jinki salary kisi bhi IT employee se zyada hai.
4. Un employees ko display karo jinki salary HR ke har employee se kam hai.
5. Lowest salary wale employee ka naam aur salary display karo.
6. HR department ki highest salary wale employee ka naam aur salary display karo.

## Day 03 Summary

- `IN` aur `NOT IN` lists ke against comparison karte hain.
- `ANY` kam-se-kam ek value ke against condition check karta hai.
- `ALL` har value ke against condition check karta hai.
- `MIN()` aur `MAX()` aggregate functions hain.
- Subqueries ko department filters aur joins ke saath combine kiya ja sakta hai.
