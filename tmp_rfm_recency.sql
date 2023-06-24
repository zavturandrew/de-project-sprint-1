drop table if exists analysis.tmp_rfm_recency;
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);


with CTE as                                              -- Считаем через окошки
    (
select user_id,

NTILE(5) OVER(ORDER BY recency   ASC) AS          recency
from(
select user_id,

MAX(case when status = 4 then order_ts else TIMESTAMP '0001-01-01 00:00:00' end)
                                                  AS recency
from analysis.orders group by user_id ) AS t
    )
insert into analysis.tmp_rfm_recency select * from CTE;
