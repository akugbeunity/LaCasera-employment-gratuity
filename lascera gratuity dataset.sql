SELECT * FROM myportfolio.kkkk;
-- create a staging table--
create table employee_gratuity
like kkkk;
insert into employee_gratuity
select * from kkkk;
select * from employee_gratuity;
-- clean data by removing blanks and giving headers to each column--
alter table employee_gratuity
rename column `MyUnknownColumn_[12]` to Gratuity_payout ;
alter table employee_gratuity
rename column NO to Nos
alter table employee_gratuity
drop column temp_row
alter table employee_gratuity
drop `MyUnknownColumn_[12]`

-- remove blank--
alter table employee_gratuity
add column temp_row int auto_increment primary key;

update employee_gratuity
set Monthly_gross_pay="null" where temp_row ="6";

delete from employee_gratuity
where name ="total";

delete from employee_gratuity
where temp_row ="6";

-- check for duplicate values--
select *, row_number()
over (partition by Nos order by Nos) as row_no
from employee_gratuity;
-- no duplicate values was found-- 
alter table employee_gratuity
drop column Number_of_yearsworked_rounded;

select * from employee_gratuity
order by Nos asc
-- to add a primary key to the table we first have to modify the colunm to integer--

-- chamge all the  datatype of each column--
alter table employee_gratuity
modify column Nos int
alter table employee_gratuity
add primary key(Nos)
-- change the datatype of date of joining to date--

UPDATE employee_gratuity
SET Date_of_joining = STR_TO_DATE(REPLACE(Date_of_joining, "'", ''), '%d-%M-%Y');
-- change the data type of other hearders
alter table employee_gratuity
modify column Date_of_joining  date; 

-- change other column datatype--
alter table employee_gratuity
modify column Grade varchar(50);
-- add the existing date to the employee_gratuity table--
alter table employee_gratuity
add column Exist_date date;
alter table employee_gratuity
modify Exist_date date after Date_of_joining;
-- add values for existing_date
update employee_gratuity
set Exist_date ="2021-06-01";


select * from employee_gratuity;

delete from employee_gratuity
where Nos is null;

 -- find the number of years worked-- 
alter table employee_gratuity
add column number_of_years_worked int;
alter table employee_gratuity
modify number_of_years_worked int after Exist_date;

update employee_gratuity
set number_of_years_worked =(round(datediff(Exist_date,Date_of_joining)/365,1));

select * from employee_gratuity;
-- find the number of weeks applicable for each worker--
alter table employee_gratuity
add column numb_of_weeks_payment_applicable int;

update employee_gratuity
set numb_of_weeks_payment_applicable =
case when number_of_years_worked <10 then 6
when number_of_years_worked <16 then   7 
when number_of_years_worked >=16 then   8 
end ;
alter table employee_gratuity 
modify numb_of_weeks_payment_applicable int after number_of_years_worked;

-- find the number of weeks to be paid--
alter table employee_gratuity
add column numb_of_weeks_tobe_paid int;

update employee_gratuity
set numb_of_weeks_tobe_paid =
number_of_years_worked*numb_of_weeks_payment_applicable;


alter table employee_gratuity 
modify numb_of_weeks_tobe_paid int after numb_of_weeks_payment_applicable;

-- basic OA payment--
alter table employee_gratuity
add column Basic_OA_payment int;
-- Error Code:1265.Data truncated for column'Basic_OA_payment'at row 1 cos the date type of monthly basic pay and gross pay are in text so we change the data type to integer
-- first we need to remove the comma with the replace function and then  update the values before changing the datatype 
select*,replace (Monthly_basic_pay,',','') as mothly_basic_pay
from employee_gratuity;
UPDATE employee_gratuity
SET Monthly_gross_pay = REPLACE(Monthly_gross_pay, ',', '');
UPDATE employee_gratuity
SET Monthly_basic_pay = REPLACE(Monthly_basic_pay, ',', '');



-- we can then change the datatype--
alter table employee_gratuity
modify column Monthly_basic_pay int;
alter table employee_gratuity
modify column Monthly_gross_pay int;
-- we can then find the basic OA paymennt
update employee_gratuity
set Basic_OA_payment =
case when number_of_years_worked <16 then Monthly_basic_pay
when number_of_years_worked >=16 then Monthly_gross_pay
end ;


select * from employee_gratuity;
-- find the gratuity payout
 select *,numb_of_weeks_tobe_paid/4*Basic_OA_payment as gratuity_payout
from employee_gratuity;
-- add column gratuity payout whichmis gotten by dividing the numb_of_weeks_tobe_paid by 4 and multiply by Basic_OA_payment

 alter table employee_gratuity
add column gratuity_payout int
update employee_gratuity
set gratuity_payout =numb_of_weeks_tobe_paid/4*Basic_OA_payment
-- to get the 5% extra gratuity by mutiplying 5% by gratuity_payout
alter table employee_gratuity
add column Extra_gratia int 
update employee_gratuity
set Extra_gratia = 0.05*gratuity_payout
-- total payout is the addition of gratuity payout and extra gratia
alter table employee_gratuity
add column Total_payout int 
update employee_gratuity
set Total_payout =Extra_gratia+gratuity_payout;
-- check for distinct value in the grade column to know if you should trim, there are scatterd values which are in duplicates  so we need to trim the column 
select distinct Grade
from employee_gratuity

-- we need to remove space by updating it to a more proper way--
update employee_gratuity
set Grade= 'JB10'
where Grade='JB10'
-- EXPLORATITORY DATA ANALYSIS
-- 1) sum of gratuity_payout
select sum(gratuity_payout)from employee_gratuity;
select sum(Extra_gratia) from employee_gratuity;
select sum(Total_payout) from employee_gratuity;

-- 2)CALCULATE TOTAL GRATUITY PAY OUT TO  (a) JUNIOR, (b) SENIOR © MANAGEMENT STAFF			
alter table employee_gratuity
add column Grade_level varchar(50);
update employee_gratuity
set Grade_level=
case when Grade <'JB8' then 'JUNIOR'
when Grade >='JB8' then 'SENIOR_STAFF'
when Grade <'JB9' then 'MANAGMNT'
end; 
 alter table employee_gratuity
 modify column Grade_level varchar(50) after Grade;

-- 3) TO CALCULATE TOTAL GRATUITY PAYOUT OF JUNIOR STAFF 
select Grade_level,sum(Total_payout)
from employee_gratuity group by Grade_level;
--- to calculate using windows function--
select*,sum(Total_payout)
over(partition by Grade_level) as sum_of_totalpayout_by_grade_level
from employee_gratuity; 


-- 4) CALCULATE TOTAL GRATUITY PAYOUT TO EACH DEPARTMENT AND NUMBER OF COLLECTED GRATUITY	
select Department, sum(gratuity_payout)	
from employee_gratuity
group by Department;
-- the number of staff colected gratuity--
select count(gratuity_payout)
from employee_gratuity;

-- 5) CALCULATE GRATUITY PAYOUT TO EACH GRADE
select Grade,sum(gratuity_payout)
from employee_gratuity 
group by Grade;

-- 6) WHAT IS THE TOTAL GRATUITY COLLECTED FOR STAFF ABOVE (A) 10YRS AND  (B) LESS than 9YRS IN SERVICE				
  select number_of_years_worked, sum(Total_payout)
  from employee_gratuity group by number_of_years_worked
  having (number_of_years_worked) >10;
	-- B) for 9 years--
  select number_of_years_worked, sum(Total_payout)
  from employee_gratuity group by number_of_years_worked
  having (number_of_years_worked) <9;
-- 7)HOW MANY EMPLOYEES COMPUTED THEIR GRATUITY PAYOUT WITH MONTHLY BASIC SALARY				
select count(gratuity_payout)
from employee_gratuity
where number_of_years_worked >= 16;

-- 8) HOW MANY EMPLOYEES CONPUTED THEIR GRATUITY PAYOUT WITH MONTHLY GROSS SALARY				
select count(gratuity_payout)
from employee_gratuity
where number_of_years_worked <16;
-- 9) the employee whoes total payout is higher than the avearge total payout		
 select * from employee_gratuity
 where Total_payout > (select avg(Total_payout) from employee_gratuity);
 
 -- 10) top 1 highest gratuity_payout earner in each department
 select Nos,Name,Employee_code,Department,gratuity_payout,
 first_value(Name)over(partition by Department order by gratuity_payout desc) as higest_gratuity_payout_earner
 from employee_gratuity;
 
-- 11) FIND THE 2ND HIGEST TOTAL PAYOUT BASED ON GRADE LEVEL
select *,
nth_value(Name,2) over(partition by Grade order by Total_payout desc range between unbounded preceding and unbounded following) as 2nd_higest_earner_in_grade
from employee_gratuity;
-- 12)FIND THE FIRST 10 EMOLPYEE TO JOIN THE COMPANY BASED ON DATE OF JOINING
select * from 
(select *,
rank() over (order by Date_of_joining asc) as first_to_join
from employee_gratuity)T
where T. first_to_join <=10;
-- 13)
explain select * from employee_gratuity;
 delimiter $$
create procedure get_Employee_code(in find_Nos int)
 begin 
 select * from employee_gratuity
 where Nos=find_Nos;
 end $$
 delimiter ;
 call get_Employee_code(10);