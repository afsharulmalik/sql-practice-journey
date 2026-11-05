# Database Normalization — Day 4: BCNF (Boyce–Codd Normal Form)

## 1. BCNF kya hai?
BCNF ka full form **Boyce–Codd Normal Form** hai. Ye 3NF se stricter normal form hai.

**Rule:** Har non-trivial functional dependency `X → Y` ke liye, `X` ka superkey hona zaroori hai.

Simple words: jo attribute(s) kisi doosre attribute ko determine karte hain, unhe table ki row uniquely identify kar paani chahiye.

## 2. Important terms

- **Functional dependency:** `X → Y` ka matlab hai X ki value Y ko uniquely determine karti hai.
- **Superkey:** Attribute(s) ka aisa set jo relation ki har row ko uniquely identify kare. Superkey mein extra attributes bhi ho sakte hain.
- **Candidate key:** Minimal superkey; iske kisi proper subset se row uniquely identify nahi hoti.
- **Non-trivial FD:** `X → Y` non-trivial hai jab Y, X ka subset na ho.

## 3. Example: BCNF violation

Table: `Student_Teacher(student_id, teacher_id, subject_id)`

Assumptions:
- Har student-teacher pair ke liye ek subject record hota hai.
- Har teacher sirf ek subject padhata hai.
- Ek teacher multiple students ko padha sakta hai.

Functional dependencies:
- `(student_id, teacher_id) → subject_id`
- `teacher_id → subject_id`

Candidate key: `(student_id, teacher_id)`

`teacher_id` akela superkey nahi hai, kyunki ek teacher multiple students ko padha sakta hai. Isliye `teacher_id → subject_id` BCNF violate karti hai.

## 4. BCNF mein decomposition

Original table ko split karein:

### Teacher_Subject
| teacher_id (PK) | subject_id |
|---|---|
| T1 | SQL |
| T2 | Java |

### Student_Teacher
| student_id | teacher_id |
|---|---|
| S1 | T1 |
| S2 | T1 |
| S1 | T2 |

Yahan `Teacher_Subject` mein `teacher_id` subject determine karta hai. `Student_Teacher` student aur teacher ka relationship record karta hai.

**Note:** Ye decomposition upar di gayi assumptions par based hai. Real schema mein keys aur dependencies ko business rules se confirm karna zaroori hai. BCNF decomposition hamesha dependency-preserving nahi hoti; kabhi-kabhi constraints enforce karne ke liye additional logic chahiye hota hai.

## 5. BCNF violation kab hoti hai?
Agar koi non-trivial FD `X → Y` hai aur `X` superkey nahi hai, to relation BCNF violate karta hai.

### BCNF violation nahi
`student_id → student_name`, jab `student_id` superkey ho.

Reason: determinant `student_id` superkey hai.

### BCNF violation
`teacher_id → subject_id`, jab `teacher_id` superkey nahi hai.

Reason: determinant superkey nahi hai.

## 6. 3NF vs BCNF

| 3NF | BCNF |
|---|---|
| Less strict | More strict |
| Formal rule kuch cases mein non-superkey determinant allow kar sakta hai, agar RHS prime attribute ho | Har non-trivial FD ka determinant superkey hona chahiye |
| Har 3NF relation BCNF mein nahi hota | Har BCNF relation 3NF mein hota hai |

**Important:** Beginner lessons mein 3NF ko aksar “transitive dependency remove karo” kaha jata hai. Formal 3NF definition candidate keys, prime attributes aur functional dependencies par based hoti hai.

## 7. 1NF, 2NF, 3NF, BCNF recap

- **1NF:** Har cell mein atomic value; repeating groups nahi.
- **2NF:** 1NF + non-prime attributes ki partial dependency nahi.
- **3NF:** Formal rule ke mutabiq har non-trivial FD `X → A` ke liye X superkey ho ya A prime attribute ho.
- **BCNF:** Har non-trivial FD `X → Y` ke liye X superkey ho.

## 8. Related dependency definitions

### Full Functional Dependency
Attribute composite candidate key ke poore set par depend karta hai, aur key ka koi proper subset use determine nahi kar sakta.

Example: `(student_id, course_id) → marks`.

### Partial Dependency
Non-prime attribute composite candidate key ke sirf ek proper subset par depend karta hai.

Example: `student_id → student_name`, jab composite key `(student_id, course_id)` ho.

### Transitive Dependency
Beginner-level example: `employee_id → dept_id` aur `dept_id → dept_name`; isliye employee ID department name ko indirectly determine karti hai.

### Multivalued Dependency
`X ↠ Y`: X ki ek value ke liye Y ki multiple independent values ho sakti hain. Iska major relation 4NF se hai.

### “No Dependency”
“No dependency” ek standard named dependency type nahi hai. Agar `X → Y` hold nahi karti, to X, Y ko functionally determine nahi karta.

## 9. Practice questions with answers

**Q1.** `teacher_id → subject_id`, aur teacher_id superkey nahi hai. BCNF violation?  
**Answer:** Haan. Determinant superkey nahi hai.

**Q2.** `(student_id, teacher_id) → subject_id` aur `(student_id, teacher_id)` candidate key hai. Kya yeh FD BCNF satisfy karti hai?  
**Answer:** Haan, kyunki determinant candidate key/superkey hai.

**Q3.** BCNF ka main rule kya hai?  
**Answer:** Har non-trivial FD ka determinant superkey hona chahiye.

**Q4.** `student_id → student_name`, aur student_id superkey hai. Kya BCNF satisfy hoti hai?  
**Answer:** Haan.

**Q5.** Kya har 3NF relation BCNF mein hota hai?  
**Answer:** Nahi. Har BCNF relation 3NF mein hota hai, lekin kuch 3NF relations BCNF violate kar sakte hain.

## 10. Exam-ready summary
BCNF kehta hai ki har non-trivial functional dependency `X → Y` mein X superkey hona chahiye. Agar kisi dependency ka determinant superkey nahi hai, to relation BCNF violate karta hai. Aise relation ko suitable smaller relations mein decompose kiya ja sakta hai. BCNF, 3NF se stricter hai; har BCNF relation 3NF mein hota hai, lekin har 3NF relation BCNF mein nahi hota.
