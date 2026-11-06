
# SQL Transactions — Day 03 Notes
## Topic: ACID Properties

**Goal:** SQL transactions ki four ACID properties samajhna aur unhe practical examples aur interview questions se revise karna.

---

## 1. ACID Properties kya hain?

ACID database transactions ki four important properties ka group hai.

| Property | Full Form | Main Purpose |
|---|---|---|
| A | Atomicity | All or Nothing |
| C | Consistency | Valid database state maintain karna |
| I | Isolation | Concurrent transactions ke interference ko control karna |
| D | Durability | Committed changes ko persist rakhna |

---

## 2. Atomicity

**Meaning:** All or Nothing.

Transaction ke changes ko ek unit ki tarah treat kiya jata hai. Transaction successfully commit hoti hai, ya failure ki situation mein uske uncommitted changes rollback kiye jaate hain.

### Example: Bank Transfer

Account A se Account B mein ₹1,000 transfer karne hain.

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

COMMIT;
```

Agar dono updates successful hain, toh transaction commit ho sakti hai.

Agar beech mein error aaye, toh failed transaction ko rollback karna chahiye:

```sql
ROLLBACK;
```

**Important:** PostgreSQL mein SQL error ke baad current transaction failed state mein ja sakti hai. `ROLLBACK` uncommitted changes undo karta hai.

**Real-world example:** Payment mein amount debit ho gaya, lekin corresponding credit fail ho gaya. Atomicity partial transaction ko commit hone se bachane mein help karti hai.

---

## 3. Consistency

**Meaning:** Transaction database ko valid state se doosri valid state mein le jaati hai, database ke applicable rules aur constraints ko maintain karte hue.

### Example: CHECK Constraint

```sql
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    balance NUMERIC(10, 2)
        CHECK (balance >= 0)
);
```

Valid insert:

```sql
INSERT INTO accounts (account_id, balance)
VALUES (1, 5000);
```

Invalid update:

```sql
UPDATE accounts
SET balance = -1000
WHERE account_id = 1;
```

Negative balance `CHECK` constraint ko violate karta hai. PostgreSQL is update ko reject karega.

Consistency ko support karne wale database rules mein shamil hain:
- PRIMARY KEY
- FOREIGN KEY
- UNIQUE
- NOT NULL
- CHECK

**Real-world example:** Bank account ka balance defined business rules ko violate nahi karna chahiye.

**Important:** Consistency ka matlab sirf negative balance rokna nahi hai. Ismein database ke applicable integrity constraints aur business rules shamil hain.

---

## 4. Isolation

**Meaning:** Multiple concurrent transactions ke beech unwanted interference ko control karna.

Isolation levels decide karte hain ki ek transaction doosri concurrent transactions ke changes ko kab aur kis tarah observe kar sakti hai.

### Example: READ COMMITTED

```sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM accounts
WHERE account_id = 1;

COMMIT;
```

PostgreSQL mein `READ COMMITTED` har statement ko committed data ka snapshot deta hai.

### Common Concurrency Problems

**1. Dirty Read**

Ek transaction doosri transaction ke uncommitted changes read karti hai.

PostgreSQL mein dirty reads supported nahi hain; `READ UNCOMMITTED` use karne par bhi behavior `READ COMMITTED` jaisa hota hai.

**2. Non-repeatable Read**

Ek transaction same row ko do baar read karti hai, lekin beech mein doosri transaction commit kar deti hai. Dobara read karne par value badal sakti hai.

**3. Phantom Read**

Same condition wali query dobara chalane par matching rows ka set badal sakta hai, kyunki doosri transaction ne matching rows insert ya delete karke commit kiya.

**4. Lost Update**

Concurrent transactions ek hi data ko update karti hain aur ek update doosre ke result ko overwrite kar sakta hai.

### PostgreSQL Isolation Levels

| Isolation Level | Simplified Behavior |
|---|---|
| READ COMMITTED | Har statement committed snapshot use karti hai |
| REPEATABLE READ | Transaction ke andar stable snapshot provide karta hai |
| SERIALIZABLE | Concurrent transactions ka result serial execution ke equivalent hona chahiye; conflicts par transaction abort ho sakti hai |

**Interview Point:** PostgreSQL ka default isolation level `READ COMMITTED` hai.

---

## 5. Durability

**Meaning:** Successfully committed changes failure ke baad bhi persistent rehne chahiye.

### Example

```sql
BEGIN;

UPDATE accounts
SET balance = 4000
WHERE account_id = 1;

COMMIT;
```

Successful commit ke baad database ko committed balance ko crash recovery ke baad bhi preserve karna chahiye, subject to correct database and storage configuration.

**Real-world example:** Online payment successful hone ke baad server restart hone par payment ka committed record available rehna chahiye.

**Important:** Durability ka sambandh committed changes se hai. Uncommitted changes ko `ROLLBACK` kiya ja sakta hai.

---

## 6. Combined Practical: Bank Transfer

Assume `accounts` table mein `account_id` aur `balance` columns hain, aur accounts 1 aur 2 pehle se exist karte hain.

```sql
BEGIN;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

SELECT *
FROM accounts
WHERE account_id IN (1, 2);

COMMIT;
```

### Expected Result

Agar initial balances hain:
- Account 1: ₹5,000
- Account 2: ₹2,000

Successful transfer ke baad:
- Account 1: ₹4,000
- Account 2: ₹3,000

Total balance transfer se pehle aur baad ₹7,000 hi rahega.

### ACID Connection

- Atomicity: Transfer ke partial changes commit nahi hone chahiye.
- Consistency: Applicable database rules maintain hone chahiye.
- Isolation: Concurrent transactions ke interference ko control kiya jana chahiye.
- Durability: Commit ke baad transfer persistent rehna chahiye.

**Note:** Production banking systems mein insufficient balance checks, concurrent updates, error handling aur idempotency jaise additional controls bhi zaroori hote hain.

---

## 7. Practice Questions with Answers

### Q1. Bank transfer mein debit successful hua, lekin credit fail ho gaya. Transaction ke changes undo kar diye gaye. Kaunsi property?

**Answer: Atomicity**

Reason: Transaction ke uncommitted changes ko ek unit ki tarah handle kiya gaya.

### Q2. `CHECK (balance >= 0)` negative balance ko reject karta hai. Kaunsi property?

**Answer: Consistency**

Reason: Database apna integrity constraint maintain karta hai.

### Q3. Ek transaction doosri transaction ke uncommitted changes read nahi kar sakti. Kaunsi property?

**Answer: Isolation**

Reason: Concurrent transactions ke beech data visibility ko control kiya jata hai.

### Q4. Successful commit ke baad server restart hone par bhi changes available rehte hain. Kaunsi property?

**Answer: Durability**

Reason: Committed data failure ke baad bhi persistent rehna chahiye.

### Q5. Atomicity ka simple meaning kya hai?

**Answer: All or Nothing.**

Reason: Transaction ke changes ko ek unit ki tarah commit ya rollback kiya jata hai.

### Q6. PostgreSQL ka default transaction isolation level kya hai?

**Answer: READ COMMITTED.**

Reason: PostgreSQL mein default par har statement committed snapshot use karti hai.

### Q7. Dirty Read kya hota hai?

**Answer:** Jab ek transaction doosri transaction ke uncommitted changes read karti hai.

Reason: Agar writer transaction rollback kar de, toh reader ne aisa data dekha jo commit nahi hua tha.

### Q8. Durability kis event ke baad relevant hoti hai?

**Answer:** Successful `COMMIT` ke baad.

Reason: Durability committed changes ko preserve karne se related hai.

### Q9. Agar same row ko ek transaction mein dobara read karne par committed value badal jaaye, toh ise kya kehte hain?

**Answer: Non-repeatable Read.**

Reason: Do reads ke beech doosri transaction ne same row ko modify karke commit kiya.

### Q10. Kya PostgreSQL mein READ UNCOMMITTED dirty reads allow karta hai?

**Answer: Nahi.**

Reason: PostgreSQL mein `READ UNCOMMITTED` ka behavior `READ COMMITTED` jaisa hota hai.

---

## 8. Interview Quick Revision

- Atomicity = All or Nothing
- Consistency = Database rules aur constraints maintain karna
- Isolation = Concurrent transactions ke interaction ko control karna
- Durability = Committed changes ko persistent rakhna
- PostgreSQL default isolation = READ COMMITTED
- `COMMIT` = Transaction ke changes commit karna
- `ROLLBACK` = Current transaction ke uncommitted changes undo karna
- `CHECK` = Column values par condition enforce karna
- Dirty Read = Uncommitted data read karna
- Non-repeatable Read = Same row ko dobara read karne par committed value badalna
- Phantom Read = Repeated query par matching rows ka set badalna

---

## 9. Day 03 Completion Checklist

- [x] Atomicity
- [x] Consistency
- [x] Isolation
- [x] Durability
- [x] PostgreSQL examples
- [x] Concurrency problems
- [x] Final practice: 4/4 correct

**Status: Day 03 Completed**

**Next Topic:** SQL Transactions Day 04 — Isolation Levels in PostgreSQL, practical demonstrations aur concurrency scenarios.

