--
-- Лабораторная работа №2 ч2 - Загрузка данных из СУБД Oracle на примере PXF
--
/*
1. Создайте аналоги таблиц-справочников dim_clients_rnd, dim_accounts_hist_rnd, но распределенные по полям:
  • Клиенты по полю clientcode
  • Счета по полю acccode
2. Постфикс у таблиц укажите _id вместо _rnd
3. Выполните инициализирующаю загрузку cчетов:
   insert into etl.dim_accounts_hist_id
   select *
     ,'05.01.2020'::date date_from
     ,'12.31.2100'::date date_to
   from etl.stg_accounts_id;
4. Создайте аналоги процедур загрузки stage-таблиц sp_dim_client_rnd_full_load,
   sp_dim_account_hist_rnd_merge, но для новых таблиц:
5. В загрузке счетов используется вспомогательная таблица stg_accounts_new_id, в ней содержаться измененные данные по счетам.
6. Замерьте время выполнения каждой из версий:
   • sp_dim_client_rnd_full_load, sp_dim_client_id_full_load, sp_dim_client_rep_full_load
   • sp_dim_account_hist_rnd_merge, sp_dim_account_hist_id_merge
*/