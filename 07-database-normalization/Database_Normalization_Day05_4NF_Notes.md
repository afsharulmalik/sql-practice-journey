# Database Normalization — Day 5: Fourth Normal Form (4NF)

## 1. What is 4NF?

A relation is in **Fourth Normal Form (4NF)** if, for every **non-trivial multivalued dependency** `X ↠ Y`, `X` is a **superkey**.

In simple words: if one entity has multiple independent sets of values, store those facts separately to avoid unnecessary combinations and redundancy.

## 2. Multivalued Dependency (MVD)

A multivalued dependency is written as `X ↠ Y`.

It means that for a given value of `X`, there can be multiple values of `Y`, independently of the other attributes in the relation.

Example:
- One student can have several hobbies.
- The same student can know several languages.
- If hobbies and languages are independent, combining them in one table creates repeated combinations.

**Remember:** A multivalued dependency (`↠`) is different from a functional dependency (`→`).

- `X → Y`: each X value determines one Y value.
- `X ↠ Y`: each X value can be associated with a set of Y values, independently of the remaining attributes.

## 3. Example: Why 4NF is needed

Suppose the table is:

### `Student(student_id, hobby, language)`

| student_id | hobby | language |
|---|---|---|
| 1 | Cricket | English |
| 1 | Cricket | Hindi |
| 1 | Music | English |
| 1 | Music | Hindi |

Student 1 has two hobbies and two languages. Since these are independent facts, all combinations appear in the table. This creates redundant rows.

The multivalued dependencies are:
- `student_id ↠ hobby`
- `student_id ↠ language`

If `student_id` is not a superkey of the original relation, these non-trivial MVDs violate 4NF.

## 4. Correct decomposition

Split the original relation into two tables:

### `Student_Hobbies(student_id, hobby)`

| student_id | hobby |
|---|---|
| 1 | Cricket |
| 1 | Music |

### `Student_Languages(student_id, language)`

| student_id | language |
|---|---|
| 1 | English |
| 1 | Hindi |

Now hobbies and languages are stored independently, avoiding repeated cross-combinations.

## 5. Another example: Employee, skills, and languages

Original relation: `Employee(employee_id, skill, language)`

If an employee's skills and languages are independent, decompose into:
- `Employee_Skills(employee_id, skill)`
- `Employee_Languages(employee_id, language)`

## 6. 1NF to 4NF — quick comparison

| Normal Form | Main focus |
|---|---|
| **1NF** | Each cell contains an atomic value; no repeating groups. |
| **2NF** | 1NF + no partial dependency of a non-prime attribute on a candidate key. |
| **3NF** | 2NF + no prohibited transitive dependency of non-prime attributes on candidate keys; formal rule also accounts for prime attributes. |
| **BCNF** | For every non-trivial functional dependency `X → Y`, X must be a superkey. |
| **4NF** | For every non-trivial multivalued dependency `X ↠ Y`, X must be a superkey. |

## 7. Important dependency terms

- **Functional dependency (`X → Y`):** X uniquely determines Y.
- **Partial dependency:** A non-prime attribute depends on a proper subset of a composite candidate key.
- **Transitive dependency:** A dependency is mediated through another attribute/set of attributes, e.g. `A → B` and `B → C` imply `A → C`.
- **Multivalued dependency (`X ↠ Y`):** For each X, a set of Y values exists independently of the other attributes.
- **No functional dependency:** `X → Y` does not hold; X does not uniquely determine Y. “No dependency” is not itself a special normal-form rule.

## 8. Common exam questions — answers

**Q1. What is the rule for 4NF?**  
Every non-trivial multivalued dependency must have a superkey as its determinant.

**Q2. What does `X ↠ Y` represent?**  
A multivalued dependency: multiple Y values can be associated with X independently of the other attributes.

**Q3. A non-trivial MVD exists and X is not a superkey. What happens?**  
The relation violates 4NF.

**Q4. Why decompose Student(student_id, hobby, language)?**  
Because hobbies and languages are independent multivalued facts, so separate hobby and language relations reduce redundancy.

**Q5. What is the best decomposition of Employee(employee_id, skill, language), if skills and languages are independent?**  
`Employee_Skills(employee_id, skill)` and `Employee_Languages(employee_id, language)`.

## 9. Exam tip

When a question mentions **two or more independent multivalued facts** about the same entity (for example, student hobbies and languages), think of **4NF**.

Do not confuse:
- **BCNF:** functional dependency `→`
- **4NF:** multivalued dependency `↠`

4NF is about non-trivial MVDs. A relation with no non-trivial MVDs is in 4NF with respect to MVDs.

## 10. What comes next?

After 4NF, the next topic in the normalization sequence is **Fifth Normal Form (5NF)**, also called Project-Join Normal Form (PJNF).
