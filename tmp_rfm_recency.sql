drop table  if exists analysis.tmp_rfm_recency;
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

with by_date_group as (
select user_id,
ROW_NUMBER() OVER (order by last_order) AS days_last
from (select user_id,
max(order_ts) last_order
from analysis.Orders
where status = 4 and date_part('year', order_ts) >= 2022
group by user_id) somervar
)
insert into analysis.tmp_rfm_recency
select  user_id,  case


when days_last <= 200 then 1
when days_last <= 400 then 2
when days_last <= 600 then 3
when days_last <= 800 then 4
when days_last <= 1000 then 5
end days_last
from by_date_group;

