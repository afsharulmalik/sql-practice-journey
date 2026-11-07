CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(250) NOT NULL UNIQUE,
    job_title VARCHAR(50) NOT NULL,
    salary INT NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL
);


INSERT INTO employees
    (first_name, last_name, email, job_title, salary, hire_date)
VALUES
    ('Robert', 'Smith', 'robert.smith@example.com', 'Sales Manager', 75000, '2022-01-10'),
    ('Priya', 'Sharma', 'priya.sharma@example.com', 'Sales Executive', 55000, '2022-03-15'),
    ('Marcus', 'Brown', 'marcus.brown@example.com', 'Support Manager', 65000, '2022-05-20'),
    ('Elena', 'Davis', 'elena.davis@example.com', 'Sales Executive', 52000, '2023-02-01'),
    ('Amit', 'Kumar', 'amit.kumar@example.com', 'Warehouse Manager', 60000, '2023-04-12'),
    ('Sara', 'Wilson', 'sara.wilson@example.com', 'Customer Support', 45000, '2023-06-18'),
    ('John', 'Taylor', 'john.taylor@example.com', 'Product Specialist', 50000, '2023-08-25'),
    ('Neha', 'Gupta', 'neha.gupta@example.com', 'Customer Support', 44000, '2024-01-05');

SELECT * FROM employees;

-- 1. CATEGORIES - product categories, the "parent" side of a one-to-many
-- relationship with products.
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description   TEXT
);

-- 2. PRODUCTS - everything TechBazaar sells. Each belongs to exactly one
-- category (many-to-one via category_id).
CREATE TABLE products (
    product_id     SERIAL PRIMARY KEY,
    category_id    INT NOT NULL REFERENCES categories(category_id),
    product_name   VARCHAR(100) NOT NULL,
    price          NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,   -- FALSE = discontinued, kept for order history
    created_at     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 3. CUSTOMERS - people who buy from TechBazaar. referred_by is a
-- self-referencing FK, same idea as employees.manager_id above.
CREATE TABLE customers (
    customer_id    SERIAL PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    phone          VARCHAR(20),                     -- nullable: not every customer gives a phone number
    city           VARCHAR(50),                     -- nullable, on purpose (NULL-handling examples later)
    country        VARCHAR(50) NOT NULL DEFAULT 'USA',
    signup_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    loyalty_points INT NOT NULL DEFAULT 0,
    referred_by    INT REFERENCES customers(customer_id)
);

-- 4. ORDERS - one row per customer order. employee_id is nullable:
-- customers can check out on the website with no sales rep involved.
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    employee_id   INT REFERENCES employees(employee_id),   -- NULL = self-service web order
    order_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'processing', 'completed', 'cancelled', 'refunded')),
    shipping_city VARCHAR(50),
    notes         TEXT
);

-- 5. ORDER_ITEMS - the line items of an order: which products, how many,
-- and at what price. unit_price is a snapshot of the price AT THE TIME of
-- the order, since a product's catalog price can change afterwards.
-- ON DELETE CASCADE: delete an order, its line items go with it.
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INT NOT NULL REFERENCES products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0)
);

-- 6. PAYMENTS - money actually collected against an order. Not every
-- order has a payment yet (e.g. still 'pending').
CREATE TABLE payments (
    payment_id     SERIAL PRIMARY KEY,
    order_id       INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date   DATE NOT NULL,
    amount         NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20) NOT NULL
                   CHECK (payment_method IN ('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'gift_card', 'upi')),
    status         VARCHAR(20) NOT NULL DEFAULT 'success'
                   CHECK (status IN ('success', 'failed', 'refunded'))
);

-- Relationships at a glance:
--   employees  (many) >─── (1) employees         [self: manager_id - already seeded above]
--   categories (1) ───< (many) products
--   customers  (1) ───< (many) orders
--   employees  (1) ───< (many) orders            [nullable FK: web orders have no rep]
--   orders     (1) ───< (many) order_items
--   products   (1) ───< (many) order_items
--   orders     (1) ───< (many) payments
--   customers  (many) >─── (1) customers         [self: referred_by]
-- order_items is a JUNCTION TABLE between orders and products - it sits
-- between them and carries its own data (quantity, unit_price), which is
-- exactly how a many-to-many relationship is modeled in SQL.


-- ----------------------------------------------------------------------------
-- SEED DATA
-- ----------------------------------------------------------------------------

INSERT INTO categories (category_name, description) VALUES
    ('Electronics',            'Gadgets, computer accessories and audio equipment'),
    ('Home & Kitchen',         'Appliances and tools for cooking and the home'),
    ('Books',                  'Programming, productivity and self-improvement books'),
    ('Clothing',               'Everyday apparel for men and women'),
    ('Sports & Outdoors',      'Fitness, camping and outdoor gear'),
    ('Beauty & Personal Care', 'Skincare, haircare and personal grooming products');

SELECT * FROM categories;

-- 30 products, 5 per category. Notes for later sections:
--   - product 3 (USB-C Hub) has 0 stock
--   - product 20 (Rain Jacket) is_active = FALSE (discontinued, still referenced by history)
--   - product 28 (Hair Dryer) is active but never ordered
INSERT INTO products (category_id, product_name, price, stock_quantity, is_active, created_at) VALUES
    (1, 'Wireless Mouse',                19.99, 120, TRUE,  '2023-01-10'),
    (1, 'Mechanical Keyboard',           79.99,  45, TRUE,  '2023-01-10'),
    (1, 'USB-C Hub',                     34.50,   0, TRUE,  '2023-02-01'),
    (1, '27-inch Monitor',              249.99,  15, TRUE,  '2023-02-15'),
    (1, 'Noise Cancelling Headphones',  129.00,  30, TRUE,  '2023-03-01'),
    (2, 'Stainless Steel Kettle',        39.99,  60, TRUE,  '2023-01-20'),
    (2, 'Non-stick Frying Pan',          24.99,  80, TRUE,  '2023-01-20'),
    (2, 'Air Fryer',                     89.99,  25, TRUE,  '2023-02-10'),
    (2, 'Coffee Maker',                  54.99,  40, TRUE,  '2023-02-10'),
    (2, 'Blender',                       44.50,  35, TRUE,  '2023-03-05'),
    (3, 'Learning SQL',                  42.00, 100, TRUE,  '2023-01-05'),
    (3, 'Clean Code',                    38.50,  70, TRUE,  '2023-01-05'),
    (3, 'The Pragmatic Programmer',      45.00,  55, TRUE,  '2023-01-05'),
    (3, 'Atomic Habits',                 16.99, 150, TRUE,  '2023-01-05'),
    (3, 'Deep Work',                     18.99,  90, TRUE,  '2023-01-05'),
    (4, 'Men''s Cotton T-Shirt',         14.99, 200, TRUE,  '2023-02-01'),
    (4, 'Women''s Denim Jacket',         59.99,  40, TRUE,  '2023-02-01'),
    (4, 'Running Shoes',                 89.00,  60, TRUE,  '2023-02-20'),
    (4, 'Wool Sweater',                  49.99,  35, TRUE,  '2023-03-10'),
    (4, 'Rain Jacket',                   69.99,  20, FALSE, '2023-02-20'),
    (5, 'Yoga Mat',                      22.00, 110, TRUE,  '2023-01-25'),
    (5, 'Dumbbell Set 20kg',             75.00,  25, TRUE,  '2023-01-25'),
    (5, 'Camping Tent 2-Person',        110.00,  18, TRUE,  '2023-03-15'),
    (5, 'Cycling Helmet',                39.99,  50, TRUE,  '2023-03-15'),
    (5, 'Water Bottle 1L',               12.99, 180, TRUE,  '2023-01-25'),
    (6, 'Moisturizing Cream',            18.50,  95, TRUE,  '2023-02-05'),
    (6, 'Electric Toothbrush',           49.99,  40, TRUE,  '2023-02-05'),
    (6, 'Hair Dryer',                    34.99,  30, TRUE,  '2023-02-05'),
    (6, 'Sunscreen SPF50',               15.99, 100, TRUE,  '2023-03-01'),
    (6, 'Perfume 50ml',                  65.00,  25, TRUE,  '2023-03-01');


SELECT * FROM products;

-- 20 customers. Notes for later sections:
--   - phone/city are NULL for several rows on purpose
--   - referred_by chains a few customers back to an earlier customer
--   - customers 19 and 20 have NO orders at all
--   - customer 18 has exactly ONE order, and it's cancelled
INSERT INTO customers (first_name, last_name, email, phone, city, country, signup_date, loyalty_points, referred_by) VALUES
    ('Alice',    'Johnson',  'alice.johnson@email.com',  '212-555-0101', 'New York',      'USA',    '2023-01-15', 320, NULL),
    ('Brian',    'Kim',      'brian.kim@email.com',      NULL,           'Los Angeles',   'USA',    '2023-02-20', 150, 1),
    ('Carla',    'Mendes',   'carla.mendes@email.com',   '305-555-0103', 'Miami',         'USA',    '2023-03-05',  80, NULL),
    ('David',    'Okoro',    'david.okoro@email.com',    '312-555-0104', 'Chicago',       'USA',    '2023-03-22',   0, NULL),
    ('Elena',    'Petrova',  'elena.petrova@email.com',  NULL,           'Seattle',       'USA',    '2023-04-10', 210, 1),
    ('Farid',    'Haidari',  'farid.haidari@email.com',  '206-555-0106', 'Seattle',       'USA',    '2023-04-18',  45, NULL),
    ('Grace',    'Lin',      'grace.lin@email.com',      '415-555-0107', 'San Francisco', 'USA',    '2023-05-02', 500, NULL),
    ('Hassan',   'Ali',      'hassan.ali@email.com',     NULL,           'Houston',       'USA',    '2023-05-29',  60, 3),
    ('Isabella', 'Rossi',    'isabella.rossi@email.com', '617-555-0109', 'Boston',        'USA',    '2023-06-14',   0, NULL),
    ('Jamal',    'Carter',   'jamal.carter@email.com',   '404-555-0110', 'Atlanta',       'USA',    '2023-07-01',  90, NULL),
    ('Kavya',    'Reddy',    'kavya.reddy@email.com',    '512-555-0111', 'Austin',        'USA',    '2023-07-19', 130, 7),
    ('Liam',     'O''Brien', 'liam.obrien@email.com',    NULL,           'Denver',        'USA',    '2023-08-08',  20, NULL),
    ('Mei',      'Tanaka',   'mei.tanaka@email.com',     '602-555-0113', 'Phoenix',       'USA',    '2023-08-27',  75, NULL),
    ('Noah',     'Schmidt',  'noah.schmidt@email.com',   NULL,           NULL,            'USA',    '2023-09-10',   0, NULL),
    ('Olivia',   'Martin',   'olivia.martin@email.com',  '503-555-0115', 'Portland',      'USA',    '2023-09-30', 260, 7),
    ('Paulo',    'Souza',    'paulo.souza@email.com',    NULL,           'Sao Paulo',     'Brazil', '2023-10-12',  15, NULL),
    ('Queenie',  'Wu',       'queenie.wu@email.com',     NULL,           'Toronto',       'Canada', '2023-11-02',  40, NULL),
    ('Ravi',     'Kapoor',   'ravi.kapoor@email.com',    NULL,           'Mumbai',        'India',  '2023-11-25',   0, NULL),
    ('Sofia',    'Nowak',    'sofia.nowak@email.com',    NULL,           NULL,            'Poland', '2023-12-05',   0, NULL),
    ('Tomas',    'Vidal',    'tomas.vidal@email.com',    NULL,           'Madrid',        'Spain',  '2024-01-08',   0, NULL);

SELECT * FROM customers;


SELECT employee_id, first_name, last_name
FROM employees;


-- 45 orders, spread across Jan-Jun 2024. Statuses mixed on purpose:
-- 'pending' orders have no payment yet, 'cancelled' orders never got
-- paid, and customers 19/20 place none at all. employee_id values below
-- (1-4) point at Robert/Priya/Marcus/Elena, seeded back in PART 1.
INSERT INTO orders (customer_id, employee_id, order_date, status, shipping_city) VALUES
    (1,  2,    '2024-01-05', 'completed', 'New York'),
    (3,  NULL, '2024-01-07', 'completed', 'Miami'),
    (5,  4,    '2024-01-10', 'completed', 'Seattle'),
    (7,  NULL, '2024-01-12', 'cancelled', 'San Francisco'),
    (9,  3,    '2024-01-15', 'completed', 'Boston'),
    (2,  2,    '2024-01-18', 'completed', 'Los Angeles'),
    (11, NULL, '2024-01-22', 'completed', 'Austin'),
    (4,  4,    '2024-01-25', 'pending',   'Chicago'),
    (6,  3,    '2024-02-02', 'completed', 'Seattle'),
    (8,  NULL, '2024-02-05', 'completed', 'Houston'),
    (1,  2,    '2024-02-08', 'completed', 'New York'),
    (13, 4,    '2024-02-11', 'completed', 'Phoenix'),
    (10, NULL, '2024-02-14', 'refunded',  'Atlanta'),
    (15, 3,    '2024-02-18', 'completed', 'Portland'),
    (3,  NULL, '2024-02-21', 'completed', 'Miami'),
    (7,  2,    '2024-02-25', 'completed', 'San Francisco'),
    (12, 4,    '2024-03-01', 'completed', 'Denver'),
    (5,  NULL, '2024-03-04', 'completed', 'Seattle'),
    (9,  3,    '2024-03-08', 'cancelled', 'Boston'),
    (2,  2,    '2024-03-12', 'completed', 'Los Angeles'),
    (16, NULL, '2024-03-15', 'completed', 'Sao Paulo'),
    (1,  4,    '2024-03-19', 'completed', 'New York'),
    (14, NULL, '2024-03-23', 'completed', 'Chicago'),
    (11, 3,    '2024-03-27', 'completed', 'Austin'),
    (6,  2,    '2024-04-02', 'completed', 'Seattle'),
    (18, NULL, '2024-04-05', 'cancelled', 'Mumbai'),
    (8,  4,    '2024-04-09', 'completed', 'Houston'),
    (3,  NULL, '2024-04-12', 'completed', 'Miami'),
    (13, 3,    '2024-04-16', 'completed', 'Phoenix'),
    (7,  2,    '2024-04-20', 'completed', 'San Francisco'),
    (15, NULL, '2024-04-24', 'completed', 'Portland'),
    (10, 4,    '2024-04-28', 'completed', 'Atlanta'),
    (1,  2,    '2024-05-02', 'completed', 'New York'),
    (5,  3,    '2024-05-06', 'completed', 'Seattle'),
    (9,  NULL, '2024-05-10', 'completed', 'Boston'),
    (17, 4,    '2024-05-14', 'completed', 'Toronto'),
    (2,  2,    '2024-05-18', 'pending',   'Los Angeles'),
    (12, NULL, '2024-05-22', 'completed', 'Denver'),
    (11, 3,    '2024-05-26', 'completed', 'Austin'),
    (4,  4,    '2024-05-30', 'completed', 'Chicago'),
    (6,  2,    '2024-06-03', 'completed', 'Seattle'),
    (7,  NULL, '2024-06-07', 'completed', 'San Francisco'),
    (1,  3,    '2024-06-11', 'completed', 'New York'),
    (15, 4,    '2024-06-15', 'completed', 'Portland'),
    (9,  2,    '2024-06-20', 'completed', 'Boston');

SELECT * FROM orders;

SELECT order_id, customer_id, status
FROM orders
ORDER BY order_id;

SELECT MIN(order_id) AS first_id,
       MAX(order_id) AS last_id,
       COUNT(*) AS total_orders
FROM orders;

SELECT order_id
FROM orders
ORDER BY order_id;

SELECT order_id, product_id, quantity, unit_price
FROM order_items;

-- Line items for every order above. Order 1's keyboard (74.99, below
-- today's catalog price of 79.99) and order 33's book (39.99, below
-- today's 42.00) are deliberate - proof unit_price is a per-line snapshot,
-- not always trusting products.price.
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1,  1,  1, 19.99), (1,  2,  1, 74.99),
    (2,  11, 2, 42.00), (2,  14, 1, 16.99),
    (3,  5,  1, 129.00),
    (4,  21, 2, 22.00),
    (5,  9,  1, 54.99), (5,  10, 1, 44.50),
    (6,  16, 3, 14.99), (6,  18, 1, 89.00),
    (7,  22, 1, 75.00), (7,  24, 1, 39.99),
    (8,  4,  1, 249.99),
    (9,  6,  1, 39.99), (9,  7,  2, 24.99),
    (10, 26, 2, 18.50), (10, 29, 1, 15.99),
    (11, 2,  1, 79.99), (11, 1,  2, 19.99),
    (12, 13, 1, 45.00), (12, 12, 1, 38.50),
    (13, 27, 1, 49.99),
    (14, 30, 1, 65.00), (14, 6,  1, 39.99),
    (15, 17, 1, 59.99),
    (16, 3,  1, 34.50), (16, 5,  1, 129.00),
    (17, 19, 1, 49.99), (17, 16, 2, 14.99),
    (18, 23, 1, 110.00),
    (19, 25, 4, 12.99),
    (20, 8,  1, 89.99),
    (21, 20, 1, 69.99),
    (22, 11, 1, 42.00), (22, 15, 1, 18.99),
    (23, 9,  1, 54.99),
    (24, 24, 2, 39.99), (24, 21, 1, 22.00),
    (25, 6,  1, 39.99),
    (26, 22, 1, 75.00),
    (27, 10, 1, 44.50), (27, 7,  1, 24.99),
    (28, 29, 3, 15.99),
    (29, 13, 1, 45.00),
    (30, 5,  1, 129.00), (30, 3,  1, 34.50),
    (31, 18, 1, 89.00), (31, 16, 1, 14.99),
    (32, 14, 2, 16.99), (32, 12, 1, 38.50),
    (33, 11, 1, 39.99),
    (34, 2,  1, 79.99),
    (35, 9,  1, 54.99), (35, 10, 1, 44.50),
    (36, 30, 1, 65.00),
    (37, 4,  1, 249.99),
    (38, 23, 1, 110.00),
    (39, 21, 2, 22.00), (39, 25, 2, 12.99),
    (40, 19, 1, 49.99),
    (41, 6,  1, 39.99), (41, 8,  1, 89.99),
    (42, 1,  1, 19.99), (42, 2,  1, 79.99),
    (43, 27, 1, 49.99),
    (44, 17, 1, 59.99), (44, 16, 1, 14.99),
    (45, 30, 1, 65.00), (45, 26, 1, 18.50);


SELECT order_id
FROM orders
ORDER BY order_id;

SELECT v.order_id
FROM generate_series(1, 45) AS v(order_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = v.order_id
);

SELECT v.order_id AS missing_order_id
FROM generate_series(1, 45) AS v(order_id)
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = v.order_id
);

-- Every 'completed'/'refunded' order has one payment; 'pending' (8, 37)
-- and 'cancelled' (4, 19, 26) orders have none - this asymmetry is what
-- makes LEFT JOIN / NOT EXISTS examples meaningful later.
INSERT INTO payments (order_id, payment_date, amount, payment_method, status) VALUES
    (1,  '2024-01-05',  94.98, 'credit_card',   'success'),
    (2,  '2024-01-08', 100.99, 'paypal',        'success'),
    (3,  '2024-01-10', 129.00, 'debit_card',    'success'),
    (5,  '2024-01-16',  99.49, 'gift_card',     'success'),
    (6,  '2024-01-19', 133.97, 'credit_card',   'success'),
    (7,  '2024-01-22', 114.99, 'paypal',        'success'),
    (9,  '2024-02-02',  89.97, 'debit_card',    'success'),
    (10, '2024-02-06',  52.99, 'bank_transfer', 'success'),
    (11, '2024-02-08', 119.97, 'credit_card',   'success'),
    (12, '2024-02-12',  83.50, 'paypal',        'success'),
    (13, '2024-02-16',  49.99, 'credit_card',   'refunded'),
    (14, '2024-02-18', 104.99, 'debit_card',    'success'),
    (15, '2024-02-22', 163.50, 'gift_card',     'success'),
    (16, '2024-02-26',  79.97, 'credit_card',   'success'),
    (17, '2024-03-02', 110.00, 'paypal',        'success'),
    (18, '2024-03-04',  60.99, 'debit_card',    'success'),
    (20, '2024-03-13', 101.98, 'credit_card',   'success'),
    (21, '2024-03-16',  69.99, 'bank_transfer', 'success'),
    (22, '2024-03-19',  60.99, 'paypal',        'success'),
    (23, '2024-03-24',  54.99, 'credit_card',   'success'),
    (24, '2024-03-28', 101.98, 'debit_card',    'success'),
    (25, '2024-04-02',  39.99, 'gift_card',     'success'),
    (27, '2024-04-10',  69.49, 'paypal',        'success'),
    (28, '2024-04-13',  47.97, 'credit_card',   'success'),
    (29, '2024-04-17',  45.00, 'debit_card',    'success'),
    (30, '2024-04-21', 163.50, 'bank_transfer', 'success'),
    (31, '2024-04-25', 103.99, 'credit_card',   'success'),
    (32, '2024-04-29',  72.48, 'paypal',        'success'),
    (33, '2024-05-02',  39.99, 'credit_card',   'success'),
    (34, '2024-05-07',  79.99, 'debit_card',    'success'),
    (35, '2024-05-11',  99.49, 'gift_card',     'success'),
    (36, '2024-05-15',  65.00, 'credit_card',   'success'),
    (38, '2024-05-23', 110.00, 'paypal',        'success'),
    (39, '2024-05-27',  69.98, 'debit_card',    'success'),
    (40, '2024-05-31',  49.99, 'bank_transfer', 'success'),
    (41, '2024-06-04', 129.98, 'credit_card',   'success'),
    (42, '2024-06-08',  99.98, 'paypal',        'success'),
    (43, '2024-06-12',  49.99, 'debit_card',    'success'),
    (44, '2024-06-16',  74.98, 'gift_card',     'success'),
    (45, '2024-06-21',  83.50, 'credit_card',   'success');


-- Sanity check - run this and confirm row counts. Expected: employees 8,
-- categories 6, products 30, customers 20, orders 45, order_items 69,
-- payments 40.

SELECT 'employees'   AS table_name, COUNT(*) AS row_count FROM employees
UNION ALL SELECT 'categories',   COUNT(*) FROM categories
UNION ALL SELECT 'products',     COUNT(*) FROM products
UNION ALL SELECT 'customers',    COUNT(*) FROM customers
UNION ALL SELECT 'orders',       COUNT(*) FROM orders
UNION ALL SELECT 'order_items',  COUNT(*) FROM order_items
UNION ALL SELECT 'payments',     COUNT(*) FROM payments;


--! yhaapar se select query ka kaam ho rha hai
--! Dql (data query language)

SELECT * FROM products;

SELECT product_id, 
       product_name AS p_name,
       stock_quantity
FROM products;

SELECT * FROM customers;

SELECT DISTINCT country FROM customers;

SELECT * FROM products
WHERE price>150;

--! give me products having stocks > 0 and price < 150

SELECT * FROM products
WHERE stock_quantity > 0 AND price>150;

UPDATE products
SET price = price + 100;

SELECT * FROM products
WHERE is_active = FALSE;

--! give me products from electronics as well as books

SELECT * FROM products
WHERE category_id = 1 OR category_id = 3 OR category_id = 4;

-- ye equivalent hai upar wale query ke bss ye optimized hai 

SELECT * FROM products
WHERE category_id IN (1,3,4);


SELECT * FROM products
WHERE category_id IN (1,3,4);

--! give me product having product name starting with "wireless" it can be anything wireless mouse or wireless keyboard

SELECT * FROM products
WHERE product_name LIKE 'Wireless%';

INSERT INTO products
  (product_name, stock_quantity, price, category_id) VALUES (
    'Wireless Keyboard', 78, 149, 1
  ),
  ('Wireless Light',49,120,1),
  ('Wireless headphone',20,599,1)

SELECT * FROM products
WHERE product_name LIKE '%less%';

SELECT * FROM products
WHERE product_name LIKE 'less%';

SELECT * FROM products
WHERE product_name LIKE '%less';

-- give me customers who doesnot have phone number

SELECT * FROM customers;

SELECT * FROM customers
WHERE phone IS NULL;

SELECT * FROM customers
WHERE phone IS NOT NULL;

SELECT 
    first_name,
    last_name,
    COALESCE(phone, 'Not Available') AS phone_num,
    COALESCE(city, 'No input') AS city_name
FROM customers;

--! give me products from cheapest to expensive 

SELECT * FROM products
ORDER BY price ASC; -- ASC: ascending mein karta hai aur DSCE: descending mein karta hai 

SELECT * FROM products
ORDER BY price DESC;

--! Give me products from cheapest to expensive from each category

SELECT * FROM products
ORDER BY category_id, price;

SELECT * FROM products
ORDER BY category_id ASC, price DESC;

--! Give me most expensive products
SELECT * FROM products
ORDER BY price DESC;

--! Give me top 5 most expensive products
SELECT * FROM products
ORDER BY price DESC
LIMIT 5;

--! Pagination

SELECT * FROM products ORDER BY product_id;



--! give me all orders including employee details of the employee who processed that order only include order punched by employee 

--! HOW SQL JOINS ACTUALLY WORKS
SELECT * FROM orders;

SELECT * 
FROM orders AS O
JOIN employees AS e ON e.employee_id = o.employee_id;

SELECT o.status,
    o.order_id,
    e.email,
    e.first_name
FROM orders as O
    INNER JOIN employees AS e ON o.employee_id = e.employee_id;


--! give me all orders and include employee details of employee who processed that order and if it is directly coming from customer keep employee details empty

SELECT o.status,
    o.order_id,
    e.email,
    e.first_name
FROM orders as O
    LEFT JOIN employees AS e ON o.employee_id = e.employee_id; -- left join mein left ke saare aayenge until and unless last wala case acccurate ho 

SELECT o.status,
    o.order_id,
    e.email,
    e.first_name
FROM orders as O
    RIGHT JOIN employees AS e ON o.employee_id = e.employee_id; -- right join mein left ke saare aayenge until and unless last wala case acccurate ho, it favour its own table 

SELECT o.status,
    o.order_id,
    e.email,
    e.first_name
FROM orders as O
    FULL OUTER JOIN employees AS e ON o.employee_id = e.employee_id;

SELECT *
FROM customers
CROSS JOIN categories; -- connecting every col of one table to the each col of another table



--! Give me all customers who didn't place any order

SELECT * 
FROM customers AS c 
JOIN orders AS o.customer_id = c.customer_id;

SELECT 
    c.first_name,
    c.email,
    o.status,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
ON o.customer_id = c.customer_id
WHERE o.status IS NULL;

--! Give me orders which have not been paid

SELECT *
FROM orders AS o 
LEFT JOIN payments AS p ON p.order_id = o.order_id
WHERE p.payment_id is NULL;


--! Give information about all orders that are there in the DB include info about order_items, product, customer and category the product belongs to.
-- jaise koi order place karne wla page hai whaa par ye query hoga taaki kisne order kiya hai kab kiya hai kya naam hai kya order kiya hai sb track kar sake 

SELECT 
    o.order_id,
    o.status,
    oi.product_id,
    oi.unit_price,
    p.product_name,
    c.category_name,
    cu.first_name,
    cu.last_name
FROM orders AS o 
LEFT JOIN order_items as oi ON oi.order_id = o.order_id
LEFT JOIN products as p ON p.product_id = oi.product_id
LEFT JOIN categories as c ON c.category_id = p.category_id
LEFT JOIN customers as cu ON cu.customer_id = o.customer_id;


--! Give me info about employees including their manager's info

SELECT 
    emp.first_name as "Employee First Name",
    emp.last_name as "Employee Last Name",
    manager_tbl.first_name as "Manager First Name",
    manager_tbl.last_name as "Manager Last Name"
FROM employees as emp
LEFT JOIN employees as manager_tbl on emp.manager_id = manager_tbl.employee_id;



--!           AGGREGATE KA CONCEPT

--! cOLLEGE : 5 students
--! 5LPA, 10, 5, 10, 15
--! What is an everage CTC of the college:
--! Total ctc across students / number of students
--! (5 + 10 + 5 + 10 + 15) / 5 
--! 9 lpa -> Average cta of my college
--! total ctc awarded : 45lpa

--! I have 5 entries on student level
--? I reduced those 5 entries in a single college level entry 


--! ques : Give me total count customers on our platform
SELECT * FROM customers;

SELECT 
    COUNT(*) AS cust_count
FROM customers; -- 20

SELECT COUNT(DISTINCT country) from customers;


--! ques : Give me total revenue accross all orders

SELECT SUM(quantity * unit_price) as total_revenue FROM order_items;


--! ques : Give average price of product across all orders

SELECT 
    ROUND(AVG(price),2) as avg_price
FROM products;


--! ques : Give me min price and max price accross all orders

SELECT * FROM products ORDER BY price ASC;

SELECT MIN(price) as min_price, MAX(price) as max_price FROM products;


SELECT
    COUNT(*) AS  total_product,
    ROUND(AVG(price),2) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price,
    SUM(stock_quantity) as total_stock
FROM products;


--! ques : Give me total no of products in each category

SELECT category_id, COUNT(*)
FROM products
GROUP BY category_id;


--! ques : Give me total no of active and inactive products in each category
-- active as well as inactive from each column 

SELECT category_id, is_active, COUNT(*)
FROM products
GROUP BY category_id, is_active;


--! ques : Give me total no of products in each category include category name in the results

SELECT 
    p.category_id, 
    c.category_name,
    COUNT(*)
FROM products as p 
LEFT JOIN categories as c on c.category_id = p.category_id
GROUP BY p.category_id, c.category_name;


--! Give me total no of products in each category and give me categories having > 5 products

SELECT category_id, COUNT(*)
FROM products
GROUP BY category_id
HAVING COUNT(*)>5;

--! ques: Find departments having more than one employee, where their combined salary of whole department exceeds 20000 rupees.

SELECT 
    department_id,
    COUNT(*), 
    SUM(salary) AS total_department_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*)>1;


--! ques : Give me all the customer having atleast one cancelled order

SELECT * FROM orders;
SELECT * FROM customers;

SELECT 
    *
FROM customers as c 
LEFT JOIN orders AS O ON o.customer_id = c.customer_id
WHERE o.status = 'cancelled';
-- subqueries of the same left join wala sql
SELECT * FROM customers
WHERE customer_id IN  (7,9,18);

--? subqueries ka mtlb hai query ke andar query

SELECT customer_id FROM orders WHERE status = 'cancelled';

SELECT * FROM customers
WHERE customer_id IN(
    SELECT customer_id FROM orders WHERE status = 'cancelled'
);


--! ques : Give me all the products which are having price > average price accross all products

-- p1 : 100
-- p2 : 200
-- p3 : 1000
-- p4 : 200
--? average = 1500/4
--! p3, p5 -> returned

SELECT * FROM products;

-- main answer of the above question
SELECT * FROM products
WHERE price > (
    SELECT AVG(price) FROM products
);


SELECT AVG(price) FROM products; -- 211 average price : subqueries hai ye 


--! ques : Give me revenue sales on category level
-- electronics : 3000
-- clothing : 4000
--! give me categories having sales greater than 500

SELECT
    p.category_id,
    SUM(oi.quantity * oi.unit_price) as category_sales
FROM order_items as oi
LEFT JOIN products as p on p.product_id = oi.product_id
GROUP BY p.category_id;       


--! new concept :  Common Table Expressions (CTE)

-- iske baare mein padhna padega aur khud se chatGPT se mostly 




--! Reusability

--! Give me total spend of a customer, also give me average spend of all customers, also give me flag TRUE or FALSE basis of if customer have above everage spending.

WITH customer_total AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS customer_spend
    FROM orders as o
    LEFT JOIN order_items as oi on oi.order_id = o.order_id
    WHERE o.status = 'completed'
    GROUP BY o.customer_id
)
SELECT * FROM customer_total;





--!                                 chatGPT wale questions hai isme 


--! LEFT JOIN

--? Q1. Sabhi customers ke naam aur unke order IDs nikaliye, including those with no orders.
-- naam and order_id chaiye result mein 

SELECT
    c.name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;

--? Q2. Sabhi customers ke naam aur order amounts nikaliye.
--naam and amount chaiye

SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;

--?  Q3. Un customers ko dikhaiye jinka koi order nahi hai.
-- sirf order show karna hai 

SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount IS NULL;

--? Q4. Sabhi customers ke naam aur unke orders nikaliye jahan amount > 400 ho.
-- naam aur amount chaiye

SELECT
    c.name,
    o.amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 400;

--? Q5. Har customer ka naam aur order ID nikaliye, aur output ko customer name ke hisaab se sort karein.
-- sorting ka concept

SELECT
    c.name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY c.name ASC;


--! RIGHT JOIN 

--? Sabhi orders ke order_id aur customer names display kijiye, including those orders jinka customer record nahi hai.
-- order_id aur name

SELECT
    c.name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;

--? Sabhi orders ke order_id aur amount display kijiye, including those orders jinka matching customer nahi hai.
-- order_id aur amount

SELECT
    o.order_id,
    o.amount
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;

--? Un orders ko display kijiye jinka koi matching customer nahi hai.
-- order_id

SELECT
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

--? Sabhi orders ke order_id aur customer names display kijiye, lekin sirf un orders ke liye jinka amount > 400 hai.
-- order_id aur names

SELECT
    c.name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 400;

--? Sabhi orders ke order_id aur customer names display kijiye, aur order_id ko descending order mein sort kijiye.
-- order_id, names sorted on DESC

SELECT
    c.name,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id
ORDER BY o.order_id DESC;



--! FULL OUTER JOIN 

--? 1. Sabhi customers aur unke orders display kijiye. Un customers ko bhi include karna hai jinka order nahi hai, aur un orders ko bhi jinka customer record nahi hai.

SELECT * FROM
    customers AS c
FULL OUTER JOIN orders as o
    ON c.customer_id = o.customer_id;

--? 2. Sabhi customers ke naam aur order IDs display kijiye, including customers without orders and orders without matching customers.

SELECT
    c.name,
    o.order_id
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id;

--? 3. Sirf un customers ko display kijiye jinka koi order nahi hai aur un orders ko jinka matching customer nahi hai.

SELECT
    c.name,
    o.amount
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL 
    OR o.customer_id IS NULL;

--? FULL OUTER JOIN se customers ke naam aur order amounts nikaliye, lekin sirf un rows ko dikhaiye jahan amount > 400 ya customer ka koi order nahi hai.
-- naam aur amount

SELECT
    c.name,
    o.amount
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
    OR o.amount > 400;

--? FULL OUTER JOIN se customer names aur order IDs display kijiye, aur customer name ke ascending order mein sort kijiye.

SELECT
    c.name,
    o.order_id
FROM customers AS c
FULL OUTER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.name ASC;



--! SELF JOIN 

--? 1. Upar diye gaye employees table se employee ka naam aur uske manager ka naam display kijiye. Un employees ko bhi include karna hai jinka manager nahi hai.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id;

--? Sirf un employees ke naam nikaliye jinka manager Rahul hai. Aap apni query mein SELF JOIN use karke try kijiye.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name = 'Rahul';

--? Sirf un employees ke naam aur manager ke naam display kijiye jinka manager nahi hai.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_id IS NULL;

--? Un employees ke naam aur manager ke naam display kijiye jinka manager Rahul nahi hai. Manager na hone wale employees ko bhi output mein include kijiye.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name != 'Rahul'
   OR m.employee_id IS NULL;

--? Ab un employees ke naam display kijiye jinka manager bhi isi company mein employee hai aur manager ka naam Aman hai.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE m.employee_name = 'Aman';

--? Un employees ke naam aur manager ke naam display kijiye jinka manager khud ka manager nahi hai — yaani employee aur manager alag-alag log hain.

SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id
WHERE e.employee_id != m.employee_id;



--! CROSS JOIN

--? 1. students aur courses tables ko CROSS JOIN karke sabhi possible student-course combinations display kijiye.

SELECT
    s.student_name,
    c.course_name
FROM students AS s
CROSS JOIN courses AS c;


--? 2. 



--! MULTIPLE JOINS

--? Ab isi example mein humein customer ka naam aur order ID display karni hai, lekin sirf un customers ke liye jinhone order place kiya hai.

SELECT 
    c.name,
    o.order_id
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id;

--? Ab teeno tables customers, orders aur products ko join karke customer ka naam aur product ka naam display kijiye.

SELECT
    c.name,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products as p
    ON o.product_id = p.product_id;

--? Ab wahi 3 tables join kijiye, lekin output mein ye 3 columns chahiye:
--? customer_name
--? order_id
--? product_name
--? Condition: Sirf us customer ka record dikhaiye jiska naam 'Rahul' hai.

SELECT
    c.name,
    o.order_id,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products as p
    ON o.product_id = p.product_id
WHERE c.name = 'Rahul';

--? Ab teeno tables join karke customer name aur product name display kijiye, aur results ko customer name ke alphabetical order mein sort kijiye.

SELECT
    c.name,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products as p
    ON o.product_id = p.product_id
ORDER BY c.name ASC;

--? Ab teeno tables join karke:
--? customer_name
--? product_name
--? display kijiye, sirf Rahul ke records, aur product name ke alphabetical order mein.

SELECT
    c.name,
    p.product_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products as p
    ON o.product_id = p.product_id
WHERE c.name = 'Rahul'
ORDER BY p.product_name ASC;

--? Ab teeno tables join karke har customer ne kitne orders place kiye hain, woh display kijiye.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

--? Pichhli query mein ek change kijiye: sirf un customers ko display karna hai jinhone 2 ya usse zyada orders kiye hain.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;

--? Ab customers aur orders ko LEFT JOIN karke sabhi customers ke naam aur unke total orders display kijiye. Jin customers ne koi order nahi kiya, unka count 0 aana chahiye.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

--? Ab query likhiye jo har customer ka naam aur total order count display kare, aur customers ko sabse zyada orders se sabse kam orders ke order mein sort kare.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_orders DESC;

--? Ab customers, orders aur products ko join karke har customer ne kitne alag-alag products order kiye hain, woh display kijiye.

SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name;

--? Ab pichhli query mein sabhi customers ko include kijiye, including those who haven't placed any orders. Unke total_products ka count 0 aana chahiye.

SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name;

--? Ab har customer ka naam aur total orders display kijiye, lekin sirf un customers ko dikhaiye jinke total orders 2 ya usse zyada hain, aur sabse zyada orders wale customer ko pehle rakhiye.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2
ORDER BY total_orders DESC;

--? Ab customers, orders aur products ko join karke har product ke naam aur us product ke total orders display kijiye. Sabse zyada order hone wala product pehle aana chahiye.

SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM orders AS o
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;
-- upar wale ka solution hai ye
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;

--? Ab sabhi products, including those with zero orders, display kijiye aur unhe total orders ke descending order mein sort kijiye.

SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;

--? customers, orders aur products ko join karke har customer ka naam aur uske total products ka count dikhaiye. Sirf un customers ko include kijiye jinke products ka count 2 ya usse zyada ho.

SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
HAVING COUNT(p.product_id) >= 2;

--? Isi query mein customer name ke alphabetical order mein results sort kar dijiye.

SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
GROUP BY c.customer_id, c.name
HAVING COUNT(p.product_id) >= 2
ORDER BY c.name ASC;


--? Ab customers, orders aur products ko join karke sirf Rahul ke products aur unka total count display kijiye.

SELECT
    c.name AS customer_name,
    COUNT(p.product_id) AS total_products
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN products AS p
    ON o.product_id = p.product_id
WHERE c.name = 'Rahul'
GROUP BY c.customer_id, c.name;

--? Ab sabhi customers ko include kijiye aur unke total orders count kijiye. Sirf un customers ko dikhaiye jinke total orders 1 ya usse zyada hain.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 1;

--? customers aur orders ko LEFT JOIN karke sirf un customers ko display kijiye jinhone koi order nahi kiya hai.

SELECT
    c.name AS customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

--? Ab Q20: customers aur orders ko JOIN karke har customer ka total order count display kijiye. Un customers ko bhi include karna hai jinhone koi order nahi kiya.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

--? Q21 — JOIN + SUM()
--? Maan lijiye orders table mein ek additional column amount bhi hai.
--? customers aur orders ko LEFT JOIN karke har customer ka total order amount display kijiye. Jin customers ne koi order nahi kiya, unka total amount 0 dikhna chahiye.

-- logic of this question 

-- SUM(o.amount) har customer ke orders ka total amount calculate karta hai.
-- COALESCE(..., 0) NULL ko 0 mein convert karta hai.
-- LEFT JOIN un customers ko bhi include karta hai jinhone koi order nahi kiya.

SELECT
    c.name AS customer_name,
    COALESCE(SUM(o.amount), 0) AS total_amount
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

--? Q22 — JOIN + AVG(): Har customer ka average order amount find karna hai. Sabhi customers ko include kijiye aur jinka koi order nahi hai, unka average 0 dikhaiye.

SELECT
    c.name AS customer_name,
    COALESCE(AVG(o.amount), 0) AS average_total_order
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

--? Q23 — JOIN + WHERE + Aggregation
-- Har customer ke liye sirf ₹1,000 se zyada amount wale orders count kijiye. Sabhi customers ko include karna hai, aur jinke aise orders nahi hain unka count 0 hona chahiye.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
    AND o.amount > 1000
GROUP BY c.customer_id, c.name;

--? customers, orders, aur products tables ko JOIN karke un customers ke naam aur total orders display kijiye jinhone kam se kam 2 orders kiye hain.

SELECT
    c.name AS customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN products AS p
    ON p.product_id = o.product_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;

--? Har product ka naam aur us product ke total orders display kijiye. Jin products ka koi order nahi hai, unhe bhi include karna hai. Results ko highest order count se lowest order count mein sort kijiye.

SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM products AS p
LEFT JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_orders DESC;





--!             SUBQUERIES

--? Average salary se kam salary paane wale employees ki poori details display kijiye.

SELECT *
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);

--? Company ki maximum salary se 10,000 kam salary wale employees find kijiye.

SELECT *
FROM employees
WHERE salary < (
    SELECT MAX(salary) - 10000
    FROM employees
);

--? Un employees ke naam display kijiye jinki salary minimum salary se zyada hai.

SELECT name 
FROM employees
WHERE salary>(
    SELECT 
    MIN(salary)
    FROM employees
);

--? Q4. Un employees ke name aur salary display kijiye jinki salary company ki average salary ke barabar hai.

select name,salary 
from employees
where salary = (
    select avg(salary) from employees 
);

--? Q5. Un employees ke name aur salary display kijiye jinki salary average salary se ₹5,000 zyada hai.

select name, salary from employees
where salary > (
    select avg(salary)+5000 from employees
);
  
--! Multiple Line Subqueries
--? Highest salary wale employee ka name aur salary display kijiye.

SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

--? Un employees ka name aur department_id display kijiye jo IT ya HR department mein hain.

SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR')
);

--?Un employees ko find kijiye jinki salary kisi bhi employee ki minimum salary se zyada hai.

SELECT name
FROM employees
WHERE salary > (
    SELECT MIN(salary)
    FROM employees
);

--? Un employees ko find kijiye jinki salary sabhi IT department employees ki salary se zyada hai

SELECT *
FROM employees
WHERE salary > ALL (
    SELECT e.salary
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);


--? Un employees ke name aur department_id display kijiye jo IT, HR ya Sales department mein hain.

SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE department_name IN ('IT', 'HR', 'Sales')
);

--? Un employees ko find kijiye jo IT department mein nahi hain.

SELECT name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE department_name = 'IT'
);

--? Un employees ka name aur salary display kijiye jinki salary kisi bhi IT employee ki salary se zyada hai.

SELECT e.name, e.salary
FROM employees AS e
WHERE e.salary > ANY (
    SELECT e2.salary
    FROM employees AS e2
    JOIN departments AS d
        ON e2.department_id = d.department_id
    WHERE d.department_name = 'IT'
);

--? Un employees ko find kijiye jinki salary har HR employee ki salary se kam hai.

SELECT name, salary
FROM Employee
WHERE salary < ALL (
    SELECT salary 
    FROM Employee 
    WHERE department = 'HR'
);

--? Un employees ko find kijiye jo kisi bhi employee se zyada salary nahi paate, yani lowest salary wale employee(s).

SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);

--? Q6. Un employees ka name aur salary display kijiye jinki salary HR department ke sabse zyada salary wale employee ke barabar hai.

SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(e.salary)
    FROM employees AS e
    JOIN departments AS d
        ON e.department_id = d.department_id
    WHERE d.department_name = 'HR'
);



--! Correlated Subqueries

--? employees table se un employees ki saari columns select karo jinki salary apne department ki average salary se kam hai.

SELECT *
FROM employees AS e
WHERE e.salary < (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);


--? Un employees ko find kijiye jinki salary apne department mein sabse zyada hai.


SELECT *
FROM employees AS e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);

--? Un employees ko find kijiye jinki salary apne department mein second-highest distinct salary hai.
-- Use Method 1 (Correlated Subquery) if you want clean, easy-to-read logic that adapts easily if you ever want to change it to the 3rd or 4th highest salary (just change 1 = to 2 = or 3 =).

SELECT *
FROM employees AS e
WHERE 1 = (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > e.salary
);
-- another solution
SELECT 
    e.employee_id,
    e.employee_name,
    e.department,
    e.salary
FROM 
    Employees e
WHERE 
    e.salary = (
        SELECT MAX(e2.salary)
        FROM Employees e2
        WHERE e2.department = e.department
          AND e2.salary < (
              SELECT MAX(e3.salary)
              FROM Employees e3
              WHERE e3.department = e.department
          )
    );

--? Un departments ke employees find kijiye jahan koi bhi employee ₹30,000 se kam salary nahi kamata.

SELECT * 
FROM Employees 
WHERE department IN (
    SELECT department 
    FROM Employees 
    GROUP BY department 
    HAVING MIN(salary) >= 30000
);
-- another approach best one 
SELECT e1.*
FROM Employees e1
WHERE NOT EXISTS (
    SELECT 1 
    FROM Employees e2 
    WHERE e2.department = e1.department 
      AND e2.salary < 30000
);

--? Un employees ko find karo jinki salary apne department ke average salary se zyada hai, aur jinke department mein kam se kam 3 employees hain.

SELECT *
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
)
AND (
    SELECT COUNT(*)
    FROM employees AS e3
    WHERE e3.department_id = e.department_id
) >= 3;

--! DAY 05

--? Un employees ko find karo jinki salary department 101 ke har employee ki salary se zyada hai.

SELECT *
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);

--? Un employees ko find kijiye jinki salary department 101 ke kam se kam ek employee ki salary se zyada hai.

SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);

--? Un employees ko find kijiye jo un departments mein kaam karte hain jahan kam se kam ek employee ki salary ₹70,000 se zyada hai.

SELECT *
FROM employees
WHERE department IN (
    SELECT distinct department
    FROM employees
    WHERE salary > 70000
);

--? Un employees ko find kijiye jinke department mein kam se kam ek employee ki salary ₹80,000 se zyada hai.

SELECT *
FROM employees AS e
WHERE EXISTS (
    SELECT 1
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > 80000
);

--? Un employees ko find kijiye jo department 101 mein kaam nahi karte.

SELECT *
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM employees
    WHERE department_id = 101
);

--? Un employees ko find karo jinki salary department 101 ke kisi bhi employee ki salary se kam hai.

SELECT *
FROM employees
WHERE salary < ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);


--? Un employees ko find karo jinki salary department 101 ke kam se kam ek employee ki salary se kam hai.

SELECT *
FROM employees
WHERE salary < ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 101
);

--? Un employees ko find kijiye jinki salary ₹50,000 se zyada hai aur jinke department ki average salary bhi ₹40,000 se zyada hai.

SELECT *
FROM employees AS e
WHERE e.salary > 50000
  AND EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.department_id = e.department_id
      HAVING AVG(e2.salary) > 40000
  );

--? Un employees ko find kijiye jinki salary ₹40,000 se zyada hai aur jinke department mein ₹30,000 se kam salary wala koi employee nahi hai.

SELECT *
FROM employees AS e
WHERE e.salary > 40000
  AND NOT EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.department_id = e.department_id
        AND e2.salary < 30000
  );

--? Aise employees find karo jinki salary apne department ki average salary se zyada hai.

SELECT *
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e2.department_id = e.department_id
);

--? Aise employees find karo jinki salary apne department ki maximum salary ke equal hai.

SELECT * 
FROM employees AS e 
WHERE e.salary = (
    SELECT MAX(e2.salary) -- 👈 यहाँ 'salary max' की जगह 'SELECT MAX' आएगा
    FROM employees AS e2 
    WHERE e2.department_id = e.department_id
);

--? Aise employees find kijiye:
-- - Jinki salary ₹40,000 se zyada hai.
-- - Jo apne department ki average salary se bhi zyada earn karte hain.
-- - EXISTS aur AVG() dono use karne hain.
-- - Subquery ko outer employee ke department se correlate karna hai.

SELECT *
FROM employees AS e
WHERE e.salary > 40000
  AND EXISTS (
      SELECT 1
      FROM employees AS e2
      WHERE e2.department_id = e.department_id
      HAVING e.salary > AVG(e2.salary)
  );



--!         CTE ka full form Common Table Expression hai
-- Ye ek temporary named result set hota hai, jise hum ek SQL statement ke andar WITH keyword se define karte hain.

--? Aapko CTE ka use karke un employees ko find karna hai jinki salary ₹50,000 se zyada hai.

WITH high_salary AS (
    SELECT *
    FROM employees
    WHERE salary > 50000
)
SELECT *
FROM high_salary;

--? CTE ka use karke un employees ko find karo jinki salary ₹40,000 se zyada hai, aur final result ko salary ke descending order mein display karo — highest salary pehle.

WITH eligible_employees AS (
    SELECT *
    FROM employees
    WHERE salary > 40000
    ORDER BY salary DESC
)
SELECT *
FROM eligible_employees;
-- another approach
WITH eligible_employees AS (
    SELECT *
    FROM employees
    WHERE salary > 40000
)
SELECT *
FROM eligible_employees
ORDER BY salary DESC;

--? Aise employees ke department ki average salary calculate karo jinki salary ₹30,000 se zyada hai.

WITH department_salary AS (
    SELECT department_id, ROUND(AVG(salary), 2) AS average_salary
    FROM employees
    WHERE salary > 30000
    GROUP BY department_id
)
SELECT *
FROM department_salary;

--? Un departments ko find karo jinki average salary ₹50,000 se zyada hai

WITH high_avg_departments AS (
    SELECT
        department_id,
        ROUND(AVG(salary), 2) AS average_salary
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > 50000
)
SELECT *
FROM high_avg_departments;

--? Do CTEs use karke un employees ko find karo jinki salary apne department ki average salary se zyada hai.

WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
),
above_avg_employees AS (
    SELECT
        e.*
    FROM employees AS e
    JOIN department_avg AS d
        ON e.department_id = d.department_id
    WHERE e.salary > d.avg_salary
)
SELECT *
FROM above_avg_employees;

--? Ek CTE department_max banaiye jo har department ki maximum salary calculate kare. Phir us CTE ko employees table ke saath JOIN karke un employees ko find kijiye jinki salary apne department ki maximum salary ke equal hai.

WITH department_max AS (
    SELECT
        department_id,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
),
equal_max_employees AS (
    SELECT e.*
    FROM employees AS e
    JOIN department_max AS dm
        ON e.department_id = dm.department_id
    WHERE e.salary = dm.max_salary
)
SELECT *
FROM equal_max_employees;

--? Un departments ke employees find karo jahan kam se kam 3 employees hain.

WITH department_counts AS (
    SELECT department_id, COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) >= 3
)
SELECT e.*
FROM employees AS e
JOIN department_counts AS dc
    ON e.department_id = dc.department_id;

--? Un departments ko find kijiye jinki average salary ₹40,000 se zyada hai, aur un departments ke saare employees display kijiye.

WITH high_avg_departments AS (
    SELECT
        department_id,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > 40000
)
SELECT e.*
FROM employees AS e
JOIN high_avg_departments AS had
    ON e.department_id = had.department_id;

--? Har department ka employee count nikalo aur saare departments display karo, including those departments jahan koi employee nahi hai.

WITH department_counts AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(dc.total_employees, 0) AS total_employees
FROM departments AS d
LEFT JOIN department_counts AS dc
    ON d.department_id = dc.department_id;

--? Har department ka naam aur uski average salary display karo. Saare departments result mein hone chahiye, chahe unmein koi employee na ho.

WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(da.avg_salary, 0) AS avg_salary
FROM departments AS d
LEFT JOIN department_avg AS da
    ON d.department_id = da.department_id;

--? Un employees ko display karo jo apne department ki average salary se zyada earn karte hain.

WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.*
FROM employees AS e
INNER JOIN department_avg AS da
    ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary;

--? Un departments ke employees find karo jahan employee count 3 ya usse zyada hai, aur un employees ki salary ₹40,000 se zyada hai.

WITH department_counts AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) >= 3
),
eligible_departments AS (
    SELECT e.*
    FROM employees AS e
    JOIN department_counts AS dc
        ON e.department_id = dc.department_id
    WHERE e.salary > 40000
)
SELECT *
FROM eligible_departments;

--? Aise employees display karo jinki salary ₹50,000 se zyada hai, aur unki salary category bhi dikhao.
-- CTE ka naam salary_categories rakho.
-- CTE ke andar employee ki details aur CASE expression use karo.
-- Salary ₹80,000 ya zyada ho toh 'High'.
-- Salary ₹50,000 se zyada lekin ₹80,000 se kam ho toh 'Medium'.
-- Final query mein saare columns aur salary category show karo

SELECT 
    e.*
    CASE 
        WHEN salary > 80000 THEN 'High'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Medium'
        ELSE 'Above Average'
    END AS salary_category
FROM employees as e
WHERE salary > 50000
ORDER BY salary DESC;
-- with cte
WITH salary_categories AS (
    SELECT
        e.*,
        CASE
            WHEN salary >= 80000 THEN 'High'
            WHEN salary > 50000 THEN 'Medium'
            ELSE 'Above Average'
        END AS salary_category
    FROM employees AS e
    WHERE salary > 50000
)
SELECT *
FROM salary_categories
ORDER BY salary DESC;

--?CTE ka use karke har department ko category do:
--  Average salary ₹60,000 ya zyada → 'High Paying'
--  Average salary ₹40,000 ya zyada, lekin ₹60,000 se kam → 'Medium Paying'
--  Average salary ₹40,000 se kam → 'Low Paying'

WITH department_salary_stats AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary,
        CASE
            WHEN AVG(salary) >= 60000 THEN 'High Paying'
            WHEN AVG(salary) >= 40000 THEN 'Medium Paying'
            ELSE 'Low Paying'
        END AS department_salary
    FROM employees
    GROUP BY department_id
)
SELECT *
FROM department_salary_stats
ORDER BY avg_salary DESC;

--? CTE ka naam department_stats rakhiye aur har department ke liye:
-- - department_name
-- - Total employees (total_employees)
-- - Average salary (avg_salary)
-- Display kijiye, un departments ko bhi include karna hai jinmein koi employee nahi hai. Aise departments ke liye employee count 0 dikhna chahiye.

WITH department_stats AS (
    SELECT
        department_id,
        COUNT(*) AS total_employees,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    COALESCE(ds.total_employees, 0) AS total_employees,
    COALESCE(ds.avg_salary, 0) AS avg_salary
FROM departments AS d
LEFT JOIN department_stats AS ds
    ON d.department_id = ds.department_id;

--? CTE ka use karke un employees ko display kijiye jinki salary apne department ki average salary se zyada hai aur salary ₹40,000 se bhi zyada hai.

WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.*
FROM employees AS e
INNER JOIN department_avg AS da
    ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary
  AND e.salary > 40000;

--? Har department mein sabse zyada salary paane wale employee(s) display kijiye.
-- Requirements:
-- - CTE ka naam department_max rakhein.
-- - department_id aur MAX(salary) calculate karein.
-- - Main query mein employees ke saath JOIN karein.
-- - Employee ki details display karein.

WITH department_max AS (
    SELECT
        department_id,
        MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.*
FROM employees AS e
INNER JOIN department_max AS dm
    ON e.department_id = dm.department_id
WHERE e.salary = dm.max_salary;

--!           WINDOW FUNCTIONS

--? employees table se har employee ka naam, salary aur poori company ki average salary display karni hai.

SELECT
    employee_name,
    salary,
    AVG(salary) OVER() AS company_avg_salary
FROM employees;

--? Ab har employee ke saath uske department ki average salary display kijiye.

SELECT
    employee_name,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg_salary
FROM employees;

--? Ab har employee ke saath uske department ki total salary display kijiye.

SELECT *,
       SUM(salary) OVER (
           PARTITION BY department_id
       ) AS department_total_salary
FROM employees;

--? Har employee ke liye employee ID ke order mein salary ka cumulative total calculate kijiye.

SELECT *,
       SUM(salary) OVER (
           ORDER BY employee_id
       ) AS running_total
FROM employees;

--? Har employee ko salary ke basis par highest se lowest order mein unique row number dena hai.

SELECT *,
       ROW_NUMBER() OVER (
           ORDER BY salary DESC
       ) AS row_num
FROM employees;

--? Har department ke employees ko salary ke descending order mein row number dijiye. Har department mein numbering 1 se dobara start honi chahiye.

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY department_id
           ORDER BY salary DESC
       ) AS row_num
FROM employees;

--? Ab employees ko salary ke descending order mein rank dijiye.

SELECT *,
       RANK() OVER (
           ORDER BY salary DESC
       ) AS salary_rank
FROM employees;

--? Ab employees ko salary ke descending order mein rank dijiye.

SELECT *,
       DENSE_RANK() OVER (
           ORDER BY salary DESC
       ) AS salary_rank
FROM employees;

--? Har department ke sabse zyada salary paane wale employee ko identify kijiye.

WITH employee_ranks AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC
           ) AS salary_rank
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE salary_rank = 1;

--? Har department mein employees ko salary ke descending order mein rank dijiye aur sirf top 3 distinct salary levels wale employees display kijiye.

WITH employee_ranks AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC
           ) AS salary_rank
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE salary_rank <= 3;

--? Har employee ki salary ke saath employee ID ke order mein previous employee ki salary display kijiye.

SELECT *,
       LAG(salary) OVER (
           ORDER BY employee_id
       ) AS previous_salary
FROM employees;

--? Ab har employee ki salary ke saath next employee ki salary display kijiye, employee ID ke ascending order mein.

SELECT *,
       LEAD(salary) OVER (
           ORDER BY employee_id
       ) AS next_salary
FROM employees;

--? Har employee ke liye uski current salary aur previous employee ki salary ke beech ka difference nikaliye.

SELECT
    employee_id,
    employee_name,
    salary,
    LAG(salary) OVER (
        ORDER BY employee_id
    ) AS previous_salary,
    salary - LAG(salary) OVER (
        ORDER BY employee_id
    ) AS salary_difference
FROM employees;

--? Har employee ki salary aur uske department ki average salary ke beech difference nikaliye.
-- Required columns: employee_name, salary, department_id, department_avg_salary, salary_difference.
-- Ab aap query likhiye.

SELECT
    employee_name,
    salary,
    department_id,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg_salary,
    salary - AVG(salary) OVER (
        PARTITION BY department_id
    ) AS salary_difference
FROM employees;

--?  Employees ko salary ke descending order mein rank karna hai aur dono functions ka result compare karna hai.

SELECT 
    emp_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS rank_result,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_result
FROM employees;
-- another solution
SELECT
    employee_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;

--? Har department ke 2 highest-paid employees nikalne hain using ROW_NUMBER().

WITH employee_ranks AS (
    SELECT
        employee_name,
        salary,
        department_id,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)
SELECT *
FROM employee_ranks
WHERE row_num <= 2;

--? DENSE_RANK() use karke company ki third-highest distinct salary nikaliye.

WITH employee_ranks AS (
    SELECT
        emp_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS dense_rank_result
    FROM employees
)
SELECT
    emp_name,
    salary,
    dense_rank_result
FROM employee_ranks
WHERE dense_rank_result = 3;

--? Har employee ke liye employee_id ascending order mein running average salary calculate kijiye.

SELECT 
    employee_id,
    emp_name,
    salary,
    AVG(salary) OVER (ORDER BY employee_id ASC) AS running_avg_salary
FROM employees;

--? Sirf un employees ko find kijiye jinki salary previous employee se zyada hai.

WITH SalaryComparison AS (
    SELECT 
        employee_id,
        emp_name,
        salary,
        -- LAG() pichle employee ki salary nikalega (employee_id ke order me)
        LAG(salary) OVER (ORDER BY employee_id ASC) AS previous_employee_salary
    FROM employees
)
SELECT 
    employee_id,
    emp_name,
    salary,
    previous_employee_salary
FROM SalaryComparison
WHERE salary > previous_employee_salary;

--? Har employee ki current salary aur next employee ki salary ka difference nikaliye. 

SELECT 
    employee_id,
    emp_name,
    salary AS current_salary,
    -- LEAD() agle employee ki salary nikalega
    LEAD(salary) OVER (ORDER BY employee_id ASC) AS next_employee_salary,
    -- Current aur next salary ka difference
    (salary - LEAD(salary) OVER (ORDER BY employee_id ASC)) AS salary_difference
FROM employees;

--? Har department mein employees ko salary ke descending order mein DENSE_RANK() dijiye.

SELECT 
    dept_id,
    emp_name,
    salary,
    DENSE_RANK() OVER (
        PARTITION BY dept_id 
        ORDER BY salary DESC
    ) AS dept_salary_rank
FROM employees;

--? Har department ke top 3 distinct salary levels wale employees find kijiye.

WITH RankedDepartmentSalaries AS (
    SELECT 
        dept_id,
        emp_name,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id 
            ORDER BY salary DESC
        ) AS dept_salary_rank
    FROM employees
)
SELECT 
    dept_id,
    emp_name,
    salary,
    dept_salary_rank
FROM RankedDepartmentSalaries
WHERE dept_salary_rank <= 3
ORDER BY dept_id, dept_salary_rank;

--? Har department mein employee_id ascending order ke according cumulative salary calculate kijiye.

SELECT 
    dept_id,
    employee_id,
    emp_name,
    salary,
    -- Har department me employee_id ke according salary judti jayegi
    SUM(salary) OVER (
        PARTITION BY dept_id 
        ORDER BY employee_id ASC
    ) AS cumulative_salary
FROM employees;

--? Har department ka highest-paid employee find kijiye. Agar highest salary par multiple employees tie karte hain, toh sabhi ko result mein dikhana hai.
-- interview challenge 

WITH DepartmentSalaries AS (
    SELECT 
        dept_id,
        employee_id,
        emp_name,
        salary,
        -- Har department me salary ke descending order me rank de rahe hain
        DENSE_RANK() OVER (
            PARTITION BY dept_id 
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT 
    dept_id,
    employee_id,
    emp_name,
    salary
FROM DepartmentSalaries
WHERE salary_rank = 1
ORDER BY dept_id;



--!   UNION AND UNION ALL 

--? ho gya github par hai sab kuch 




--! EXCEPT & INTERSECT

--? github par hai 

-- bahut kuch chal rha hai jo bss github par hai toh notes ke liye toh tum udhar hi jao and achee se padho aur revise karo sb kuch 




--! CASE EXPRESSION

-- --? employees table mein salary ke basis par status nikalna hai.
-- - Salary 50,000 ya usse zyada hai → 'Eligible'
-- - Salary 50,000 se kam hai → 'Not Eligible'

SELECT *,
       CASE
           WHEN salary >= 50000 THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS eligible_salary
FROM employees;

--? Ab employees ki salary ke basis par category banaiye:
-- - Salary >= 70000 → 'High'
-- - Salary >= 40000 aur 70000 se kam → 'Medium'
-- - Salary < 40000 → 'Low'

SELECT *,
       CASE
           WHEN salary >= 70000 THEN 'High'
           WHEN salary BETWEEN 40000 AND 69999 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;

--? Ab CASE ke through employees ka bonus calculate kijiye:
-- - Salary >= 80000 → bonus '20%'
-- - Salary >= 50000 → bonus '10%'
-- - Salary < 50000 → bonus '5%'

select *, 
    case
        when salary >= 80000 then 'bonus 20%'
        when salary >= 50000 then 'bonus 10%'   
        else 'bonus 5%'
    end as bonus_percentage
from employees;

--? Employees ko classify kijiye:
-- - Salary >= 50000 AND experience >= 3 → 'Senior'
-- - Salary >= 50000 AND experience < 3 → 'Junior'
-- - Baaki sab → 'Entry Level'

select *,
    case
        when salary >= 50000 and experience >= 3 then 'senior'
        when salary >= 50000 and experience < 3 then 'junior'
        else 'entry level'
    end as employee_level
from employees;

-- ye koi aur question hai 

SELECT *,
       CASE department_id
           WHEN 1 THEN 'IT'
           WHEN 2 THEN 'HR'
           WHEN 3 THEN 'Finance'
           ELSE 'Other'
       END AS department_name
FROM employees;



--!                             CONSTRAINT 



--? Aapko students naam ki table banani hai, jismein:
-- - student_id — integer aur Primary Key
-- - student_name — maximum 50 characters aur NOT NULL
-- - email — maximum 100 characters aur UNIQUE
-- - age — integer aur CHECK condition: age 18 ya usse zyada honi chahiye
-- Aap khud CREATE TABLE query likhkar bhejiye. Main check karke bataungi ki sahi hai ya nahi.

CREATE TABLE student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT CONSTRAINT check_age CHECK (age >= 18)
);

--? Ab products naam ki table banaiye, jismein:
-- 1. product_id — INT, Primary Key
-- 2. product_name — VARCHAR(100), NOT NULL
-- 3. price — NUMERIC(10,2), CHECK condition: price zero se zyada hona chahiye
-- 4. quantity — INT, default value 0


CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) CONSTRAINT check_price CHECK (price > 0),
    quantity INT DEFAULT 0
);

--? UNIQUE aur NOT NULL
-- users naam ki table banaiye:
-- 1. user_id — INT PRIMARY KEY
-- 2. username — VARCHAR(50) NOT NULL UNIQUE
-- 3. phone — VARCHAR(15) UNIQUE
-- 4. age — INT CHECK (age >= 18)

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    age INT CONSTRAINT check_age CHECK (age >= 18)
);

--? FOREIGN KEY
-- Ab do tables banaiye:
-- departments
-- - department_id — INT PRIMARY KEY
-- - department_name — VARCHAR(50) NOT NULL UNIQUE
-- employees
-- - employee_id — INT PRIMARY KEY
-- - employee_name — VARCHAR(50) NOT NULL
-- - department_id — INT, jo departments(department_id) ko reference kare.
-- Dono CREATE TABLE queries likhkar bhejiye. FOREIGN KEY ka syntax practice karna hai.

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    department_id INT,
    CONSTRAINT fk_employee_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
);

--? FOREIGN KEY + NOT NULL
-- Ab orders table banaiye:
-- - order_id — INT PRIMARY KEY
-- - order_amount — NUMERIC(10,2) aur CHECK (order_amount > 0)
-- - customer_id — INT NOT NULL, jo customers(customer_id) ko reference kare
-- - Foreign key ka naam fk_orders_customer rakhiye.

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_amount NUMERIC(10,2)
        CONSTRAINT check_order_amount CHECK (order_amount > 0),
    customer_id INT NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

--? DEFAULT + CHECK
-- inventory naam ki table banaiye:
-- - product_id — INT PRIMARY KEY
-- - product_name — VARCHAR(100) NOT NULL
-- - quantity — INT DEFAULT 0 aur quantity negative nahi honi chahiye
-- - price — NUMERIC(10,2) NOT NULL

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 0
        CONSTRAINT check_quantity CHECK (quantity >= 0),
    price NUMERIC(10,2) NOT NULL
);

--? Constraints ko modify karna
-- Maan lijiye inventory table already create ho chuki hai. Ab aapko:
-- 1. price par constraint lagana hai ki price 0 se zyada ho.
-- 2. product_name par UNIQUE constraint lagana hai.
-- 3. quantity ka existing CHECK constraint check_quantity remove karna hai.

ALTER TABLE inventory
ADD CONSTRAINT check_price CHECK (price > 0);

ALTER TABLE inventory
ADD CONSTRAINT unique_product_name UNIQUE (product_name);

ALTER TABLE inventory
DROP CONSTRAINT check_quantity;

--? Constraint remove karna
-- Aapki users table mein ye constraint laga hua hai:
-- CONSTRAINT check_age CHECK (age >= 18)

ALTER TABLE users
DROP CONSTRAINT check_age;

--? NOT NULL remove karna
-- employees table ke employee_name column par NOT NULL constraint laga hua hai.
-- Question: PostgreSQL mein employee_name ko NULL values accept karne dene ke liye kaunsi ALTER TABLE query likhenge?

ALTER TABLE employees
ALTER COLUMN employee_name DROP NOT NULL;

--? NOT NULL add karna
-- Ab employees table ke employee_name column par dobara NOT NULL constraint lagaiye.

ALTER TABLE employees 
ALTER COLUMN employee_name SET NOT NULL;

--? DEFAULT modify karna
-- inventory table mein quantity column ka default value abhi 0 hai. Aapko ise 10 karna hai.

ALTER TABLE inventory
ALTER COLUMN quantity SET DEFAULT 10;

--? DEFAULT remove karna
-- Ab inventory table ke quantity column se DEFAULT 10 remove kijiye, taaki future inserts mein default value automatically set na ho.

ALTER TABLE inventory
ALTER COLUMN quantity DROP DEFAULT;

--? UNIQUE constraint remove karna
-- users table mein username column par UNIQUE constraint laga hai, jiska naam users_username_key hai.
-- Question: Is constraint ko remove karne ke liye PostgreSQL query likhiye.

-- alter table users alter table username add constraint users_username_key unique (username);
ALTER TABLE users
DROP CONSTRAINT users_username_key;

--? CHECK constraint add karna
-- products table ke price column par constraint lagaiye ki price ₹100 ya usse zyada honi chahiye.
-- Constraint ka naam check_min_price rakhiye.

ALTER TABLE products
ADD CONSTRAINT check_min_price
CHECK (price >= 100);

--? UNIQUE constraint add karna
-- employees table mein email column par UNIQUE constraint add kijiye. Constraint ka naam unique_employee_email rakhiye.

ALTER TABLE employees
ADD CONSTRAINT unique_employee_email UNIQUE (email);

--? products table mein price column par laga hua check_min_price constraint remove kijiye.

ALTER TABLE products
DROP CONSTRAINT check_min_price;

--? employees table mein department_id column par FOREIGN KEY constraint add kijiye, jo departments table ke department_id ko reference kare. Constraint ka naam fk_employee_department rakhiye.

ALTER TABLE employees
ADD CONSTRAINT fk_employee_department
FOREIGN KEY (department_id)
REFERENCES departments(department_id);

--? employees table mein fk_employee_department naam ka foreign key constraint remove kijiye.

ALTER TABLE employees
DROP CONSTRAINT fk_employee_department;

--? employees table mein employee_id column ko PRIMARY KEY banaiye. Constraint ka naam pk_employee_id rakhiye.

ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);

--? employees table mein employee_id ko PRIMARY KEY banane ke baad, us primary key constraint ko remove kijiye. Constraint ka naam pk_employee_id hai.

ALTER TABLE employees
DROP CONSTRAINT pk_employee_id;

--? products table mein quantity column par CHECK constraint add kijiye, jiska naam check_product_quantity ho. Condition: quantity 0 ya usse zyada honi chahiye.

ALTER TABLE products
ADD CONSTRAINT check_product_quantity CHECK (quantity >= 0);

--? users table mein phone column par laga UNIQUE constraint remove kijiye. Constraint ka naam users_phone_key hai.

ALTER TABLE users
DROP CONSTRAINT users_phone_key;

--? employees table mein employee_name column par NOT NULL constraint dobara apply kijiye.

ALTER TABLE employees
ALTER COLUMN employee_name SET NOT NULL;

--? inventory table mein quantity column ka default value 10 se change karke 5 kar dijiye.

ALTER TABLE inventory
ALTER COLUMN quantity SET DEFAULT 5;

--? products table mein product_name column ko NOT NULL banaiye.

ALTER TABLE products
ALTER COLUMN product_name SET NOT NULL;





--!                         SQL Function

--? maximum number

CREATE OR REPLACE FUNCTION maximum_number(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT GREATEST(a, b);
$$;

--? minimum number

CREATE OR REPLACE FUNCTION minimum_number(
    a NUMERIC,
    b NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT LEAST(a, b);
$$;

--? percentage

CREATE OR REPLACE FUNCTION calculate_percentage(
    marks NUMERIC,
    total_marks NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT (marks * 100.0) / total_marks;
$$;

--? Ek function grade_student(marks NUMERIC) banaiye, jo ye grades return kare:
-- - Marks >= 90 → A
-- - Marks >= 75 → B
-- - Marks >= 40 → C
-- - Marks < 40 → Fail

CREATE OR REPLACE FUNCTION grade_student(marks NUMERIC)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    IF marks >= 90 THEN
        RETURN 'A';
    ELSIF marks >= 75 THEN
        RETURN 'B';
    ELSIF marks >= 40 THEN
        RETURN 'C';
    ELSE
        RETURN 'Fail';
    END IF;
END;
$$;

--? Functions ki practice
Malik ji, ab ek function banaiye discount_price(price NUMERIC, discount_percent NUMERIC), jo discount apply karne ke baad final price return kare.

Formula: Final Price={Price}\times\frac{100-\text{Discount}}{100}
Example: discount_price(1000, 20) ka output 800 hona chahiye.

CREATE OR REPLACE FUNCTION discount_price(
    price NUMERIC, 
    discount_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN price * (100 - discount_percent) / 100;
END;
$$ LANGUAGE plpgsql;

--? 

















































--! ALL THE BEST SHERRRRRRRRRRRR 






















