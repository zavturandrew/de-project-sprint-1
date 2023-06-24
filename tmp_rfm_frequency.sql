drop table  if exists analysis.tmp_rfm_frequency;
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);


with CTE as                                              -- Считаем через окошки
    (
select user_id,
NTILE(5) OVER(ORDER BY recency ASC) AS          recency
from(
select user_id,
SUM(case when status = 4 then 1 else 0 end) AS       recency

from analysis.orders  where date_part('year', order_ts) >= 2022 group by user_id ) AS t
    )
insert into analysis.tmp_rfm_frequency
select * from CTE;