# Bank Loan Analytics: Credit Risk & Portfolio Performance

An end-to-end analytics workflow on a 39,717-loan consumer lending portfolio, from raw, inconsistent source files to validated SQL KPIs and dashboards in Power BI, Tableau and Excel.

![Python Pandas](https://img.shields.io/badge/Python-Pandas-blue)
![MySQL KPI Analysis](https://img.shields.io/badge/MySQL-KPI%20Analysis-4479A1)
![PPower BI Dashboard](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811)
![Tableau Dashboard](https://img.shields.io/badge/Tableau-Dashboard-E97627)
![Excel Power Query](https://img.shields.io/badge/Excel-Power%20Query-217346)

Project internship with AI Variant (Sep–Dec 2023), completed as part of the ExcelR Data Analyst certification program, using a historical consumer loan dataset (2007–2011).

# Business Questions

• How has lending volume grown over time?

• How does default risk change across credit grades?

• Which borrower segments (home ownership, verification status, state) carry the most risk?

• How much has the portfolio actually returned against what was lent?

# Key Insights
	
💰 $434.8M funded across 39,717 loans (2007–2011)	| 📈 Lending grew from $2.2M (2007) → $256M (2011)

⚠️ Default rate on completed loans: 14.59%	| 📊 Default risk rises from 6% (Grade A) → 34% (Grade G)

🏠 Renters default more often (15.4%) than mortgage holders (13.7%)	| 💳 Riskier grades carry more existing credit-card debt (avg revolving balance $11K for A vs $20K for G)

# Dashboards
![Power BI](https://drive.google.com/file/d/1eTXRZzBxmdaHq6MUJKucjmTXZtDRx6px/view?usp=sharing) 

![Tableau](https://drive.google.com/file/d/1eHvkIASRYm9FlOkCh6xSgk6Ve_-1kw8a/view?usp=sharing)

![Excel](https://drive.google.com/file/d/1EEdZ0BxDA4pdF8knqgdjyTzHZbOhkonA/view?usp=sharing) 

All three dashboards use the same cleaned dataset and the same KPI definitions, so the numbers match across tools.

# Approach

# 1. Data Cleaning & Validation (Python)

The portfolio arrived as two separate files (CSV + Excel) that needed to be joined and audited before any reporting.

• Verified the join key in both directions, then merged with a one-to-one validated join.

• Found hidden missing values stored as text ("NA", "N/A", "NONE", blank spaces) that standard null checks miss, and converted them using column-specific rules.

• Kept the meaning of missing values as flags (ever_delinquent, has_public_record, has_desc) instead of filling blanks with misleading zeros.
Converted text fields to proper types ("36 months" → 36, "11.89%" → 0.1189, "Aug-09" → date).

• Ran business-rule checks (funded ≤ requested, repayments add up, no payment before issue date) with 0 violations.

• Investigated anomalies instead of deleting them. For example, 71 loans with no payment date turned out to be defaults where all money came from collections.

# 2. Data Modelling & KPI Analysis (MySQL)

• Designed a typed relational table with exact DECIMAL types for money and rates, a primary key, and documented nullable columns.

• Wrote KPI queries using window functions (LAG) and conditional aggregation:

Year-over-year lending growth

Revolving balance by grade and sub-grade

Payment-to-funded ratio by verification status

Loan status by state and credit-pull year

Default rate by home ownership (completed loans only)

# 3. Dashboards (Power BI · Tableau · Excel)

Interactive filters for year, state, grade and loan status, with KPI cards, trend lines and segment comparisons.

Repository Structure

├── data/

│   ├── raw/            # Finance_1.csv, Finance_2.xlsx

│   └── processed/      # loans_clean.csv

├── notebooks/

│   └── 01_cleaning.ipynb

├── sql/

│   ├── 01_setup_and_import.sql

│   └── 02_kpis.sql

├── dashboards/         # .pbix, .twbx, .xlsx

└── images/             # dashboard screenshots

# Tech Stack

Data Cleaning: Python, Pandas, NumPy 

Database & Analysis: MySQL (window functions, conditional aggregation) 

Visualization & BI: Power BI, Tableau, Excel (Power Query)


