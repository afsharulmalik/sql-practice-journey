# SQL Constraints — Complete Notes + 25 Practice Questions (PostgreSQL)

**Status:** Topic completed  
**Database:** PostgreSQL

This file includes the concepts, syntax, common mistakes, and the 25-question practice set with answers.

---

## Part 1 — Constraints: Concepts and Syntax

Constraints are rules applied to table columns or tables to maintain data accuracy and integrity.

The six common constraints are:
- `NOT NULL`
- `UNIQUE`
- `PRIMARY KEY`
- `FOREIGN KEY`
- `CHECK`
- `DEFAULT`

### 1. `NOT NULL`
Prevents a column from storing `NULL`.

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL
);
```

Set `NOT NULL` on an existing column:

```sql
ALTER TABLE employees
ALTER COLUMN employee_name SET NOT NULL;
```

Remove `NOT NULL`:

```sql
ALTER TABLE employees
ALTER COLUMN employee_name DROP NOT NULL;
```

Before setting `NOT NULL`, existing rows must not contain `NULL` in that column.

### 2. `UNIQUE`
Prevents duplicate values in a column or combination of columns.

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE
);
```

Add a named `UNIQUE` constraint:

```sql
ALTER TABLE employees
ADD CONSTRAINT unique_employee_email UNIQUE (email);
```

Drop a named constraint:

```sql
ALTER TABLE users
DROP CONSTRAINT users_phone_key;
```

Existing duplicates can prevent a `UNIQUE` constraint from being added. PostgreSQL normally allows multiple `NULL` values under a `UNIQUE` constraint.

### 3. `PRIMARY KEY`
Uniquely identifies each row. It enforces uniqueness and non-nullness. A table can have only one primary key constraint, but the key can include multiple columns.

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL
);
```

Add a named primary key:

```sql
ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);
```

Drop it:

```sql
ALTER TABLE employees
DROP CONSTRAINT pk_employee_id;
```

The key column(s) must have no duplicate or `NULL` values, and the table must not already have a primary key.

### 4. `FOREIGN KEY`
Ensures that child-table values refer to an existing key in the parent table, unless the foreign-key value is `NULL` and the column permits it.

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    department_id INT,
    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);
```

Add a foreign key:

```sql
ALTER TABLE employees
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (department_id)
REFERENCES departments(department_id);
```

Drop it:

```sql
ALTER TABLE employees
DROP CONSTRAINT fk_employee_department;
```

The referenced column(s) must meet PostgreSQL's referenced-key requirements, usually being a primary key or unique key. Existing non-null child values must match a parent key when adding the constraint. A foreign key does not automatically make its column `NOT NULL`.

### 5. `CHECK`
Requires a condition to be true for each row.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) CONSTRAINT check_price CHECK (price > 0),
    quantity INT CONSTRAINT check_quantity CHECK (quantity >= 0)
);
```

Add a named `CHECK` constraint:

```sql
ALTER TABLE products
ADD CONSTRAINT check_min_price CHECK (price >= 100);
```

Drop it:

```sql
ALTER TABLE products
DROP CONSTRAINT check_min_price;
```

Existing rows that violate a new condition can prevent the constraint from being added. A `CHECK` condition evaluating to `NULL` is not considered false, so also use `NOT NULL` when nulls must be forbidden.

### 6. `DEFAULT`
Supplies a value when an `INSERT` omits the column or uses `DEFAULT`.

```sql
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 0,
    price NUMERIC(10,2) NOT NULL
);
```

Change the default:

```sql
ALTER TABLE inventory
ALTER COLUMN quantity SET DEFAULT 5;
```

Remove the default:

```sql
ALTER TABLE inventory
ALTER COLUMN quantity DROP DEFAULT;
```

Changing a default does not update existing rows; it affects future inserts that omit the column or explicitly use `DEFAULT`.

---

## Part 2 — `ALTER TABLE` Quick Reference

| Goal | Syntax |
|---|---|
| Add named constraint | `ALTER TABLE table_name ADD CONSTRAINT constraint_name ...;` |
| Drop constraint | `ALTER TABLE table_name DROP CONSTRAINT constraint_name;` |
| Set `NOT NULL` | `ALTER TABLE table_name ALTER COLUMN column_name SET NOT NULL;` |
| Remove `NOT NULL` | `ALTER TABLE table_name ALTER COLUMN column_name DROP NOT NULL;` |
| Set default | `ALTER TABLE table_name ALTER COLUMN column_name SET DEFAULT value;` |
| Remove default | `ALTER TABLE table_name ALTER COLUMN column_name DROP DEFAULT;` |

---

## Part 3 — All 25 Practice Questions with Answers

The questions below preserve the practice sequence and include the correct answer for each. Where the original question specified a constraint name, that exact name is used.

### Q1. Create a `student` table with a primary key, a required name, a unique email, and age of at least 18.

```sql
CREATE TABLE student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT CONSTRAINT check_age CHECK (age >= 18)
);
```

### Q2. Create a `products` table with a primary key, required product name, positive price, and quantity defaulting to 0.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) CONSTRAINT check_price CHECK (price > 0),
    quantity INT DEFAULT 0
);
```

### Q3. Create a `users` table with a primary key, unique and required username, unique phone, and age of at least 18.

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    age INT CONSTRAINT check_age CHECK (age >= 18)
);
```

### Q4. Create `departments` and `employees` tables, with employees referencing departments.

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    department_id INT,
    CONSTRAINT employee_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);
```

### Q5. Create an `orders` table with a positive order amount and a required customer reference.

Assumes `customers(customer_id)` already exists and is a valid referenced key.

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_amount NUMERIC(10,2)
        CONSTRAINT check_order_amount CHECK (order_amount > 0),
    customer_id INT NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
```

### Q6. Create an `inventory` table with a primary key, required product name, non-negative quantity defaulting to 0, and required price.

```sql
CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 0 CONSTRAINT check_quantity CHECK (quantity >= 0),
    price NUMERIC(10,2) NOT NULL
);
```

### Q7. Add a positive-price check and a unique product name to `inventory`, then drop `check_quantity`.

```sql
ALTER TABLE inventory
ADD CONSTRAINT check_price CHECK (price > 0);

ALTER TABLE inventory
ADD CONSTRAINT unique_product_name UNIQUE (product_name);

ALTER TABLE inventory
DROP CONSTRAINT check_quantity;
```

### Q8. Drop the `check_age` constraint from `users`.

```sql
ALTER TABLE users
DROP CONSTRAINT check_age;
```

### Q9. Remove `NOT NULL` from `employees.employee_name`.

```sql
ALTER TABLE employees
ALTER COLUMN employee_name DROP NOT NULL;
```

### Q10. Set `employees.employee_name` to `NOT NULL`.

```sql
ALTER TABLE employees
ALTER COLUMN employee_name SET NOT NULL;
```

### Q11. Set the default for `inventory.quantity` to 10.

```sql
ALTER TABLE inventory
ALTER COLUMN quantity SET DEFAULT 10;
```

### Q12. Remove the default from `inventory.quantity`.

```sql
ALTER TABLE inventory
ALTER COLUMN quantity DROP DEFAULT;
```

### Q13. Drop the `users_username_key` constraint.

```sql
ALTER TABLE users
DROP CONSTRAINT users_username_key;
```

**Note:** Constraint names can vary depending on how the table was created. Use the actual name shown by your database if it differs.

### Q14. Add a check to `products.price` requiring a minimum price of 100; name it `check_min_price`.

```sql
ALTER TABLE products
ADD CONSTRAINT check_min_price CHECK (price >= 100);
```

### Q15. Add a unique constraint on `employees.email`, named `unique_employee_email`.

```sql
ALTER TABLE employees
ADD CONSTRAINT unique_employee_email UNIQUE (email);
```

### Q16. Drop the `check_min_price` constraint from `products`.

```sql
ALTER TABLE products
DROP CONSTRAINT check_min_price;
```

### Q17. Add a foreign key on `employees.department_id` referencing `departments.department_id`; name it `fk_employee_department`.

```sql
ALTER TABLE employees
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (department_id)
REFERENCES departments(department_id);
```

### Q18. Drop `fk_employee_department` from `employees`.

```sql
ALTER TABLE employees
DROP CONSTRAINT fk_employee_department;
```

### Q19. Add a primary key on `employees.employee_id`, named `pk_employee_id`.

```sql
ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);
```

### Q20. Drop `pk_employee_id` from `employees`.

```sql
ALTER TABLE employees
DROP CONSTRAINT pk_employee_id;
```

### Q21. Add a check to `products.quantity` requiring a value of 0 or more; name it `check_product_quantity`.

```sql
ALTER TABLE products
ADD CONSTRAINT check_product_quantity CHECK (quantity >= 0);
```

### Q22. Drop the `users_phone_key` constraint from `users`.

```sql
ALTER TABLE users
DROP CONSTRAINT users_phone_key;
```

### Q23. Set `employees.employee_name` to `NOT NULL`.

```sql
ALTER TABLE employees
ALTER COLUMN employee_name SET NOT NULL;
```

### Q24. Change the default of `inventory.quantity` to 5.

```sql
ALTER TABLE inventory
ALTER COLUMN quantity SET DEFAULT 5;
```

### Q25. Set `products.product_name` to `NOT NULL`.

```sql
ALTER TABLE products
ALTER COLUMN product_name SET NOT NULL;
```

---

## Part 4 — Common Mistakes to Avoid

1. **Wrong `NOT NULL` syntax**

   Incorrect:
   ```sql
   ALTER TABLE employees ADD CONSTRAINT employee_name NOT NULL;
   ```

   Correct:
   ```sql
   ALTER TABLE employees
   ALTER COLUMN employee_name SET NOT NULL;
   ```

2. `ADD CONSTRAINT` adds a rule; it does not declare or change a column's data type.
3. A foreign key must reference the correct parent table and valid key.
4. Use the actual constraint name when dropping a constraint.
5. Changing a `DEFAULT` does not update existing rows.
6. Existing data must satisfy newly added constraints: duplicates can block `UNIQUE`; nulls can block `NOT NULL`; invalid values can block `CHECK` and foreign-key constraints.
7. A primary key can only be defined once per table. If a primary key already exists, drop or modify it intentionally before adding another.
8. `CHECK (age >= 18)` alone does not forbid `NULL`; combine it with `NOT NULL` if age is mandatory.

---

## Part 5 — Final Revision Checklist

- [ ] Explain all six constraints.
- [ ] Create tables with multiple constraints.
- [ ] Add and drop named constraints.
- [ ] Add and drop a primary key.
- [ ] Add and drop a foreign key.
- [ ] Set and remove `NOT NULL`.
- [ ] Set and remove a default.
- [ ] Explain how existing data can prevent a constraint from being added.

**Completed:** SQL Constraints and `ALTER TABLE` constraint operations in PostgreSQL.
