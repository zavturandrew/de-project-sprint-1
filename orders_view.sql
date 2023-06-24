CREATE OR REPLACE VIEW analysis.orders as (

select sl.order_id, sl.dttm as order_ts,po.user_id,po. bonus_payment, po.payment, po.cost, po.bonus_grant, sl.status_id as status from production.orderstatuslog as sl
join production.orders  as po on sl.order_id= po.order_id
);