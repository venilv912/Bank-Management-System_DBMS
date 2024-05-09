CREATE SCHEMA FundsAndFinanceBank;
SET SEARCH_PATH TO FundsAndFinanceBank;

CREATE TABLE Customer(
	Customer_ID INT PRIMARY KEY,
	Joining_date DATE
);

CREATE TABLE Customer_Details(
	Customer_ID INT PRIMARY KEY REFERENCES Customer(Customer_ID),
	Fname VARCHAR(15),
	Mname VARCHAR(15),
	Lname VARCHAR(15),
	DoB DATE,
	Gender VARCHAR(15),
	Phone_No VARCHAR(15),
	Email VARCHAR(30),
	street VARCHAR(30),
	city VARCHAR(20),
	"state" VARCHAR(20)
);

CREATE TABLE Branch(
	IFS_CODE CHAR(11) PRIMARY KEY,
	Branch_Name VARCHAR(20),
	branch_street VARCHAR(30),
	branch_city VARCHAR(20),
	branch_state VARCHAR(20)
);

CREATE TABLE Branch_Contacts(
	IFS_CODE CHAR(11) REFERENCES Branch(IFS_CODE)
        ON DELETE CASCADE,
	Branch_Contact_No VARCHAR(15),
	PRIMARY KEY (IFS_CODE, Branch_Contact_No)
);

CREATE TABLE Account(
	Account_Number INT PRIMARY KEY,
	IFS_CODE CHAR(11) REFERENCES Branch(IFS_CODE)
		ON DELETE SET NULL,
	Customer_ID INT REFERENCES Customer(Customer_ID)
		ON DELETE CASCADE,
	Account_Status VARCHAR(15) CHECK(Account_Status in ('Active', 'Inactive', 'Frozen', 'Blocked'))
);

CREATE TABLE Account_Details(
	Account_Number INT PRIMARY KEY REFERENCES Account(Account_Number)
		ON DELETE CASCADE,
	Account_type VARCHAR(15) CHECK(Account_Type in ('Savings', 'Current', 'Fixed_Deposit')),
	Balance NUMERIC(14, 2),
	Interest_Rate NUMERIC(4, 2),
	Opening_date DATE
);

CREATE TABLE Transaction(
	Transaction_ID CHAR(10) PRIMARY KEY,
	Sender_Account_No INT REFERENCES Account(Account_Number),
	Receiver_Account_No INT REFERENCES Account(Account_Number),
	Transaction_Type VARCHAR(15) CHECK(Transaction_Type in ('Transfer', 'Credit_Card', 'Deposit', 'Withdrawal')),
	Transaction_Date DATE,
	Transaction_Amount NUMERIC(10, 2)
);

CREATE TABLE Employee(
	Employee_ID INT PRIMARY KEY,
	IFS_CODE CHAR(11) REFERENCES Branch(IFS_CODE)
		ON DELETE SET NULL,
	Employee_Fname VARCHAR(15),
	Employee_Mname VARCHAR(15),
	Employee_Lname VARCHAR(15),
	"role" VARCHAR(35) CHECK("role" in ('Manager', 'Customer_Service_Representative', 'Loan_Officer', 'Credit_Analyst'))
);

CREATE TABLE Loan(
	Loan_ID INT PRIMARY KEY,
	Account_Number INT REFERENCES Account(Account_Number),
	Employee_ID INT REFERENCES Employee(Employee_ID)
		ON DELETE SET NULL,
	Loan_Type VARCHAR(25) CHECK(Loan_Type in ('Education_Loan',  'Home_Loan', 'Gold_Loan', 'Personal_Loan', 'Loan_Against_Property', 'Business_Loan', 'Medical_Loan', 'Vehicle_Loan')),
	Loan_Amount NUMERIC(10, 2),
	Interest_Rate NUMERIC(4, 2),
	Debt NUMERIC(10, 2),
	Duration INT,
	Loan_Approval_Date DATE,
	Loan_Approval_Status VARCHAR(15) CHECK(Loan_Approval_Status in ('Approved', 'Not_Approved', 'Under_Review'))
);

CREATE TABLE Loan_Repayment(
	Loan_ID INT REFERENCES Loan(Loan_ID),
	Installment_Date DATE,
	Payment_Date DATE,
	Amount_Paid NUMERIC(10, 2),
	Status VARCHAR(15) CHECK(Status in ('PAID_ON_TIME', 'PAID_LATE', 'NOT_PAID')),
	PRIMARY KEY (Loan_ID, Installment_Date)
);

CREATE TABLE Credit_Card(
	Card_ID INT PRIMARY KEY,
	Account_Number INT REFERENCES Account(Account_Number),
	Employee_ID INT REFERENCES Employee(Employee_ID)
		ON DELETE SET NULL,
	Credit_Limit NUMERIC(10, 2),
	Fine_Rate NUMERIC(4, 2),
	Card_Approval_Status VARCHAR(15) CHECK(Card_Approval_Status in ('Approved', 'Not_Approved', 'Under_Review'))
);

CREATE TABLE Card_Transaction(
	Card_Transaction_ID CHAR(10) PRIMARY KEY,
	Card_ID INT REFERENCES Credit_Card(Card_ID),
	Amount_Spent NUMERIC(10, 2),
	Card_Transaction_Date DATE,
	Card_Repayment_Status VARCHAR(15) CHECK(Card_Repayment_Status in ('PAID_ON_TIME', 'PAID_LATE', 'NOT_PAID')),
	Due_Date DATE
);