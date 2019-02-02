
select * from orders limit 10;

select * from categories limit 10;

select * from products limit 10;

select category, prod_id, price, myrank
from
(select category, prod_id, price, rank() OVER (PARTITION BY category ORDER BY price DESC) as myrank
from products) A
where myrank <= 3;






select
	category,
	avg(price)
from
	products
group by category
order by category;

select category, prod_id, sum_amount_product, prod_rank
from
	(select D.category, D.prod_id, C.sum_amount_product,
	rank() over (partition by category order by sum_amount_product desc) as prod_rank
	from
	(	(select prod_id, sum(totalamount) as sum_amount_product
		from
			(select *
			from
			 	orders
				inner join
				(select orderid, prod_id from cust_hist) A
				on orders.orderid = A.orderid) B
			group by prod_id) C
	 	inner join 
	 	(select prod_id, category from products) D
	 	on C.prod_id = D.prod_id)) E
	 where prod_rank <= 5;
	
	 
	 
	 

select * from	 
(((
	 
select * from
(select orderid, totalamount from orders) A
inner join
(select orderid, prod_id from cust_hist) B
on A.orderid = B.orderid;



inner join
(select prod_id, category from products) D
on C.prod_id = D.prod_id) E;
	 
	 
-- base table	 
select
	 C.orderid, C.prod_id, D.price, D.category
from	 
	(select
		 A.orderid, B.prod_id
	from	 
		(select distinct(orderid) from orders) A
		inner join
		(select orderid, prod_id from cust_hist) B
		on A.orderid = B.orderid) C
	inner join
	(select prod_id, price, category from products) D
	on C.prod_id = D.prod_id;
	 

-- top 5 sales in volume per category
select G.category, G.prod_id, G.n_sales, G.n_sales_rank
from 	 
	(select
		 F.category, F.prod_id, F.n_sales,
		 rank() over (partition by F.category order by F.n_sales desc) as n_sales_rank
	from	 
		(select
			 E.category, E.prod_id, count(*) as n_sales
		from	 
			(select
				 C.orderid, C.prod_id, D.price, D.category
			from	 
				(select
					 A.orderid, B.prod_id
				from	 
					(select distinct(orderid) from orders) A
					inner join
					(select orderid, prod_id from cust_hist) B
					on A.orderid = B.orderid) C
				inner join
				(select prod_id, price, category from products) D
				on C.prod_id = D.prod_id) E 
		group by category, prod_id) F) G
where n_sales_rank <= 5;	 
