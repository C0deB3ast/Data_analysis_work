## Q1: Default Rate by Loan Grade

**Query logic:** Grouped by loan_grade, calculated default % as (SUM(loan_status)/COUNT(*))*100

**Findings:**
| Grade | Total Loans | Default % |
|-------|------------|-----------|
| A |       10,777      10.0% |
| B |       10,451      16.3% |
| C |       6,458       20.7% |
| D |       3,626       59.0% |
| E |       964         64.4% |
| F |       241         70.5% |
| G |       64          98.4% |

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

## Q3: Home Ownership vs Default

**Query logic:** Grouped by person_home_ownership, calculated default % per category.

**Findings:**
| Ownership | Total Loans | Default % |
|-----------|------------|-----------|
| RENT | 16,446 | 31.6% |
| OTHER | 107 | 30.8% |
| MORTGAGE | 13,444 | 12.6% |
| OWN | 2,584 | 7.5% |

**Insight:** Home ownership status is a strong, low-cost risk signal. Renters 
default at ~4x the rate of outright owners (31.6% vs 7.5%) and represent the 
largest portfolio segment. Mortgage-holders default less than renters despite 
also carrying debt — likely because mortgage approval itself acts as a prior 
credit-worthiness filter.

## Q4: Credit History Length vs Default

**Findings:**
| Bucket | Total Loans | Default % |
|--------|------------|-----------|
| 0-2 yrs | 5,965 | 23.6% |
| 3-5 yrs | 13,749 | 22.1% |
| 6-10 yrs | 9,405 | 20.6% |
| 10+ yrs | 3,462 | 21.0% |

**Insight:** Default rate broadly decreases with longer credit history but is 
NOT strictly monotonic — ticks back up slightly at 10+ yrs. Loan volume peaks 
in the 3-5 yr bucket (bell-curve shape), not a linear increase — reflecting 
the natural age/tenure distribution of the loan-seeking population. Compared 
to loan_grade and home_ownership (which show clean monotonic risk gradients), 
credit history length is a weaker, noisier risk signal on its own.

## Q5: Loan Intent-Wise Portfolio Concentration & Risk

**Findings:**
| Intent | Total Loans | Portfolio Share % | Default % |
|--------|------------|-------------------|-----------|
| DEBTCONSOLIDATION | 5,212 | 16.0% | 28.6% |
| MEDICAL | 6,071 | 18.0% | 26.7% |
| HOMEIMPROVEMENT | 3,605 | 12.0% | 26.1% |
| EDUCATION | 6,453 | 19.6% | 17.2% |
| PERSONAL | 5,521 | 16.9% | 19.9% |
| VENTURE | 5,719 | 17.5% | 14.8% |

**Insight:** "Distress-driven" loan purposes (debt consolidation, medical, home 
improvement) show meaningfully higher default rates (26-29%) than "growth-driven" 
purposes (venture, education: 15-17%). This likely reflects borrower financial 
state at time of application rather than the loan purpose itself. VENTURE's low 
default despite being a "riskier" category on paper may reflect stricter 
underwriting/collateral requirements for business loans. loan_intent is a 
usable risk signal not currently reflected in loan_int_rate (which tracks only 
loan_grade — see Q2b).

## Q6: Rank Borrowers by Loan Amount within Grade

**Query logic:** RANK()/DENSE_RANK()/ROW_NUMBER() with PARTITION BY loan_grade, 
ORDER BY loan_amnt DESC — ranks each borrower's loan size within their own grade.

**Findings:** Within Grade A, many borrowers share the exact same maximum 
loan_amnt (35,000), causing large tie clusters at rank 1 under RANK().

**Insight:** 
- The repeated max value across many borrowers suggests a policy-driven loan 
  amount ceiling (per-grade or portfolio-wide cap) rather than organic variation.
- This ranking is the basis for concentration-risk monitoring — identifying 
  the largest exposures within each risk grade (e.g., "top 10 largest loans 
  per grade") tells the bank not just how many borrowers might default, but 
  how much ₹ exposure is concentrated in its largest accounts.
- RANK() vs DENSE_RANK() vs ROW_NUMBER() behave differently on ties: RANK 
  skips subsequent ranks after a tie, DENSE_RANK doesn't skip, ROW_NUMBER 
  always assigns unique sequential numbers regardless of ties. ROW_NUMBER is 
  more useful here for cleanly extracting "top N per grade" without tie inflation.

##  Q6b max amount of every loan grade
अगर ceiling grade-specific होती (जैसे A को ज़्यादा मिलता, G को कम), तो वो एक risk-based lending limit होता — logical, क्योंकि safe borrower को ज़्यादा भरोसा। पर यहाँ सबको same flat cap मिल रहा है, चाहे risk कुछ भी हो — ये दिखाता है कि ये शायद:

एक product-level constraint है (जैसे ये एक specific "small-ticket personal loan" product है, जिसकी design ही 35,000 max की है — bank का कोई अलग बड़ा-ticket product अलग होगा)
या एक regulatory/operational limit (unsecured lending पर एक ceiling, risk grade से independent)

## Q7: Grades with Above-Average Default Rate

**Query logic:** Subquery computing overall portfolio avg default rate, 
outer query using HAVING to filter grades exceeding it.

**Findings:** Grades D, E, F, G all exceed the portfolio average (~21.8%):
D: 59.0%, E: 64.4%, F: 70.5%, G: 98.4%

**Insight:** There's a sharp "risk cliff" between C (20.7%) and D (59.0%) — 
nearly a 3x jump — rather than a smooth gradient. This suggests the bank's 
risk tiers aren't evenly spaced in terms of actual outcome risk; D-G should 
likely be treated as a distinct high-risk tier requiring stricter underwriting, 
not just "slightly worse" than A-C.

## Q8: Running Total of Loan Amount by Grade

**Query logic:** CTE for grade-wise totals, then SUM() OVER (ORDER BY loan_grade) 
for cumulative running total.

**Findings:**
| Grade | Grade Total (₹) | Running Total (₹) |
|-------|-----------------|--------------------|
| A | 92,027,750 | 92,027,750 |
| B | 104,462,800 | 196,490,550 |
| C | 59,503,125 | 255,993,675 |
| D | 39,339,350 | 295,333,025 |
| E | 12,450,875 | 307,783,900 |
| F | 3,546,875 | 311,330,775 |
| G | 1,100,525 | 312,431,300 |

**Insight:** A+B grades alone account for ~63% of total portfolio value, while 
D-G (the high-default-rate grades from Q7) together make up only ~18%. This 
confirms that high default RATE in D-G doesn't translate to proportional 
₹ exposure — the bank's actual financial risk is more contained than the raw 
default percentages alone would suggest. Count-based and value-based risk 
views tell different stories and both are needed for a full picture.