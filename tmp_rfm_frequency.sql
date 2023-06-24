drop table  if exists analysis.tmp_rfm_frequency;
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);


with CTE as                                              -- Считаем через окошки
    (
select user_id, NTILE(5) OVER(ORDER BY count( case when status= 4 then order_id= 1 else order_id= 0 end)) as frequency from analysis.orders  where date_part('year', order_ts) >= 2022  group by user_id )
insert into analysis.tmp_rfm_frequency
select * from CTE;