drop table  if exists analysis.tmp_rfm_frequency;
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

with by_freq_group as (
select user_id,
ROW_NUMBER() OVER (order by count(order_id)) AS freqs_count
from analysis.orders
where status = 4 and date_part('year', order_ts) >= 2022
group by user_id
)
insert into analysis.tmp_rfm_frequency

select user_id, case

when freqs_count <= 200 then 1
when freqs_count <= 400 then 2
when freqs_count <= 600 then 3
when freqs_count <= 800 then 4
when freqs_count <= 1000 then 5
end
 from by_freq_group;


