--Stored Procedures & Triggers
--
--1------------------------------Stored Procedures
--Excution:
--query -> Parse -> Optimize -> Query tree -> Excution Plan
--query -> Syntax -> Metadata -> From where select -> Memory (EX:joins or Subqueries)
--any query, view or Function pass the Excution every time it runs 
--Stored Procedures pass the Excution First time Only & Save The Query Tree 
--Second Time The Procedure Run will start from  Excution Plan
--So Stored Procedures Is Best For Preformance
--best for network wise because of small character (calling procedure insted of quer)
--Hide objects Names(Tables, Functions, Views) For Security
--Write DML Queries in Stored Procedures (select - Insert - Update - Delete)
--flexability Can Use restrict like If, try Catch or while loop
--Avoid Errors (Catch Errors) on Database
--Can Use Parameters (UnLike Views)
--Hide Businuss Rules
--Calling Functions Or Views Inside Stored Procedures
--

select * from student
go
create procedure GetStByID @i int
as select * from student where id=@i
go
getstbyid 80 --Calling Procedure
---------
go 
Create Procedure InsertSt @FN varchar (30) as
insert into student(fname) values (@fn)
go
InsertSt 'Omar'  --Calling Procedure

drop Procedure InsertSt
---------
--Using If to void Errors or Duplicated data
drop Procedure InsertSt
go 
Create Procedure InsertSt @FN varchar (30) as
if not exists(select fname from student where fname=@fn)
insert into student(fname) values (@fn)
else
select 'Name Already Exsist, Change The Name & Try Again'
go
InsertSt 'am'  --Calling Procedure

----

drop Procedure InsertSt
go 
Create Procedure InsertSt @i int, @FN varchar (30) as
 begin try
 insert into student(id,fname) values (@i,@fn)
end try
begin catch
select 'Name Already Exsist, Change The Name & Try Again'
end catch
go
InsertSt 2,'mr'  --Calling Procedure
--
--
---------------------Using With view
--Creating view 
drop view if exists al
go
create view al with encryption
as 
select * from student
with check OPTION
go
--Callin View
select * from  al
--Adding View to Stored Procedure
drop proc if exists GetAll
go
create proc GetAll 
with encryption 
as 
select * from  al
--Caling Stored Procedure
GetAll
-----------------------
--default values (parameters)
--1-Call By Position
go
create proc SumN @x int=0 ,@y int=0
as select @x+@y

SumN				--no parameters, just Default 0
SumN 700			--One Parameter & one Default 700
SumN 632,600		--two Parameters 1232
--
--1-Call By Name
go
create proc SumH @x int=100 ,@y int=200
as select @x+@y

SumH				--no parameters, just Default 300
SumH 700			--One Parameter & one Default 900
SumH 632,600		--two Parameters 1232
--By Name
SumH				--no parameters, just Default 300
SumH @y=700			--One Parameter & one Default 800
SumH @x=700			--One Parameter & one Default 900
SumH @y=632,@x=600		--two Parameters 1232
------------------------------
--insert data in new table 

select * from student
go
drop Procedure if exists GetStByID
go
create procedure GetStByID @i int
as select * from student where id=@i
--insert based on execute
--using execute is mandatory

insert into kid(kid,kname)
execute getstbyid 2 --Calling Procedure

------
--simple insert 
insert into tableName values ()
--insert constructor
insert into tableName  (),(),(),(),(),()
--insert based on select 
insert into tableName select * from Tablex
--Bulk insert
insert from file
--insert based on execute [from procedure]
insert into tableName(id,Fname)
execute procedureName  

-----------------------------
--Return Data From Stored Procedure
--Return always return int only & one value
--can't return nchar or other data type
--Like Scalar Function
--teh value written by DB Dev
--1-return parameter
select * from student
go
drop Procedure if exists GetStByN
go
create procedure GetStByN @i varchar(30)
as
declare @x int		--declare variable
select @x=id from student where Fname=@i
return @x			--return int 

--on calling 
drop Procedure if exists InsertSt
go 
Create Procedure InsertSt @i int, @FN varchar (30) 
as
 begin try
 insert into student(id,fname) values (@i,@fn)
 return 200		--return type int refere to 200 ok
end try
begin catch
select 'Name Already Exsist, Change The Name & Try Again'
return 404		--return type int refere to 404 not found
end catch
go

--Calling Procedure & Store result [return Value] into Variable
declare @y int
exec  @y= InsertSt 5,'MMR'
select @y as result

---------------------------
--2-output Parameter into Stored Procedure

select * from student
drop procedure if exists GetStByN
go
create procedure GetStByN @i varchar(10),@y int output		--output parameter
as select @y=id from student where fname=@i
go

--save id [output] into variable result [output]
--this get one row only [record]
--this get the last row if data are duplicated 
declare @result int
execute GetStByN 'mmr',@result output
select @result

----
--2 outputs
select * from student
go
create procedure GetSt_Age_Name @i int,@y int output,@z nvarchar(40) output--output parameter
as select @y=age,@z=fname from student where id=@i
go

declare @w int,@e char(20)
execute GetSt_Age_Name 6,@w output,@e output
select @w as age ,@e as name

-----------
--3-input - output prameter
--y on procedure will be the value of w (6) 
--where runs before select so @y will be input for id  [id=6]
--when goes to select @y will be the output of age
select * from student
go
create procedure GetSt_Age_Nam @y int output,@z nvarchar(40) output--output parameter
as select @y=age,@z=fname from student where id=@y
go

declare @w int=6,@e char(20)
execute GetSt_Age_Nam @w output,@e output
select @w as age ,@e as name

---------------------------
--Dynamic Procedure query
--worest preformance Procedure because the query runs in runtime.
--For developers only
go
Create  proc GetData @col char(20),@t char(20)
with encryption
as 
execute('select '+@col+'from '+@t)

GetData '*','student'
GetData '*','exam'
GetData '*','kid'
-------------------------------
--Stored Procedure types

--1-Built-in SP
--starts with sp_
sp_helptext
sp_helptext'GetSt_Age_Nam'
sp_bindrule
sp_addtype

--2-User Defined SP
--Create procedure & calling

--3-Trigger
--can't call, has No Parameter
--implicit code 
--Like Event Listener on jS
-- the trigger fired if the query get rows or not
--inherit table schema by Default
--after[for update],instead of
go
create trigger T1
on Student after insert 
as 
select 'One Row Inserted Successfully' as Result
--
insert into student(id,fname,age) values (11,'Mostafa',26)

------
go
create trigger t2
on student after update
as
select getdate() as Update_Time
--
update student set id=12 where id=11

----
--instead of
--disable update for user
go
create trigger t3 
on student
instead of Update
as
select 'not allawed for user '+SUSER_NAME()

update student set id=10 where id=12

-----
--Making Table Read Only
drop trigger if exists t3
go
create trigger t4
on student
instead of insert,update,delete
as 
select SUSER_NAME(),getdate()

update student set id=10 where id=12
insert into student(id,fname,age) values (13,'Mohamed',20)

--Disable Trigger
--the trigger created on the table so we alter the table 
alter table student disable trigger t4
--
delete from student where id=10
--
--Enable Trigger
alter table student enable trigger t4
----------
--the trigger uses schema like tables
create schema dat

create table dat.student(id int primary key,Fname char(10),Lname char(10),age int,)

insert into dat.student(id,Fname,Lname,age) 
values(1,'Mostafa','Mahmoud',26),(2,'alaa','Mahmoud',30),(3,'ahmed','Mahmoud',34),
	  (4,'omar','ahmed',6),(5,'Assem','Mahmoud',4),(6,'asmaa','Mahmoud',24)

create trigger T_dat
on dat.student
instead of delete
as 
select 'Can not Delete'

delete from dat.student where id=6 --can't delete
--to disable trigger
--we must use schema on alter as the table schema
alter table dat.student disable trigger T_dat
delete from dat.student where id=6 --one row affected

---------------------------------------
--trigger for update == trigger after update 
-- the trigger fired if the query get rows or not

drop trigger if exists  t4,t2

go
create trigger t4
on student
 for update -- after update 
as 
select SUSER_NAME(),getdate()

update student set id=10 where id=1000	-- there is no id =1000 
-- Zero row affected because if id but the trigger still fired

--------------------using Update as Function into triggers
drop trigger if exists  t4
go
create trigger t4
on student
 for update -- after update 
as 
if update(age)		--using update as FN to fire trigger on age column only of student table
select SUSER_NAME(),getdate()

--the triggrt fired only if we update age column
update student set age=30 where id=1
--if updating any other column we get  (1 row affected)
update student set fname='salah' where id=1

-----------------------------
--Trigger with Inserted - Deleted
--
--inserted, Deleted Are Tables Built-in But Can't Use outside Triggers
--Useful to Know What Inserted or Deleted Are & To Watch the changes of Any Operations
--Like: Insert,Update,Delete On The Table
drop trigger if exists C_D
go
Create trigger C_D
on student
after update,insert,Delete
as 
select * from inserted
select * from deleted

--Create Two Tables For inserted , Deleted 
--If Use Insert The inserted Table Will Show The Inserted Record & Deleted Will Be Empty
insert into student values (17,'MMR',38)
--If Use Delete The Deleted Table Will Show The Deleted Record  & Inserted Will Be Empty
Delete from student Where id =17
--If Use Update The inserted Table Will Show The Updated Record & Deleted Table Will Show The Modified Record
update student set fname='Omar',age=18 where id=9
--
-------------------------------------------------
--Prevent Users From insert into Student Table On Tuesday
select datename(dw,getdate()) -- to Know The Day Name
--First Trigger With Instead Of
drop trigger if exists Ins
go
create trigger Ins
on student
instead of insert
as 
if datename(dw,getdate())='Tuesday' --To Compare The Day Name 
Select 'Can not insert Users on Tuesday'
--
insert into student values (20,'Ahmed',27)

-------
select format(getdate(),'dddd') -- to Know The Day Name
--Second Trigger With After Insert
drop trigger if exists Ins
go
create trigger Ins
on student
for insert --after insert
as 
if format(getdate(),'dddd')='Tuesday' --To Compare The Day Name 
begin
Select 'Can not insert Users on Tuesday'
delete from student Where id in(select id from inserted)
end
--
insert into student values (19,'Yaser',27)
--------------
-------
select format(getdate(),'dddd') -- to Know The Day Name
--Third Trigger With After Insert
drop trigger if exists Ins
go
alter trigger Ins
on student
instead of insert --after insert
as 
if format(getdate(),'dddd')!='Tuesday' --To Compare The Day Name 
begin
insert into student
Select * from inserted
end
Select 'Can not insert Users on Tuesday'

--
insert into student values (24,'Yaser',20)

---------------------------------------------------------
--Create Auditing Table [Report] for Updating
--create table if not exists
--U = User table 
-- sysobjects is a Built-in view Contains one row for each object that is created within a database
--such as a constraint, default, log, rule, and stored procedure.  #MS Docs
--The Trigger Fire When Updating ID From Student & Prevent Update
-- Once it is Fired A new Table Created Called Report To Collect Data 
--Of UserName, The Date, The Old ID, The New ID

drop trigger if exists t10
go
create trigger t10
on student
instead of update
as
if update(id)
begin
if not exists (select * from sysobjects where name='report' and xtype='U')
create table report(_User Nvarchar(70),_date date,_old int,_New int)
declare @new int ,@old int
select @old =id from deleted
select @new =id from inserted
insert into report
values (SUSER_NAME(),getdate(),@old,@new)
end
----
--will not Fired
update student set id=30 where  fname='MMR'




































