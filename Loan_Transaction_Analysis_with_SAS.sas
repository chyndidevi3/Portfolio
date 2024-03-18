/*Read all excel sheets of excel file into a single sas data*/
libname PROJECT xlsx '/home/u63521737/Bank/DataProject.xlsx';

data test;
set project.order;
run;

/*DATA CLEANING*/
/*clean new transaction variable operation and k_symbol*/
data clean_newtrans;
set project.New_Transaction;
missing_obs = missing(cats(of operation));
if missing_obs=1 then delete;
drop A;
run;

data clean_newtrans2;
set work.clean_newtrans;
missing_obs2 = missing(cats(of k_symbol));
if missing_obs2=1 then delete;
drop missing_obs missing_obs2;
run;
/*cleaning order sheet*/
data clean_order;
set project.Order;
missing_obs = missing(cats(of k_symbol));
if missing_obs=1 then delete;
drop missing_obs;
run;



/*PROBLEM 1
Prepare a dashboard for the All the Accounts doing Credit transactions from Moravia and Prague. Prepare the Aggregated View of the transactions basis on 2 things i.e.
a. Account Wise
b. Month Wise
c. Account and Month wise.
A1=DISTIRCT CODE  A3=DISTRICT NAME*/
%Macro find_dis(dis_name);
DATA find_district;
set project.district;
dis=index(A3, "&dis_name.");
if dis>0 then output;
drop dis; run;
proc print data=find_district;run;
%mend;
%find_dis(Moravia);

/*Prague district code=1 
Moravia district code=53-77*/

/*Find account id with distric code prague and moravia*/
proc sql;
create table acc_dis as
select account_id
from PROJECT.NEW_ACCOUNT
where district_id in (1,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77);
quit;

proc sql;
create table acc_type_credit as
select account_id, date, type, operation, amount, balance, k_symbol
from WORK.CLEAN_NEWTRANS2
where type="CREDIT";
quit;
/*1A Account Wise*/
proc sql;
create table prob_1a as
select *
from work.acc_dis as a
inner join work.acc_type_credit as b
on a.account_id=b.account_id;
quit;

PROC export data=work.prob_1a
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob1A";run;
/*1B Month Wise*/
proc sql;
create table prob_1b as
select *
from work.acc_dis as c
inner join project.loan as d
on c.account_id=d.account_id;
quit;
PROC export data=work.prob_1b
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob1B";run;

proc print data=work.prob_1b;run;

/*1C Account and Month Wise*/
data prob_1c;
set work.prob_1a
	work.prob_1b;
run;

PROC export data=work.prob_1c
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob1C";run;
proc print data=work.prob_1c;run;



/*Problem 2
Analysis on Highly populated versus Low populated districts. Find out the amount of 
Credit and Debit transaction from 5 highly populated and 5 lowest populated areas 
respectively, above analysis should be from last 3 months*/
/*sorting no of inhabitants (a4)*/
proc sql;
select *
from project.district
order by a4 asc;
quit;
/*5 Highly populated=1,54,74,70,68
5 lowest populated=69,29,31,19,13*/
/*Find account id on New_Account sheet with district code highly populated*/
proc sql;
create table acc_dis_highest_pop as
select account_id, district_id
from PROJECT.New_Account
where district_id in (1,54,74,70,68);
quit;
/*Find account id, type credit and debit, last 3 months*/
proc sql;
create table debit_high_pop as
select *
from work.acc_dis_highest_pop as e
inner join clean_newtrans2 as f
on e.account_id=f.account_id
where type="DEBIT"
order by date desc;
quit;
/*981217 last date DEBIT
981214 last date CREDIT*/
	

/*Amount of Debit in 5 highest populated place in last 3 month*/
proc sql;
create table debit_high_pop_last3 as
select sum(amount) as Amount_Debit_5HighestPop
from work.debit_high_pop
where date>=980917 and date <= 981217;
quit;
/*Amount_Debit_5HighestPop = 12076017*/


/*CREDIT 5 HIGHEST POPULATED LAST 3 MONTH*/
proc sql;
create table credit_high_pop as
select *
from work.acc_dis_highest_pop as e
inner join clean_newtrans2 as f
on e.account_id=f.account_id
where type="CREDIT"
order by date desc;
quit;
/*981214 last date CREDIT*/
/*Amount of Credit in 5 highest populated place in last 3 month*/
proc sql;
create table credit_high_pop_last3 as
select sum(amount) as Amount_Credit_5HighestPop
from work.credit_high_pop
where date>=980914 and date <= 981214;
quit;
/*Amount_Credit_5HighestPop = 2870696*/




/*LOWEST POPULATED*/

/*Find account id on New_Account sheet with district code lowest populated*/
proc sql;
create table acc_dis_lowest_pop as
select account_id, district_id
from PROJECT.New_Account
where district_id in (69,29,31,19,13);
quit;

/*Find account id, type credit and debit, last 3 months*/
proc sql;
create table debit_lowest_pop as
select *
from work.acc_dis_lowest_pop as g
inner join clean_newtrans2 as h
on g.account_id=h.account_id
where type="DEBIT"
order by date desc;
quit;
/*981216 last date	*/


/*Amount of Debit in 5 lowest populated place in last 3 month*/
proc sql;
create table debit_lowest_pop_last3 as
select sum(amount) as Amount_Debit_5LowestPop
from work.debit_lowest_pop
where date>=980916 and date <= 981216;
quit;
/*Amount_Debit_5LowestPop = 2776336.8*/


/*Find account id, type credit and debit, last 3 months*/
proc sql;
create table credit_lowest_pop as
select *
from work.acc_dis_lowest_pop as g
inner join clean_newtrans2 as h
on g.account_id=h.account_id
where type="CREDIT"
order by date desc;
quit;
/*981214 last date	*/


/*Amount of Debit in 5 lowest populated place in last 3 month*/
proc sql;
create table credit_lowest_pop_last3 as
select sum(amount) as Amount_Credit_5LowestPop
from work.credit_lowest_pop
where date>=980914 and date <= 981214;
quit;
/*Amount_Credit_5LowestPop = 579995*/


data prob2;
set work.debit_high_pop_last3
	work.credit_high_pop_last3
	work.debit_lowest_pop_last3
	work.credit_lowest_pop_last3;
run;

PROC export data=work.prob2
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob2";run;

/*PROBLEM 3
How many cards are issued to mid age females?*/

PROC sql;
create table prob3 as
select count(client_id) as Num_of_cards
from project.New_Client
where gender="FEMALE" AND age_levels='MIDDLE AGED';
run;
/*output 1326*/

PROC export data=work.prob3
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob3";run;


/*PROBLEM 4
Number of cards issued in district where average salary 
is more than 9000, is it a good strategy?*/
proc sql;
create table dis_avgsal_more9000 as
select A1
from project.District
where A11 >9000;
quit;

proc sql;
create table prob4 as
select count(client_id) as Numofcards_avgsalarymore9000
from work.dis_avgsal_more9000 as h
inner join project.New_Client as i
on h.A1=i.district_id;
quit;
/*output 2519*/

PROC export data=work.prob4
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob4";run;


/*PROBLEM 5
Are we providing loans to members belonging to district where 
committed crimes are more than 6000 for code 95, if yes then 
provide the number of loans per district?
*/
/*see what A15 data type*/
proc contents data=project.district;
run;

/*change A15 from char to numeric*/
data district_a15;
set project.district;
A15_num=input(A15, 5.);
run;
proc contents data=work.district_a15;
run;

/*Select district code that have more than 6000 crime95*/
PROC sql;
create table dis_crime_more6000 as
select A1,A3
from work.district_a15
where A15_num > 6000;
quit;

/*Find account_id in district*/
proc sql;
create table account_district_crime6000 as
select *
from work.dis_crime_more6000 as j
left join project.New_Account as k
on j.A1=k.district_id;
quit;
proc print data=account_district_crime6000;run;

/*Find loan for every account_id*/
proc sql;
create table loan_crime_dis as
select *
from work.account_district_crime6000 as l
inner join project.Loan as m
on l.account_id=m.account_id;
quit;

/*Number of loan for every district*/
proc sql;
create table prob5 as
select A3, freq(A3) as Number_of_loan
from loan_crime_dis
group by A3;
quit;

PROC export data=work.prob5
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob5";run;





/*PROBLEM 6
How much money was collected from other banks for customer belongs to 
districts where unemployment rate for any year is greater than 2%.*/
proc contents data=project.District;
run;
/*change A12 from char to numeric*/
data district_a12;
set project.district;
A12_num=input(A12, 4.);
run;
proc contents data=work.district_a12;
run;

/*Get the district code*/
proc sql;
create table dis_unemploy2 as
select A1
from work.district_a12
where A12_num > 2 or a13 > 2;
quit;

/*Find account id that has the district code*/
proc sql;
create table acc_dis_unemploy2 as
select account_id
from work.dis_unemploy2 as n
inner join project.New_Account as o
on n.A1=o.district_id;
quit;


/*Filter transaction collection from another bank*/
proc sql;
create table filter_collection as
select *
from work.clean_newtrans2
where operation="COLLECTION FROM ANOTHER BANK";
quit;

/*Find account id and amount that has the district code*/
proc sql;
create table prob6 as
select sum(amount) as Sum_of_Money
from work.acc_dis_unemploy2 as p
inner join work.filter_collection as q
on p.account_id=q.account_id;
quit;
/*output 124095383*/

PROC export data=work.prob6
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob6";run;



/*PROBLEM 7
Create profile of customers in accordance of districts where max money is being paid to
a. Insurance.
b. Household
c. Leasing
d. Loan*/

/*Including district_id into order sheet*/
proc sql;
create table acc_dis_1 as
select *
from project.New_Account as r
inner join work.clean_order as s
on r.account_id=s.account_id;
quit;

/*Insurance*/
proc sql;
create table prob7a as
select *
from work.acc_dis_1
where k_symbol="POJISTNE"
group by district_id;
quit;
PROC export data=work.prob7a
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob7A";run;

/*Household*/
proc sql;
create table prob7b as
select *
from work.acc_dis_1
where k_symbol="SIPO"
group by district_id;
quit;
PROC export data=work.prob7b
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob7B";run;

/*Leasing*/
proc sql;
create table prob7c as
select *
from work.acc_dis_1
where k_symbol="LEASING"
group by district_id;
quit;
PROC export data=work.prob7c
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob7C";run;

/*Loan*/
proc sql;
create table prob7d as
select *
from work.acc_dis_1
where k_symbol="UVER"
group by district_id;
quit;

PROC export data=work.prob7d
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob7D";run;
	

/*PROBLEM 8
Create profile of customers in accordance of districts for the status 
of loan payment, there will be 4 categories.
*/
/*Including district_id into loan sheet*/
proc sql;
create table acc_dis_2 as
select *
from project.New_Account as t
inner join project.Loan as u
on t.account_id=u.account_id;
quit;

/*A*/
proc sql;
create table prob8A as
select *
from work.acc_dis_2
where status="A"
group by district_id;
quit;
PROC export data=work.prob8A
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob8A";run;

/*B*/
proc sql;
create table prob8B as
select *
from work.acc_dis_2
where status="B"
group by district_id;
quit;
PROC export data=work.prob8B
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob8B";run;

/*C*/
proc sql;
create table prob8C as
select *
from work.acc_dis_2
where status="C"
group by district_id;
quit;
PROC export data=work.prob8C
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob8C";run;

/*D*/
proc sql;
create table prob8D as
select *
from work.acc_dis_2
where status="D"
group by district_id;
quit;
PROC export data=work.prob8D
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob8D";run;





	
/*PROBLEM 9
Relate the output of above with district conditions like 
Crime, Unemployment Rate and Average Salary.
*/
%MACRO status_type(status);
proc sql;
create table tab_&status. as
select district_id, count(account_id) as number_of_person_&status.
from work.prob8&status.
group by district_id;
quit;
%mend;
%status_type(B);

/*TABLE district
*/
%MACRO status_type2(stat);
proc sql;
create table dis_&stat. as
select district_id, number_of_person_&stat., A2, A15, A16, A12, A13, A11
from tab_&stat. as a
inner join project.District as b
on a.district_id=b.A1;
quit;
%mend;
%status_type2(D);

/*Export all table data to excel so we can use it to create a graph*/
PROC export data=work.dis_A
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob9A";run;
PROC export data=work.dis_B
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob9B";run;
PROC export data=work.dis_C
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob9C";run;
PROC export data=work.dis_D
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob9D";run;






/*PROBLEM 10
Owners from which district are issuing permanent orders and asking for a loan.
*/
PROC sql;
create table acc_owner as
select account_id, type
from project.New_Disposition 
where type="OWNER";
quit;
/*Account_id with owner status*/
proc sql;
create table acc_owner_dis as
select *
from work.acc_owner as c
inner join project.New_Account as d
on c.account_id=d.account_id;
quit;
/*Find district_id which district are issuing permanent orders and asking for a loan*/
proc sql;
create table prob10 as
select district_id, count(account_id) as num_of_acc
from work.acc_owner_dis
group by district_id;
quit;

/*Answer : From all of the district*/

PROC export data=work.prob10
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob10";run;
	
	







/*PROBLEM 11
Can we say customers from Bohemia are the ones having 
more male customers possessing Gold cards in comparison 
of Moravia?*/
%Macro find_dis(dis_name);
DATA find_district;
set project.district;
dis=index(A3, "&dis_name.");
if dis>0 then output;
drop dis; run;
proc print data=find_district;run;
%mend;
%find_dis(Bohemia);

/*Bohemia district code*/
proc sql;
create table bohemia_code as
select A1
from work.find_district;
quit;

/*accound id with bohemia district code*/
proc sql;
create table acc_dis_bohemia as
select *
from work.bohemia_code as a
inner join project.New_Account as b
on a.A1=b.district_id;
quit;

/*accound_id, district_id, disp_id, client_id*/
proc sql;
create table acc_bohemia2 as
select *
from work.acc_dis_bohemia as c
inner join project.New_Disposition as d
on c.account_id=d.account_id;
quit;

proc sql;
create table acc_bohemia3 as
select *
from work.acc_bohemia2 as e
inner join project.New_Client as f 
on e.client_id=f.client_id
where gender="MALE";
quit;

proc sql;
create table acc_bohemia4 as
select account_id, district_id, disp_id, client_id, gender
from work.acc_bohemia3;
quit;

proc sql;
create table acc_bohemia5 as
select count(account_id) as Bohemia_male_gold
from work.acc_bohemia4 as g
inner join project.New_Card as h
on g.disp_id=h.disp_id
where type="GOLD";
quit;
/*Output 25*/


/*MORAVIA*/
%Macro find_dis(dis_name);
DATA find_dis_Moravia;
set project.district;
dis=index(A3, "&dis_name.");
if dis>0 then output;
drop dis; run;
proc print data=find_dis_Moravia;run;
%mend;
%find_dis(Moravia);

/*Moravia district code*/
proc sql;
create table moravia_code as
select A1
from work.find_dis_moravia;
quit;

/*accound id with moravia district code*/
proc sql;
create table acc_dis_moravia as
select *
from work.moravia_code as a
inner join project.New_Account as b
on a.A1=b.district_id;
quit;

/*accound_id, district_id, disp_id, client_id*/
proc sql;
create table acc_moravia2 as
select *
from work.acc_dis_moravia as c
inner join project.New_Disposition as d
on c.account_id=d.account_id;
quit;

proc sql;
create table acc_moravia3 as
select *
from work.acc_moravia2 as e
inner join project.New_Client as f 
on e.client_id=f.client_id
where gender="MALE";
quit;

proc sql;
create table acc_moravia4 as
select account_id, district_id, disp_id, client_id, gender
from work.acc_moravia3;
quit;

proc sql;
create table acc_moravia5 as
select count(account_id) as Moravia_male_gold
from work.acc_moravia4 as g
inner join project.New_Card as h
on g.disp_id=h.disp_id
where type="GOLD";
quit;
/*output 22*/

/*Combine table*/
data prob11;
set work.acc_bohemia5
	work.acc_moravia5;
run;

/*YES, We can say customers from Bohemia are the ones having more 
male customers possessing Gold cards in comparison of Moravia*/

PROC export data=work.prob11
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob11";run;	
	





/*PROBLEM 12
How many customers having credit card are also availing the loan facilities.
*/
proc sql;
create table prob12 as
select count(account_id) as Cust_CC_Loan
from project.New_Transaction
where type="CREDIT" AND k_symbol="LOAN PAYMENT";
quit;

/*No customer*/

PROC export data=work.prob12
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob12";run;









/*PROBLEM 13
Can we say that customers having Classic and Junior card are the ones who are more in debt.
*/
proc sql;
create table classic_junior as
select *
from project.New_Card
where type="CLASSIC" or type="JUNIOR";
quit;

/*Find disp_id in New_Disposition sheet to get the account_id*/
proc sql;
create table disp_id_join as
select *
from work.classic_junior as e
inner join project.New_Disposition as f 
on e.disp_id=f.disp_id;
quit;

/*Find account_id in Loan sheet to get the status*/
proc sql;
create table prob13 as
select status, count(status) as num_status
from work.disp_id_join as g
inner join project.Loan as h 
on g.account_id=h.account_id
group by status;
quit;

/*No, we can not say that customers having Classic and Junior card are the ones who are 
more in debt because customers who having classic and junior card are the ones who are
more in running in contract*/	
	
PROC export data=work.prob13
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob13";run;








/*PROBLEM 14
How will you analyze the performance of Mid age vs adults in terms of loan repayments.
*/
/*data middle aged and adult*/
proc sql;
create table middle_adult as
select client_id, age_levels
from project.New_Client
where age_levels="MIDDLE AGED" OR age_levels="ADULT";
quit;

/*Find account_id*/
proc sql;
create table acc_midd_adult as
select *
from middle_adult as m 
inner join project.New_Disposition as n 
on m.client_id=n.client_id;
quit;

/*Find account with k_symbol=UVER*/
proc sql;
create table acc_loan as
select *
from acc_midd_adult as o
inner join work.clean_order as p 
on o.account_id=p.account_id
where k_symbol='UVER'
GROUP BY age_levels;
quit;

proc sql;
create table prob14 as
select age_levels, count(age_levels) as num_of_age_level
from acc_loan
group by age_levels;
quit;

PROC export data=work.prob14
	outfile="/home/u63521737/Bank/ExcelAnswer_C.xlsx"
	dbms=xlsx replace;
	sheet="Prob14";run;
