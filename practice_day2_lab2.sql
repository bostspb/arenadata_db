--
-- Лабораторная работа №2 - Партиционирование таблицы
--
-- Создание партиционированных таблиц. Ключ партиционирования.
-- Разные типы хранения. Мульти-партиционирование.
-- Удаление. Разбиение. Обмен партиций. Внешние таблицы.
-- Загрузка в партиционированные таблицы.
--

/**
 * 1. Создайте партиционированную таблицу table3 (dttm timestamp, id int):
 *     1) С 1-го января 2016 включительно по 1-ое января 2017 храните данные колоночно со сжатием ZSTD уровня 5;
 *     2) С 1-го января 2017 включительно по 1-ое января 2018 храните данные колоночно со сжатием ZSTD уровня 1;
 *     3) С 1-го января 2018 включительно по 1-го января 2019 храните данные в heap-таблице;
 *     4) Предусмотрите DEFAULT PARTITION.
 */

create table table3 (
	dttm timestamp, 
	id int
)
distributed by (id)
partition by range (dttm) (
	partition y2016 start (date '2016-01-01') with (appendonly = true, orientation = column, compresstype = zstd, compresslevel = 5),
	partition y2017 start (date '2017-01-01') with (appendonly = true, orientation = column, compresstype = zstd, compresslevel = 1),
	partition y2018 start (date '2018-01-01') end (date '2019-01-01') with (appendonly = false),
	default partition extra_date	
);

select * 
from pg_catalog.pg_partitions
where tablename = 'table3'
/*
schemaname|tablename|partitionschemaname|partitiontablename     |partitionname|parentpartitiontablename|parentpartitionname|partitiontype|partitionlevel|partitionrank|partitionposition|partitionlistvalues|partitionrangestart                               |partitionstartinclusive|partitionrangeend                                 |partitionendinclusive|partitioneveryclause|partitionisdefault|partitionboundary                                                                                                                                                                                                       |parenttablespace|partitiontablespace|
----------+---------+-------------------+-----------------------+-------------+------------------------+-------------------+-------------+--------------+-------------+-----------------+-------------------+--------------------------------------------------+-----------------------+--------------------------------------------------+---------------------+--------------------+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+-------------------+
public    |table3   |public             |table3_1_prt_y2016     |y2016        |                        |                   |range        |             0|            1|                2|                   |'2016-01-01 00:00:00'::timestamp without time zone|true                   |'2017-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2016 START ('2016-01-01 00:00:00'::timestamp without time zone) END ('2017-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='true', orientation='column', compresstype=zstd, compresslevel='5')|pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_y2017     |y2017        |                        |                   |range        |             0|            2|                3|                   |'2017-01-01 00:00:00'::timestamp without time zone|true                   |'2018-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2017 START ('2017-01-01 00:00:00'::timestamp without time zone) END ('2018-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='true', orientation='column', compresstype=zstd, compresslevel='1')|pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_y2018     |y2018        |                        |                   |range        |             0|            3|                4|                   |'2018-01-01 00:00:00'::timestamp without time zone|true                   |'2019-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2018 START ('2018-01-01 00:00:00'::timestamp without time zone) END ('2019-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='false')                                                           |pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_extra_date|extra_date   |                        |                   |range        |             0|             |                1|                   |                                                  |false                  |                                                  |false                |                    |true              |DEFAULT PARTITION extra_date                                                                                                                                                                                            |pg_default      |pg_default         |
*/


-- так же можно сделать через exchange partition в несколько запросов


/**
 * 2. Добавьте партицию для периода с 1-го января 2015 включительно по 1-ое января 2016.
 *    Используйте ZSTD уровня 19.
 */
alter table table3 split default partition  
start (date '2015-01-01') inclusive 
end (date '2016-01-01') exclusive into (
	partition y2015, 
	default partition
);

/*
adb=# \d+ table3_1_prt_y2015
                            Table "public.table3_1_prt_y2015"
 Column |            Type             | Modifiers | Storage | Stats target | Description
--------+-----------------------------+-----------+---------+--------------+-------------
 dttm   | timestamp without time zone |           | plain   |              |
 id     | integer                     |           | plain   |              |
Check constraints:
    "table3_1_prt_y2015_check" CHECK (dttm >= '2015-01-01 00:00:00'::timestamp without time zone AND dttm < '2016-01-01 00:00:00'::timestamp without time zone)
Inherits: table3
Distributed by: (id)
*/

create table tmp_table ( like table3)
with (
	appendoptimized = true,
	compresstype = zstd,
	compresslevel = 19
)
distributed by (id);

alter table table3 exchange partition  
for (date '2015-01-01') 
with table tmp_table with validation;
/*
adb=# \d+ table3_1_prt_y2015
                      Append-Only Table "public.table3_1_prt_y2015"
 Column |            Type             | Modifiers | Storage | Stats target | Description
--------+-----------------------------+-----------+---------+--------------+-------------
 dttm   | timestamp without time zone |           | plain   |              |
 id     | integer                     |           | plain   |              |
Compression Type: zstd
Compression Level: 19
Block Size: 32768
Checksum: t
Check constraints:
    "table3_1_prt_y2015_check" CHECK (dttm >= '2015-01-01 00:00:00'::timestamp without time zone AND dttm < '2016-01-01 00:00:00'::timestamp without time zone)
Inherits: table3
Distributed by: (id)
Options: appendonly=true, compresstype=zstd, compresslevel=19
*/


/**
 * 3. Переименуйте созданную партицию в old_one.
 */
ALTER TABLE table3 RENAME PARTITION FOR (date '2015-01-01') TO old_one;


/**
 * 4. Изучите информацию о партициях таблицы table3 в pg_partitions.
 */
select * 
from pg_catalog.pg_partitions
where tablename = 'table3'
/*
schemaname|tablename|partitionschemaname|partitiontablename     |partitionname|parentpartitiontablename|parentpartitionname|partitiontype|partitionlevel|partitionrank|partitionposition|partitionlistvalues|partitionrangestart                               |partitionstartinclusive|partitionrangeend                                 |partitionendinclusive|partitioneveryclause|partitionisdefault|partitionboundary                                                                                                                                                                                                       |parenttablespace|partitiontablespace|
----------+---------+-------------------+-----------------------+-------------+------------------------+-------------------+-------------+--------------+-------------+-----------------+-------------------+--------------------------------------------------+-----------------------+--------------------------------------------------+---------------------+--------------------+------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------+-------------------+
public    |table3   |public             |table3_1_prt_old_one   |old_one      |                        |                   |range        |             0|            1|                1|                   |'2015-01-01 00:00:00'::timestamp without time zone|true                   |'2016-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION old_one START ('2015-01-01 00:00:00'::timestamp without time zone) END ('2016-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='true', compresstype=zstd, compresslevel='19')                   |pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_y2016     |y2016        |                        |                   |range        |             0|            2|                2|                   |'2016-01-01 00:00:00'::timestamp without time zone|true                   |'2017-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2016 START ('2016-01-01 00:00:00'::timestamp without time zone) END ('2017-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='true', orientation='column', compresstype=zstd, compresslevel='5')|pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_y2017     |y2017        |                        |                   |range        |             0|            3|                3|                   |'2017-01-01 00:00:00'::timestamp without time zone|true                   |'2018-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2017 START ('2017-01-01 00:00:00'::timestamp without time zone) END ('2018-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='true', orientation='column', compresstype=zstd, compresslevel='1')|pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_y2018     |y2018        |                        |                   |range        |             0|            4|                4|                   |'2018-01-01 00:00:00'::timestamp without time zone|true                   |'2019-01-01 00:00:00'::timestamp without time zone|false                |                    |false             |PARTITION y2018 START ('2018-01-01 00:00:00'::timestamp without time zone) END ('2019-01-01 00:00:00'::timestamp without time zone) WITH (appendonly='false')                                                           |pg_default      |pg_default         |
public    |table3   |public             |table3_1_prt_extra_date|extra_date   |                        |                   |range        |             0|             |                0|                   |                                                  |false                  |                                                  |false                |                    |true              |DEFAULT PARTITION extra_date                                                                                                                                                                                            |pg_default      |pg_default         |
*/

