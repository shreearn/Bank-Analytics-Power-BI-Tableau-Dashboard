# =========================================================================================
# Bank Loan Analytics | 02- KPI Queries
# Run 01_setup_and_import.sql first.
# rates are stored as farctions (0.1459); multiplied by 100 here for display
# ==========================================================================================

USE new_bank_analytics;

# ------------------------------------------------------------------------------------------
# KPI 1: Year-wise loan amount stats
# How much did the bank lend each year, and how fast did grow?
# -------------------------------------------------------------------------------------------
SELECT
    YEAR(issue_d) AS loan_year,
    COUNT(*) AS total_loans,
    SUM(loan_amnt) AS total_loan_amount,
    SUM(funded_amnt) AS total_funded_amount,
    ROUND(AVG(funded_amnt), 2) AS avg_funded_amount,
    MAX(funded_amnt) AS max_funded_amount,
    MIN(funded_amnt) AS min_funded_amount,
    # LAG() looks at the previous row (previous year) -> year-over-year growth
    ROUND(100 * (SUM(funded_amnt) - LAG(SUM(funded_amnt)) OVER (ORDER BY YEAR(issue_d)))
              / LAG(SUM(funded_amnt)) OVER (ORDER BY YEAR(issue_d)), 1) AS funded_growth_pct
FROM loans
GROUP BY YEAR(issue_d)
ORDER BY loan_year;


# ---------------------------------------------------------------------
# KPI 2: Grade and sub-grade wise revolving balance
# How much existing credit-card debt do borrowers in each risk grade carry?
# (revol_bal = borrower's revolving debt elsewhere, not money owed to this bank)
# ---------------------------------------------------------------------
SELECT
    grade,
    sub_grade,
    COUNT(*) AS total_loans,
    SUM(revol_bal) AS total_revol_bal,
    ROUND(AVG(revol_bal), 2) AS avg_revol_bal,
    MAX(revol_bal) AS max_revol_bal,
    MIN(revol_bal) AS min_revol_bal
FROM loans
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

# ---------------------------------------------------------------------
# KPI 3: Total payment by verification status
# Totals alone mostly reflect loan volume, so payment_to_funded_ratio
# makes the groups comparable: money received per $1 lent.
# Note: total_pymnt includes collection recoveries on defaulted loans.
# ---------------------------------------------------------------------
SELECT
    verification_status,
    COUNT(*) AS total_loans,
    SUM(funded_amnt) AS total_funded,
    SUM(total_pymnt) AS total_payment,
    ROUND(SUM(total_pymnt) / SUM(funded_amnt), 3) AS payment_to_funded_ratio
FROM loans
GROUP BY verification_status
ORDER BY total_payment DESC;


# ---------------------------------------------------------------------
# KPI 4: State-wise and last-credit-pull-year-wise loan status
# One row per state and year, with a column per loan status
# (SUM(condition) counts the rows where the condition is true).
# 2 loans have no credit pull date; they appear with credit_pull_year = NULL.
# ---------------------------------------------------------------------
SELECT
    addr_state,
    YEAR(last_credit_pull_d) AS credit_pull_year,
    COUNT(*) AS total_loans,
    SUM(loan_status = 'Fully Paid') AS fully_paid,
    SUM(loan_status = 'Charged Off') AS charged_off,
    SUM(loan_status = 'Current') AS current_loans
FROM loans
GROUP BY addr_state, YEAR(last_credit_pull_d)
ORDER BY addr_state, credit_pull_year;



# ---------------------------------------------------------------------
# KPI 5: Home ownership vs last payment date stats
# How long did borrowers keep paying (issue date -> last payment),
# and how often did each group default?
# Default rate uses completed loans only: Current loans have no outcome yet.
# AVG ignores NULLs, so the 71 never-paid loans are counted separately.
# ---------------------------------------------------------------------
SELECT
    home_ownership,
    COUNT(*) AS total_loans,
    ROUND(AVG(TIMESTAMPDIFF(MONTH, issue_d, last_pymnt_d)), 1) AS avg_months_paying,
    MAX(last_pymnt_d) AS latest_payment_date,
    SUM(last_pymnt_d IS NULL) AS loans_never_paid,
    ROUND(100 * SUM(loan_status = 'Charged Off')
              / SUM(loan_status IN ('Charged Off', 'Fully Paid')), 2) AS default_rate_pct
FROM loans
GROUP BY home_ownership
ORDER BY total_loans DESC;
