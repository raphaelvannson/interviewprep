select * from product_tests;




select product_id, test_id, test_result, count(*) as n
from product_tests
group by product_id, test_id, test_result;



select product_id, test_id, max(n) as max_n
from
  (select product_id, test_id, test_result, count(*) as n
  from product_tests
  group by product_id, test_id, test_result) A
group by product_id, test_id;






select A.product_id, A.test_id, A.test_result, A.n, B.max_n
from
  (select product_id, test_id, test_result, count(*) as n
  from product_tests
  group by product_id, test_id, test_result) A
left join
  (select product_id, test_id, max(n) as max_n
  from
    (select product_id, test_id, test_result, count(*) as n
    from product_tests
    group by product_id, test_id, test_result) A
  group by product_id, test_id) B
on A.product_id = B.product_id and A.test_id = B.test_id and A.n = B.max_n;






select G.product_id, G.test_id, F.test_result, F.n
from
(select distinct product_id, test_id from product_tests) G
left join 
(select D.product_id, D. test_id, D.test_result, D.n, E.n_best
from
(
  select B.product_id, B.test_id, B.test_result, B.n, C.max_count
  from
   (select product_id, test_id, test_result, count(*) as n
   from product_tests
   group by product_id, test_id, test_result) B
  left join
   (select A.product_id, A.test_id, max(n) as max_count
   from
   (select product_id, test_id, test_result, count(*) as n
   from product_tests
   group by product_id, test_id, test_result) A
   group by product_id, test_id) C
  on B.product_id = C.product_id and B.test_id = C.test_id
  having n = max_count) D
left join
 (select D.product_id, D. test_id, count(*) as n_best
  from 
  (
   select B.product_id, B.test_id, B.test_result, B.n, C.max_count
   from
    (select product_id, test_id, test_result, count(*) as n
    from product_tests
    group by product_id, test_id, test_result) B
   left join
    (select A.product_id, A.test_id, max(n) as max_count
    from
      (select product_id, test_id, test_result, count(*) as n
        from product_tests
        group by product_id, test_id, test_result) A
    group by product_id, test_id) C
   on B.product_id = C.product_id and B.test_id = C.test_id
   having n = max_count) D
group by product_id, test_id) E
on D.product_id = E.product_id and D.test_id = E.test_id
having n_best = 1) F
on G.product_id = F.product_id and G.test_id = F.test_id;













Select distinct product_id, test_id
From product_tests C
Left join
(Select B.product_id, B.test_id, B.test_result, B.max_result_count, count(*) as max_result_count
from 
(Select A.product_id, A.test_id, A.test_result, max(A.result_count) as max_result
  From
          (Select product_id, test_id, test_result, count(*) as result_count
          From product_tests
          Group by product_id, test_id, test_result) A
Group by A.product_id, A.test_id, A.test_result) B
Group by B.product_id, B.test_id, B.test_result
Having max_result_count = 1) D
On C.product_id = D.product_id and C.test_id = D.test_id;




      select A.product_id, A.test_id, A.test_result, A.result_count, max(A.result_count) as max_result_count
      from;
      

select H.product_id, H.test_id, I.test_result, I.max_test_result_count
from
(select distinct product_id, test_id from product_tests) H
left join
(select F.product_id, F.test_id, G.test_result, G.max_test_result_count
from
  (select D.product_id, D.test_id, count(*) as max_count
  from
    (select B.product_id, B.test_id, B.test_result, B.test_result_count, C.max_test_result_count
     from
      (Select product_id, test_id, test_result, count(*) as test_result_count
      From product_tests
      Group by product_id, test_id, test_result) B
    left join 
      (select A.product_id, A.test_id, max(test_result_count) as max_test_result_count
        from
        (Select product_id, test_id, test_result, count(*) as test_result_count
        From product_tests
        Group by product_id, test_id, test_result) A
      group by A.product_id, A.test_id) C
      on B.product_id = C.product_id and B.test_id = C.test_id
    having test_result_count = max_test_result_count) D
  group by D.product_id, D.test_id 
  having max_count = 1) F
left join
  (select E.product_id, E.test_id, E.test_result, max(E.test_result_count) as max_test_result_count
  from
       (Select product_id, test_id, test_result, count(*) as test_result_count
       From product_tests
       Group by product_id, test_id, test_result) E
    group by E.product_id, E.test_id) G
on F.product_id = G.product_id and F.test_id = G.test_id) I
on H.product_id = I.product_id and H.test_id = I.test_id;


select * from product_tests;
           
           




