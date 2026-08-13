## Q1: Default Rate by Loan Grade

**Query logic:** Grouped by loan_grade, calculated default % as (SUM(loan_status)/COUNT(*))*100

**Findings:**
| Grade | Total Loans | Default % |
|-------|------------|-----------|
| A |       10,777         10.0% |
| B |       10,451         16.3% |
| C |       6,458          20.7% |
| D |       3,626          59.0% |
| E |       964            64.4% |
| F |       241            70.5% |
| G |       64             98.4% |

**Insights:**
- Loan grade is a strong predictor of default — near-linear increase in default rate from A (10%) to G (98.4%).
- Inverse relationship between volume and risk: safer grades (A/B) make up the bulk of the portfolio (~65%), while riskier grades (D-G) are deliberately kept low-volume — consistent with conservative underwriting.
- Low-volume, high-risk grades (D-G) may still contribute disproportionately to total NPA value despite small loan counts — worth checking ₹ amount, not just count, in a follow-up query.

---

## Q2: High-Risk Borrowers (DTI > 40%)

**Query logic:** Filtered loan_percent_income > 0.4, calculated count and average interest rate; compared against portfolio-wide average.

**Findings:**
- High-DTI borrowers: 1,120 (~3.4% of total portfolio)
- Avg interest rate (high-DTI group): 11.66%
- Avg interest rate (overall portfolio): 11.01%
- Gap: only 0.65 percentage points

**Insights:**
- Bank keeps high-DTI lending to a small share of the portfolio (~3.4%), suggesting disciplined income-based underwriting limits.
- The interest rate premium for high-DTI borrowers is unexpectedly small (0.65 pts) — if pricing were properly risk-adjusted for DTI, the gap should be much larger.
- This suggests loan_int_rate may be driven primarily by loan_grade rather than loan_percent_income — DTI risk may not be fully priced in independently. Worth testing by comparing high-DTI vs normal-DTI rates *within* the same grade.

## Q2b: DTI Premium Within Grade

**Query logic:** Conditional aggregation (CASE WHEN) comparing avg interest rate 
for high-DTI (>40%) vs normal-DTI (<=40%) borrowers, within each loan_grade.

**Findings:** Across grades B-G, high-DTI borrowers receive interest rates roughly 
equal to or even slightly LOWER than normal-DTI borrowers in the same grade.

**Insight:** loan_int_rate is driven almost entirely by loan_grade, not by 
loan_percent_income (DTI) independently. The earlier observed 0.65pt gap 
(Q2) was likely a grade-composition effect, not a genuine DTI risk premium — 
i.e., high-DTI borrowers happen to skew toward riskier grades, but DTI itself 
isn't separately priced in. This is a potential underpriced-risk gap in the 
bank's pricing model.