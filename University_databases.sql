-- Zaprojektuj bazę danych dla UNIWERSYTETU 
USE master;
IF EXISTS(select * from sys.databases where name='university')
ALTER DATABASE university SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE if exists university
go
CREATE DATABASE university
go
USE university
go

--Uniwersytet przechowuje dane o studentach: nazwisko, imię, wiek i numer grupy
--dziekańskiej. Aktualnie istnieją następujące numery grup: DMIe1001, DMZm1003,
--ZMZm2001, ZMIe2001. Student nie musi być przypisany do grupy.

CREATE TABLE students (
student_id int identity primary key,
surname varchar(30) not null,
first_name varchar(25),
date_of_birth date,
group_no char(10),
foreign key (group_no) references groups
on delete no action on update cascade
);

create table groups (
group_no char(10) primary key);
insert into groups values ('DMIe1001');
insert into groups values ('DMZm1003');
insert into groups values ('ZMZm2001');
insert into groups values ('ZMIe2001');

--Studenci dokonują płatności. Podczas rejestracji wpłaty w bazie danych zapisywane
--są: dane wpłacającego studenta oraz kwota i data wpłaty. Jeden student może dokonać
--wielu wpłat.

create table tuition_fees (
payment_id int identity primary key,
student_id int not null,
fee_amount smallmoney not null,
date_of_payment date not null default current_timestamp,
constraint rtfs foreign key (student_id) references students (student_id) 
on delete no action on update no action);

--Należy przechowywać dane dotyczące wykładów: nazwę wykładu (nazwy wykładów są unikalne),
--liczbę godzin w semestrze przewidzianą na dany wykład, dane prowadzącego wykładowcy
--(nie muszą być znane w chwili rejestracji wykładu w bazie danych), identyfikator 
--poprzedzającego wykładu (poprzedzający wykład może być maksymalnie jeden) oraz nazwę 
--katedry odpowiedzialnej za obsadę wykładowcy dla wykładu, znaną w chwili rejestracji 
--nowego wykładu. Wykładem poprzedzającym jest jeden z wykładów zarejestrowanych w bazie 
--danych. Nazwy katedr są ustalone

create table modules (
module_id int identity primary key,
module_name varchar(50) unique not null,
no_of_hours tinyint not null,
lecturer_id int,
preceding_module int references modules (module_id),
department varchar(100) not null,
foreign key (lecturer_id) references lecturers
on delete no action on update no action,
foreign key (department) references departments
on delete no action on update cascade,
check (no_of_hours <= 60)
);

create table departments (
department varchar(100) primary key);

create table lecturers (
lecturer_id int primary key,
acad_position varchar(40),
department varchar(100) not null,
foreign key (acad_position) references acad_positions 
on delete no action on update cascade,
foreign key (lecturer_id) references employees (employee_id) on delete cascade,
foreign key (department) references departments (department) on delete no action on update cascade
);

--Studenci zapisują się na wykłady. Jeden student może uczęszczać na wiele wykładów.
--Na jeden wykład może uczęszczać wielu studentów. Podczas rejestracji studenta na wykład
--od razu lub w późniejszym terminie ustalana jest planowana data egzaminu.

create table students_modules (
student_id int not null,
module_id int not null,
planned_exam_date date,
primary key (student_id, module_id),
foreign key (module_id) references modules on delete no action,
foreign key (student_id) references students on delete cascade
);

--Uniwersytet przechowuje dane o wszystkich swoich pracownikach (nazwisko,
--imię, datę zatrudnienia, PESEL). O tych pracownikach, którzy są wykładowcami
--przechowywane są dodatkowo: stopień bądź tytuł naukowy oraz nazwa katedry,
--w której pracuje dany wykładowca. Jak zostało to wcześniej wskazane, nazwy 
--katedr są ustalone.

create table employees (
employee_id int identity primary key,
surname varchar(30) not null,
first_name varchar(25) not null,
employment_date date,
PESEL char(11));

--Od stopnia (tytułu) naukowego zależy stawka za godziny nadliczbowe. Istniejące 
--stopnie (tytuły) naukowe (w nawiasie podano stawkę za jedną godzinę nadliczbową): 
--magister (40), doktor (45), profesor nadzwyczajny (50), doktor habilitowany (60),
--habilitowany profesor nadzwyczajny (65), profesor zwyczajny (80).
--Stopień/tytuł naukowy wykładowcy może być nieznany.

create table acad_positions (
acad_position varchar(40) primary key,
overtime_rate smallmoney not null);

insert into acad_positions values ('master','40');
insert into acad_positions values ('doctor','45');
insert into acad_positions values ('associate professor','50');
insert into acad_positions values ('habilitated doctor','60');
insert into acad_positions values ('habilitated associate professor','65');
insert into acad_positions values ('full professor','80');

--ależy przechowywać oceny studentów. Rejestracja oceny odbywa się w ten sposób, że 
--zapisywane są dane o studencie, wykładzie, data otrzymania oceny oraz sama ocena. 
--Istnieje możliwość otrzymania wielu ocen przez tego samego studenta z tego samego 
--wykładu. Każdy taki przypadek musi być zarejestrowany pod inną datą. Aktualnie skala 
--ocen jest następująca: 2, 3, 3.5, 4, 4.5, 5, 5.5, 6. 

create table grades (
grade decimal(2,1) primary key);

insert into grades values (2);
insert into grades values (3);
insert into grades values (3.5);
insert into grades values (4);
insert into grades values (4.5);
insert into grades values (5);
insert into grades values (5.5);
insert into grades values (6);

create table student_grades (
student_id int,
module_id int,
exam_date date,
grade decimal(2,1) not null,
primary key (student_id, module_id, exam_date),
foreign key (student_id, module_id) references students_modules 
on delete cascade on update cascade,
foreign key (grade) references grades on delete no action on update cascade
);