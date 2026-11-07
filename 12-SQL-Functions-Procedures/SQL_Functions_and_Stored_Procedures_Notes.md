
# SQL Functions and Stored Procedures — Complete Notes

**Database:** PostgreSQL  
**Status:** Completed  
**Purpose:** SQL learning, backend development, and placement preparation

---

## 1. Introduction

SQL Functions and Stored Procedures allow us to save reusable logic inside a database.

They reduce repeated code and help organize database operations.

- **Function:** Usually calculates or returns a value or a set of rows.
- **Stored Procedure:** Executes one or more operations, such as inserting or updating data.

Both can be created and reused whenever required.

---

# Part A: SQL Functions

## 2. What Is a Function?

A Function is a named database object that accepts inputs, performs operations, and returns a result.

Functions are useful for:
- Mathematical calculations
- Business rules
- Data transformations
- Reusable queries
- Returning a value or a table

### General Syntax

```sql
CREATE OR REPLACE FUNCTION function_name(parameters)
RETURNS return_type
LANGUAGE SQL
AS $$
    SELECT expression;
$$;
```

`CREATE OR REPLACE FUNCTION` creates a function or replaces its existing definition, subject to PostgreSQL's compatibility rules.

---

## 3. Function Without Parameters

Example: Return a fixed message.

```sql
CREATE OR REPLACE FUNCTION get_message()
RETURNS TEXT
LANGUAGE SQL
AS $$
    SELECT 'Hello World';
$$;
```

Call the function:

```sql
SELECT get_message();
```

Output:

```text
Hello World
```

---

## 4. Function With Parameters

Parameters allow us to pass values to a function.

Example: Add two numbers.

```sql
CREATE OR REPLACE FUNCTION add_numbers(
    a INT,
    b INT
)
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT a + b;
$$;
```

Call:

```sql
SELECT add_numbers(10, 20);
```

Output:

```text
30
```

Explanation:
- `a` and `b` are input parameters.
- `INT` is the data type of each parameter.
- `RETURNS INT` specifies the return type.
- `SELECT add_numbers(10, 20)` executes the function.

---

## 5. Function to Calculate Square

```sql
CREATE OR REPLACE FUNCTION square_number(n INT)
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT n * n;
$$;
```

Call:

```sql
SELECT square_number(5);
```

Output:

```text
25
```

---

## 6. GREATEST() and LEAST()

PostgreSQL provides built-in functions to compare multiple values.

### GREATEST()

Returns the greatest non-NULL value among the supplied arguments.

```sql
SELECT GREATEST(10, 25);
```

Output:

```text
25
```

Custom function:

```sql
CREATE OR REPLACE FUNCTION maximum_number(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT GREATEST(a, b);
$$;
```

### LEAST()

Returns the smallest non-NULL value among the supplied arguments.

```sql
SELECT LEAST(10, 25);
```

Output:

```text
10
```

Custom function:

```sql
CREATE OR REPLACE FUNCTION minimum_number(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT LEAST(a, b);
$$;
```

Note: PostgreSQL's `GREATEST()` and `LEAST()` ignore NULL arguments unless all arguments are NULL.

---

## 7. Function to Calculate Percentage

Formula:

Percentage = (Marks × 100) / Total Marks

```sql
CREATE OR REPLACE FUNCTION calculate_percentage(
    marks NUMERIC,
    total_marks NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT (marks * 100.0) / total_marks;
$$;
```

Call:

```sql
SELECT calculate_percentage(450, 500);
```

Output:

```text
90.0000000000000000
```

Important: If `total_marks` is zero, PostgreSQL raises a division-by-zero error. Production code should validate the input.

---

## 8. CASE Expression Inside a Function

A `CASE` expression evaluates conditions and returns a result.

```sql
CREATE OR REPLACE FUNCTION check_result(marks NUMERIC)
RETURNS TEXT
LANGUAGE SQL
AS $$
    SELECT CASE
        WHEN marks >= 40 THEN 'Pass'
        ELSE 'Fail'
    END;
$$;
```

Call:

```sql
SELECT check_result(75);
SELECT check_result(35);
```

Outputs:

```text
Pass
Fail
```

A `CASE` expression is useful for simple conditional logic in SQL.

---

## 9. SQL vs PL/pgSQL

PostgreSQL supports different languages for defining functions.

### LANGUAGE SQL

Useful for SQL statements and expressions.

```sql
CREATE OR REPLACE FUNCTION multiply_numbers(a INT, b INT)
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT a * b;
$$;
```

### LANGUAGE plpgsql

Useful for procedural logic such as:
- Variables
- IF / ELSIF / ELSE
- Loops
- Multiple statements
- Exception handling

Example:

```sql
CREATE OR REPLACE FUNCTION multiply_numbers_plpgsql(
    a INT,
    b INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN a * b;
END;
$$;
```

Both functions return the product of two numbers.

---

## 10. IF / ELSIF / ELSE in a Function

Create a function that returns a student's grade.

Rules:
- Marks >= 90: A
- Marks >= 75: B
- Marks >= 40: C
- Marks < 40: Fail

```sql
CREATE OR REPLACE FUNCTION grade_student(marks NUMERIC)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    IF marks >= 90 THEN
        RETURN 'A';
    ELSIF marks >= 75 THEN
        RETURN 'B';
    ELSIF marks >= 40 THEN
        RETURN 'C';
    ELSE
        RETURN 'Fail';
    END IF;
END;
$$;
```

Test:

```sql
SELECT grade_student(95); -- A
SELECT grade_student(80); -- B
SELECT grade_student(55); -- C
SELECT grade_student(30); -- Fail
```

Important:
- Use `IF` for the first condition.
- Use `ELSIF` for additional conditions.
- Use `ELSE` for the default result.
- Close the block with `END IF;`.
- In PL/pgSQL, `RETURN` returns the function's result.

Conditions are checked from top to bottom. Once a condition is true and returns a value, the remaining conditions are not evaluated.

---

## 11. Function to Calculate Discounted Price

Formula:

Final Price = Price × (100 − Discount Percentage) / 100

```sql
CREATE OR REPLACE FUNCTION discount_price(
    price NUMERIC,
    discount_percent NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN price * (100 - discount_percent) / 100;
END;
$$;
```

Test:

```sql
SELECT discount_price(1000, 20);
```

Output:

```text
800
```

Another test:

```sql
SELECT discount_price(2500, 10);
```

Output:

```text
2250
```

Production improvement: Validate that the price is non-negative and the discount percentage is between 0 and 100, if those are the business rules.

---

## 12. Calling Functions

Functions are commonly called using `SELECT`.

```sql
SELECT add_numbers(10, 20);

SELECT square_number(5);

SELECT maximum_number(10, 25);

SELECT minimum_number(10, 25);

SELECT calculate_percentage(450, 500);

SELECT grade_student(80);

SELECT discount_price(1000, 20);
```

A suitable function can also be used in a SQL expression:

```sql
SELECT name, discount_price(price, 10) AS discounted_price
FROM products;
```

This example assumes the `products` table contains `name` and `price` columns.

---

## 13. Function Returning a Table

A PostgreSQL function can return multiple rows using `RETURNS TABLE`.

Example:

```sql
CREATE OR REPLACE FUNCTION get_it_employees()
RETURNS TABLE (
    employee_name VARCHAR,
    employee_salary NUMERIC
)
LANGUAGE SQL
AS $$
    SELECT name, salary
    FROM employees
    WHERE department = 'IT';
$$;
```

Call:

```sql
SELECT *
FROM get_it_employees();
```

This example assumes the `employees` table has compatible `name`, `salary`, and `department` columns.

---

## 14. Drop a Function

Drop a function using its name and parameter types.

```sql
DROP FUNCTION function_name(parameter_types);
```

Example:

```sql
DROP FUNCTION square_number(INT);
```

Use `IF EXISTS` to avoid an error if the function does not exist:

```sql
DROP FUNCTION IF EXISTS square_number(INT);
```

PostgreSQL uses the function's parameter types to identify the correct overload.

---

# Part B: Stored Procedures

## 15. What Is a Stored Procedure?

A Stored Procedure is a named database object containing logic that is executed using `CALL`.

It is useful for:
- Inserting records
- Updating records
- Processing orders
- Performing multiple related operations
- Implementing database workflows

### General Syntax

```sql
CREATE OR REPLACE PROCEDURE procedure_name(parameters)
LANGUAGE plpgsql
AS $$
BEGIN
    -- SQL statements
END;
$$;
```

Call a procedure using:

```sql
CALL procedure_name(arguments);
```

---

## 16. Procedure Without Parameters

Create a procedure that displays a message.

```sql
CREATE OR REPLACE PROCEDURE show_message()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Hello! Stored Procedure started.';
END;
$$;
```

Call:

```sql
CALL show_message();
```

The notice appears in the database client's messages or output panel.

`RAISE NOTICE` displays a message; it does not return a normal function-style value.

---

## 17. Procedure With Parameters

A procedure can accept input parameters.

```sql
CREATE OR REPLACE PROCEDURE greet_user(
    user_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Welcome %!', user_name;
END;
$$;
```

Call:

```sql
CALL greet_user('Malik');
```

Expected notice:

```text
NOTICE: Welcome Malik!
```

The `%` in `RAISE NOTICE` is a placeholder for the supplied argument.

---

## 18. Practical Procedure: Insert an Employee

Suppose the `employees` table contains:
- `name`
- `department`
- `salary`

Create a procedure:

```sql
CREATE OR REPLACE PROCEDURE add_employee(
    p_name VARCHAR,
    p_department VARCHAR,
    p_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (name, department, salary)
    VALUES (p_name, p_department, p_salary);

    RAISE NOTICE 'Employee added successfully!';
END;
$$;
```

Execute:

```sql
CALL add_employee('Aman', 'IT', 50000);
```

Verify:

```sql
SELECT *
FROM employees
WHERE name = 'Aman';
```

Important:
- Ensure the table and columns exist.
- Satisfy any `NOT NULL`, unique, check, and foreign-key constraints.
- Calling the procedure again may insert another row unless constraints or logic prevent duplicates.
- The procedure's SQL statements execute in the caller's transaction context unless applicable procedure transaction control is used.

---

## 19. Procedure to Update an Employee Salary

Suppose `employees` has `employee_id` and `salary`.

```sql
CREATE OR REPLACE PROCEDURE update_employee_salary(
    p_employee_id INT,
    p_new_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
    SET salary = p_new_salary
    WHERE employee_id = p_employee_id;

    RAISE NOTICE 'Salary update statement executed.';
END;
$$;
```

Call:

```sql
CALL update_employee_salary(1, 60000);
```

Verify:

```sql
SELECT employee_id, salary
FROM employees
WHERE employee_id = 1;
```

The notice confirms that the statement executed, not necessarily that a row matched. For production code, check the affected-row count when needed.

---

## 20. IN, OUT, and INOUT Parameters

PostgreSQL procedures and functions can use parameter modes.

- `IN`: Input value; this is the default.
- `OUT`: Output parameter.
- `INOUT`: Parameter used for both input and output.

Example procedure with an `OUT` parameter:

```sql
CREATE OR REPLACE PROCEDURE get_square(
    IN n INT,
    OUT result INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    result := n * n;
END;
$$;
```

Call:

```sql
CALL get_square(5, NULL);
```

The returned output parameter contains `25`.

For output parameters in a procedure, supply the required argument position in the `CALL` statement. PostgreSQL's procedure invocation rules govern how output arguments are supplied.

---

## 21. Transaction Control in Procedures

One important difference is that PostgreSQL permits transaction control statements such as `COMMIT` and `ROLLBACK` in certain procedures.

However, transaction control is subject to restrictions:
- The procedure must be called in a context that permits transaction control.
- A `CALL` inside an explicit transaction block cannot use procedure-level `COMMIT` or `ROLLBACK` to end that transaction.
- Functions cannot independently commit or roll back the surrounding transaction.

Example of a procedure containing transaction control:

```sql
CREATE OR REPLACE PROCEDURE transaction_example()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO transaction_demo (name, balance)
    VALUES ('Example User', 1000);

    COMMIT;
END;
$$;
```

This procedure is intended to illustrate transaction control. Call it in a context where PostgreSQL permits the internal `COMMIT`, and ensure the example table exists with compatible columns.

Do not put `CALL transaction_example()` inside an explicit `BEGIN ... COMMIT` transaction block if the procedure must execute its own `COMMIT`.

For normal application logic, transaction boundaries are often managed by the application or the caller rather than inside every procedure.

---

# Part C: Function vs Stored Procedure

## 22. Main Differences

| Feature | Function | Stored Procedure |
|---|---|---|
| Create | `CREATE FUNCTION` | `CREATE PROCEDURE` |
| Execute | Usually `SELECT` | `CALL` |
| Return result | Returns a scalar value, a set, or a table, as defined | Can use `OUT`/`INOUT` parameters; not called as a normal scalar expression |
| Use inside `SELECT` | Suitable functions can be used in expressions or queries | Cannot be called directly as a normal SQL expression |
| Typical purpose | Calculation, transformation, query result | Operations and workflows |
| Transaction control | Cannot independently commit/rollback | Can, subject to PostgreSQL restrictions |
| Parameters | Supports parameter modes | Supports parameter modes |

### Simple Rule

**Function:** Commonly used when a result needs to be returned or reused in a query.

**Procedure:** Commonly used to execute a database operation or workflow.

This is a useful general distinction, not an absolute rule for every application.

---

## 23. Real-World Use Cases

### Function Use Cases

1. Calculate tax.
2. Calculate discounted price.
3. Calculate employee bonus.
4. Convert or format data.
5. Return filtered records.
6. Calculate business metrics.

### Procedure Use Cases

1. Insert an employee.
2. Update a salary.
3. Process an order.
4. Perform multiple database operations.
5. Execute a controlled database workflow.

---

# Part D: Common Mistakes

## 24. Mistake: Calling a Procedure With SELECT

Incorrect:

```sql
SELECT show_message();
```

Correct:

```sql
CALL show_message();
```

## 25. Mistake: Calling a Function With CALL

For a normal function returning a value, use:

```sql
SELECT square_number(5);
```

Not:

```sql
CALL square_number(5);
```

## 26. Mistake: Forgetting Parameter Types

Function:

```sql
CREATE OR REPLACE FUNCTION add_numbers(a INT, b INT)
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT a + b;
$$;
```

The parameter types are required when defining the function.

## 27. Mistake: Incorrect IF Syntax

Correct PL/pgSQL syntax:

```sql
IF condition THEN
    -- statements
ELSIF another_condition THEN
    -- statements
ELSE
    -- statements
END IF;
```

Every conditional block must be closed correctly.

## 28. Mistake: Ignoring Invalid Inputs

Examples:
- Division by zero in percentage calculations.
- Negative prices when not permitted.
- Discount percentages outside the allowed range.
- Missing or invalid employee IDs.

Functions and procedures should validate business rules where appropriate.

---

# Part E: Practice Questions

## 29. Beginner Questions

**Q1.** What is a SQL Function?

**Q2.** What is a Stored Procedure?

**Q3.** Which command is normally used to call a function that returns a value?

**Q4.** Which command is used to execute a procedure?

**Q5.** What does `RETURNS NUMERIC` mean?

## 30. Intermediate Questions

**Q6.** Create a function named `double_number(n INT)` that returns twice the input value.

**Q7.** Create a function named `minimum_number(a NUMERIC, b NUMERIC)` that returns the smaller value.

**Q8.** Create a function named `check_result(marks NUMERIC)` that returns `Pass` for marks >= 40 and `Fail` otherwise.

**Q9.** Create a function named `discount_price(price NUMERIC, discount_percent NUMERIC)` that returns the final price after discount.

**Q10.** Create a procedure named `greet_user(user_name VARCHAR)` that displays a welcome message.

## 31. Advanced Questions

**Q11.** Explain the difference between a Function and a Stored Procedure in PostgreSQL.

**Q12.** Why can a function be used in a `SELECT` expression while a procedure is invoked with `CALL`?

**Q13.** What is the purpose of `IN`, `OUT`, and `INOUT` parameters?

**Q14.** Can a PostgreSQL procedure control transactions?

**Q15.** Why should business inputs such as discounts and salaries be validated?

---

# Part F: Practice Answers

## Answer 6: Double a Number

```sql
CREATE OR REPLACE FUNCTION double_number(n INT)
RETURNS INT
LANGUAGE SQL
AS $$
    SELECT n * 2;
$$;

SELECT double_number(10);
```

Output: `20`

## Answer 7: Minimum Number

```sql
CREATE OR REPLACE FUNCTION minimum_number(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT LEAST(a, b);
$$;

SELECT minimum_number(10, 25);
```

Output: `10`

## Answer 8: Pass or Fail

```sql
CREATE OR REPLACE FUNCTION check_result(marks NUMERIC)
RETURNS TEXT
LANGUAGE SQL
AS $$
    SELECT CASE
        WHEN marks >= 40 THEN 'Pass'
        ELSE 'Fail'
    END;
$$;

SELECT check_result(75);
SELECT check_result(35);
```

Outputs: `Pass`, `Fail`

## Answer 9: Discounted Price

```sql
CREATE OR REPLACE FUNCTION discount_price(
    price NUMERIC,
    discount_percent NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN price * (100 - discount_percent) / 100;
END;
$$;

SELECT discount_price(1000, 20);
```

Output: `800`

## Answer 10: Welcome Procedure

```sql
CREATE OR REPLACE PROCEDURE greet_user(
    user_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Welcome %!', user_name;
END;
$$;

CALL greet_user('Malik');
```

Expected notice: `Welcome Malik!`

---

# Part G: Interview Revision

## 32. Important Interview Questions

**Q1. What is a Function?**

A reusable database object that accepts parameters and returns a scalar value, a set of rows, or a table, depending on its definition.

**Q2. What is a Stored Procedure?**

A reusable database object invoked with `CALL`, commonly used to execute database operations and workflows.

**Q3. Can a Function return multiple rows?**

Yes. PostgreSQL supports set-returning functions and functions defined with `RETURNS TABLE`.

**Q4. Can a Procedure return output?**

Yes. PostgreSQL procedures can use `OUT` and `INOUT` parameters.

**Q5. Can a Function commit a transaction independently?**

No. A function cannot independently commit or roll back the surrounding transaction.

**Q6. Can a Procedure commit a transaction?**

Yes, in PostgreSQL, subject to the procedure's calling context and transaction-control restrictions.

**Q7. What is PL/pgSQL?**

It is PostgreSQL's procedural language for writing database logic using variables, conditions, loops, exception handling, and multiple SQL statements.

**Q8. When should we use a Function?**

Use a function when reusable logic needs to calculate or return a value or rows, including when it must be used in a SQL query.

**Q9. When should we use a Procedure?**

Use a procedure when a database operation or workflow is best represented as an explicit `CALL`.

---

# 33. Final Summary

- Functions and Stored Procedures save reusable database logic.
- Use `CREATE OR REPLACE FUNCTION` to create or replace a function definition.
- Use `SELECT function_name(...)` to call a value-returning function.
- Use `CREATE OR REPLACE PROCEDURE` to create or replace a procedure definition.
- Use `CALL procedure_name(...)` to execute a procedure.
- `LANGUAGE SQL` is useful for SQL expressions and statements.
- `LANGUAGE plpgsql` supports procedural logic such as `IF`, loops, and variables.
- Functions can return scalar values, sets, or tables.
- Procedures can use output parameters and, under the applicable restrictions, transaction control.
- Always validate business inputs and handle errors appropriately.

**Status: SQL Functions & Stored Procedures — Completed.**
