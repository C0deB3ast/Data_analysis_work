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
SELECT
cst.name,
cst.segment,
ln.amount
From customers cst 
Left join loan ln on cst.customer_id = ln.customer_id
Where amount > (SELECT
Avg(amount) as Avg_loan
From loan)
