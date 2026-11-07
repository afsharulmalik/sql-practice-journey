# SQL Locks, Isolation Levels and Deadlocks — Complete Notes

## 1. SQL Locks

### What is a Lock?
A lock is a mechanism used by a database to control concurrent access to data and maintain consistency when multiple transactions operate on the same resources.

**Why are locks needed?**
- To prevent conflicting concurrent modifications.
- To maintain data consistency.
- To coordinate simultaneous transactions.
- To prevent certain race conditions.

### Types of Locks

#### A. Row-Level Locks
Locks specific rows rather than every row in a table.

```sql
BEGIN;

SELECT *
FROM employees
WHERE employee_id = 1
FOR UPDATE;

COMMIT;
```

`FOR UPDATE` locks the selected rows against conflicting updates and deletes until the transaction ends.

#### B. Table-Level Locks
Locks a table against operations that conflict with the acquired lock mode.

```sql
BEGIN;

LOCK TABLE employees IN ACCESS EXCLUSIVE MODE;

COMMIT;
```

`ACCESS EXCLUSIVE` is the most restrictive PostgreSQL table lock mode. It conflicts with ordinary `SELECT` queries as well as writes.

### SELECT FOR UPDATE
Used when a transaction needs to read a row and then safely modify it.

```sql
BEGIN;

SELECT salary
FROM employees
WHERE employee_id = 1
FOR UPDATE;

UPDATE employees
SET salary = salary + 5000
WHERE employee_id = 1;

COMMIT;
```

If another transaction tries to update the same row, it normally waits until the first transaction finishes.

**Important:** An ordinary `SELECT` generally does not wait for a row-level `FOR UPDATE` lock.

### When Are Locks Released?
Row locks are normally released when the transaction commits or rolls back.

```sql
COMMIT;
-- or
ROLLBACK;
```

### Lock Timeout
Set the maximum time a statement should wait to acquire a lock:

```sql
SET lock_timeout = '5s';
```

If the lock cannot be acquired within five seconds, PostgreSQL cancels the statement with an error. In an explicit transaction, the transaction may then need a `ROLLBACK`.

---

## 2. Transactions and ACID

A transaction is a logical unit of database operations.

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 500
WHERE account_id = 2;

COMMIT;
```

### ACID Properties

- **Atomicity:** All transaction operations succeed together, or the transaction is rolled back.
- **Consistency:** A transaction preserves database rules and constraints.
- **Isolation:** Concurrent transactions are controlled to prevent unacceptable interference.
- **Durability:** Committed changes persist, subject to the database's durability configuration and guarantees.

---

## 3. Isolation Levels

Isolation levels define how concurrent transactions can observe each other's changes.

### A. READ UNCOMMITTED
The SQL standard permits dirty reads at this level.

**PostgreSQL behavior:** PostgreSQL treats `READ UNCOMMITTED` as `READ COMMITTED`. Dirty reads are not permitted.

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM employees;

COMMIT;
```

### B. READ COMMITTED
This is the **default isolation level in PostgreSQL**.

Each statement gets a new snapshot of data committed before that statement begins.

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT salary
FROM employees
WHERE employee_id = 1;

-- Another transaction updates salary and commits.

SELECT salary
FROM employees
WHERE employee_id = 1;

COMMIT;
```

The second query may return the updated salary.

**Key point:** Non-repeatable reads and phantom reads can occur.

### C. REPEATABLE READ
Maintains a consistent transaction-level snapshot.

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT salary
FROM employees
WHERE employee_id = 1;

-- Another transaction updates salary and commits.

SELECT salary
FROM employees
WHERE employee_id = 1;

COMMIT;
```

The second query continues to see the row version from the transaction's snapshot.

In PostgreSQL, `REPEATABLE READ` also prevents phantom reads. Conflicting concurrent updates can cause a transaction to fail, requiring a retry.

### D. SERIALIZABLE
The strongest PostgreSQL isolation level. It ensures that successfully committed concurrent transactions behave consistently with some serial execution order.

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT *
FROM accounts
WHERE account_id = 1;

COMMIT;
```

PostgreSQL may abort a transaction if a serialization anomaly could occur. Applications should be prepared to retry the entire transaction.

---

## 4. Isolation Levels Comparison

| Feature | Read Committed | Repeatable Read | Serializable |
|---|---|---|---|
| Default in PostgreSQL | Yes | No | No |
| Dirty reads | Prevented | Prevented | Prevented |
| Non-repeatable reads | Possible | Prevented | Prevented |
| Phantom reads | Possible | Prevented in PostgreSQL | Prevented |
| Serialization anomalies | Possible | Some possible | Prevented through detection and aborts |
| May require retry after conflict | Yes, for some errors | Yes | Yes |

**Remember:** PostgreSQL's `REPEATABLE READ` is stronger against phantom reads than the minimum guarantee required by the SQL standard.

---

## 5. Read Anomalies

### A. Dirty Read
Reading uncommitted changes made by another transaction.

PostgreSQL does not permit dirty reads.

### B. Non-repeatable Read
Reading the same row twice within a transaction and getting different values because another transaction committed an update.

Possible under PostgreSQL `READ COMMITTED`.

### C. Phantom Read
Repeating a query with the same condition and seeing a different set of matching rows because of concurrent inserts or deletes.

Possible under `READ COMMITTED`; prevented by PostgreSQL `REPEATABLE READ` and `SERIALIZABLE`.

### D. Serialization Anomaly
The combined outcome of concurrent transactions cannot be explained by any serial execution order.

`SERIALIZABLE` detects such conflicts and may abort a transaction.

---

## 6. Deadlocks

### What Is a Deadlock?
A deadlock occurs when transactions wait for resources held by one another, creating a circular wait.

### Example

- Transaction 1 locks Employee A and waits for Employee B.
- Transaction 2 locks Employee B and waits for Employee A.

Neither can proceed until the deadlock is resolved.

### PostgreSQL Deadlock Example

Session 1:

```sql
BEGIN;

UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 1;

UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 2;

COMMIT;
```

Session 2:

```sql
BEGIN;

UPDATE employees
SET salary = salary + 2000
WHERE employee_id = 2;

UPDATE employees
SET salary = salary + 2000
WHERE employee_id = 1;

COMMIT;
```

If these statements interleave so each transaction holds one row lock and waits for the other, a deadlock can occur.

### How PostgreSQL Handles Deadlocks
PostgreSQL detects deadlocks and aborts one of the transactions so the other can proceed.

The error commonly includes:

```text
ERROR: deadlock detected
SQLSTATE: 40P01
```

The application may retry the aborted transaction.

### How to Prevent Deadlocks

1. Acquire locks in a consistent order across transactions.
2. Keep transactions short.
3. Avoid waiting for user input or external network calls inside transactions.
4. Use appropriate indexes to avoid unnecessarily broad work.
5. Handle deadlock errors and retry safely when appropriate.

---

## 7. Important PostgreSQL Error Codes

| SQLSTATE | Meaning |
|---|---|
| `40P01` | Deadlock detected |
| `40001` | Serialization failure |
| `55P03` | Lock not available |

These codes help applications identify concurrency-related failures.

---

## 8. Practical Interview Questions

### Q1. What is a database lock?
A mechanism that coordinates concurrent access to database resources and protects consistency.

### Q2. What does `SELECT FOR UPDATE` do?
It locks the selected rows against conflicting updates and deletes until the transaction ends.

### Q3. What is PostgreSQL's default isolation level?
`READ COMMITTED`.

### Q4. Does PostgreSQL allow dirty reads?
No. `READ UNCOMMITTED` behaves as `READ COMMITTED`.

### Q5. What is a non-repeatable read?
Reading the same row twice and seeing a different value due to a committed concurrent update.

### Q6. What is a phantom read?
Repeating a predicate query and seeing a different set of matching rows.

### Q7. Which isolation level provides the strongest protection?
`SERIALIZABLE`.

### Q8. What is a deadlock?
A circular wait in which transactions hold resources that other transactions need.

### Q9. How does PostgreSQL resolve a deadlock?
It aborts one of the transactions.

### Q10. How can deadlocks be reduced?
Use consistent lock ordering and short transactions.

### Q11. What is `lock_timeout`?
A setting that limits how long a statement waits to acquire a lock.

### Q12. What is the difference between `REPEATABLE READ` and `SERIALIZABLE`?
`REPEATABLE READ` provides a stable snapshot. `SERIALIZABLE` additionally detects serialization anomalies and may abort transactions to preserve serializable behavior.

---

## 9. Quick Revision

- **Lock:** Controls concurrent access to data.
- **`FOR UPDATE`:** Locks selected rows against conflicting updates and deletes.
- **`COMMIT` / `ROLLBACK`:** Ends a transaction and releases its locks.
- **`READ COMMITTED`:** Each statement gets a new snapshot.
- **`REPEATABLE READ`:** Consistent snapshot across the transaction.
- **`SERIALIZABLE`:** Strongest isolation; conflicts may require retries.
- **Dirty read:** Reading uncommitted data.
- **Non-repeatable read:** Same row, different value.
- **Phantom read:** Same predicate, different set of rows.
- **Deadlock:** Circular waiting between transactions.
- **`40P01`:** Deadlock detected.
- **`40001`:** Serialization failure.
- **Best prevention:** Consistent lock ordering and short transactions.

---

## 10. Suggested Practice

1. Open two PostgreSQL query sessions.
2. Use `BEGIN` in both sessions.
3. Lock the same employee row with `SELECT ... FOR UPDATE` in Session 1.
4. Try updating that employee in Session 2 and observe the wait.
5. Commit Session 1 and observe Session 2 continue.
6. Repeat using `READ COMMITTED` and `REPEATABLE READ` to compare snapshots.

**Note:** Run concurrency experiments only in a practice database, and roll back any unintended changes.
