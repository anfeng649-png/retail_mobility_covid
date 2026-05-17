

* ==========================================
* Research question：

* Did COVID-19 have heterogeneous effects on Australian retail sales across categories of different necessity levels, and did these effects differ between the shock and recovery phases?
* ==========================================


* ── Data Setup ──────────────────────────────
* Import ABS retail turnover data (seasonally adjusted, monthly)
import excel "/Users/liang/Desktop/2026/interview/retail_abs.xlsx", ///
    sheet("Data1") cellrange(A11:V529) clear

* Rename key variables
rename (A I K L) (date food clothing deptstore)
describe date food clothing deptstore

* ── Sample Restriction ───────────────────────────────
* Keep 2015 onwards to focus on the pre/post-COVID period
keep if date >= td(01jan2015)
summarize food clothing deptstore
* 126 monthly observations from January 2015 to June 2025.
* Food dominates in scale (mean ~12,128) with moderate variation (SD ~1,683).
* Clothing shows the highest relative volatility (SD/mean ~20%).
* Department store is the smallest category (mean ~1,670) with low absolute variation.

* ── Time series setup ────────────────────────────────
gen mdate = mofd(date)
format mdate %tm
tsset mdate

* ── Visualise levels ─────────────────────────────────
tsline food clothing deptstore
* Food shows a brief spike in early 2020 (panic buying), then continues its upward trend.
* Clothing dropped sharply during COVID but rebounded strongly, possibly reflecting pent-up demand.
* Department store sales fell the most and recovered the slowest, remaining the weakest series throughout.
* This suggests COVID had heterogeneous effects across retail categories -- the key question for the regression.

* ── Growth Rates ─────────────────────────────────────
* Calculate month-on-month percentage growth rates
gen food_growth2     = (food     - L.food)     / L.food     * 100
gen clothing_growth2 = (clothing - L.clothing) / L.clothing * 100
gen dept_growth2     = (deptstore - L.deptstore) / L.deptstore * 100

summarize food_growth2 clothing_growth2 dept_growth2
* All three series average modest monthly growth (~0.4% for food and dept, ~1.2% for clothing).
* Clothing is by far the most volatile (SD ~13.8, min -52.9%, max +129.2%),
* reflecting sharp COVID-driven swings.
* Food is the most stable (SD ~2.8), consistent with its role as a necessity good.
* Department store sits in between (SD ~6.1).

* ── Visualise Growth Rates ───────────────────────────
tsline food_growth2 clothing_growth2 dept_growth2
* Growth rates are stable and close to zero before 2020 across all three categories.
* COVID triggered a sharp spike-and-crash in clothing (down ~53%, then up ~129%),
* dwarfing the movements in food and department store.
* Food growth shows a brief positive spike in early 2020 (panic buying)
* but quickly returned to baseline, confirming its resilience as a necessity good.
* Post-2021, all three series revert to pre-COVID volatility levels,
* suggesting the shock was temporary rather than structural.

* ── COVID Impact: Regression Analysis ───────────────
* Split COVID into two phases to separate shock from rebound
gen covid_shock   = (mdate >= tm(2020m3) & mdate <= tm(2020m9))
gen covid_rebound = (mdate >= tm(2020m10) & mdate <= tm(2021m6))

* Regress each category's growth rate on both COVID phases
reg food_growth2     covid_shock covid_rebound
reg clothing_growth2 covid_shock covid_rebound
reg dept_growth2     covid_shock covid_rebound

* ── Log-Level Regression ─────────────────────────────
* Using log sales levels reduces noise from month-to-month volatility
* and allows coefficients to be interpreted as percentage changes
gen log_food     = log(food)
gen log_clothing = log(clothing)
gen log_dept     = log(deptstore)

* Regress log sales on COVID phases
reg log_food     covid_shock covid_rebound
reg log_clothing covid_shock covid_rebound
reg log_dept     covid_shock covid_rebound

* ── Results & Interpretation ─────────────────────────
* Food: neither covid_shock nor covid_rebound is significant (p>0.1).
* COVID had no statistically detectable effect on food retail sales,
* consistent with food being a necessity good with inelastic demand.

* Clothing: covid_shock coefficient = -0.334 (p<0.001).
* Sales were approximately 33% below the pre-COVID baseline during the shock period.
* covid_rebound is not significant, suggesting sales recovered to normal
* levels but did not overshoot -- no evidence of pent-up demand at the aggregate level.

* Department store: covid_shock coefficient = -0.105 (p=0.009).
* Sales were approximately 10% below baseline during the shock period.
* The effect is significant but substantially smaller than clothing,
* reflecting the more diversified product mix of department stores.

* Key finding: COVID had heterogeneous effects across retail categories.
* The magnitude of the shock is strongly related to how discretionary the category is:
* clothing (-33%) >> department store (-10%) >> food (no effect).
* This is consistent with consumers cutting discretionary spending
* while maintaining expenditure on necessities during the pandemic.





