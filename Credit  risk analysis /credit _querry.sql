/*Default rate by loan grade*/
/*
SELECT
loan_grade,
Count(*) As total_loans,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent

From credit_risk
GROUP BY loan_grade
ORDER BY Def_percent DESC;
*/
           


/*High risk borrowers*/

/*SELECT
Count(*) As total_high_risk_borrowers,
Round(Avg(loan_int_rate):: numeric, 2) AS avg_loan_int_rate
From credit_risk
WHERE loan_percent_income > 0.4 */

