
# SQL Transactions — Day 02 Notes
## Topic: SAVEPOINT, ROLLBACK TO SAVEPOINT & Multiple Savepoints

**Learning Goal:** PostgreSQL transactions ke andar checkpoints create karna, selected changes undo karna aur transaction ko safely commit karna.

---

## 1. SAVEPOINT kya hota hai?

`SAVEPOINT` ek transaction ke andar checkpoint banata hai. Isse hum baad mein us checkpoint ke baad hue changes ko undo kar sakte hain, bina poori transaction cancel kiye.

### Syntax

```sql
SAVEPOINT savepoint_name;
```

### Example

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

COMMIT;
```

**Explanation:**
- `BEGIN` transaction start karta hai.
- Pehla `UPDATE` balance ₹4500 karta hai.
- `SAVEPOINT sp1` checkpoint banata hai.
- Doosra `UPDATE` balance ₹3500 karta hai.
- `COMMIT` final changes permanently save karta hai.

Final balance: ₹3500.

---

## 2. ROLLBACK TO SAVEPOINT

`ROLLBACK TO SAVEPOINT` selected savepoint ke baad ke changes undo karta hai. Transaction active rehti hai, isliye aap aur queries execute kar sakte hain.

### Syntax

```sql
ROLLBACK TO SAVEPOINT savepoint_name;
```

### Example

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp1;

COMMIT;
```

**Final balance: ₹4500**

Kyunki ₹3500 wala update undo ho gaya aur ₹4500 wala update `sp1` se pehle hua tha.

---

## 3. Multiple SAVEPOINTs

Ek transaction mein multiple savepoints bana sakte hain.

### Example

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

SAVEPOINT sp2;

UPDATE transaction_demo
SET balance = 2000
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp2;

COMMIT;
```

**Final balance: ₹3500**

Reason:
- `sp1` se pehle balance ₹4500 tha.
- `sp2` banne se pehle balance ₹3500 tha.
- `sp2` ke baad balance ₹2000 hua.
- `ROLLBACK TO SAVEPOINT sp2` ne ₹2000 wala update undo kar diya.
- `COMMIT` ne ₹3500 save kar diya.

### Important PostgreSQL rule

Agar aap kisi purane savepoint par rollback karte hain, toh uske baad banaye gaye savepoints invalidate ho jaate hain.

Example:

```sql
ROLLBACK TO SAVEPOINT sp1;
```

Iske baad `sp1` ke baad banaya gaya `sp2` available nahi rahega. Lekin `sp1` khud active rehta hai.

---

## 4. SAVEPOINT aur Full ROLLBACK mein difference

| Command | Effect |
|---|---|
| `SAVEPOINT sp1;` | Checkpoint create karta hai |
| `ROLLBACK TO SAVEPOINT sp1;` | Selected checkpoint ke baad ke changes undo karta hai |
| `ROLLBACK;` | Current transaction ke saare uncommitted changes undo karta hai |
| `COMMIT;` | Current transaction ke changes save karta hai |

**Yaad rakhein:** `ROLLBACK TO SAVEPOINT` aur `ROLLBACK` same nahi hain.

---

## 5. Combined Practical

Initial balance: ₹5000

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

SAVEPOINT sp2;

UPDATE transaction_demo
SET balance = 2000
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp2;

UPDATE transaction_demo
SET balance = 3000
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp1;

COMMIT;

SELECT * FROM transaction_demo
WHERE name = 'Malik';
```

**Final balance: ₹4500**

Explanation:
1. Balance ₹4500 hua.
2. `sp1` create hua.
3. Balance ₹3500 hua.
4. `sp2` create hua.
5. Balance ₹2000 hua.
6. `ROLLBACK TO sp2` se balance ₹3500 hua.
7. Balance dobara ₹3000 hua.
8. `ROLLBACK TO sp1` se `sp1` ke baad ke changes undo hue.
9. `COMMIT` ne ₹4500 save kar diya.

---

## 6. Practice Questions with Answers

### Q1. SAVEPOINT ka main purpose kya hai?

**Answer:** Transaction ke andar checkpoint create karna, jahan tak changes ko preserve karke baad ke changes undo kiye ja sakein.

### Q2. Final balance kya hoga?

Initial balance ₹5000 hai.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp1;

COMMIT;
```

**Answer: ₹4500**

Explanation: ₹3500 wala update undo hua; ₹4500 wala update save hua.

### Q3. Final balance kya hoga?

Initial balance ₹5000 hai.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4000
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 2500
WHERE name = 'Malik';

SAVEPOINT sp2;

UPDATE transaction_demo
SET balance = 1000
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp2;

COMMIT;
```

**Answer: ₹2500**

Explanation: `sp2` ke baad ka ₹1000 wala update undo hua.

### Q4. Final balance kya hoga?

Initial balance ₹5000 hai.

```sql
BEGIN;

UPDATE transaction_demo
SET balance = 4500
WHERE name = 'Malik';

SAVEPOINT sp1;

UPDATE transaction_demo
SET balance = 3500
WHERE name = 'Malik';

SAVEPOINT sp2;

UPDATE transaction_demo
SET balance = 2000
WHERE name = 'Malik';

ROLLBACK TO SAVEPOINT sp1;

COMMIT;
```

**Answer: ₹4500**

Explanation: `sp1` ke baad ke saare changes undo ho gaye.

### Q5. `ROLLBACK TO SAVEPOINT sp1` ke baad transaction ka kya hota hai?

**Answer:** Transaction active rehti hai. Aap further queries execute kar sakte hain aur baad mein `COMMIT` ya full `ROLLBACK` kar sakte hain.

### Q6. Kya purane savepoint par rollback karne ke baad newer savepoint use kar sakte hain?

**Answer:** Nahi. PostgreSQL mein purane savepoint par rollback karne se uske baad banaye gaye savepoints invalidate ho jaate hain.

### Q7. `ROLLBACK;` aur `ROLLBACK TO SAVEPOINT sp1;` mein kya difference hai?

**Answer:**
- `ROLLBACK;` poori current transaction ke uncommitted changes undo karta hai.
- `ROLLBACK TO SAVEPOINT sp1;` sirf `sp1` ke baad ke changes undo karta hai aur transaction ko active rakhta hai.

---

## 7. Important Rules for Revision

1. `SAVEPOINT` ko transaction ke andar use karein.
2. Savepoint names unique rakhna readability ke liye achha hai.
3. `ROLLBACK TO SAVEPOINT` poori transaction cancel nahi karta.
4. `COMMIT` current transaction ke changes save karta hai.
5. Full `ROLLBACK` current transaction ke uncommitted changes undo karta hai.
6. Purane savepoint par rollback karne se newer savepoints invalidate ho jaate hain.
7. PostgreSQL mein savepoint name galat ya unavailable hone par command error de sakti hai.
8. Ye examples tabhi expected balance denge jab `transaction_demo` mein `name = 'Malik'` ki exactly ek row ho.

---

## 8. Day 02 Completion Checklist

- [x] SAVEPOINT
- [x] ROLLBACK TO SAVEPOINT
- [x] Multiple SAVEPOINTs
- [x] Savepoints ka order aur rollback behavior
- [x] Combined practical
- [x] Final practice questions and answers

**Day 02 Status: Completed**

**Next Topic:** SQL Transactions Day 03 — ACID Properties (Atomicity, Consistency, Isolation, Durability).
