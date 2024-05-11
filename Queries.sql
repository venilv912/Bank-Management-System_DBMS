-- (1) Top 5 Branches of the Bank, Account-wise
SELECT ifs_code, branch_name, count(account_number) AS accounts FROM branch NATURAL JOIN Account
group by ifs_code, branch_name
order by accounts desc
limit 5;

-- (2) Total number of transactions performed by every account
SELECT Account.Account_Number, COALESCE(total_transactions, 0) AS total_transactions FROM Account LEFT JOIN
(SELECT Account_Number, count(transaction_id) AS total_transactions FROM
(SELECT transaction_id, sender_account_no AS Account_Number FROM transaction
UNION
SELECT transaction_id, receiver_account_no AS Account_Number FROM transaction)
group by Account_Number) AS r
ON Account.Account_Number=r.Account_Number
order by total_transactions desc;

-- (3) Top 5 most active branches according to transactions performed (which branches have most transactions)
SELECT IFS_CODE, branch_name, count(transaction_id) AS total_transactions
FROM Branch NATURAL JOIN Account NATURAL JOIN
(SELECT transaction_id, sender_account_no AS Account_Number FROM transaction
UNION
SELECT transaction_id, receiver_account_no AS Account_Number FROM transaction)
group by IFS_CODE
order by total_transactions desc
limit 5;


-- (4) All Loan Eligible Accounts (which are all 'Active' Accounts and are either 'Savings' or 'Current')
SELECT Customer_ID, Account_Number FROM Account NATURAL JOIN Account_Details
WHERE Account_type in ('Savings', 'Current') AND
Account_Status = 'Active'
order by Customer_ID;


-- (5) To get Branch-wise count of all Loan Eligible Accounts
SELECT IFS_CODE, branch_name, count(Account_Number) AS loan_eligible_accounts
FROM Branch NATURAL JOIN Account NATURAL JOIN Account_Details
WHERE Account_type in ('Savings', 'Current') AND
Account_Status = 'Active'
group by IFS_CODE, branch_name
order by IFS_CODE;

-- (6) Transaction Details of all Transactions/Transactions made in specific period of time from an account
-- (6.1) Transaction Details of All Transactions of an account
(SELECT * FROM Transaction where sender_account_no = 787901040)
UNION
(SELECT * FROM Transaction where receiver_account_no = 787901040);

-- (6.2) Transactions made in specific period of time from an account
SELECT * 
FROM Transaction 
WHERE (sender_account_no = 787901135 OR receiver_account_no = 787901135)
AND transaction_date >= CURRENT_DATE - INTERVAL '1' MONTH;


-- (7) total number of accounts for each account types
SELECT account_type, count(account_number) AS total_accounts FROM account_details
group by account_type;


-- (8) To get Minimum, Maximum and Average Interest Rates for different Account Types
SELECT account_type, min(Interest_Rate) AS Min_Interest_Rate,
max(Interest_Rate) AS Max_Interest_Rate,
ROUND(avg(Interest_Rate), 2) AS Avg_Interest_Rate
FROM account_details
group by account_type;


-- (9) To know all Transactions that happened in specific period of time
(SELECT * FROM transaction where transaction_date>='2020-01-01' and transaction_date<'2024-01-01')
UNION
(SELECT * FROM transaction where transaction_date>='2020-01-01' and transaction_date<'2024-01-01');


-- (10) To know total amount credited/debited for every account
SELECT COALESCE(r1.Account_Number, r2.Account_Number) AS Account_Number,
COALESCE(Amount_Credited, 0.00) AS Amount_Credited,
COALESCE(Amount_Debited, 0.00) AS Amount_Debited FROM 
(SELECT sender_account_no AS Account_Number, sum(transaction_amount) AS Amount_Debited FROM transaction
where transaction_type in ('Transfer', 'Withdrawal')
group by sender_account_no) AS r1
FULL OUTER JOIN
(SELECT receiver_account_no AS Account_Number, sum(transaction_amount) AS Amount_Credited FROM transaction
where transaction_type in ('Transfer', 'Deposit')
group by receiver_account_no) AS r2
ON r1.Account_Number=r2.Account_Number
order by Account_Number;


-- (11) To know year-wise number of transactions for each account
SELECT Account_Number, EXTRACT(YEAR FROM Transaction_date) AS year, count(transaction_id) AS total_transactions FROM
(SELECT transaction_id, transaction_date, receiver_account_no AS Account_Number FROM transaction
UNION
SELECT transaction_id, transaction_date, sender_account_no AS Account_Number FROM transaction)
group by Account_Number, year
order by Account_Number, year;


-- (12) To know total amount Credited and Debited for an account for any month
SELECT COALESCE(r1.Account_Number, r2.Account_Number) as Account_Number,
COALESCE(Amount_Credited, 0.00) as Amount_Credited,
COALESCE(Amount_Debited, 0.00) as Amount_Debited FROM
(SELECT sender_account_no AS Account_Number, sum(transaction_amount) AS Amount_Debited FROM transaction
where sender_account_no=787901105 AND EXTRACT(YEAR from transaction_date)=2024
AND EXTRACT(MONTH from transaction_date)=1
AND transaction_type in ('Transfer', 'Withdrawal')
group by sender_account_no) as r1
FULL OUTER JOIN
(SELECT receiver_account_no AS Account_Number, sum(transaction_amount) AS Amount_Credited FROM transaction
where receiver_account_no=787901105 AND EXTRACT(YEAR from transaction_date)=2024
AND EXTRACT(MONTH from transaction_date)=1
AND transaction_type in ('Transfer', 'Deposit')
group by receiver_account_no) as r2
ON r1.Account_Number=r2.Account_Number;


-- (13) To know Monthly Average Transaction Amount of the Bank for every year
select Extract(YEAR FROM transaction_date) as year,
Extract(MONTH FROM transaction_date) as month,
ROUND(AVG(Transaction_Amount), 2) AS Average_Transaction_Amount FROM Transaction
group by year, month
order by year, month;


-- (14) Customer Details of all the customers who have not paid the Loan Installments
SELECT Customer_ID, Loan_Amount, Fname, Mname, Lname, Phone_No, Email
FROM Customer_Details NATURAL JOIN Account NATURAL JOIN Loan NATURAL JOIN Loan_Repayment
WHERE Loan_Repayment.status='NOT_PAID'
ORDER BY Customer_ID;


-- (15) Number of loans Approved/Under_Review/Not Approved by each Loan_Officer for any Branch
select Employee_ID, Branch_Name, Loan_Approval_Status, count(Loan_id) as total_loans
FROM Employee NATURAL JOIN Branch NATURAL JOIN Loan
where IFS_CODE='IFSC0010001'
group by Employee_ID, Branch_Name, Loan_Approval_Status
order by employee_id;


-- (16) Number of credit_cards approved/under_review/rejected by a particular credit_analyst
select Employee_ID, Branch_Name, Card_Approval_Status, count(Card_ID) as total_cards
FROM Employee NATURAL JOIN Branch NATURAL JOIN Credit_Card
where IFS_CODE='IFSC0010004'
group by Employee_ID, Branch_Name, Card_Approval_Status
order by employee_id;


-- (17) To know all Upcoming Installment Dates for Loan for each account if any
select Account_Number, Loan_ID, Installment_Date FROM Loan NATURAL JOIN Loan_Repayment
where Status='NOT_PAID' AND Installment_Date>=CURRENT_DATE;


-- (18) To know all Upcoming due dates for credit card for each account if any
select Account_Number, Card_ID, Card_Transaction_ID, Due_Date FROM Credit_Card NATURAL JOIN Card_Transaction
where Card_Repayment_Status='NOT_PAID' AND Due_Date>=CURRENT_DATE;


-- (19) To know top 5 account with highest balance (only current/savings)
SELECT Account_Number, balance, Account_Type FROM Account NATURAL JOIN Account_Details
WHERE Account_type in ('Savings','Current')
order by balance desc limit 5;


-- (20) Customer Details of all the customers who have not paid the Credit Card Bill
SELECT Customer_ID, Amount_spent as bill_amount, card_transaction_date, card_id, Fname, Mname, Lname, Phone_No, Email
FROM Customer_Details NATURAL JOIN Account NATURAL JOIN credit_card NATURAL JOIN card_transaction
WHERE card_Repayment_status='NOT_PAID'
ORDER BY Customer_ID;


-- (21) To know the Upcoming Installment Date for Loan for particular account
select Account_Number, Loan_ID, Installment_Date FROM Loan NATURAL JOIN Loan_Repayment
where Status='NOT_PAID' AND Installment_Date>=CURRENT_DATE AND Account_Number=787901120;


-- (22) To know the Upcoming Due Date for credit card for particular account
select Account_Number, Card_ID, Card_Transaction_ID, Due_Date FROM Credit_Card NATURAL JOIN Card_Transaction
where Card_Repayment_Status='NOT_PAID' AND Due_Date>=CURRENT_DATE AND Account_Number=787901135;


-- (23) To know Yearly Number of New Customers
select EXTRACT(year from joining_date) as year,count(customer_id) as new_customers from customer
group by year
order by year;


-- (24) To know Yearly Number of New Accounts
select EXTRACT(year from opening_date) as year,count(account_number) as new_accounts from account_details
group by year
order by year;


-- (25) To know top 5 highest transaction
select transaction_id, sender_account_no,receiver_account_no,transaction_amount, transaction_date
from transaction
where transaction_type not in ('Deposit','Withdrawal')
order by transaction_amount desc limit 5;


-- (26) To get Complete Details of all the Loans which are not yet approved/under review by an employee
select Loan_ID, Account_Number, Loan_Type, Loan_Amount, Employee_ID as Loan_Reviewed_Under FROM Loan
where Loan_Approval_Status='Under_Review';


-- (27) To get Complete Details of all the Loans which have been approved by an employee
select Loan_ID, Account_Number, Loan_Type, Loan_Amount, Interest_Rate, Debt,
Duration, Loan_Approval_Date, Employee_ID as Loan_Approved_By FROM Loan
where Loan_Approval_Status='Approved';


-- (28) To know the loan_approval status for a particular account
select Account_Number, Loan_ID, Loan_Amount as Requested_Amount, Loan_Approval_Status FROM LOAN
where Loan_ID=77012;


-- (29) To get information about all branches in a particular city
SELECT IFS_CODE, Branch_Name, Branch_Street, Branch_Contact_No FROM Branch NATURAL JOIN Branch_Contacts
where Branch_City='Ahmedabad' AND Branch_State='Gujarat';


-- (30) To find Information of CSRs(Customer Service Representatives) of any specific Bank Branch
select Employee_ID, Employee_Fname, Employee_Mname, Employee_Lname FROM Employee
WHERE Role='Customer_Service_Representative' AND IFS_CODE='IFSC0010010';


-- (31) To Get Information about branch whose Interest Rate is Maximum for any specific account type in any city
select IFS_CODE, Branch_Name, branch_street, ROUND(avg(Interest_Rate), 2) AS Interest_Rate FROM Branch NATURAL JOIN Account NATURAL JOIN Account_Details
where branch_city='Ahmedabad' AND Account_Type='Fixed_Deposit'
group by IFS_CODE
order by Interest_Rate desc
limit 1;


-- (32) To get Minimum, Maximum and Average Interest Rates for different Loan Types
SELECT Loan_Type, min(Interest_Rate) AS Min_Interest_Rate,
max(Interest_Rate) AS Max_Interest_Rate,
ROUND(avg(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Loan
group by Loan_Type;


-- (33) To get information about all branches in a particular area
SELECT IFS_CODE, Branch_Name, Branch_Contact_No FROM Branch NATURAL JOIN Branch_Contacts
where Branch_Street='Infocity Road' AND Branch_City='Gandhinagar' AND Branch_State='Gujarat';


-- (34) To Get Information about branch whose Interest Rate is Maximum for each account type in any city
SELECT Account_Type, IFS_CODE, Branch_Name, branch_street, Interest_Rate FROM
(SELECT Account_Type, IFS_CODE, Branch_Name, branch_street, ROUND(avg(Interest_Rate), 2) AS Interest_Rate,
ROW_NUMBER() OVER (PARTITION BY Account_Type ORDER BY avg(Interest_Rate) DESC) AS top
FROM Branch NATURAL JOIN Account NATURAL JOIN Account_Details
WHERE branch_city = 'Ahmedabad'
GROUP BY Account_Type, IFS_CODE, Branch_Name, branch_street)
WHERE top = 1;


-- (35) To find Information of Manager of all Branches in any particular city
select Employee_ID, Employee_Fname, Employee_Mname, Employee_Lname FROM Employee NATURAL JOIN Branch
WHERE Role='Manager' AND branch_city='Rajkot';


-- (36) To know the value of a fixed deposit after a fixed period of time for any Account
select Account_Number, Balance as Current_Balance,
ROUND((Balance*POWER((1+(Interest_Rate/100)), 1)), 2) as First_Year,
ROUND((Balance*POWER((1+(Interest_Rate/100)), 5)), 2) as Fifth_Year,
ROUND((Balance*POWER((1+(Interest_Rate/100)), 10)), 2) as Tenth_Year
from Account_Details
where Account_Number=787901059;


-- (37) To get the information of Accounts whose Loan Repayment has been completed.
select Account_Number, Loan_ID, Loan_Type, Loan_Amount, Loan_Approval_Date, Loan_Completion_Date FROM
(select Account_Number, Loan_ID, Loan_Type, Loan_Amount, Loan_Approval_Date, Payment_Date as Loan_Completion_Date,
ROW_NUMBER() OVER (PARTITION BY Loan_ID order by Payment_Date desc) as rn
from Loan NATURAL JOIN Loan_Repayment
where debt=0)
where rn=1;


-- (38) Access details of a all associated accounts of any customer
select Customer_ID, Account_Number, Account_Status, Account_type, Balance, Interest_Rate, Opening_Date
FROM Account NATURAL JOIN Account_Details
where Customer_ID=10028;


-- (39) To get Complete Details of all the Credit Cards which are not yet approved/under review by an employee
select Card_ID, Account_Number, Employee_ID as Card_Reviewed_Under FROM Credit_Card
where Card_Approval_Status='Under_Review';


-- (40) To get Complete Details of all the Credit Cards which have been approved by an employee
select Card_ID, Account_Number, Credit_Limit, Fine_Rate, Employee_ID as Card_Approved_By FROM Credit_Card
where Card_Approval_Status='Approved';