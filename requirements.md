# Витрина RFM

## 1.1. Выясните требования к целевой витрине.


-----------

{
    Необходимо готовое решение предоставления данных именнуемое далее 'витрина данных' с наименованием 'dm_rfm_segments',  метриками 'user_id', 'recency', 'frequency', 'monetary_value' c размещением в БД схеме 'analysis' со статусами заказов в статусе  'production'.'orderstatuses' 'closed' (id=4)
    По условию задачи производится усеченная инкрементальность без обновления имеющихся данных с начала 2022 года.
    Аннотация метрик: 
     User-id                                                                          ИД записи таблицы пользователей.
     Recency (пер. «давность») — сколько времени прошло с момента последнего заказа. 1 - не было заказов, 5 заказ относительно недавно.
     Frequency (пер. «частота») — количество заказов.                                1  низкая периодичность заказов, 5 частая периодичность заказов.
     Monetary Value (пер. «денежная ценность») — сумма затрат клиента.               1 - наименьшая сумма, 5 наибольшая сумма.
     
}
       



## 1.2. Изучите структуру исходных данных.

Подключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

{   Фиксация: входная таблица orders в БД схеме production. Поля: order_id, status, user_id, order_ts.

    Офф-топ комментарий: Подключение доступно, аунтефикация доступна, данные коректно отображаются. Отмечу низкий уровень дружественности для пользователя -  возьню с докерами и опечаткамив в тех.описании. Также 'убогие' инструменты. Пинг в чате есть большой лаг.
    
}


## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

Семантику см. таблицу file: data_quality.md 
-----------
БД доступна, пустых значений и дубликатов не обнаружено.

{
    исходя из DDL таблиц средствами ПО JetBrains Datagrip: 
    create table production.orderitems
(
    id         integer generated always as identity
        primary key,
    product_id integer                  not null
        references production.products,
    order_id   integer                  not null
        references production.orders,
    name       varchar(2048)            not null,
    price      numeric(19, 5) default 0 not null
        constraint orderitems_price_check
            check (price >= (0)::numeric),
    discount   numeric(19, 5) default 0 not null,
    quantity   integer                  not null
        constraint orderitems_quantity_check
            check (quantity > 0),
    unique (order_id, product_id),
    constraint orderitems_check
        check ((discount >= (0)::numeric) AND (discount <= price))
);
    create table production.orders
(
    order_id      integer                  not null
        primary key,
    order_ts      timestamp                not null,
    user_id       integer                  not null,
    bonus_payment numeric(19, 5) default 0 not null,
    payment       numeric(19, 5) default 0 not null,
    cost          numeric(19, 5) default 0 not null,
    bonus_grant   numeric(19, 5) default 0 not null,
    status        integer                  not null,
    constraint orders_check
        check (cost = (payment + bonus_payment))
);
create table production.orderstatuses
(
    id  integer      not null
        primary key,
    key varchar(255) not null
);
create table production.orderstatuslog
(
    id        integer generated always as identity
        primary key,
    order_id  integer   not null
        references production.orders,
    status_id integer   not null
        references production.orderstatuses,
    dttm      timestamp not null,
    unique (order_id, status_id)
);
create table production.products
(
    id    integer                  not null
        primary key,
    name  varchar(2048)            not null,
    price numeric(19, 5) default 0 not null
        constraint products_price_check
            check (price >= (0)::numeric)
);
create table production.users
(
    id    integer       not null
        primary key,
    name  varchar(2048),
    login varchar(2048) not null
);


orderitems:
    id  целочисленный тип данных integer,  выступает ключом с типом  PRIMARY KEY orderitems_pkey, значение генерируется СУБД автоматически (уникальность поддерживается индексом orderitems_pkey),
    product_id целочисленный тип данных integer, не может принимать пустое значение, явлется внешним ключом orderitems_product_id_fkey, уникальность поддерживается индексом orderitems_order_id_product_id_key,      
    order_id целочисленный тип данных integer, не может принимать пустое значение, явлется внешним ключом orderitems_order_id_fkey, уникальность поддерживается индексом orderitems_pkey       
    name символьный тип данных varchar имеющий ограничение по длине символьного массива с размером 2048 байта,не может принимать пустой значение,
    price вещественное число с указанной точностью numeric(19, 5) не может принимать пустое значение, имеющее значение по умолчанию 0, см. ограничение orderitems_price_check!     
    discount  вещественное число с указанной точностью numeric(19, 5) не может принимать пустое значение, имеющее значение по умолчанию 0, см. ограничение  orderitems_check check
    quantity  целочисленный тип данных integer, не может принимать пустое значение,количество больше нуля, см. ограничение  orderitems_quantity_check
Ограничения: orderitems_price_check check (price >= (0)::numeric),
                    orderitems_check check ((discount >= (0)::numeric) AND (discount <= price)),
                    orderitems_quantity_check check (quantity > 0);


orders: 
    order_id целочисленный тип данных integer, не может принимать пустое значение, выступает ключом с типом  PRIMARY KEY,
    order_ts временной тип  данных timestamp,  не может принимать пустое значение,
    user_id целочисленный тип данных integer, не может принимать пустое значение,
    bonus_payment вещественное число с указанной точностью numeric(19, 5) не может принимать пустое значение, имеющее значение по умолчанию 0,
    payment вещественное число с указанной точностью numeric(19, 5) не может принимать пустое значение, имеющее значение по умолчанию 0,
    cost вещественное число с указанной точностью numeric(19, 5) не может принимать пустое значение, имеющее значение по умолчанию 0, см. ограничение constraint orders_check!
Ограничение составное по значению   constraint orders_check  check (cost = (payment + bonus_payment));

orderstatuses:
    id целочисленный тип данных integer,  выступает ключом с типом  PRIMARY KEY orderstatuses_pkey, не может принимать пустого значения, уникальность поддерживается индексом orderstatuslog_pkey
    key символьный тип данных varchar имеющий ограничение по длине символьного массива с размером 255 байта,не может принимать пустое значение;

orderstatuslog:
    id целочисленный тип данных integer,  выступает ключом с типом  PRIMARY KEY orderstatuslog_pkey, значение генерируется СУБД автоматически (уникальность поддерживается индексом orderitems_pkey),
    order_id целочисленный тип данных integer, не может принимать пустое значение, явлется внешним ключом orderstatuslog_order_id_fkey, уникальность поддерживается индексом orderstatuslog_order_id_status_id_key,  
    status_id  целочисленный тип данных integer, не может принимать пустое значение, явлется внешним ключом orderstatuslog_status_id_fkey, уникальность поддерживается индексом  orderstatuslog_pkey,
    dttm временной тип  данных timestamp,  не может принимать пустое значение;

products: 
    id целочисленный тип данных integer, не может принимать пустое значение, выступает ключом с типом  PRIMARY KEY products_pkey , уникальность поддерживается индексом products_pkey, 
    name символьный тип данных varchar имеющий ограничение по длине символьного массива с размером 2048 байта,не может принимать пустое значение; 
    price целочисленный тип данных integer, не может принимать пустое значение, см. ограничение products_price_check!            
Ограничение: products_price_check check (price >= (0)::numeric)

users: 
     id целочисленный тип данных integer, не может принимать пустое значение, выступает ключом с типом  PRIMARY KEYusers_pkey, уникальность поддерживается индексом users_pkey, 
     name символьный тип данных varchar имеющий ограничение по длине символьного массива с размером 2048 байта, может принимать пустое значение; 
     login символьный тип данных varchar имеющий ограничение по длине символьного массива с размером 2048 байта, не может принимать пустое значение; }




## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

см. файл views.sql

Вас попросили обращаться только к объектам из схемы analysis при расчёте витрины. Чтобы не дублировать данные, которые находятся в этой же базе, сделайте представления. Представления будут находиться в схеме analysis и отображать данные из схемы production.  

Напишите SQL-запросы, чтобы создать пять представлений (по одному на каждую таблицу):
Users, OrderItems,OrderStatuses,Products,Orders.
Выполните написанные SQL-скрипты.
Создайте документ views.sql. В этот документ вставьте код создания представлений.

```SQL
--Впишите сюда ваш ответ
                                                         -- Начало блока вьюшек--
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
                                                         -- Конец блока вьюшек--


```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

см. файл datamart_ddl.sql

Далее вам необходимо создать витрину. Напишите запрос с CREATE TABLE и выполните его на предоставленной базе данных в схеме analysis. Помните, что при создании таблицы необходимо учитывать названия полей, типы данных и ограничения.
Создайте документ datamart_ddl.sql и сохраните в него написанный запрос.

```SQL
--Впишите сюда ваш ответ
create table if not exists analysis.dm_rfm_segments      -- Создаем витрину dm_rfm_segments при условии если ранее не существовала
(
    user_id        integer not null
        primary key,
    recency        integer not null
        constraint dm_rfm_segments_recency_check
            check (recency         between 1 and 5),
    frequency      integer not null
        constraint dm_rfm_segments_frequency_check
            check (frequency       between 1 and 5),
    monetary_value integer not null
        constraint dm_rfm_segments_monetary_value_check
            check (monetary_value  between 1 and 5)

);

comment on table analysis.dm_rfm_segments is 'RFM project showcase from sprint number 1';

comment on column analysis.dm_rfm_segments.user_id is 'ref this.id to production.users';

comment on column analysis.dm_rfm_segments.recency is 'recency category computed value of Client(user) by date ';

comment on column analysis.dm_rfm_segments.frequency is 'calculated value of order frequency category by Client(user) by calc count pts';

comment on column analysis.dm_rfm_segments.monetary_value is 'calculated value of the category of cash spending of orders by the Client (user)';

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Выполнить:
1. tmp_rfm_recency.sql
2. tmp_rfm_frequency.sql
3. tmp_rfm_monetary_value.sql
4. datamart_query.sql


```SQL
--Впишите сюда ваш ответ


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

insert into analysis.dm_rfm_segments
select f.user_id as user_id, f.recency as frequency, m.recency as monetary_value, r.recency as recency from analysis.tmp_rfm_frequency as f 
join analysis.tmp_rfm_monetary_value as m on m.user_id= f.user_id join analysis.tmp_rfm_recency as r on f.user_id=r.user_id



/*
0,3,4,1
1,3,3,4
2,3,5,2
3,3,3,2
4,3,3,4
5,5,5,5
6,3,5,1
7,3,2,4
8,1,3,1
9,2,2,1
10,4,2,3

*/
```

### 2. Доработка представлений

Вместо поля с одним статусом разработчики добавили таблицу для журналирования всех изменений статусов заказов — production.OrderStatusLog.
Структура таблицы production.OrderStatusLog: 
id — синтетический автогенерируемый идентификатор записи,
order_id — идентификатор заказа, внешний ключ на таблицу production.Orders,
status_id — идентификатор статуса, внешний ключ на таблицу статусов заказов production.OrderStatuses,
dttm — дата и время получения заказом этого статуса.
Чтобы ваш скрипт по расчёту витрины продолжил работать, вам необходимо внести изменения в то, как формируется представление analysis.Orders: вернуть в него поле status. Значение в этом поле должно соответствовать последнему по времени статусу из таблицы production.OrderStatusLog.
Для проверки предоставьте код на языке SQL, который обновляет представление analysis.Orders.
Создайте документ orders_view.sql и сохраните в нём написанный запрос.

см. файл orders_view.sql

```SQL

drop view if exists analysis.orders;   --Рефакт вьюшки под прежние алгоритмы.
create view analysis.orders as
select po.user_id,sl.order_id, sl.status_id as status,sl.dttm as order_ts from production.orderstatuslog as sl
join production.orders  as po on sl.order_id= po.order_id where sl.status_id =4

```SQL