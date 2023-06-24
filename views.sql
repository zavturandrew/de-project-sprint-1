drop view if exists analysis.Orders;
create view analysis.Orders as
    (
    select * from production.orders
       );

drop view if exists analysis.OrderItems;
create view analysis.OrderItems as
    (
       select * from production.orderitems
       );

drop view if exists analysis.OrderStatuses;
create view analysis.OrderStatuses as
    (
       select * from production.orderstatuses
       );


drop view if exists analysis.Users;
create view analysis.Users as
    (
       select * from production.users
       );

drop view if exists analysis.Products;
create view analysis.Products as
    (
       select * from production.products
       );