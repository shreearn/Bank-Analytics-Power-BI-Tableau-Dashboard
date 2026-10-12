# Creating database (container for all tables)
Create database new_bank_analytics;
use new_bank_analytics;

# Droping table to fix error
DROP TABLE IF EXISTS loans;

# Creating table with the correct data type for every column
# Decimal = Exact numbers for money and rates ( float can give 0.1+0.2= 0.30000000004)
# Date = real dates, so YEAR() and dates maths work
# Null = Columns that are allowed to be blank (only the ones kept blank in cleaning)
create table loans (
# Loan identity 
id INT  NOT NULL, 
member_id INT NOT NULL,

# Loan Terms
loan_amnt INT NOT NULL,
funded_amnt INT NOT NULL,
funded_amnt_inv DECIMAL(12,2) NOT NULL,
term TINYINT NOT NULL, # 36 or 60 months
int_rate DECIMAL(6,4) NOT NULL, # fraction: 0.1189 = 11.89%
installment DECIMAL(10,2) NOT NULL, 
grade CHAR(1) NOT NULL,
sub_grade CHAR(2) NOT NULL,

# Borrower
emp_title VARCHAR(100) NULL,
emp_length VARCHAR(10) NULL,
home_ownership VARCHAR(10) NOT NULL,
annual_inc DECIMAL(12,2) NOT NULL,
verification_status VARCHAR(20) NOT NULL,
issue_d Date NOT NULL,
loan_status VARCHAR(15) NOT NULL,
purpose VARCHAR(25) NOT NULL,
title VARCHAR(100) NULL,
zip_code CHAR(5) NOT NULL,
addr_state CHAR(2) NOT NULL,
dti DECIMAL(5,2) NOT NULL,

# Credit history
delinq_2yrs TINYINT NOT NULL,
earliest_cr_line DATE NOT NULL,
inq_last_6mths TINYINT NOT NULL,
mths_since_last_delinq SMALLINT NULL, # NULL = never late
mths_since_last_record SMALLINT NULL, # NULL = never had public record
open_acc TINYINT NOT NULL,
pub_rec  TINYINT NOT NULL,
revol_bal INT NOT NULL,
revol_util DECIMAL(5,4) NULL, # fraction, Null = cannot be calculated
total_acc TINYINT NOT NULL,

# payments
out_prncp DECIMAL(12,2) NOT NULL,
out_prncp_inv DECIMAL(12,2) NOT NULL,
total_pymnt DECIMAL(12,2) NOT NULL,
total_pymnt_inv DECIMAL(12,2) NOT NULL,
total_rec_prncp DECIMAL(12,2) NOT NULL,
total_rec_int DECIMAL(12,2) NOT NULL,
total_rec_late_fee DECIMAL(12,2) NOT NULL,
recoveries DECIMAL(12,2) NOT NULL,
collection_recovery_fee DECIMAL(12,2) NOT NULL,
last_pymnt_d DATE NULL, # NULL = never paid (71 loans)
last_pymnt_amnt DECIMAL(12,2) NOT NULL,
last_credit_pull_d DATE NULL, #

# flags created during cleaning (1= yes, 0= no)
ever_delinquent TINYINT NOT NULL,
has_public_record TINYINT NOT NULL,
has_desc TINYINT NOT NULL,
emp_length_yrs TINYINT NULL,
PRIMARY KEY (id) # one per loan;
);


# Check which folder MYSQL is allowed to read from
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\loans_clean.csv'
INTO TABLE loans
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' # text with commas inside is wrapped in quotes
LINES TERMINATED BY '\r\n' # Windows line endings (pandas on Windows)
IGNORE 1 LINES # skip the header row
(id, member_id, loan_amnt, funded_amnt, funded_amnt_inv, term, int_rate, installment,
 grade, sub_grade, @emp_title, @emp_length, home_ownership, annual_inc,
 verification_status, issue_d, loan_status, purpose, @title, zip_code, addr_state, dti,
 delinq_2yrs, earliest_cr_line, inq_last_6mths, @mths_delinq, @mths_record,
 open_acc, pub_rec, revol_bal, @revol_util, total_acc, out_prncp, out_prncp_inv,
 total_pymnt, total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee,
 recoveries, collection_recovery_fee, @last_pymnt_d, last_pymnt_amnt,
 @last_credit_pull_d, ever_delinquent, has_public_record, has_desc, @emp_length_yrs)

# Columns that can be blank go into a @variable first.
# NULLIF(@x, '') = "if the cell is empty, store NULL, otherwise store the value".
# Without this, MySQL would store '' or 0 instead of NULL
SET emp_title              = NULLIF(@emp_title, ''),
    emp_length             = NULLIF(@emp_length, ''),
    title                  = NULLIF(@title, ''),
    mths_since_last_delinq = NULLIF(@mths_delinq, ''),
    mths_since_last_record = NULLIF(@mths_record, ''),
    revol_util             = NULLIF(@revol_util, ''),
    last_pymnt_d           = NULLIF(@last_pymnt_d, ''),
    last_credit_pull_d     = NULLIF(@last_credit_pull_d, ''),
    emp_length_yrs         = ROUND(NULLIF(@emp_length_yrs, ''));   # "10.0" -> 10
 

# veryfing the import 
SHOW WARNINGS LIMIT 10;   # only "Note" rows (rounding money to 2 decimals) are O K

SELECT COUNT(*) AS total_loans,  #expect 39717
       SUM(funded_amnt) AS total_funded, #expect 434810325
       SUM(loan_status = 'Charged Off') AS charged_off, # expect 5627
       SUM(loan_status = 'Fully Paid') AS fully_paid, # expect 32950
       SUM(loan_status = 'Current') AS current_loans # expect 1140
FROM loans;

SELECT SUM(emp_title IS NULL) AS emp_title_nulls, # expect 2459
       SUM(emp_length IS NULL) AS emp_length_nulls, # expect 1075
       SUM(title IS NULL) AS title_nulls, # expect 13
       SUM(mths_since_last_delinq IS NULL) AS delinq_nulls, #  expect 25682
       SUM(mths_since_last_record IS NULL) AS record_nulls, # expect 36931
       SUM(revol_util IS NULL) AS revol_util_nulls, # expect 50
       SUM(last_pymnt_d IS NULL) AS last_pymnt_nulls,# expect 71
       SUM(last_credit_pull_d IS NULL) AS credit_pull_nulls, # expect 2
       SUM(mths_since_last_delinq = 0) AS real_zeros # expect 443
FROM loans;



