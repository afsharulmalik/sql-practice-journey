# Database Normalization — Day 2: Second Normal Form (2NF)

## 1. Normalization kya hai?
Normalization database tables ko organize karne ka process hai, jisse duplicate data kam ho, insert/update/delete anomalies se bacha ja sake, aur data consistency improve ho.

## 2. Functional Dependency (FD)
Functional dependency ka matlab hai ki ek attribute ya attributes ka set kisi doosre attribute ki value ko uniquely determine karta hai.

**Notation:** `X → Y`

Agar do rows mein `X` same hai, to un rows mein `Y` bhi same hona chahiye.

**Example:** `student_id → student_name` — ek `student_id` ek hi student name determine karta hai.

## 3. Full Functional Dependency
Jab koi non-key attribute **composite candidate key ke poore set** par depend kare, aur key ka koi proper subset us attribute ko determine na kar sake, to ise full functional dependency kehte hain.

**Example:** `Student_Courses(student_id, course_id, marks)`

Composite key: `(student_id, course_id)`

`(student_id, course_id) → marks`

Marks student aur course ke combination par depend karte hain. Sirf `student_id` ya sirf `course_id` se marks determine nahi hote.

## 4. Partial Dependency
Jab koi non-prime attribute composite candidate key ke **sirf ek part** par depend kare, poori key par nahi, to ise partial dependency kehte hain.

**Example:** `Student_Courses(student_id, course_id, student_name, course_name)`

Composite key: `(student_id, course_id)`

- `student_id → student_name`
- `course_id → course_name`

`student_name` sirf `student_id` par aur `course_name` sirf `course_id` par depend karte hain. Ye partial dependencies hain, kyunki dono key ke sirf ek part par depend hain.

## 5. Multivalued Dependency (MVD)
Jab ek attribute ki value ke liye doosre attribute ki **multiple independent values** ho sakti hain, to multivalued dependency ho sakti hai.

**Notation:** `X ↠ Y` (double arrow)

**Example:** `Student(student_id, hobby, language)`

Ek student ki multiple hobbies aur multiple languages ho sakti hain, aur hobbies languages se independent hain. Dono independent lists ko ek hi table mein store karne se combinations repeat ho sakte hain.

Behtar decomposition:
- `Student_Hobbies(student_id, hobby)`
- `Student_Languages(student_id, language)`

MVD ka main connection **Fourth Normal Form (4NF)** se hai, 2NF se nahi.

## 6. “No Dependency” ka kya matlab hai?
**“No dependency” apne aap mein ek standard functional-dependency type ka naam nahi hai.** Iska meaning context par depend karta hai.

- Agar `X` se `Y` determine nahi hota, to `X → Y` functional dependency hold nahi karti.
- Agar non-key attribute key se determine hi nahi hota, to table ka design ya data model incomplete/incorrect ho sakta hai.
- Normalization mein aam taur par full, partial, transitive aur multivalued dependency jaise concepts discuss hote hain.

## 7. Second Normal Form (2NF)
Koi relation 2NF mein tab hota hai jab:
1. Woh pehle **First Normal Form (1NF)** mein ho.
2. Har non-prime attribute kisi bhi candidate key ke kisi proper subset par partially dependent na ho.

**Beginner-friendly shortcut:** Composite primary key wale simple examples mein non-key attributes ko poori key par depend karna chahiye, key ke sirf ek part par nahi.

**Important:** Formal definition candidate keys aur prime/non-prime attributes par based hoti hai. Agar relation ki har candidate key single-column ki ho, to 1NF relation mein partial dependency nahi hoti; isliye woh 2NF mein bhi hota hai.

## 8. Example: 2NF Violation

Table: `student_courses`

| student_id | course_id | student_name | course_name | marks |
|---|---|---|---|---:|
| 1 | 101 | Aman | SQL | 85 |
| 1 | 102 | Aman | Java | 90 |
| 2 | 101 | Riya | SQL | 88 |

Assumed composite key: `(student_id, course_id)`

Functional dependencies:
- `(student_id, course_id) → marks` — **full functional dependency**
- `student_id → student_name` — **partial dependency**
- `course_id → course_name` — **partial dependency**

`student_name` aur `course_name` composite key ke sirf ek part par depend karte hain. Isliye table 2NF violate karta hai.

## 9. Table ko 2NF mein kaise convert karein?

### Students
| student_id (PK) | student_name |
|---|---|
| 1 | Aman |
| 2 | Riya |

### Courses
| course_id (PK) | course_name |
|---|---|
| 101 | SQL |
| 102 | Java |

### Student_Courses
| student_id (FK) | course_id (FK) | marks |
|---|---|---:|
| 1 | 101 | 85 |
| 1 | 102 | 90 |
| 2 | 101 | 88 |

Ab `student_name` sirf `Students` mein hai, `course_name` sirf `Courses` mein hai, aur `marks` student-course combination par depend karta hai. Isse partial dependencies remove ho jaati hain.

## 10. E-commerce example

Table: `order_items(order_id, product_id, quantity, product_name)`

Assumed composite key: `(order_id, product_id)`

- `(order_id, product_id) → quantity` — **full functional dependency**
- `product_id → product_name` — **partial dependency**

`product_name` ko `Products(product_id, product_name)` table mein rakhna chahiye. `order_items` mein `order_id`, `product_id`, `quantity` rakhein.

## 11. Quick comparison

| Dependency | Meaning | Example |
|---|---|---|
| Full functional | Attribute poori composite key par depend karta hai | `(student_id, course_id) → marks` |
| Partial | Attribute composite key ke sirf ek part par depend karta hai | `student_id → student_name` |
| Transitive | Key non-key attribute ko kisi doosre non-key attribute ke through determine karti hai | `employee_id → dept_id → dept_name` |
| Multivalued | Ek value ke saath doosre attribute ki multiple independent values ho sakti hain | `student_id ↠ hobby` |

## 12. Practice recap

1. Composite key `(student_id, course_id)` hai. `student_id → student_name`. Kaunsi dependency?  
   **Answer:** Partial dependency.

2. `(student_id, course_id) → marks`, aur marks sirf kisi ek key part se determine nahi hote. Kaunsi dependency?  
   **Answer:** Full functional dependency.

3. Composite key `(order_id, product_id)` hai aur `product_id → product_name`. 2NF issue?  
   **Answer:** `product_name` partial dependency hai.

4. Ek student ki multiple hobbies aur multiple languages independent hain. Kaunsa concept?  
   **Answer:** Multivalued dependency.

5. Kya “no dependency” ek standard dependency type hai?  
   **Answer:** Nahi. Ye aam taur par batata hai ki specified functional dependency hold nahi karti; exact meaning context par depend karta hai.

## 13. 1NF, 2NF aur 3NF recap

- **1NF:** Har cell mein atomic/single value; repeating groups nahi.
- **2NF:** 1NF + non-prime attributes ki partial dependency nahi.
- **3NF:** Beginner-level summary mein, 2NF ke baad transitive dependency ko remove karna.

**Yaad rakhein:** Partial dependency 2NF ke liye, transitive dependency 3NF ke liye, aur multivalued dependency 4NF ke liye especially important hai.
