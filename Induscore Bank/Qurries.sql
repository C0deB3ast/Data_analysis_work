/*How many customers in every zone*/
/*SELECT
br.zone,
Count(customer_id) as cust_count
From customers cst
INNER JOIN branches br ON cst.branch_id = br.branch_id
GROUP BY
br.zone
ORDER BY 
cust_count DESC*/

/*What is total loan amount of every Segment(Retail,SME, etc.)*/
/*SELECT
cust.segment,
Sum(ln.amount) as total_loan
From customers cust
Left join loan ln on cust.customer_id = ln.customer_id
GROUP BY
cust.segment
ORDER BY
total_loan DESC;*/

/*Find the customers who's loan amount is higher than overall average loan amount*/
/*SELECT
cst.name,
cst.segment,
ln.amount
From customers cst 
Left join loan ln on cst.customer_id = ln.customer_id
Where amount > (SELECT
Avg(amount) as Avg_loan
From loan)*/

/*What is the total transaction amount of each branch then find only those branch whoes total transactions is higher than 5 lakh.*/
/*WITH more_5lk AS(
Select
br.branch_name,
Sum(trn.amount) AS total_amount 
From transactions trn
Left join Accounts acc ON trn.account_id = acc.account_id
LEFT JOIN customers cst ON acc.customer_id = cst.customer_id
LEFT JOIN branches br ON cst.branch_id = br.branch_id
WHERE trn.amount IS NOT NULL
GROUP BY 
br.branch_name
)

SELECT *
From more_5lk
WHERE total_amount > 500000 */

/*Get total transaction amount of each branch and Rank them basis of Highest transaction*/ 
/*WITH branch_transc AS (
    SELECT
        br.branch_name,
        SUM(trn.amount) AS total_amount
    FROM transactions trn
    LEFT JOIN accounts acc ON trn.account_id = acc.account_id
    LEFT JOIN customers cst ON acc.customer_id = cst.customer_id
    LEFT JOIN branches br ON cst.branch_id = br.branch_id
    WHERE trn.amount IS NOT NULL
    GROUP BY br.branch_name
)
SELECT
    branch_name,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS branch_rank
FROM branch_transc
ORDER BY branch_rank;*/

/*Get total transaction amount of FY (2022,23,24) And Find how much change come in trasaction from Prev FY*/
/*WITH fy_transac AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM txn_date) >= 4
            THEN EXTRACT(YEAR FROM txn_date) + 1
            ELSE EXTRACT(YEAR FROM txn_date)
        END AS fiscal_year,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY fiscal_year
)
SELECT
    fiscal_year,
    total_amount,
    LAG(total_amount) OVER (ORDER BY fiscal_year) AS prev_yr_fy,
    total_amount - LAG(total_amount) OVER (ORDER BY fiscal_year) AS yoy_tranx_change
FROM fy_transac
ORDER BY fiscal_year;*/

/*Find the customers who hold multiple accounts in the same branch shows customers pairs*/
/*SELECT
    cst.name,
    br.branch_name,
    act1.account_id AS account_1,
    act1.account_type AS type_1,
    act2.account_id AS account_2,
    act2.account_type AS type_2
FROM accounts act1
JOIN accounts act2 ON act1.customer_id = act2.customer_id
    AND act1.account_id < act2.account_id
JOIN customers cst ON act1.customer_id = cst.customer_id
JOIN branches br ON cst.branch_id = br.branch_id;*/

/*Shows every branch's total Credit and debit amount in two diff columns*/
/*SELECT
    br.branch_name,
    SUM(CASE WHEN trn.txn_type = 'Credit' THEN trn.amount ELSE 0 END) AS total_credit,
    SUM(CASE WHEN trn.txn_type = 'Debit' THEN trn.amount ELSE 0 END) AS total_debit
FROM transactions trn
LEFT JOIN accounts acc ON trn.account_id = acc.account_id
LEFT JOIN customers cst ON acc.customer_id = cst.customer_id
LEFT JOIN branches br ON cst.branch_id = br.branch_id
GROUP BY br.branch_name
ORDER BY total_credit, total_debit;*/

/*Rank every customer on the basis of loan amount by all 3 methods of RANK */
/*SELECT
    name,
    amount,
    ROW_NUMBER() OVER (ORDER BY amount DESC) AS row_num,
    RANK() OVER (ORDER BY amount DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_rank_val
FROM (VALUES
    ('Ravi Iyer', 800000),
    ('Vikram Singh', 800000),
    ('Suresh Patel', 700000)
) AS t(name, amount)
ORDER BY amount DESC;*/

/*Find FY wise total transaction and also find its running total (Cumalative sum across Years)*/
/*WITH fy_transac AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM txn_date) >= 4
            THEN EXTRACT(YEAR FROM txn_date) + 1
            ELSE EXTRACT(YEAR FROM txn_date)
        END AS fiscal_year,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY fiscal_year
)
SELECT
    fiscal_year,
    total_amount,
    SUM(total_amount) OVER (ORDER BY fiscal_year) AS cumulative_total
FROM fy_transac
ORDER BY fiscal_year;*/

/*Shows total amount of every FY with also next FY amount*/
/*WITH fy_transac AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM txn_date) >= 4
            THEN EXTRACT(YEAR FROM txn_date) + 1
            ELSE EXTRACT(YEAR FROM txn_date)
        END AS fiscal_year,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY fiscal_year
)
SELECT
    fiscal_year,
    total_amount,
    LEAD(total_amount) OVER (ORDER BY fiscal_year) AS next_fy_total
FROM fy_transac
ORDER BY fiscal_year;*/

/*Correlated subquery:- Shows loan amount of every customers with that also shows that his loan amount is more or less than his branch's Average loan amount*/
/*WITH Avg_loan_amnt AS (
    SELECT
        cst.name AS customer_name,
        ln.amount AS loan_amount,
        (SELECT AVG(ln2.amount)
         FROM loan ln2
         JOIN customers cst2 ON ln2.customer_id = cst2.customer_id
         WHERE cst2.branch_id = cst.branch_id) AS branch_avg_ln_amount
    FROM customers cst
    JOIN loan ln ON cst.customer_id = ln.customer_id
)
SELECT
    customer_name,
    loan_amount,
    branch_avg_ln_amount,
    CASE
        WHEN loan_amount > branch_avg_ln_amount THEN 'More than the branch average'
        ELSE 'Less than or equal to branch average'
    END AS comparison
FROM Avg_loan_amnt;*/

