with customers_with_more_than_one_order as (
	select
		customerid,
		count(*)
	from
		orders
	group by
		customerid
	having 
		count(*) > 1
--		and customerid < 100
)

select
	o.customerid,
	generate_series(min(orderdate), max(orderdate), '1 day')::date days
from
	orders o
	inner join
	customers_with_more_than_one_order c
	on o.customerid = c.customerid
group by
	o.customerid
order by
	o.customerid,
	days





/*
select (date('2004-10-01') - interval '4 months')::date


select generate_series(date('2019-01-01'), date('2019-02-01'), '1 day')::date

select 
		customerid,
		extract(month from min(orderdate))::int as cohort_id
		--cast(extract(month from min(orderdate)) as int) as cohort_id
	from
		orders
	group by
		customerid
*/


with
-- cohort_id = activation month for each customer
cohorts as (
	select 
		customerid,
		extract(month from min(orderdate))::int as cohort_id
	from
		orders
	group by
		customerid
),

-- n users per cohort = n new users in month
cohorts_counts as (
	select
		cohort_id,
		count(*) n_new_users
	from
		cohorts
	group by
		cohort_id
),

-- cohort activity per month
cohorts_activity as (
	select distinct
		c.cohort_id,
		c.customerid,
		extract(month from o.orderdate)::int as activity_month,
		extract(month from o.orderdate)::int - c.cohort_id as activity_index
	from
		cohorts c
		inner join
		orders o
		on c.customerid = o.customerid
	where
		extract(month from o.orderdate)::int - c.cohort_id >= 1
),
			 
-- cohort activity counts
cohorts_activity_counts as (
	select
		cohort_id,
		activity_index,
		count(*) as n_active_users_in_cohort
	from
		cohorts_activity
	group by
		cohort_id,
		activity_index
)
			 
select
	c.cohort_id,
	a.activity_index,
	--round(cast(a.n_active_users_in_cohort as numeric) / c.n_new_users * 100, 2) as retention_pct
	round(a.n_active_users_in_cohort::numeric / c.n_new_users * 100, 2) as retention_pct
from
	cohorts_counts c
	inner join
	cohorts_activity_counts a
	on c.cohort_id = a.cohort_id
order by
	c.cohort_id,
	a.activity_index	
	 
			 
			 


/*
with

ordered_orders as(
	select
		customerid,
		orderdate,
		lag(orderdate) over(partition by customerid order by customerid, orderdate) as previous_order_date,
		orderdate - lag(orderdate) over(partition by customerid order by customerid, orderdate) as ndays_between_orders
	from
		orders
)

select
	customerid,
	count(*) as n_orders,
	avg(ndays_between_orders) as avg_ndays_between_orders
from
	ordered_orders
group by
	customerid
*/


/*

-- RANGE RETENTION

with 

-- cohort definition
-- list of all customerid who activated in a period
cohorts as (
	select
		customerid,
		cast(extract(month from min(orderdate)) as integer) as cohort_activation_period
	from
		orders
	group by
		customerid
),

-- Number of users per cohort
cohort_counts as (
	select 
		cohort_activation_period,
		count(*) as n_users_in_cohort
	from
		cohorts
	group by
		cohort_activation_period
),

-- customer IDs who were active per cohort per period following activation
cohort_activity as (
	select distinct
		c.cohort_activation_period,
		c.customerid,
		cast(extract(month from o.orderdate) as integer) as cohort_activity_period,
		cast(extract(month from o.orderdate) as integer) - c.cohort_activation_period as activity_index
	from
		cohorts c
		inner join
		orders o
		on c.customerid = o.customerid
	where
		cast(extract(month from o.orderdate) as integer) - c.cohort_activation_period >= 1
),
--select * from cohort_activity order by cohort_activation_period, activity_index, customerid

-- count number of users who returned per cohort and per period following activation
activity_counts as (
	select
		cohort_activation_period,
		activity_index,
		count(*) as n_active_users_in_cohort
	from
		cohort_activity
	group by
		cohort_activation_period,
		activity_index
)
--select * from activity_counts order by cohort_activation_period, activity_index

select
	c.cohort_activation_period,
	c.n_users_in_cohort,
	a.activity_index,
	a.n_active_users_in_cohort,
	round(cast(a.n_active_users_in_cohort as numeric) / c.n_users_in_cohort * 100, 2) as retention_pct
from
	cohort_counts c
	inner join
	activity_counts a
	on c.cohort_activation_period = a.cohort_activation_period
order by
	c.cohort_activation_period,
	a.activity_index
*/


/*
-- CLASSIC RETENTION
with

-- define cohort: users who activated X months ago (3)
-- replace date('2004-10-01') by now() if working with live dataset and want to see the last X months
cohort as (
	select
		customerid
	from 
		(select
			customerid,
	 		orderdate,
			row_number() over(partition by customerid order by orderdate asc) as order_number
		from
			orders) subq
	where
		order_number = 1
		and orderdate >= (select (date('2004-10-01') - interval '4 months')::date)
		and orderdate <= (select (date('2004-10-01') - interval '3 months')::date)	
),

-- Get one row per customer id per day if the customer was active at least once
cohort_activity as (
	select distinct
		o.orderdate::date,
		c.customerid
	from
		cohort c
		inner join
		orders o
		on c.customerid = o.customerid
	where
		orderdate > (select (date('2004-10-01') - interval '3 months')::date)
		and orderdate < (select (date('2004-10-01'))::date)
),
				 
all_dates as (
	select generate_series(
				date('2004-10-01') - interval '3 months',
				date('2004-10-01') - interval '1 day',
				'1 day')::date as date
)
					
select
	date,
	(select count(*) from cohort) as n_users_in_cohort,
	coalesce(n_active_users, 0) n_active_users_in_cohort,
	round(cast(coalesce(n_active_users, 0) as numeric) / (select count(*) from cohort) * 100, 2) as retention_pct
from
	all_dates d
	left join
	(select orderdate, count(*) as n_active_users from cohort_activity group by orderdate) c
	on d.date = c.orderdate
order by
	date
*/

			 

			 
			 
/*
-- MONTH OVER MONTH RETENTION
with cohorts as (
	select distinct
		cast(extract(month from orderdate) as integer) as month,
		customerid
	from
		orders
),

--select * from cohorts order by month, customerid

n_actvive_users_per_month as (
	select
		month,
		count(*) n_actvive_users_in_first_month
	from
		cohorts
	group by
		month
),

--select * from n_actvive_users_per_month
n_actvive_users_two_months as (
	select
		f.month,
		count(*) as n_active_users_in_first_and_second_month
	from
		cohorts f
		inner join
		cohorts s
		on f.customerid = s.customerid
		and f.month = s.month - 1
	group by
		f.month
)

select
	f.month,
	n_actvive_users_in_first_month,
	n_active_users_in_first_and_second_month,
	round(cast(n_active_users_in_first_and_second_month as numeric) / n_actvive_users_in_first_month * 100, 2) as retention_pct
from
	n_actvive_users_per_month f
	inner join
	n_actvive_users_two_months s
	on f.month = s.month
order by
	f.month
*/






/*

with cohorts as (
	select distinct
		cast(extract(month from orderdate) as integer) as month,
		customerid
	from
		orders	
	order by 
		cast(extract(month from orderdate) as integer),
		customerid
),

cohort_activity as (
	select
		customerid,
		month,
		lead(month) over(partition by customerid order by month, customerid) as next_visit_month,
		lead(month) over(partition by customerid order by month, customerid) - month as months_between_visits
	from
		cohorts
	order by
		customerid,
		month
),

classified_cohort_activity as (
	select
		customerid,
		month,
		next_visit_month,
		months_between_visits,
		case
			when months_between_visits is null then 'lost'
			when months_between_visits = 1 then 'retained'
			else 'returning'
		end as classification
	from
		cohort_activity
)

select
	month,
	round(cast(count(*) filter(where classification = 'retained') as numeric) * 100, 2) / count(*) as returning_next_month,
	round(cast(count(*) filter(where classification = 'returning') as numeric) * 100, 2) / count(*) as returning_later,
	round(cast(count(*) filter(where classification = 'lost') as numeric) * 100, 2) / count(*) as lost
from
	classified_cohort_activity
group by
	month
order by 
	month
	
	


*/



