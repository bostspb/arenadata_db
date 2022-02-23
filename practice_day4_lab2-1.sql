--
-- Лабораторная работа №2 ч1 - Загрузка данных из СУБД Oracle на примере PXF
--
/*
1. Создайте аналоги stage-таблиц stg_clients_rnd, stg_accounts_rnd, stg_provodki_rnd, но распределенные по полям:
   • Клиенты по полю clientcode
   • Счета по полю acccode
   • Проводки по полю dbacc
2. Постфикс у таблиц укажите _id вместо _rnd
3. Создайте аналоги процедур загрузки stage-таблиц 
   sp_stg_client_rnd_load,
   sp_stg_account_rnd_load, 
   sp_stg_provodki_rnd_load, но для новых таблиц.
4. Замерьте время выполнения каждой из версий:
   • sp_stg_client_rnd_load, sp_stg_client_id_load
   • sp_stg_accoun_rnd_load, sp_stg_account_id_load
   • sp_stg_provodki_rnd_load, sp_stg_provodki_id_load
*/

create table stg_clients_id (like stg_clients_rnd)
distributed by (clientcode);

create table stg_accounts_id (like stg_accounts_rnd)
distributed by (acccode);

create table stg_provodki_id (like stg_provodki_rnd)
distributed by (dbacc);


-------------------------------------
-------------------------------------


CREATE OR REPLACE FUNCTION etl.sp_stg_client_id_load()
	RETURNS void
	LANGUAGE plpgsql
	VOLATILE
AS $$
	
declare
    v_function text := 'sp_stg_client_id_load';
    v_location text;

begin
    v_location := 'Truncate stg_clients_id';
    truncate etl.stg_clients_id;
    insert into etl.stg_clients_id
    select *
            ,md5(fio||'|'||inn||'|'||gender||'|'||to_char(birthdate,'ddmmyyyy')||'|'||doc_seria||'|'||doc_number)::uuid
            ,now()
            ,'ABS'
            ,1
    from etl.stg_clients_ext;

exception
    when others then
        raise exception '(%:%:%)', v_function, v_location, sqlerrm;
end;

$$
EXECUTE ON ANY;


-----------------------------------
-----------------------------------


CREATE OR REPLACE FUNCTION etl.sp_stg_account_id_load()
	RETURNS void
	LANGUAGE plpgsql
	VOLATILE
AS $$
	
declare
    v_function text := 'sp_stg_account_id_load';
    v_location text;

begin
    v_location := 'Truncate stg_accounts_id';
    truncate etl.stg_accounts_id;
    insert into etl.stg_accounts_id
    select *
            ,md5(acccode||'|'||accnum||'|'||accname||'|'||to_char(opendate,'ddmmyyyy')||'|'||to_char(COALESCE(closedate,'12.31.2100'),'ddmmyyyy')||'|'||clicode)::uuid
            ,now()
            ,'ABS'
    from etl.stg_accounts_ext;

exception
    when others then
        raise exception '(%:%:%)', v_function, v_location, sqlerrm;
end;

$$
EXECUTE ON ANY;


------------------------------------------
------------------------------------------


CREATE OR REPLACE FUNCTION etl.sp_stg_provodki_id_load(p_operday date)
	RETURNS void
	LANGUAGE plpgsql
	VOLATILE
AS $$
	
declare
    v_function text := 'sp_stg_provodki_id_load';
    v_location text;

begin
    v_location := 'Truncate stg_provodki_id';
    truncate etl.stg_provodki_id;
    v_location := 'Insert into stg_provodki_id';
    insert into stg_provodki_id
    select proid,
           operday,
           dbacc,
           dbcur,
           cracc,
           crcur,
           dbsum,
           crsum,
           purpose,
           md5(to_char(operday,'ddmmyyyy')||'|'||dbacc||'|'||dbcur||'|'||cracc||'|'||crcur||'|'||dbsum||'|'||crsum||'|'||purpose)::uuid,
           now(),'ABS'
    from stg_provodki_ext
    where operday = p_operday;

exception
    when others then
        raise exception '(%:%:%)', v_function, v_location, sqlerrm;
end;

$$
EXECUTE ON ANY;


---------------------------------------
---------------------------------------


explain analyze select sp_stg_client_rnd_load();  -- 10559.584 ms
explain analyze select sp_stg_client_id_load();  -- 8964.564 ms

explain analyze select sp_stg_account_rnd_load();  -- 23371.105 ms
explain analyze select sp_stg_account_id_load();  -- 34845.256 ms

explain analyze select sp_stg_provodki_rnd_load('05.05.2020');  -- 10656.802 ms
explain analyze select sp_stg_provodki_id_load('05.05.2020');  -- 10588.901 ms


