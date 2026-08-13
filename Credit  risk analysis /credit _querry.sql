/* 1. Default rate by loan grade*/
/*
SELECT
loan_grade,
Count(*) As total_loans,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent

From credit_risk
GROUP BY loan_grade
ORDER BY Def_percent DESC;
*/
           


/*2. High risk borrowers*/

/*SELECT
Count(*) As total_high_risk_borrowers,
Round(Avg(loan_int_rate):: numeric, 2) AS avg_loan_int_rate
From credit_risk
WHERE loan_percent_income > 0.4 */

/*2b . DTI premium within grade */
SELECT
loan_grade,
AVG(Case When loan_percent_income > 0.4 THEN loan_int_rate
        END) AS dti_high,
        AVG(Case WHEN loan_percent_income <= 0.4 Then loan_int_rate
        End) As dti_normal 

From credit_risk
GROUP BY loan_grade
ORDER BY dti_high,
        dti_normal;
