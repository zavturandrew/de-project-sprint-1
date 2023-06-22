drop table  if exists analysis.tmp_rfm_monetary_value;
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

with by_pay_group as (
select user_id,
ROW_NUMBER() OVER (order by sum(payment)) AS payments_count
from analysis.orders
where status = 4 and date_part('year', order_ts) >= 2022
group by user_id
)
insert into analysis.tmp_rfm_monetary_value
select user_id,


case
when payments_count <= 200 then 1
when payments_count <= 400 then 2
when payments_count <= 600 then 3
when payments_count <= 800 then 4
when payments_count <= 1000 then 5
end payments_count
from by_pay_group
