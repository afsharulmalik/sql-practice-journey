
# SQL Transactions — Day 1 Notes

**Database:** PostgreSQL  
**Topics:** BEGIN, COMMIT, ROLLBACK  
**Goal:** Placement Preparation & Backend Development

---

## 1. What is a Transaction?

A transaction is a group of SQL operations treated as one logical unit of work.

Transactions help maintain database consistency when multiple operations belong together.

**Example:** In an e-commerce application, creating an order and reducing product stock may need to succeed or fail together.

---

## 2. BEGIN

`BEGIN` starts a new transaction.

### Syntax

```sql
BEGIN;
```

### Example

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4000
WHERE name = 'Malik';
```

The update is part of the current transaction. It has not been committed yet.

---

## 3. COMMIT

`COMMIT` saves the changes made in the current transaction.

### Example

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 3000
WHERE name = 'Malik';

COMMIT;

SELECT * FROM transaction_demo;
```

**Result:** The balance becomes `3000`, assuming the update affects the intended row.

Once committed, a later `ROLLBACK` cannot undo that already-committed transaction.

---

## 4. ROLLBACK

`ROLLBACK` cancels the current transaction's uncommitted changes.

### Example

Suppose Malik's previously committed balance is `3000`.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 100
WHERE name = 'Malik';

ROLLBACK;

SELECT * FROM transaction_demo;
```

**Result:** The balance returns to `3000` because the update to `100` was rolled back.

---

## 5. Combined Practical Example

Assume `transaction_demo` already exists and exactly one row matches `name = 'Malik'`.

### Step 1: Check the current balance

```sql
SELECT * FROM transaction_demo;
```

### Step 2: Update and save the balance

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 3000
WHERE name = 'Malik';

COMMIT;

SELECT * FROM transaction_demo;
```

The committed balance should now be `3000`.

### Step 3: Make another update and undo it

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 100
WHERE name = 'Malik';

ROLLBACK;

SELECT * FROM transaction_demo;
```

The final balance should still be `3000`.

---

## 6. Quick Reference

| Command | Purpose |
|---|---|
| `BEGIN` | Starts a transaction |
| `COMMIT` | Saves the transaction's changes |
| `ROLLBACK` | Undoes the current transaction's uncommitted changes |

### Transaction Flow

`BEGIN` → Execute SQL statements → Choose `COMMIT` to save OR `ROLLBACK` to undo.

---

## 7. Important Points

1. `BEGIN` starts a transaction.
2. `COMMIT` saves the transaction's changes.
3. `ROLLBACK` undoes uncommitted changes in the current transaction.
4. `ROLLBACK` after a successful `COMMIT` does not undo that committed transaction.
5. PostgreSQL clients may automatically commit individual statements when they run outside an explicit transaction.
6. Always use a suitable `WHERE` condition when updating data.
7. Check how many rows an `UPDATE` affects, especially when working with important data.
8. For real financial transfers, use carefully designed transactions, constraints, and concurrency handling.

---

## 8. Practice Questions

**Try answering all five questions before checking Section 9.**

### Q1. Basic Concept

Which command starts a transaction in PostgreSQL?

A. `SAVE`  
B. `BEGIN`  
C. `COMMIT`  
D. `ROLLBACK`

### Q2. ROLLBACK

The starting balance is `5000`.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 3000
WHERE name = 'Malik';

ROLLBACK;
```

What is the final balance?

A. `3000`  
B. `5000`  
C. `0`  
D. The row is deleted

### Q3. COMMIT

The starting balance is `5000`.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4000
WHERE name = 'Malik';

COMMIT;

ROLLBACK;
```

What is the final balance?

A. `5000`  
B. `4000`  
C. `0`  
D. `2000`

### Q4. Multiple Transactions

The starting balance is `5000`.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

COMMIT;

BEGIN;

UPDATE transaction_demo
SET balance = 2000
WHERE name = 'Malik';

ROLLBACK;
```

What is the final balance?

A. `5000`  
B. `4500`  
C. `2000`  
D. `0`

### Q5. Save Changes

You have started a transaction and updated a row. You want to keep the update permanently.

Which command should you execute?

A. `ROLLBACK`  
B. `BEGIN`  
C. `COMMIT`  
D. `DROP`

---

## 9. Answer Key with Explanations

### Q1. Correct Answer: B — BEGIN

`BEGIN` starts a transaction. `COMMIT` saves changes, while `ROLLBACK` cancels uncommitted changes.

### Q2. Correct Answer: B — 5000

The update to `3000` was not committed. `ROLLBACK` undoes it, so the previous balance remains `5000`.

### Q3. Correct Answer: B — 4000

`COMMIT` saved the balance as `4000`. The later `ROLLBACK` cannot undo the already-committed change.

### Q4. Correct Answer: B — 4500

The first transaction committed `4500`.

The second transaction changed the balance to `2000`, but `ROLLBACK` undid only that second transaction's uncommitted update.

The final balance is `4500`.

### Q5. Correct Answer: C — COMMIT

Use `COMMIT` to save the changes made in the current transaction.

---

## 10. Day 1 Completion Checklist

- [ ] I understand what a transaction is.
- [ ] I can start a transaction using `BEGIN`.
- [ ] I can save changes using `COMMIT`.
- [ ] I can undo uncommitted changes using `ROLLBACK`.
- [ ] I can predict the final balance after multiple transactions.
- [ ] I have attempted the five practice questions.
- [ ] I have reviewed the answer explanations.

---

## Next Topic

**SQL Transactions — Day 2**

Topics:
- `SAVEPOINT`
- `ROLLBACK TO SAVEPOINT`
- Undoing selected changes without rolling back the entire transaction
