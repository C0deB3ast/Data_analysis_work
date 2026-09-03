# Give Me Some Credit — Data Cleaning Notes

**Dataset:** Kaggle "Give Me Some Credit" (`cs-training.csv`)
**Tooling:** Python (pandas) in Google Colab
**Goal:** Practice self-driven data cleaning on a genuinely messy BFSI/credit-risk dataset, then move into SQL-based analysis once cleaned.

---

## 1. Raw Dataset Overview

- 150,000 rows, 11 feature columns + 1 unnamed index column
- Target column: `SeriousDlqin2yrs` (1 = serious delinquency within 2 years)

### Issues identified on first inspection (`df.info()`, `df.describe()`)

| Column | Issue |
|---|---|
| `Unnamed: 0` | No proper name — just a row index |
| `MonthlyIncome` | 29,731 missing values, stored as literal text `"NA"` (not a real NaN) |
| `NumberOfDependents` | 3,924 missing values, same `"NA"` string issue |
| `age` | 1 row with `age = 0` (impossible value) |
| `NumberOfTime30-59DaysPastDueNotWorse`, `NumberOfTimes90DaysLate`, `NumberOfTime60-89DaysPastDueNotWorse` | Suspicious values of 96 and 98 (max should be a small count, not near-100) |
| `RevolvingUtilizationOfUnsecuredLines` | Should be a ratio (~0–1), but max was 50,708 |
| `DebtRatio` | Max value of 329,664 — clearly not a normal ratio |

---

## 2. Cleaning Steps Performed

### 2.1 Load with correct NA handling
```python
df = pd.read_csv('cs-training.csv', na_values=['NA'])
```
Loading with `na_values=['NA']` converts the literal `"NA"` text strings into real `NaN` at load time, so pandas treats `MonthlyIncome` and `NumberOfDependents` as proper numeric columns with real missing values instead of corrupted object columns.

### 2.2 Rename index column
```python
df = df.rename(columns={'Unnamed: 0': 'customer_id'})
```

### 2.3 Missing value imputation

- **`MonthlyIncome` → median**, not mean. The distribution is right-skewed (mean ≈ 6,670 vs median ≈ 5,400) — a few very high earners pull the mean up, so median better represents the "typical" borrower and avoids overstating missing incomes.
- **`NumberOfDependents` → mode**. This is a discrete count variable (0, 1, 2...), so the most frequent value is a more sensible fill than a mean/median that could produce a non-integer.

```python
df['MonthlyIncome'] = df['MonthlyIncome'].fillna(df['MonthlyIncome'].median())
df['NumberOfDependents'] = df['NumberOfDependents'].fillna(df['NumberOfDependents'].mode()[0])
```

### 2.4 Invalid `age = 0`
Only 1 row affected. Chose to **replace with median age** rather than drop the row, since dropping would also discard otherwise-valid data (income, credit history, etc.) in that row for the sake of a single bad field.

```python
df.loc[df['age'] == 0, 'age'] = df['age'].median()
```

### 2.5 Placeholder/sentinel codes (96 / 98) in late-payment columns
Investigation showed all 269 affected rows had **96/98 in all three late-payment columns simultaneously**, with no correlation to age, income, or default status — a strong sign these are system-generated placeholder codes (e.g. "unknown"/"error"), not genuine counts.

Given the affected rows were only ~0.18% of the dataset, decided **dropping was simpler and safer than adding a separate "data error" flag column** — the impact of dropping is negligible, and the extra complexity of a flag column wasn't justified for such a small slice.

```python
df = df[~((df['NumberOfTime30-59DaysPastDueNotWorse'] >= 96) &
          (df['NumberOfTimes90DaysLate'] >= 96) &
          (df['NumberOfTime60-89DaysPastDueNotWorse'] >= 96))]
```
Result: 150,000 → 149,731 rows.

### 2.6 Outlier capping — `RevolvingUtilizationOfUnsecuredLines`
~2.2% of rows (3,321) had values >1, up to 50,708 — too large a slice to simply drop. Applied **99th percentile capping (Winsorization)** to control the extreme tail while preserving all rows.

```python
cap_value = df['RevolvingUtilizationOfUnsecuredLines'].quantile(0.99)
df['RevolvingUtilizationOfUnsecuredLines'] = df['RevolvingUtilizationOfUnsecuredLines'].clip(upper=cap_value)
```
Result: max dropped from 50,708 → ~1.09, mean became a sane ~0.32.

### 2.7 `DebtRatio` — the hardest case: a multi-stage investigation

This column went through several rounds of investigation before the real root cause was found. Documenting the full path here because the *process* is the useful takeaway, not just the final fix.

**Attempt 1 — 99th percentile capping.** Same approach as `RevolvingUtilizationOfUnsecuredLines`. Did **not** work — post-cap mean (317) was still wildly higher than the median (0.37), meaning the extreme tail went deeper than just the top 1%.

**Attempt 2 — 95th percentile capping.** Widened the cap. Still didn't work — mean dropped only to 255, still nowhere close to the median. This was the first strong signal that the problem wasn't "a few extreme outliers" but something structural.

**Investigation A — near-zero income.** Rows with `DebtRatio > 10` mostly had very low or zero genuine `MonthlyIncome` (e.g. income = 0 or 1) — since `DebtRatio` is a debt/income-style ratio, dividing by a near-zero income mathematically inflates the ratio regardless of actual debt level. **Fix:** dropped the ~2,268 rows (~1.5%) with genuine `MonthlyIncome < 100`, since this income level itself is unrealistic/unreliable data:
```python
df = df[df['MonthlyIncome'] >= 100]
```
This explained *some* of the distortion, but after re-running, `DebtRatio`'s max was still 329,664 — so this wasn't the whole story.

**Investigation B — IQR method.** Tried the standard Interquartile Range method (`upper bound = Q3 + 1.5×IQR`) to statistically define outliers. This flagged ~20% of rows as "outliers" — far too large a share to be genuine errors. This showed that `DebtRatio`'s natural distribution is skewed enough that a generic statistical rule misclassifies real data as outliers here; a domain-based threshold was needed instead of a purely statistical one.

**Investigation C — implied debt payment.** Reverse-engineered `DebtRatio × MonthlyIncome` to get an implied monthly debt payment in ₹. For most rows this was sensible (median ≈ ₹2,150), but the max was an impossible ₹1.78 billion — confirming the *majority* of the column was fine, and the problem was concentrated in a specific subset, not the whole column.

**Root cause found — hidden dependency on the earlier income imputation.** Split the data by whether `MonthlyIncome` equalled 5400 (our own imputed median from step 2.3) vs. genuine income values:
- Where income was genuine: `DebtRatio` median ≈ 0.29, max ≈ 170 — completely normal.
- Where income was imputed (= 5400): `DebtRatio` median ≈ **1,141**, max = 329,664 — completely broken.

This revealed that for rows with originally-missing income, `DebtRatio` was likely never a true ratio to begin with (possibly a raw debt figure with no income to divide by at source) — and imputing `MonthlyIncome` afterward made this pre-existing problem look like a fresh outlier issue.

**Final fix:** treated `DebtRatio` as genuinely unreliable (not just "extreme") for every row where income had been imputed, setting it to null and re-imputing with the median of the *genuine* DebtRatio values:
```python
df.loc[df['MonthlyIncome'] == 5400, 'DebtRatio'] = np.nan
df['DebtRatio'] = df['DebtRatio'].fillna(df['DebtRatio'].median())
```

**Lesson learned:** the order and interdependency of cleaning operations matters. Imputing one column (`MonthlyIncome`) before understanding a mathematically-related column (`DebtRatio = debt/income`) created a misleading signal that took several rounds of hypothesis-testing to properly trace back to its source. Generic statistical rules (IQR, fixed percentiles) aren't always the right tool — sometimes the real fix requires understanding *why* a value is wrong, not just *how extreme* it is.

---

## 3. Summary of Row Count Changes

| Step | Rows |
|---|---|
| Original | 150,000 |
| After dropping 96/98 placeholder rows | 149,731 |
| After dropping rows with genuine `MonthlyIncome < 100` | 147,463 |

No further rows were dropped — the `DebtRatio` fix for imputed-income rows was handled via nulling + re-imputation, not row removal.

---

## 4. Key Takeaways (for interview discussion)

1. **Distinguish real outliers from placeholder/sentinel codes** by checking whether extreme values are correlated across related columns (269 rows with 96/98 in *all three* late-payment columns simultaneously — not random noise).
2. **Mean vs. median imputation** depends on skew — used median for `MonthlyIncome` because a right-skewed distribution makes the mean an unreliable "typical" value.
3. **Drop vs. capping vs. flagging** is a judgment call based on what % of data is affected: ~0.18% → simple drop; ~2.2% → capping to preserve rows.
4. **Percentile capping isn't a universal fix** — it worked for `RevolvingUtilizationOfUnsecuredLines` but failed repeatedly for `DebtRatio`, because the real issue wasn't tail-extremity, it was a data-integrity problem in a specific subset of rows.
5. **Generic statistical outlier rules (like IQR) can misfire** on naturally skewed real-world data — it flagged ~20% of `DebtRatio` as outliers, which was clearly wrong once cross-checked against the implied debt payment.
6. **Cleaning operations can have hidden dependencies** — imputing `MonthlyIncome` before understanding that `DebtRatio` was mathematically derived from it caused a confusing, hard-to-trace distortion. The fix required reverse-engineering the relationship (`DebtRatio × MonthlyIncome`) and segmenting data by imputed vs. genuine values to find the true root cause.

---

## 5. Next Steps

- Export cleaned dataset to CSV
- Load into PostgreSQL (Neon DB via Codespaces) for SQL-based analysis, following the same workflow used in the [[credit-risk-analysis]] project
- Later stages: Excel-based validation of key aggregates, Power BI dashboard for presentation
