# SQL Triggers — Complete Notes

## 1. What is a Trigger?

A **Trigger** is a database object that automatically executes a specified function when a particular event occurs on a table or view.

Simple words mein, Trigger ek automatic mechanism hai jo `INSERT`, `UPDATE` ya `DELETE` jaise operations hone par execute hota hai.

### Real-world examples

- Employee ki salary change hone par old aur new salary audit table mein save karna.
- Employee delete hone par uska record deletion history mein store karna.
- Negative salary ko database mein insert ya update hone se rokna.
- Kisi important table mein changes ka audit maintain karna.

**Important:** PostgreSQL mein trigger aur trigger function alag objects hote hain. Trigger event aur timing define karta hai, jabki trigger function execute hone wala code contain karti hai.

---

## 2. How Does a Trigger Work?

Trigger ka execution flow:

1. User SQL operation execute karta hai.
2. Database trigger event aur timing check karta hai.
3. Matching trigger execute hota hai.
4. Trigger function apna code run karti hai.
5. Operation continue hota hai, modify hota hai, skip hota hai ya error ki wajah se fail ho sakta hai—trigger type aur function par depend karta hai.

Example:

```sql
UPDATE employees
SET salary = 70000
WHERE employee_id = 1;
```

Agar table par matching `UPDATE` trigger bana hai, toh uski function automatically execute ho sakti hai.

---

## 3. Types of Triggers

Triggers ko different categories mein divide kiya jaata hai.

### A. Based on Timing

#### 1. BEFORE Trigger

SQL operation perform hone se pehle execute hota hai.

**Use cases:**
- Data validation
- `NEW` row ko modify karna
- Invalid operation ko reject karna

Example:

```sql
CREATE OR REPLACE FUNCTION validate_salary()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary < 0 THEN
        RAISE EXCEPTION 'Salary cannot be negative';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER salary_validation_trigger
BEFORE INSERT OR UPDATE
ON employees
FOR EACH ROW
EXECUTE FUNCTION validate_salary();
```

Is example mein negative salary ko reject kiya jaata hai.

`BEFORE` row-level trigger mein `RETURN NEW` row ko accept karta hai. `RETURN NULL` current row operation ko skip kar deta hai.

#### 2. AFTER Trigger

Operation complete hone ke baad execute hota hai.

**Use cases:**
- Audit logs maintain karna
- Changes ko doosri table mein record karna
- Related records ya notifications ke liye database-side logic

Example:

```sql
CREATE OR REPLACE FUNCTION log_employee_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'New employee inserted: %',
        NEW.employee_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER employee_insert_trigger
AFTER INSERT
ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_insert();
```

`AFTER` trigger mein return value ignore hoti hai. `RETURN NEW` likhna common hai.

#### 3. INSTEAD OF Trigger

Original operation ko perform karne ke bajaye uski jagah execute hota hai. PostgreSQL mein yeh **views par row-level triggers** ke liye use hota hai.

**Use case:** Complex view par `INSERT`, `UPDATE` ya `DELETE` ko custom logic se handle karna.

Example syntax:

```sql
CREATE TRIGGER view_insert_trigger
INSTEAD OF INSERT
ON employee_view
FOR EACH ROW
EXECUTE FUNCTION handle_view_insert();
```

Yeh tabhi kaam karega jab `employee_view` view ho aur `handle_view_insert()` naam ki suitable trigger function pehle se bani ho.

### B. Based on Execution Level

#### 1. Row-Level Trigger

Har affected row ke liye trigger function execute hoti hai.

Syntax:

```sql
FOR EACH ROW
```

Example: Ek query 100 employee rows update kare, toh row-level trigger har affected row ke liye execute ho sakta hai.

**Use cases:** Row-specific audit logs, validation aur per-record processing.

#### 2. Statement-Level Trigger

Har SQL statement ke liye trigger function ek baar execute hoti hai, chahe statement zero, one ya multiple rows affect kare.

Syntax:

```sql
FOR EACH STATEMENT
```

Example:

```sql
CREATE OR REPLACE FUNCTION log_employee_statement()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'An employee-table statement was executed';
    RETURN NULL;
END;
$$;

CREATE TRIGGER employee_update_statement_trigger
AFTER UPDATE
ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_employee_statement();
```

Statement-level trigger mein `OLD` aur `NEW` individual row records available nahi hote. `RETURN NULL` yahan appropriate hai, kyunki statement-level trigger ke return value ka effect nahi hota.

### C. Based on Event

PostgreSQL ke table triggers ke common events:

- `INSERT` — naya record insert hone par
- `UPDATE` — existing record update hone par
- `DELETE` — record delete hone par
- `TRUNCATE` — table ke saare records remove karne ke operation par; yeh statement-level trigger event hota hai

Example:

```sql
CREATE TRIGGER employee_change_trigger
AFTER INSERT OR UPDATE OR DELETE
ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_change();
```

Is trigger ko handle karne wali function ko teenon operations ke liye sahi logic implement karna hoga.

**Note:** PostgreSQL mein `TRUNCATE` ke liye row-level trigger nahi hota. Trigger events ko combine karte waqt timing aur level ki compatibility bhi zaroor check karein.

---

## 4. OLD and NEW Variables

`OLD` aur `NEW` trigger function ke special record variables hain.

| Operation | OLD | NEW |
|---|---|---|
| INSERT | Available nahi | Insert hone wali row |
| UPDATE | Update se pehle ki row | Update ke baad ki row |
| DELETE | Delete hone wali row | Available nahi |

Example:

```sql
RAISE NOTICE 'Old salary: %', OLD.salary;
RAISE NOTICE 'New salary: %', NEW.salary;
```

Yeh example `UPDATE` trigger ke liye relevant hai.

**Memory trick:**
- `OLD` = operation se pehle ya delete hone wali row
- `NEW` = insert ya update ke baad ki row

---

## 5. TG_OP Variable

`TG_OP` PostgreSQL ka special trigger variable hai jo batata hai ki kaunsa operation trigger ko execute kar raha hai.

Possible values:

- `'INSERT'`
- `'UPDATE'`
- `'DELETE'`
- `'TRUNCATE'` — statement-level trigger ke context mein

Example:

```sql
CREATE OR REPLACE FUNCTION log_employee_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Employee inserted';

    ELSIF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Employee updated';

    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Employee deleted';
    END IF;

    RETURN NULL;
END;
$$;
```

Yeh function example message display karta hai. Isse table changes automatically log nahi hote; persistent audit ke liye audit table mein `INSERT` karna padega.

---

## 6. Practical Example: Salary Audit Trigger

Jab employee ki salary change ho, tab old salary, new salary aur change time save karna.

### Step 1: Create audit table

```sql
CREATE TABLE salary_audit (
    audit_id SERIAL PRIMARY KEY,
    employee_id INT,
    old_salary NUMERIC,
    new_salary NUMERIC,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Step 2: Create trigger function

```sql
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO salary_audit (
        employee_id,
        old_salary,
        new_salary
    )
    VALUES (
        OLD.employee_id,
        OLD.salary,
        NEW.salary
    );

    RETURN NEW;
END;
$$;
```

### Step 3: Create trigger

```sql
CREATE TRIGGER salary_update_trigger
AFTER UPDATE OF salary
ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION log_salary_change();
```

### Step 4: Test the trigger

```sql
UPDATE employees
SET salary = 60000
WHERE employee_id = 1;

SELECT * FROM salary_audit;
```

**Expected behaviour:** Agar employee ki salary actually change hui, toh audit table mein old salary aur new salary ka record add hoga.

Assumptions:
- `employees` table mein `employee_id` aur `salary` columns exist karte hain.
- Employee ID `1` exist karti hai.
- Salary change update statement successful hota hai.

---

## 7. How to Drop a Trigger

PostgreSQL mein trigger drop karne ke liye table ka naam dena hota hai.

```sql
DROP TRIGGER salary_update_trigger ON employees;
```

Isse trigger remove hota hai, lekin uski trigger function automatically delete nahi hoti.

Function ko separately remove karne ke liye:

```sql
DROP FUNCTION log_salary_change();
```

Agar function kisi existing trigger ke through use ho rahi hai, toh pehle dependency resolve karni padegi.

`CASCADE` dependencies ko bhi remove kar sakta hai, isliye use carefully karein.

---

## 8. BEFORE vs AFTER vs INSTEAD OF

| Feature | BEFORE | AFTER | INSTEAD OF |
|---|---|---|---|
| Execution | Operation se pehle | Operation ke baad | Original operation ki jagah |
| Common use | Validation, row modification | Audit logging | Views par custom operations |
| `NEW` modify kar sakte hain? | Haan, row-level triggers mein | Original row ko change karne ke liye nahi | View operation ko custom logic se handle kar sakte hain |
| Row-level `RETURN` ka effect | Row operation ko control karta hai | Return value ignored | View operation ko control karta hai |

---

## 9. Row-Level vs Statement-Level

| Feature | FOR EACH ROW | FOR EACH STATEMENT |
|---|---|---|
| Execution | Har affected row ke liye | Har statement ke liye ek baar |
| Individual `OLD`/`NEW` records | Available, event par depend karta hai | Available nahi |
| Use case | Per-record validation/audit | Statement-level tracking |
| Zero rows affected | Koi row-level execution nahi | Statement trigger phir bhi execute hota hai |

---

## 10. Important Rules and Best Practices

1. PostgreSQL mein trigger function ko `RETURNS TRIGGER` declare karna hota hai.
2. Trigger function ko direct normal SQL function ki tarah call nahi karte; trigger event ke through execute hoti hai.
3. Trigger function ko `CREATE TRIGGER` se attach karna hota hai.
4. `BEFORE` row-level trigger mein `RETURN NEW` row ko proceed karne deta hai.
5. `BEFORE` row-level trigger mein `RETURN NULL` current row operation ko skip karta hai.
6. `AFTER` trigger ka return value ignore hota hai.
7. Trigger function ke andar same table par `UPDATE` karte waqt recursion ka risk check karein.
8. `WHEN` condition se unnecessary trigger executions ko avoid kiya ja sakta hai.
9. Trigger failure se triggering statement fail ho sakta hai. Trigger ke database changes aam taur par usi transaction ka hissa hote hain.
10. Triggers ko simple, predictable aur well-tested rakhein. Unnecessary triggers debugging aur performance ko difficult bana sakte hain.

---

## 11. Common Mistakes

### Mistake 1: `RETURNS TRIGGER` bhool jaana

Incorrect:

```sql
CREATE FUNCTION my_trigger_function()
RETURNS VOID
...
```

Correct trigger function declaration:

```sql
CREATE OR REPLACE FUNCTION my_trigger_function()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN NEW;
END;
$$;
```

### Mistake 2: DELETE mein `NEW` use karna

`DELETE` operation mein deleted row ke liye `OLD` use karein.

### Mistake 3: Trigger ko wrong syntax se drop karna

Incorrect:

```sql
DROP TRIGGER salary_update_trigger;
```

Correct:

```sql
DROP TRIGGER salary_update_trigger ON employees;
```

### Mistake 4: Trigger function ko manually execute karna

Trigger function ko directly call nahi karte. Usse execute karne ke liye matching trigger event generate karte hain.

### Mistake 5: Audit trigger mein unchanged values log karna

Condition use kar sakte hain:

```sql
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
```

Isse unchanged salary par audit row insert nahi hogi.

---

## 12. Interview Questions and Answers

**Q1. What is a trigger?**

A trigger is a database object that automatically invokes a trigger function when a specified event occurs.

**Q2. What is the difference between BEFORE and AFTER triggers?**

`BEFORE` trigger operation se pehle execute hota hai; `AFTER` trigger operation ke baad.

**Q3. What are OLD and NEW?**

Special record variables that provide the previous and new row values, depending on the operation.

**Q4. What is TG_OP?**

A special variable that identifies the triggering operation, such as `INSERT`, `UPDATE` or `DELETE`.

**Q5. What is a row-level trigger?**

A trigger that executes for each affected row.

**Q6. What is a statement-level trigger?**

A trigger that executes once per SQL statement, regardless of how many rows are affected.

**Q7. Can a trigger return a value?**

Trigger functions return a value of type `TRIGGER`. Its effect depends on the trigger timing and level. For example, an `AFTER` trigger ignores its return value.

**Q8. Can a trigger prevent an operation?**

Yes. A `BEFORE` row-level trigger can return `NULL` to skip the current row operation, or raise an exception to abort the statement.

**Q9. Can PostgreSQL triggers be created on views?**

Yes. PostgreSQL supports `INSTEAD OF` row-level triggers on views, and certain other trigger types are also available depending on the view and event.

**Q10. What is trigger recursion?**

It occurs when trigger actions cause further trigger executions, potentially creating repeated execution cycles.

---

## 13. Practice Questions

1. What is the difference between a trigger and a trigger function?
2. Which variable provides the old salary during an `UPDATE`?
3. Which trigger timing is suitable for validating salary before an update?
4. What is the difference between `FOR EACH ROW` and `FOR EACH STATEMENT`?
5. How do you drop a trigger without dropping its function?
6. What does `TG_OP` return?
7. What happens when a `BEFORE` row-level trigger returns `NULL`?
8. Why is `IS DISTINCT FROM` useful in audit triggers?
9. Which variable is available for a deleted row?
10. What is trigger recursion, and how can it be avoided?

---

## Final Summary

- **Trigger:** Automatically executes in response to a configured database event.
- **Trigger function:** Contains the logic executed by the trigger.
- **BEFORE:** Validate or modify a row before the operation.
- **AFTER:** Perform post-operation logic, such as auditing.
- **INSTEAD OF:** Handle operations on views through custom logic.
- **FOR EACH ROW:** Executes for each affected row.
- **FOR EACH STATEMENT:** Executes once per SQL statement.
- **OLD:** Previous or deleted row.
- **NEW:** Inserted or updated row.
- **TG_OP:** Identifies the triggering operation.

**GitHub file:** `SQL-Triggers/SQL_Triggers_Notes.md`
