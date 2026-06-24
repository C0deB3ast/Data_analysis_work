-- Branches
INSERT INTO branches (branch_name, city, zone) VALUES
('Connaught Place', 'Delhi', 'North'),
('Bandra West', 'Mumbai', 'West'),
('Koramangala', 'Banglore', 'South'),
('Salt Lake', 'Kolkata', 'East'),
('Jubilee Hills', 'Hyderabad', 'South');

-- Customers
INSERT INTO customers (name, segment, branch_id, join_date) VALUES
('Arjun Mehta', 'Corporate', 1, '2021-03-15'),
('Priya Sharma', 'Retail', 1, '2020-07-22'),
('Ravi Iyer', 'SME', 3, '2021-11-01'),
('Neha Gupta', 'Retail', 2, '2022-01-10'),
('Suresh Patel', 'Corporate', 2, '2020-05-18'),
('Ananya Roy', 'Retail', 4, '2022-06-30'),
('Vikram Singh', 'SME', 1, '2021-08-14'),
('Meera Nair', 'Corporate', 3, '2020-12-01'),
('Deepak Joshi', 'Retail', 5, '2023-02-20'),
('Kavita Reddy', 'SME', 5, '2021-04-05'),
('Amit Bose', 'Corporate', 4, '2022-09-17'),
('Sunita Kulkarni', 'Retail', 3, '2020-03-11'),
('Rahul Verma', 'SME', 2, '2023-05-25'),
('Pooja Chatterjee', 'Retail', 4, '2021-10-08'),
('Karan Malhotra', 'Corporate', 1, '2022-12-01'),
('Divya Menon', 'Retail', 3, '2020-08-19'),
('Nikhil Agarwal', 'SME', 5, '2021-06-30'),
('Shreya Das', 'Retail', 2, '2023-01-14'),
('Tarun Saxena', 'Corporate', 4, '2022-11-22'),
('Lalita Pillai', 'Retail', 5, '2022-04-03'); 

-- Accounts

INSERT INTO accounts (customer_id, account_type, opening_date, balance) VALUES
(1, 'Current', '2021-03-15', 850000.00),
(2, 'Savings', '2020-07-22', 42000.50),
(3, 'Current', '2021-11-01', 175000.00),
(4, 'Savings', '2022-01-10', 28000.75),
(5, 'Current', '2020-05-18', 620000.00),
(6, 'Savings', '2022-06-30', 15000.00),
(7, 'Current', '2021-08-14', 230000.00),
(8, 'FD', '2020-12-01', 1500000.00),
(9, 'Savings', '2023-02-20', 9500.00),
(10, 'Current', '2021-04-05', 310000.00),
(11, 'FD', '2022-09-17', 2000000.00),
(12, 'Savings', '2020-03-11', 55000.25),
(13, 'Current', '2023-05-25', 88000.00),
(14, 'Savings', '2021-10-08', 32000.00),
(15, 'Current', '2022-12-01', 540000.00),
(16, 'Savings', '2020-08-19', 71000.00),
(17, 'Current', '2021-06-30', 195000.00),
(18, 'Savings', '2023-01-14', 12000.00),
(19, 'FD', '2020-11-22', 3000000.00),
(20, 'Savings', '2022-04-03', 24000.00),
-- Self-join ke liye: kuch customers ke 2 accounts
(1, 'Savings', '2022-05-10', 120000.00),
(5, 'FD', '2021-09-01', 500000.00),
(8, 'Current', '2022-03-15', 280000.00),
(12, 'FD', '2021-07-20', 800000.00);

--Loans
INSERT INTO loan (customer_id, loan_type, amount, disbursed_date, status) VALUES
(1, 'Business', 5000000.00, '2021-04-01', 'Active'),
(2, 'Personal', 150000.00, '2021-01-15', 'Closed'),
(3, 'Business', 800000.00, '2022-02-10', 'NPA'),
(4, 'Home', 2500000.00, '2022-03-01', 'Active'),
(5, 'Business', 10000000.00, '2020-06-01', 'Active'),
(6, 'Personal', 80000.00, '2022-08-15', 'Closed'),
(7, 'Auto', 450000.00, '2021-09-20', 'Active'),
(8, 'Home', 8000000.00, '2021-01-10', 'Active'),
(9, 'Personal', 50000.00, '2023-03-01', 'Active'),
(10, 'Business', 1200000.00, '2021-05-15', 'NPA'),
(11, 'Home', 15000000.00, '2022-10-01', 'Active'),
(12, 'Personal', 200000.00, '2020-04-20', 'Closed'),
(13, 'Auto', 600000.00, '2023-06-10', 'Active'),
(14, 'Home', 3500000.00, '2021-11-05', 'Active'),
(15, 'Business', 7000000.00, '2023-01-15', 'Active'),
(16, 'Personal', 120000.00, '2020-09-10', 'Closed'),
(17, 'Auto', 350000.00, '2021-07-22', 'NPA'),
(18, 'Personal', 75000.00, '2023-02-01', 'Active'),
(19, 'Business', 20000000.00, '2021-01-05', 'Active'),
(20, 'Home', 1800000.00, '2022-05-20', 'Active');

--Transactions (FY2022-2024, spread across accounts)
INSERT INTO transactions (account_id, txn_type, amount, txn_date) VALUES
-- FY2022
(1, 'Credit', 200000.00, '2022-04-10'),
(1, 'Debit', 50000.00, '2022-05-15'),
(2, 'Credit', 15000.00, '2022-04-22'),
(3, 'Credit', 80000.00, '2022-06-01'),
(3, 'Debit', 30000.00, '2022-07-10'),
(5, 'Credit', 500000.00, '2022-04-05'),
(5, 'Debit', 120000.00, '2022-08-20'),
(7, 'Credit', 90000.00, '2022-05-30'),
(8, 'Credit', 300000.00, '2022-09-15'),
(10, 'Debit', 60000.00, '2022-06-25'),
(12, 'Credit', 25000.00, '2022-07-18'),
(14, 'Credit', 18000.00, '2022-10-05'),
(15, 'Credit', 250000.00, '2022-11-12'),
(16, 'Debit', 35000.00, '2022-08-30'),
(19, 'Credit', 800000.00, '2022-12-01'),
-- FY2023
(1, 'Credit', 350000.00, '2023-04-08'),
(1, 'Debit', 80000.00, '2023-06-14'),
(2, 'Credit', 20000.00, '2023-05-19'),
(4, 'Credit', 12000.00, '2023-04-25'),
(5, 'Credit', 650000.00, '2023-07-03'),
(5, 'Debit', 200000.00, '2023-09-22'),
(6, 'Credit', 8000.00, '2023-05-11'),
(9, 'Credit', 5000.00, '2023-04-01'),
(10, 'Credit', 95000.00, '2023-08-17'),
(11, 'Credit', 500000.00, '2023-06-30'),
(13, 'Credit', 40000.00, '2023-07-25'),
(15, 'Credit', 300000.00, '2023-10-10'),
(17, 'Debit', 45000.00, '2023-08-05'),
(18, 'Credit', 10000.00, '2023-03-15'),
(19, 'Credit', 1000000.00, '2023-11-20'),
-- FY2024
(1, 'Credit', 420000.00, '2024-04-12'),
(1, 'Debit', 100000.00, '2024-07-08'),
(3, 'Credit', 110000.00, '2024-05-20'),
(4, 'Debit', 8000.00, '2024-04-30'),
(5, 'Credit', 750000.00, '2024-06-15'),
(7, 'Credit', 120000.00, '2024-05-05'),
(8, 'Credit', 400000.00, '2024-08-22'),
(11, 'Credit', 700000.00, '2024-07-14'),
(12, 'Credit', 30000.00, '2024-04-18'),
(14, 'Debit', 22000.00, '2024-06-28'),
(15, 'Credit', 380000.00, '2024-09-05'),
(16, 'Credit', 45000.00, '2024-05-25'),
(19, 'Credit', 1200000.00, '2024-10-10'),
(20, 'Credit', 15000.00, '2024-04-07'),
(21, 'Credit', 50000.00, '2024-08-30');


SELECT *
From branches;

TRUNCATE TABLE branches RESTART IDENTITY CASCADE;