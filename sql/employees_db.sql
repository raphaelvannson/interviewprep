show tables;



describe current_dept_emp;

describe departments;

describe dept_emp;

describe dept_emp_latest_date;

describe dept_manager;

describe employees;

describe salaries;

describe titles;



select count(*) from current_dept_emp;
select count(*) from departments;
select count(*) from dept_emp;
select count(*) from dept_emp_latest_date;
select count(*) from dept_manager;
select count(*) from employees;
select count(*) from salaries;
select count(*) from titles;





select * from current_dept_emp;
select * from departments;
select * from dept_emp;
select * from dept_emp_latest_date;
select * from dept_manager;
select * from employees;
select * from salaries;
select * from titles;



-- number of depts per employee
select emp_no, count(*) as dept_count
from current_dept_emp
group by emp_no
order by dept_count
desc;

select * from current_dept_emp;


select CURRENT_DATE();

-- current employee dept 
select count(*)
from current_dept_emp;

select emp_no
from current_dept_emp
where current_date() < to_date;



select * from (
  select current_employees.emp_no, birth_date, first_name, last_name, gender, hire_date, dept_no, from_date from
   (select * from employees where emp_no in
     (select emp_no from current_dept_emp where current_date() < to_date)
   ) as current_employees
  left join dept_emp
  on current_employees.emp_no = dept_emp.emp_no
) as emp_dept_no
left join departments
on emp_dept_no.dept_no = departments.dept_no;



--select * from
--(
select
   E.emp_no, E.birth_date, E.first_name, E.last_name, E.gender, E.hire_date,
   E.dept_no, E.from_date, E.to_date,
   E.dept_name,
   E.manager_emp_no,
   F.manager_first_name, F.manager_last_name
from(
  select
   A.emp_no, A.birth_date, A.first_name, A.last_name, A.gender, A.hire_date,
   B.dept_no, B.from_date, B.to_date,
   C.dept_name,
   D.manager_emp_no
  from employees A
  left join dept_emp B
  on A.emp_no = B.emp_no
  left join departments C
  on B.dept_no = C.dept_no
  left join (select dept_no, emp_no as manager_emp_no from dept_manager) D
  on B.dept_no = D.dept_no) as E
left join (select emp_no, first_name as manager_first_name, last_name as manager_last_name from employees) F -- where emp_no in (select emp_no from dept_manager)
on E.manager_emp_no = F.emp_no;
--where current_date() < E.to_date;
--group by emp_no
--order by occurences desc;



left join (select emp_no, first_name, last_name from employees where emp_no in (select emp_no from dept_manager)) E
on A.manager_emp_no = E.emp_no;


  E.first_name, E.last_name
  
  
  

where emp_no in (select emp_no from current_dept_emp where current_date() < to_date);


select *
from employees
left join dept_emp
on employees.emp_no = dept_emp.emp_no
where current_date() < to_date
left join departments
on dept_no = departments.dept_no;








select A.emp_no, B.salary
from employees A
left join (select salary from salaries where current_date() < to_date) B
on A.emp_no = B.emp_no;


select count(*) from titles where current_date() < to_date;

select count(*) from salaries where current_date() < to_date;

select count(*) from employees where current_date() < to_date; 


--*************************************************************
-- Average salary per department
-- Number of current salaries
select count(*) from salaries where current_date() < to_date;
--240124


-- Number of current salaries per employee (verify there is only 1 current salary per employee)
select max(n_salaries) as max_n_salaries
from
(
  (select emp_no, count(*) as n_salaries
  from salaries
  where current_date() < to_date
  group by emp_no
  order by n_salaries desc
  ) n_salaries_per_emp
);
--1


-- number of department per employee
select max(n_dept) as max_n_dept_per_emp
from
(
  (select emp_no, count(*) as n_dept
  from dept_emp
  where current_date() < to_date
  group by emp_no
  ) n_dept_per_emp
);
--1


-- departments with employes
select distinct dept_no from dept_emp;


select C.dept_no, count(distinct C.emp_no) as n_employees, min(C.salary) as min_salary, avg(C.salary) as avg_salary, max(C.salary) as max_salary
from
(
  (select A.emp_no, A.dept_no, B.salary
  from (select emp_no, dept_no from dept_emp where current_date() < to_date) A
  left join (select emp_no, salary from salaries where current_date() < to_date) B
  on A.emp_no = B.emp_no) C
)
group by C.dept_no
order by dept_no;





--*************************************************************
-- Nth percentile

set @percentile := 0.01;

select F.dept_no, max(F.salary) as percentile
from
(select D.dept_no, D.emp_no, D.salary, D.rank / E.n_emp_per_dept as salary_percentile_per_dept
  from
  (select
    C.emp_no, C.dept_no, C.salary,
    (case 
      when C.dept_no = @curDeptno
      then @curRow := @curRow + 1
      else @curRow := 1 and @curDeptno := C.dept_no
    end) + 1 as rank
    from
      (select A.emp_no, A.dept_no, B.salary
        from (select emp_no, dept_no from dept_emp where current_date() < to_date) A
        left join (select emp_no, salary from salaries where current_date() < to_date) B
        on A.emp_no = B.emp_no
      order by dept_no, salary) C,
    (select @curRow := 1, @curDeptno := '') ranker) D
  left join (select dept_no, count(distinct emp_no) as n_emp_per_dept from dept_emp group by dept_no) E
  on D.dept_no = E.dept_no
  having salary_percentile_per_dept <= @percentile) F
group by F.dept_no;


--order by salary asc;



select 
  emp_no, first_name, last_name, if(emp_no % 2 = 0, first_name, last_name) as res,
  (@rownumb := @rownumb + 1) as rownumb,
  (case 
    when emp_no % 2 = 0
    then @rownumb
    else 0
  end) as modulo
from employees, (select @rownumb := 0) ranker; 


select 
  emp_no,
  row_number() 
from employees;


select avg(salary), std(salary), pow(std(salary), 2) from salaries;






select * from titles;

select distinct title from titles where current_date() < to_date; 



Select sum(salary)
From salaries
Where  current_date() < to_date;

Select min(salary)
From salaries
Where  current_date() < to_date;



select distinct title from titles;



Select max(salary)
From  (
      salaries A
      Inner join  (
                  select emp_no
                  from titles
                   where title = 'Senior Engineer'
                  And current_date() < to_date
                 ) B
      On A. emp_no = B.emp_no
      );



select distinct dept_no from dept_emp;



Select count(*) as n_employees, avg(B.salary) as avg_salary
From
  (
  Select emp_no
  From Dept_emp
  Where dept_no = 'd001'
  And current_date() < to_date
  ) A
  Left join (select emp_no, salary
            From salaries
            Where current_date() < to_date) B
	On A.emp_no = B.emp_no;
  
  

Select max(salary), min(salary), sum(salary), avg(salary) 
From salaries
Where current_date() < to_date;




Select title, count(*)
From titles
Where current_date() < to_date
Group by title
Order by title;



Select A.title, min(B.salary), max(B.salary), (max(B.salary) - min(B.salary)) as salary_diff
From (
(Select emp_no, title
From titles
where current_date() < to_date) A
Left join
(select emp_no, salary 
From salaries
Where current_date() < to_date) B
On A.emp_no = B.emp_no
)
Group by title
Order by title;




Select E.manager_no, min(E.salary)
from
(Select C.emp_no, C.salary, C.dept_no, D.emp_no as manager_no
From
(Select A.emp_no, A.salary, B.dept_no
From (select emp_no, salary from salaries where  current_date() < to_date) A
Left join (select emp_no, dept_no from dept_emp where current_date() < to_date) B
On A.emp_no = B.emp_no) C
Left join (select dept_no, emp_no from dept_manager where current_date() < to_date) D
On C.dept_no = D.dept_no
Having C.emp_no <> manager_no) E
Group by manager_no
Order by manager_no;


Select C.dept_no, sum(C.salary)
from
(Select A.emp_no, A.salary, B.dept_no
From
(Select emp_no, salary from salaries where current_date() < to_date) A
Left join (Select emp_no, dept_no from dept_emp where current_date() < to_date) B
On A.emp_no = B.emp_no) C
Group by dept_no
Order by dept_no;




select distinct title from titles;






Select A.title, avg(B.salary)
From
	(
	(Select emp_no, title From titles Where title <> 'Senior Engineer' and current_date() < to_date) A
  Left join (Select emp_no, salary From salaries Where current_date() < to_date) B
  On A.emp_no = B.emp_no
)
Group by A.title
Order by A.title;







Select D.title, sum(C.salary), min(C.salary), max(C.salary), avg(C.salary)
  from
  (Select A.emp_no, B.salary 
    From
    (Select emp_no From dept_emp Where dept_no = 'd001' and current_date() < to_date) A
    Left join 
    (select emp_no, salary from salaries where current_date() < to_date) B
    On A.emp_no = B.emp_no) C
  Left join (select emp_no, title from titles  where current_date() < to_date) D
  On C.emp_no = D.emp_no
Group by D.title
Order by D.title;







Select B.title, max(A.salary)
from
(Select emp_no, salary 
From salaries
Where salary >= 40000
And current_date() < to_date) A
Left join (select emp_no, title from titles where current_date() < to_date) B
On A.emp_no = B.emp_no
Group by title
order by title;





Select B.dept_no, avg(A.salary), count(*) as n_employees
From
(Select emp_no, salary from salaries  where current_date() < to_date) A
Left join (select emp_no, dept_no from dept_emp where current_date() < to_date) B
On A.emp_no = b.emp_no
Group by B.dept_no
Having n_employees > 20000;


select emp_no, count(*) from salaries
group by emp_no
order by count(*) asc;








Select emp_no, count(*)
From salaries
Group by emp_no
Having count(*) > 1
Order by n_salaries asc;



Select A.emp_no from
(Select emp_no, count(*) From salaries Group by emp_no Having count(*) > 1) A;


select * from salaries limit 10;

Select emp_no, salary, from_date from
Salaries where emp_no in(
Select A.emp_no from
(Select emp_no, count(*) From salaries Group by emp_no Having count(*) > 1) A)
Order by emp_no, from_date asc;

select count(distinct emp_no) from salaries;








Select count(distinct emp_no) 
from
(Select emp_no, salary, salary * 1.15 as previous_salary, ((salary - previous_salary) / previous_salary) as salary change
From
(Select emp_no, from_date, salary 
From
  Salaries 
  where emp_no in (
    Select A.emp_no from
    (Select emp_no, count(*) From salaries Group by emp_no Having count(*) > 1) A)
    Order by emp_no, from_date asc) B
Group by emp_no
Having previous_salary <> null and salary_change > 0.1) C;



select count(distinct G.emp_no) 
from
(select F.emp_no, F.from_date, F.salary, F.previous_salary, (F.salary / F.previous_salary) as salary_change
from
(select E.emp_no, E.from_date, E.salary, (E.salary * 0.88) as previous_salary
from
  (select D.emp_no, D.from_date, D.salary  --(salary / previous_salary) as salary_change
  from
   (select B.emp_no, C.from_date, C.salary
    from  
      (select distinct emp_no from 
     (Select emp_no, count(*) From salaries Group by emp_no Having count(*) > 1) A
     ) B
      left join salaries C
      on B.emp_no = C.emp_no) D
  order by emp_no, from_date
  ) E
group by emp_no) F
having salary_change > 1.1) G;

--group by emp_no


select count(distinct(emp_no))
from
(select emp_no, count(*)
from salaries
group by emp_no
having count(*) > 10) A;



select * from employees;


select  A.first_name, 
        case 
          when count(*) = 1 then true
          else false
        end as one_gender
from
  (select first_name, gender, count(*) as n
  from employees
  group by first_name, gender) A
group by first_name
having one_gender = false;



select first_name, gender, count(*) as n
  from employees
  group by first_name, gender;




select * from salaries where current_date() < to_date;

select * from dept_emp where current_date() < to_date;


Select B.dept_no, avg(A.salary), min(A.salary) as min_salary, max(A.salary) as max_salary, count(*)
From
(Select emp_no, salary from salaries where current_date() < to_date) A
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) B
on A.emp_no = B.emp_no
Group by B.dept_no;




Select D.dept_no, C.salary
from
(Select emp_no, salary from salaries where current_date() < to_date) C
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) D
on C.emp_no = D.emp_no;



Select E.dept_no, E.salary, F.min_salary, F.max_salary
from
(Select D.dept_no, C.salary
from
(Select emp_no, salary from salaries where current_date() < to_date) C
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) D
on C.emp_no = D.emp_no) E
Left join
(Select B.dept_no, min(A.salary) as min_salary, max(A.salary) as max_salary
From
(Select emp_no, salary from salaries where current_date() < to_date) A
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) B
on A.emp_no = B.emp_no
Group by B.dept_no) F
On E.dept_no = F.dept_no
Where E.salary > F.min_salary * 1.1 and E.salary < F.max_salary * 0.9;





select G.dept_no, G.avg_salary, G.n_salaries,
  case
  when G.avg_salary < 80000 then "low"
  else "high"
  end as hl
from
(Select G.dept_no, avg(G.salary) as avg_salary, count(*) as n_salaries
from
(Select E.dept_no, E.salary, F.min_salary, F.max_salary
from
(Select D.dept_no, C.salary
from
(Select emp_no, salary from salaries where current_date() < to_date) C
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) D
on C.emp_no = D.emp_no) E
Left join
(Select B.dept_no, min(A.salary) as min_salary, max(A.salary) as max_salary
From
(Select emp_no, salary from salaries where current_date() < to_date) A
Left join
(select emp_no, dept_no from dept_emp where current_date() < to_date) B
on A.emp_no = B.emp_no
Group by B.dept_no) F
On E.dept_no = F.dept_no
Where E.salary > F.min_salary * 1.1 and E.salary < F.max_salary * 0.9) G
Group by dept_no) G;




select count(*) from salaries where salary is not null;

select count(*) from salaries where salary is null;



show tables;


select * from salaries;

select * from dept_emp;



select B.dept_no, max(A.salary) as max_salary;

select dept_no, max(salary) as max_salary
from
  (Select emp_no, salary from salaries where current_date() < to_date) A
  inner join
  (select emp_no, dept_no from dept_emp where current_date() < to_date) B
  on A.emp_no = B.emp_no
group by dept_no
having max_salary < 140000
order by dept_no;



select
  dept_no,
  sum(low_salary) / count(*) as prop_low_salaries
  from
    (select
      dept_no,
      salary,
      (case when salary < 80000 then 1 else 0 end) as low_salary
      from
        (Select emp_no, salary from salaries where current_date() < to_date) A
        inner join
        (select emp_no, dept_no from dept_emp where current_date() < to_date) B
        on A.emp_no = B.emp_no) C
group by dept_no
order by prop_low_salaries desc;



select
  dept_no,
  salary,
  (case 
      when dept_no = @curDeptno
      then @curRow := @curRow + 1
      else @curRow := 1 and @curDeptno := dept_no
    end) + 1 as rank
from


  select
    dept_no,
    salary
  from 
    (;
    
    select
      dept_no,
      salary
    from
      (Select emp_no, salary from salaries where current_date() < to_date) A
      inner join
      (select emp_no, dept_no from dept_emp where current_date() < to_date and dept_no in ('d001', 'd002')) B
      on A.emp_no = B.emp_no
      limit 20;
      ) C    
  order by dept_no, salary desc;
  
  
  group by dept_no) D,
  (select @curRow := 1, @curDeptno := '') ranker


        





select F.dept_no, max(F.salary) as percentile
from
(select D.dept_no, D.emp_no, D.salary, D.rank / E.n_emp_per_dept as salary_percentile_per_dept
  from
  (select
    C.emp_no, C.dept_no, C.salary,
    (case 
      when C.dept_no = @curDeptno
      then @curRow := @curRow + 1
      else @curRow := 1 and @curDeptno := C.dept_no
    end) + 1 as rank
    from
      (select A.emp_no, A.dept_no, B.salary
        from (select emp_no, dept_no from dept_emp where current_date() < to_date) A
        left join (select emp_no, salary from salaries where current_date() < to_date) B
        on A.emp_no = B.emp_no
      order by dept_no, salary) C,
    (select @curRow := 1, @curDeptno := '') ranker) D
  left join (select dept_no, count(distinct emp_no) as n_emp_per_dept from dept_emp group by dept_no) E
  on D.dept_no = E.dept_no
  having salary_percentile_per_dept <= @percentile) F
group by F.dept_no;





