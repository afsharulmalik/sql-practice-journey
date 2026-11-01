# SQL SELF JOIN — Day 05 Notes

## 1. What is SELF JOIN?

SELF JOIN is a technique in SQL in which a table is joined with itself.

It is useful when rows in the same table are related to each other, such as employees and their managers.

## 2. Example Table: employees

| employee_id | employee_name | manager_id |
|---:|---|---:|
| 1 | Rahul | NULL |
| 2 | Aman | 1 |
| 3 | Priya | 1 |
| 4 | Neha | 2 |
| 5 | Karan | 2 |

- `employee_id`: Unique ID of each employee.
- `employee_name`: Name of the employee.
- `manager_id`: ID of the employee's manager.
- `NULL`: Employee has no manager.

## 3. Display Employees and Their Managers

```sql
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id;
```

### Key points
- `e` represents the employee.
- `m` represents the manager.
- Both aliases refer to the same table.
- `LEFT JOIN` keeps employees even when they have no manager.

## 4. Find Employees Whose Manager Is Rahul

```sql
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name = 'Rahul';
```

Expected employees: Aman and Priya.

## 5. Find Employees Without a Manager

```sql
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_id IS NULL;
```

Expected employee: Rahul.

## 6. Find Employees Whose Manager Is Aman

```sql
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name = 'Aman';
```

Expected employees: Neha and Karan.

## 7. Important Concepts

- SELF JOIN is a technique, not a separate JOIN keyword.
- Use aliases to distinguish the two references to the same table.
- Use `LEFT JOIN` when employees without managers must also appear.
- Use `INNER JOIN` when only matching employee-manager pairs are needed.
- Use `IS NULL` to check for NULL values; do not use `= NULL`.
- A comparison such as `column != 'Rahul'` does not include NULL values automatically.

## Practice Completed

- Display employee and manager names.
- Find employees managed by Rahul.
- Find employees without a manager.
- Find employees managed by Aman.

**Topic:** SQL SELF JOIN — Day 05  
**Status:** Completed
