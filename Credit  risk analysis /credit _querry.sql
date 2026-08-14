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
/*SELECT
loan_grade,
AVG(Case When loan_percent_income > 0.4 THEN loan_int_rate
        END) AS dti_high,
        AVG(Case WHEN loan_percent_income <= 0.4 Then loan_int_rate
        End) As dti_normal 

From credit_risk
GROUP BY loan_grade
ORDER BY dti_high,
        dti_normal;*/

/*Q3. Home Ownership Vs Default*/

/*SELECT
person_home_ownership,
Count(*) As total_loans,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent

From credit_risk
GROUP BY person_home_ownership
ORDER BY Def_percent DESC;*/

/*Q4. Credit History Bucket Wise Risk*/

/*SELECT
Case
When cb_person_cred_hist_length <=2 Then '0-2 yrs'
When cb_person_cred_hist_length <=5 Then '3-5 yrs'
When cb_person_cred_hist_length <=10 Then '6-10 yrs'
Else '10+ yrs'
End As Hist_Bucket,
Count(*) As total_loans,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent
From credit_risk
GROUP BY Hist_Bucket
ORDER BY Def_percent DESC;*/

/*Q5 — Loan intent-wise portfolio concentration:*/

SELECT
loan_intent,
Count(*) As total_loans,
Round(Sum(loan_amnt):: numeric / Sum(Sum(loan_amnt)) OVER()* 100, 1) AS portfolio_share_prt,
Round((Sum(loan_status)::numeric /Count(*))*100,1)  AS Def_percent
From credit_risk
GROUP BY loan_intent
ORDER BY portfolio_share_prt,
        Def_percent Desc;