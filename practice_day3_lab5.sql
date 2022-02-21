--
-- Лабораторная работа №5 - COPY
--
/**
 * 1. Создайте таблицу table7: create table table7 (id int, state text) distributed randomly;
 * 2. Вставьте данные: insert into table7 select gen, 'text ' || gen::text from generate_series(1,200000) gen;
 * 3. С помощью утилиты gpssh создайте директорию /tmp/copy_out на всех северах-сегментах.
 * 4. Выполните экспорт таблицы table7 на всех сегментах в файл '/tmp/copy_out/table7_<SEGID>.csv' с разделителем ','.
 * 5. Выведите первые 10 строк любого сгенерированного файла (утилита head <file>).
 * 6. Очистите таблицу table7 (TRUNCATE).
 * 7. Загрузите таблицу из сгенерированных файлов.
 * 8. Очистите таблицу table7 (TRUNCATE).
 * 9. Выполните команду на сервере sdw1: echo 'wrong string' >> /tmp/copy_out/table7_0.csv
 * 10. Загрузите таблицу из сгенерированных файлов, сохраняя ошибочные строки в лог.
 * 11. Просмотрите лог ошибок по данной таблице.
 * 12. Очистите лог ошибочных записей.
 */

create table table7 (id int, state text) distributed randomly;

insert into table7 select gen, 'text ' || gen::text from generate_series(1,200000) gen;

-- gpssh -f /home/gpadmin/arenadata_configs/arenadata_segment_hosts.hosts mkdir /tmp/copy_out

copy table7 to '/tmp/copy_out/table7_<SEGID>.csv' ON SEGMENT delimiter ',';

-- ssh sdw1

-- ls /tmp/copy_out/
-- table7_0.csv  table7_1.csv

-- head /tmp/copy_out/table7_0.csv
/*
2,text 2
8,text 8
19,text 19
20,text 20
26,text 26
28,text 28
35,text 35
40,text 40
42,text 42
52,text 52
 */

truncate table7;
select count(*) from table7;
-- 0

copy table7 from '/tmp/copy_out/table7_<SEGID>.csv' ON SEGMENT delimiter ',';
select count(*) from table7;
-- 200 000

truncate table7;
select count(*) from table7;
-- 0

-- ssh sdw1
-- echo 'wrong string' >> /tmp/copy_out/table7_0.csv
-- tail /tmp/copy_out/table7_0.csv
/*
199957,text 199957
199962,text 199962
199964,text 199964
199970,text 199970
199977,text 199977
199989,text 199989
199990,text 199990
199993,text 199993
199994,text 199994
wrong string
*/

copy table7 
from '/tmp/copy_out/table7_<SEGID>.csv' 
ON SEGMENT delimiter ','
LOG errors
SEGMENT REJECT LIMIT 5 rows;

select count(*) from table7;
-- 200 000

select * from gp_read_error_log('public.table7');
/*
cmdtime                      |relname|filename                  |linenum|bytenum|errmsg                                                     |rawdata     |rawbytes|
-----------------------------+-------+--------------------------+-------+-------+-----------------------------------------------------------+------------+--------+
2022-02-21 17:08:54.700 +0300|table7 |/tmp/copy_out/table7_0.csv|  49791|       |invalid input syntax for integer: "wrong string", column id|wrong string|        |
 */

-- очищаем лог с ошибками
select * from gp_truncate_error_log('public.table7');
/*
gp_truncate_error_log|
---------------------+
true                 |
*/

select * from gp_read_error_log('public.table7');
/*
cmdtime|relname|filename|linenum|bytenum|errmsg|rawdata|rawbytes|
-------+-------+--------+-------+-------+------+-------+--------+
 */

