# Database Normalization — Day 1: First Normal Form (1NF)

## 1. Normalization kya hai?
Normalization database tables ko organize karne ka process hai, jisse duplicate data aur insert, update, delete anomalies kam ki ja sakein.

## 2. First Normal Form (1NF)
Basic 1NF rules:
- Har cell mein ek single/atomic value honi chahiye.
- Ek column mein comma-separated multiple values store karne se bachein.
- Repeating groups ya `product1`, `product2`, `product3` jaise repeating columns avoid karein.
- Sirf 1NF satisfy karna 2NF/3NF satisfy karne ki guarantee nahi hai.

## 3. Example: Multiple values in one cell

### Incorrect design
| employee_id | name | phone_numbers |
|---|---|---|
| 101 | Rahul | 9876543210, 9123456780 |

`phone_numbers` cell mein do values hain.

### Better row-based representation
| employee_id | name | phone_number |
|---|---|---|
| 101 | Rahul | 9876543210 |
| 101 | Rahul | 9123456780 |

Real-world design mein `employees` aur `employee_phones` ko separate tables mein rakhna aksar better hota hai.

## 4. Repeating columns avoid karein

### Poor design
| order_id | customer_name | product1 | product2 | product3 |
|---|---|---|---|---|
| 501 | Aman | Laptop | Mouse | Keyboard |

Agar order mein aur products hon, toh naye columns add karne padenge.

### Better representation
| order_id | customer_name | product |
|---|---|---|
| 501 | Aman | Laptop |
| 501 | Aman | Mouse |
| 501 | Aman | Keyboard |

E-commerce systems mein generally `orders` aur `order_items` jaise separate tables use hote hain.

## 5. Multiple skills example
Comma-separated skills, jaise `Java, SQL, Python`, ko ek cell mein rakhne ke bajay separate rows ya `student_skills` table mein store karein.

| student_id | skill |
|---|---|
| 101 | Java |
| 101 | SQL |
| 101 | Python |

## 6. Repeated IDs are not automatically a 1NF violation
Ek student ke multiple emails ho sakte hain:

| student_id | email |
|---|---|
| 101 | rahul@gmail.com |
| 101 | rahul@college.edu |

`student_id` ka repeat hona apne aap mein 1NF violation nahi hai. Har cell mein single value hona important hai. Real-world design mein separate email table useful ho sakti hai.

## 7. 1NF quick checklist
- Kya har cell mein ek value hai?
- Kya comma-separated multiple values store ki ja rahi hain?
- Kya `product1`, `product2`, `product3` jaise repeating columns hain?
- Kya multi-valued attributes ko separate rows/table mein model karna better hoga?

## 8. Intro to 2NF
2NF padhne se pehle:
- **Composite key:** do ya zyada columns milkar row ko uniquely identify karte hain.
- **Partial dependency:** non-key attribute composite key ke sirf ek part par depend karta hai.

Example:
`(student_id, course_id)` composite key ho sakti hai.
`student_name` sirf `student_id` par depend karta hai aur `course_name` sirf `course_id` par. Aisi partial dependencies 2NF violation ka cause ban sakti hain.

## Practice answers recap
1. Multiple phone numbers in one cell → not 1NF.
2. `product1`, `product2`, `product3` repeating columns → poor design; avoid repeating groups.
3. Comma-separated skills → separate rows or student-skills table.
4. Single-valued `name`, `salary`, `department` cells can satisfy 1NF.
5. Repeated `student_id` across rows is not automatically a 1NF violation.
