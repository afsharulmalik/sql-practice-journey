# Database Normalization — Day 3: Third Normal Form (3NF)

## 1. Normalization kya hai?
Normalization database tables ko is tarah organize karna hai ki unnecessary duplication kam ho, data consistent rahe, aur insert/update/delete anomalies se bacha ja sake.

## 2. 3NF kya hai?
Beginner-friendly definition: koi relation 3NF mein tab hota hai jab woh 2NF mein ho aur non-key attributes ki transitive dependency na ho.

Formal definition: har non-trivial functional dependency `X → A` ke liye, ya to `X` superkey ho, ya `A` prime attribute ho (candidate key ka hissa).

## 3. Transitive Dependency
Jab key kisi non-key attribute ko kisi doosre attribute ke through determine kare, to ise beginner-level explanation mein transitive dependency kehte hain.

**Example:**
- `employee_id → dept_id`
- `dept_id → dept_name`

Isliye `employee_id` `dept_name` ko indirectly determine karta hai:

`employee_id → dept_id → dept_name`

Yahan `dept_name` department ki information hai, employee ki directly stored information nahi.

## 4. Example table: 3NF violation

`Employees(employee_id, employee_name, dept_id, dept_name)`

| employee_id | employee_name | dept_id | dept_name |
|---|---|---|---|
| 101 | Aman | 10 | IT |
| 102 | Riya | 20 | HR |
| 103 | Rahul | 10 | IT |

Assumed dependencies:
- `employee_id → employee_name, dept_id`
- `dept_id → dept_name`

`dept_name` ko har employee row mein repeat karna padta hai. Department ka naam update karne par multiple rows update karni padengi, jisse inconsistency ka risk hota hai.

## 5. 3NF mein decomposition

### Employees
| employee_id (PK) | employee_name | dept_id (FK) |
|---|---|---|
| 101 | Aman | 10 |
| 102 | Riya | 20 |
| 103 | Rahul | 10 |

### Departments
| dept_id (PK) | dept_name |
|---|---|
| 10 | IT |
| 20 | HR |

Ab:
- `employee_id` employee details determine karta hai.
- `dept_id` department details determine karta hai.
- Employees table mein `dept_name` duplicate nahi hota.
- `Employees.dept_id` foreign key ke through `Departments.dept_id` se linked hota hai.

## 6. SQL example

```sql
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    dept_id INT REFERENCES departments(dept_id)
);
```

Sample data:

```sql
INSERT INTO departments (dept_id, dept_name)
VALUES
    (10, 'IT'),
    (20, 'HR');

INSERT INTO employees (employee_id, employee_name, dept_id)
VALUES
    (101, 'Aman', 10),
    (102, 'Riya', 20),
    (103, 'Rahul', 10);
```

Department name ke saath employees dekhne ke liye:

```sql
SELECT
    e.employee_id,
    e.employee_name,
    d.dept_name
FROM employees AS e
JOIN departments AS d
    ON e.dept_id = d.dept_id;
```

## 7. 1NF vs 2NF vs 3NF vs 4NF

| Normal Form | Beginner-level key idea |
|---|---|
| **1NF** | Har cell mein atomic value; repeating groups nahi |
| **2NF** | 1NF + non-prime attributes ki partial dependency nahi |
| **3NF** | 2NF + transitive dependency se bachna |
| **4NF** | Non-trivial multivalued dependencies ko handle karna |

**Important:** Ye beginner-level summaries hain. Formal normalization definitions candidate keys, prime attributes, superkeys aur functional dependencies par based hoti hain.

## 8. Dependencies ki definitions — revision

### Functional Dependency
`X → Y`: X ki value Y ko uniquely determine karti hai.

Example: `employee_id → employee_name`.

### Full Functional Dependency
Attribute composite candidate key ke poore set par depend karta hai, aur key ka koi proper subset use determine nahi kar sakta.

Example: `(student_id, course_id) → marks`.

### Partial Dependency
Non-prime attribute composite candidate key ke sirf ek proper subset par depend karta hai.

Example: `(student_id, course_id)` key ke saath `student_id → student_name`.

### Transitive Dependency
Beginner-level form: key attribute kisi non-key attribute ko doosre attribute ke through determine karti hai.

Example: `employee_id → dept_id` aur `dept_id → dept_name`.

### Multivalued Dependency (MVD)
`X ↠ Y`: X ke liye Y ki multiple independent values associated ho sakti hain.

Example: ek student ki multiple hobbies aur multiple languages, jo ek-doosre se independent hain. MVD ka major relation 4NF se hai.

### “No Dependency”
“No dependency” ek standard named dependency type nahi hai. Agar `X → Y` hold nahi karti, to X, Y ko functionally determine nahi karta. Exact meaning context par depend karta hai.

## 9. 3NF kyun useful hai?
- Department ya category jaisi information ki unnecessary repetition kam hoti hai.
- Update anomalies ka risk kam hota hai.
- Data consistency maintain karna easy hota hai.
- Relationships primary key aur foreign key ke through clear hoti hain.

## 10. Practice questions with answers

**Q1.** Dependencies: `student_id → dept_id`, `dept_id → dept_name`. Transitive dependency kis attribute ki wajah se hai?  
**Answer:** `dept_name`.

**Q2.** Employees aur Departments ko 3NF ke liye kaise split karenge?  
**Answer:** `Employees(employee_id, employee_name, dept_id)` aur `Departments(dept_id, dept_name)`.

**Q3.** 3NF ke liye kaunsi dependency remove karne par focus karte hain?  
**Answer:** Beginner-level explanation mein transitive dependency.

**Q4.** `dept_id` Employees table mein kya role play karta hai?  
**Answer:** Foreign key (FK); Departments table mein `dept_id` primary key (PK) hai.

**Q5.** Kya 3NF mein foreign keys allowed hain?  
**Answer:** Haan, foreign keys bilkul allowed hain.

## 11. Exam-ready summary
3NF relation ko 2NF mein hona chahiye aur non-key attributes ki transitive dependency se bachna chahiye. Example: `employee_id → dept_id → dept_name`. Isko `Employees(employee_id, employee_name, dept_id)` aur `Departments(dept_id, dept_name)` mein decompose kar sakte hain, jahan `dept_id` Employees mein FK aur Departments mein PK hai.
