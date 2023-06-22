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