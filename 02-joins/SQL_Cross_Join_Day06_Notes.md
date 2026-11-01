# SQL CROSS JOIN — Day 06 Notes

## 1. What is CROSS JOIN?

CROSS JOIN combines every row of the first table with every row of the second table.

It produces a **Cartesian Product** of the two tables.

## 2. Example Tables

### students

| student_id | student_name |
|---:|---|
| 1 | Rahul |
| 2 | Aman |

### courses

| course_id | course_name |
|---:|---|
| 101 | Java |
| 102 | SQL |
| 103 | Python |

## 3. CROSS JOIN Query

```sql
SELECT
    s.student_name,
    c.course_name
FROM students AS s
CROSS JOIN courses AS c;
```

### Expected Output

| student_name | course_name |
|---|---|
| Rahul | Java |
| Rahul | SQL |
| Rahul | Python |
| Aman | Java |
| Aman | SQL |
| Aman | Python |

Total rows = 2 × 3 = 6.

## 4. Important Formula

**Total output rows = Rows in Table A × Rows in Table B**

Examples:

- 4 students × 5 courses = 20 rows
- 3 students × 4 courses = 12 rows
- 6 employees × 3 departments = 18 rows

## 5. CROSS JOIN vs INNER JOIN

| CROSS JOIN | INNER JOIN |
|---|---|
| Generates all possible combinations | Returns rows matching a condition |
| Does not require an `ON` condition | Usually uses an `ON` condition |
| Produces a Cartesian Product | Produces matching records |

## 6. Important Points

- CROSS JOIN does not require an `ON` condition.
- Output size depends on the number of rows in both tables.
- If either table is empty, the result contains zero rows.
- Large tables can produce a very large result set.
- Table aliases such as `s` and `c` make queries easier to read.

## 7. Practice Completed

- Calculated output rows for CROSS JOIN.
- Wrote a CROSS JOIN query using aliases.
- Practiced combining students and courses.
- Practiced combining employees and departments.

**Topic:** SQL CROSS JOIN — Day 06  
**Status:** Completed
