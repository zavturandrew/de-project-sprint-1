FilenameList:
1. requirements.md   +                                |   в котором будете описывать решение. В этом же документе зафиксируйте, какие поля вы будете использовать для расчёта витрины.
2. views.sql          +                               |   В этот документ вставьте код создания представлений.
3. datamart_ddl.sql    +                              |   Напишите запрос с CREATE TABLE и выполните его на предоставленной базе данных в схеме analysis. Помните, что при создании таблицы необходимо учитывать названия полей, типы данных и ограничения.
4. tmp_rfm_recency.sql  +                             |   Реализуйте расчёт витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте. Для решения предоставьте код запроса.
5. tmp_rfm_frequency.sql +                            | 
6. tmp_rfm_monetary_value.sql +                       |
7. datamart_query.sql                                |  и напишите в нём запрос, который на основе данных, подготовленных в таблицах analysis.tmp_rfm_recency,  analysis.tmp_rfm_frequency и analysis.tmp_rfm_monetary_value, заполнит витрину analysis.dm_rfm_segments. 
8. orders_view.sql                                   | Для проверки предоставьте код на языке SQL, который обновляет представление analysis.Orders
9. data_quality.md                                   |  Описание качества данных
10. README.md
    