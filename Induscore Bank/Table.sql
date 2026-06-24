CREATE TABLE branches (
    branch_id Serial Primary Key,
    branch_name VARCHAR(100),
    city VARCHAR(50),
    zone VARCHAR(20)
    );

CREATE TABLE customers (
    customer_id Serial Primary Key,
    name VARCHAR(100),
    segment VARCHAR(20),
    branch_id INT REFERENCES branches(branch_id),
    join_date DATE
);

CREATE TABLE accounts (
    account_id Serial Primary Key,
    customer_id INT REFERENCES customers(customer_id),
    account_type VARCHAR(20),
    opening_date DATE,
    balance NUMERIC(15,2)
);

CREATE TABLE loan (
account_id Serial Primary Key,
customer_id INT REFERENCES customers(customer_id),
loan_type VARCHAR(30),
amount NUMERIC(15,2),
disbursed_date DATE,
status VARCHAR(20)
);

CREATE TABLE transactions (
    txn_id Serial Primary Key,
    account_id INT REFERENCES accounts(account_id),
    txn_type VARCHAR(10),
    amount NUMERIC(15,2),
    txn_date DATE
);
