/**** PROJECT 1  (DDL CONCEPTS)    DUE DATE AUG 20TH 2021*****/



CREATE DATABASE UnionBank;

CREATE SCHEMA Borrower;

/******Two tables*****/
--Borrower
--BorrowerAddress

CREATE TABLE Borrower.Borrower(
BorrowerID int not null,
BorrowerFirstName varchar (255) not null,
BorrowerMiddleInitial char (1) not null,
BorrowerLastName varchar (255) not null,
DoB datetime not null,
Gender char (1) null,
TaxPayerID_SSN varchar (9) not null,
PhoneNumber varchar (10) not null,
Email varchar (255) not null,
Citizenship varchar (255) null,
BeneficiaryName varchar (255) null,
IsUSCitizen bit null,
CreateDate datetime not null
);

ALTER TABLE [Borrower].[Borrower]
 ADD CONSTRAINT Pk_borrowerID primary key (BorrowerID)
    ,CONSTRAINT Chk_borrower_DoB check (DoB<= dateadd(year,-18, Getdate()))
	,CONSTRAINT Chk_email check (email Like '% @ %')
    ,CONSTRAINT Chk_Phone check (PhoneNumber = '10') --CONSTRAINT Chk_Phone check (LEN(PhoneNumber)=10)-- 
	,CONSTRAINT Chk_SSN check (TaxPayerID_SSN = '9')
	,CONSTRAINT default_date default (Getdate()) for [CreateDate];

	    

CREATE TABLE Borrower.BorrowerAddress(
AddressID int not null,
BorrowerID int not null,
StreetAddress varchar (255) not null,
ZIP varchar (5) not null,
CreateDate datetime not null
);

ALTER TABLE[Borrower].[BorrowerAddress]
 ADD CONSTRAINT Pk_addressID_borrowerID primary key (addressID, borrowerID)
    ,CONSTRAINT default_AddressDate default (Getdate()) for [CreateDate]
 	,CONSTRAINT Fk_BorrowerAddressid foreign key (borrowerID) references [Borrower].[Borrower](borrowerID)
  	,CONSTRAINT Fk_ZIP foreign key (ZIP) references [dbo].[US_ZipCodes] (ZIP);




/**** Three tables under the default schema Dbo****/
--Calendar
--State
--US_ZipCodes

CREATE TABLE dbo.Calendar(
CalendarDate datetime null
);


 CREATE TABLE dbo.State (
StateID char (2) not null,
StateName varchar (255) not null,
CreateDate datetime not null
);
ALTER TABLE [dbo].[State]
ADD CONSTRAINT PK_state_stateID primary Key (StateID)
   ,CONSTRAINT default_date default (Getdate ()) for [CreateDate]
   ,CONSTRAINT Unq_State_StateName Unique (StateName);



CREATE TABLE dbo.US_ZipCodes(
IsSurrogateKey int not null,
ZIP varchar (5) not null,
Latitude float null,
Longitude float null,
City  varchar (255) null,
State_ID char (2) null,
Polulation int null,
Density decimal null,
County_fips varchar (10) null,
County_name varchar (255) null,
County_names_all varchar (255) null,
County_fips_all varchar (50) null,
Timezone varchar (255) null,
CreateDate datetime not null
);

ALTER TABLE [dbo].[US_ZipCodes]
 ADD CONSTRAINT Pk_ZIP primary key (ZIP) 
    ,CONSTRAINT default_US_Zipcodes default (Getdate()) for [CreateDate]
  	,CONSTRAINT FK_US_Zipcodes_StateID foreign key (State_ID)references[dbo].[State] (StateID);
 

CREATE SCHEMA Loan;

/****Five tables under Loan schema****/
--Loan periodic
--Loan SetUpInformation
--LU_ delinquency
--LU_payment frequency
--underwriter 


CREATE TABLE Loan.LoanPeriodic(
IsSurrogateKey int not null,
LoanNumber varchar (10) not null,
CycleDate datetime not null,
ExtraMonthlyPayment numeric (18,2) not null,
UnPaidPrincipleBalance  numeric (18,2) not null,
BeginningScheduleBalance  numeric (18,2) not null,
PaidInstallment  numeric (18,2) not null,
InterestPortion  numeric (18,2) not null,
PrincipalPortion  numeric (18,2) not null,
EndScheduleBalance  numeric (18,2) not null,
ActualEndScheduleBalance  numeric (18,2) not null,
TotalInterestAccrued  numeric (18,2) not null,
TotalPrincipalAccrued  numeric (18,2) not null,
DefaultPenalty  numeric (18,2) not null,
DelinquencyCode numeric(10, 0),
CreateDate datetime not null
);

ALTER TABLE [Loan].[LoanPeriodic]
 ADD CONSTRAINT Pk_LoanNumber_cycleDate primary key (LoanNumber,CycleDate)
    ,CONSTRAINT chk_Paid check (InterestPortion+Principalportion=Paidinstallment)
	,CONSTRAINT default_loanDate default (Getdate()) for [CreateDate]
	,CONSTRAINT default_extraPay default (0) for [ExtraMonthlyPayment]
	,CONSTRAINT Fk_loanNumber foreign key (LoanNumber) references[Loan].[LoanSetupInformation] (LoanNumber) 
	,CONSTRAINT Fk_Delicode foreign key (DelinquencyCode) references[Loan].[LU_Delinquency] (DelinquencyCode);



	CREATE TABLE Loan.LoanSetupInformation(
IsSurrogateKey int not null,
LoanNumber varchar (10) not null,
PurchaseAmount numeric (18,2) not null,
PurchaseDate datetime not null,
LoanTerm int not null,
BorrowerID int not null,
UnderWriterID int not null,
ProductID char(2) not null,
InterestRate decimal (3,2)not null, 
PayementFrequency int not null,
AppraisalValue numeric (18,2) not null,
CreateDate datetime not null,
LTV decimal (4,2) not null,
FirstInterestPaymentDate datetime null,
MaturityDate datetime not null
);

ALTER TABLE [Loan].[LoanSetupInformation]
 ADD CONSTRAINT Pk_LoanNumber primary key (LoanNumber)
    ,CONSTRAINT Chk_loanTerm check (LoanTerm=35 or LoanTerm=30 or LoanTerm=15 or LoanTerm= 10)
	,CONSTRAINT Chk_LoanSetUpinfo_interestRate check (InterestRate>=0.01 and InterestRate<=0.03) --CONSTRAINT CHECK_LoanSetUpinfo_interestRate (InterestRate BETWEEN 0.01 AND 0.03)--
	,CONSTRAINT default_LoanSetUpInfo_CreateDate default (Getdate()) for [CreateDate]
	,CONSTRAINT Fk_LOanSetUpInfo_BorrowerID foreign key (BorrowerID) references [Borrower].[Borrower] (BorrowerID)
	,CONSTRAINT FK_LoanSetUpInfo_PaymentFrequency foreign key (PaymentFrequency)references [Loan].[LU_PaymentFrequency](PaymentFrequency);




CREATE TABLE Loan.LU_Delinquency(
DelinquencyCode int not null,
Delinquency varchar(255) not null
);

ALTER TABLE [Loan].[LU_Delinquency]
ADD CONSTRAINT Pk_Delicode primary key (DelinquencyCode);


CREATE TABLE Loan.LU_PaymentFrequency(
PaymentFrequency int not null,
PaymentIsMadeEvery int not null,
PaymentFrequency_Description varchar (255) not null
);

ALTER TABLE [Loan].[LU_PaymentFrequency]
 ADD CONSTRAINT PK_LU_PaymentFrequency_Payment_frequency primary key (PaymentFrequency);


CREATE TABLE Loan.UnderWriter(
UnderWriterID int not null,
UnderWriterFirstName varchar(255) null,
UnderWriterMIddleInitial char (1),
UnderWriterLastName varchar (255) not null,
PhoneNumber varchar (14) null,
Email varchar (255) not null,
CreateDate datetime not null
);

ALTER TABLE [Loan].[UnderWriter]
 ADD CONSTRAINT PK_UnderWriter_UnderwriterID primary Key (UnderWriterID)
    ,CONSTRAINT default_UnderWriter_date default (Getdate ()) for [CreateDate]
    ,CONSTRAINT Chk_UnderWriter_email check (email Like '% @ %');





