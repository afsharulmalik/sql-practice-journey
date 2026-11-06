# Database Normalization — Day 6: Fifth Normal Form (5NF)

## 1. What is 5NF?

**Fifth Normal Form (5NF)** is also called **Project-Join Normal Form (PJNF)**.

A relation is in 5NF when every non-trivial join dependency that holds in the relation is implied by its candidate keys.

In simple terms, 5NF deals with cases where a relation can be decomposed into smaller relations and reconstructed through joins without introducing incorrect extra rows.

## 2. Join Dependency (JD)

A **Join Dependency (JD)** describes a condition in which a relation can be reconstructed exactly by joining specified projections of that relation.

For a relation `R(A, B, C)`, a possible decomposition is:
- `R1(A, B)`
- `R2(A, C)`
- `R3(B, C)`

This decomposition is valid for a particular relation schema only when the relevant join dependency actually holds. Do not split every three-column table this way automatically.

## 3. Example: Supplier, Product, and Project

Suppose a business tracks:

`Supply(supplier, product, project)`

In certain business rules, a valid supply triple may be determined by three pairwise relationships:
- which products a supplier supplies,
- which projects a supplier serves,
- which products are used by a project.

In such a case, the relation may be decomposed into:

- `Supplier_Product(supplier, product)`
- `Supplier_Project(supplier, project)`
- `Product_Project(product, project)`

The decomposition is correct **only if** joining these three relations reproduces exactly the original `Supply` relation, without losing valid rows or creating spurious rows. The business rules must justify this join dependency.

## 4. Lossless join and spurious tuples

A decomposition is **lossless** when joining the decomposed relations reconstructs exactly the original relation.

A **spurious tuple** is an extra row created by joining decomposed relations that was not present in the original relation.

5NF decomposition must preserve the relation correctly. Simply splitting a table into smaller tables does not guarantee a valid decomposition.

## 5. 4NF vs 5NF

| 4NF | 5NF |
|---|---|
| Focuses on multivalued dependencies (MVDs). | Focuses on join dependencies (JDs). |
| Every non-trivial MVD must have a superkey as its determinant. | Every non-trivial JD that holds must be implied by candidate keys. |
| Handles independent multivalued facts. | Handles certain complex join relationships that require decomposition into three or more projections. |

## 6. Normal Forms — quick revision

| Normal Form | Main focus |
|---|---|
| **1NF** | Atomic values; no repeating groups. |
| **2NF** | No partial dependency of a non-prime attribute on a candidate key. |
| **3NF** | For each non-trivial FD `X → A`, X is a superkey or A is a prime attribute. |
| **BCNF** | For every non-trivial FD `X → Y`, X must be a superkey. |
| **4NF** | For every non-trivial MVD `X ↠ Y`, X must be a superkey. |
| **5NF** | Every non-trivial join dependency that holds is implied by candidate keys. |

## 7. Common exam questions — answers

**Q1. What is the main focus of 5NF?**  
Join Dependency (JD).

**Q2. What should happen after a valid decomposition?**  
Joining the decomposed relations should reproduce the original relation exactly, without spurious tuples.

**Q3. When is a join dependency satisfied?**  
When the relation can be reconstructed exactly from the specified projections by joining them.

**Q4. What is the main difference between 4NF and 5NF?**  
4NF focuses on multivalued dependencies; 5NF focuses on join dependencies.

**Q5. Does every relation in 4NF automatically satisfy 5NF?**  
No. A relation can be in 4NF but still have a non-trivial join dependency not implied by its candidate keys.

## 8. Exam tips

- **4NF → MVD (`↠`)**
- **5NF → JD (JOIN / projections)**
- **Lossless join:** no information is lost and no extra rows are introduced.
- Do not decompose a relation just because it has three columns. The functional dependencies, join dependencies, and business rules determine whether a decomposition is valid.
- 5NF is also known as **Project-Join Normal Form (PJNF)**.

## 9. What comes next?

The standard normalization sequence often ends at 5NF for introductory DBMS courses. Some advanced treatments discuss **Sixth Normal Form (6NF)**, mainly for specialized temporal and irreducible relations.
