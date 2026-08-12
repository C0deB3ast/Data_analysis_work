SELECT
loan_grade,
Count(*) As total_loans,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent

From credit_risk
GROUP BY loan_grade
ORDER BY Def_percent DESC;
