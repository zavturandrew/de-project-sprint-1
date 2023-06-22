drop view if exists analysis.orders;
create view analysis.orders as
select po.user_id,sl.order_id, po.payment, sl.status_id as status,sl.dttm as order_ts from production.orderstatuslog as sl
join production.orders  as po on sl.order_id= po.order_id