drop table if exists analysis.tmp_rfm_monetary_value;
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

with CTE as                                              -- Считаем через окошки
    (
select user_id,

NTILE(5) OVER(ORDER BY monetary_value  desc) AS          monetary_value

from(
select user_id,

SUM(case when status = 4 then payment  else 0 end) AS monetary_value


from analysis.orders  where date_part('year', order_ts) >= 2022 group by user_id ) AS t
    )
insert into analysis.tmp_rfm_monetary_value select * from CTE;
