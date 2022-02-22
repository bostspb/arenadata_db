--
-- Лабораторная работа №2 ч3 - Загрузка данных из СУБД Oracle на примере PXF
--
/*
1. Создайте аналоги stage-таблиц stg_provodki_rnd и dm_provodki_rnd, но распределенные по полю dbacc.
2. Постфикс у таблиц укажите _id вместо _rnd.
3. Создайте аналог процедуры загрузки sp_provodki_operday_load используя созданные таблицы 
   dim_clients_id, 
   dim_accounts_hist_id, 
   stg_provodki_id, 
   dm_provodki_id.
4. Создайте аналог процедуры загрузки sp_provodki_operday_load используя созданные таблицы 
   dim_accounts_hist_id, 
   stg_provodki_id, 
   dm_provodki_id,
   dim_clients_rep.
5. Замерьте время выполнения каждой из версий: 
   sp_provodki_operday_load, 
   sp_provodki_operday_load_id, 
   sp_provodki_operday_load_rep
*/
