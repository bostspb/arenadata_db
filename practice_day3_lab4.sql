--
-- Лабораторная работа №4 - PXF
--
/**
 * 1. Создайте таблицу table11 (колоночная, сжатие zstd уровня 1):
 *    id1 int,
 *    id2 int,
 *    gen text,
 *    now timestamp without time zone
 * 2. Создайте индекс на поле id1
 * 3. Вставьте в таблицу данные:
 *    insert into table11 select gen, gen, 'text' || gen::text,now() from generate_series(1,4000000) gen;
 * 4. Cоздайте READABLE внешнюю таблицу table_11_pxf_read, которая:
 *    • Будет обращаться к серверу mdw к таблице table11
 *    • Использует JDBC-драйвер PostgreSQL: org.postgresql.Driver
 *    • Использует имя пользователя gpadmin и не использовать пароль
 *    • Читает данные в один поток
 * 5. Изучите результат EXPLAIN ANALYZE запроса select count(1) from <ext_table>, заметьте время выполнения запроса
 */
create table table11 (
	id1 int,
	id2 int,
	gen text,
	now timestamp without time zone
)
with (
	appendoptimized = true,
	orientation = column,
	compresstype = zstd,
	compresslevel = 1
)
distributed by (id1);

CREATE INDEX idx_id1 ON table11 USING btree (id1);

insert into table11 select gen, gen, 'text' || gen::text,now() from generate_series(1,4000000) gen;

create external table table_11_pxf_read (like table11)
location ('pxf://public.table11?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://mdw:5432/adb&USER=gpadmin')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');

select * from table_11_pxf_read limit 5;
/*
id1|id2|gen   |now                    |
---+---+------+-----------------------+
  1|  1|text1 |2022-02-21 15:13:32.355|
 12| 12|text12|2022-02-21 15:13:32.355|
 15| 15|text15|2022-02-21 15:13:32.355|
 20| 20|text20|2022-02-21 15:13:32.355|
 23| 23|text23|2022-02-21 15:13:32.355|
 */

EXPLAIN ANALYZE 
select count(1) 
from table_11_pxf_read;

/*
QUERY PLAN                                                                                                                                         |
---------------------------------------------------------------------------------------------------------------------------------------------------+
Aggregate  (cost=0.00..438.89 rows=1 width=8) (actual time=15140.755..15140.755 rows=1 loops=1)                                                    |
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..438.89 rows=1 width=8) (actual time=30.653..15140.707 rows=4 loops=1)                  |
        ->  Aggregate  (cost=0.00..438.89 rows=1 width=8) (actual time=27.400..27.400 rows=1 loops=1)                                              |
              ->  External Scan on table_11_pxf_read  (cost=0.00..438.43 rows=250000 width=1) (actual time=509.429..14750.222 rows=4000000 loops=1)|
Planning time: 6.994 ms                                                                                                                            |
  (slice0)    Executor memory: 132K bytes.                                                                                                         |
  (slice1)    Executor memory: 156K bytes avg x 4 workers, 234K bytes max (seg3).                                                                  |
Memory used:  128000kB                                                                                                                             |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                                                               |
Execution time: 15165.428 ms                                                                                                                       |
 */




/**
 * 1. Создайте аналогичную вторую READABLE внешнюю таблицу table_11_pxf_read_parallel таким образом, чтобы:
 * • Чтение выполнялось параллельно
 * • Шардирование происходило по полю id1
 * • Размер одной пачки данных составил 500000 строк
 * • Изучите результат EXPLAIN ANALYZE запроса select count(1) from <ext_table>, заметьте время выполнения запроса
 */
create external table table_11_pxf_read_parallel (like table11)
location ('pxf://public.table11?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://mdw:5432/adb&USER=gpadmin&PARTITION_BY=id1:int&RANGE=1:4000001&INTERVAL=500000')
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_import');

select * from table_11_pxf_read_parallel limit 5;
/*
id1|id2|gen   |now                    |
---+---+------+-----------------------+
  3|  3|text3 |2022-02-21 15:13:32.355|
  4|  4|text4 |2022-02-21 15:13:32.355|
  7|  7|text7 |2022-02-21 15:13:32.355|
  8|  8|text8 |2022-02-21 15:13:32.355|
 18| 18|text18|2022-02-21 15:13:32.355|
 */

EXPLAIN ANALYZE 
select count(1) 
from table_11_pxf_read_parallel;
/*
QUERY PLAN                                                                                                                                                |
----------------------------------------------------------------------------------------------------------------------------------------------------------+
Aggregate  (cost=0.00..438.89 rows=1 width=8) (actual time=7009.576..7009.576 rows=1 loops=1)                                                             |
  ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..438.89 rows=1 width=8) (actual time=6756.729..7009.552 rows=4 loops=1)                        |
        ->  Aggregate  (cost=0.00..438.89 rows=1 width=8) (actual time=7006.935..7006.936 rows=1 loops=1)                                                 |
              ->  External Scan on table_11_pxf_read_parallel  (cost=0.00..438.43 rows=250000 width=1) (actual time=84.041..6893.573 rows=1000000 loops=1)|
Planning time: 6.809 ms                                                                                                                                   |
  (slice0)    Executor memory: 132K bytes.                                                                                                                |
  (slice1)    Executor memory: 234K bytes avg x 4 workers, 234K bytes max (seg0).                                                                         |
Memory used:  128000kB                                                                                                                                    |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                                                                      |
Execution time: 7010.664 ms                                                                                                                               |
 */




/**
 * 1. Создайте пустую таблицу table12, которая полностью повторяет структуры таблицы table11
 * 2. Создайте аналогичную WRITABLE таблицу table_12_pxf_write, которая
 *    • Будет обращаться к серверу mdw к таблице table12
 *    • Использует JDBC-драйвер PostgreSQL: org.postgresql.Driver
 *    • Использует имя пользователя gpadmin и не использовать пароль
 *    • Использует BATCH_SIZE=25
 *    • Использует POOL_SIZE=2
 *    • Распределена по полю id1
 * 3. Изучите результат EXPLAIN ANALYZE запроса
 * explain analyze insert into table_12_pxf_write select * from table11 limit 100;
 */

create table table12 (like table11)
distributed by (id1);


create writable external table table_12_pxf_write (like table11)
location ('pxf://public.table12?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://mdw:5432/adb&USER=gpadmin&BATCH_SIZE=25&POOL_SIZE=2')	
FORMAT 'CUSTOM' (FORMATTER='pxfwritable_export')
DISTRIBUTED BY (id1);


explain analyze insert into table_12_pxf_write select * from table11 limit 100;
/*
QUERY PLAN                                                                                                                                         |
---------------------------------------------------------------------------------------------------------------------------------------------------+
Insert  (cost=0.00..506.53 rows=25 width=27) (actual time=4.822..6.403 rows=100 loops=1)                                                           |
  ->  Redistribute Motion 1:4  (slice2; segments: 1)  (cost=0.00..503.79 rows=100 width=28) (actual time=2.939..2.949 rows=100 loops=1)            |
        Hash Key: table11.id1                                                                                                                      |
        ->  Result  (cost=0.00..503.79 rows=25 width=28) (actual time=1.472..1.520 rows=100 loops=1)                                               |
              ->  Limit  (cost=0.00..503.78 rows=25 width=27) (actual time=1.460..1.484 rows=100 loops=1)                                          |
                    ->  Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..503.78 rows=100 width=27) (actual time=1.453..1.458 rows=100 loops=1)|
                          ->  Limit  (cost=0.00..503.77 rows=25 width=27) (actual time=0.567..0.589 rows=100 loops=1)                              |
                                ->  Seq Scan on table11  (cost=0.00..453.55 rows=1000000 width=27) (actual time=0.558..0.571 rows=100 loops=1)     |
Planning time: 12.020 ms                                                                                                                           |
  (slice0)    Executor memory: 75K bytes avg x 4 workers, 128K bytes max (seg2).                                                                   |
  (slice1)    Executor memory: 620K bytes avg x 4 workers, 620K bytes max (seg1).                                                                  |
  (slice2)    Executor memory: 58K bytes (seg3).                                                                                                   |
Memory used:  128000kB                                                                                                                             |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                                                               |
Execution time: 473.254 ms                                                                                                                         |
 */

select * from table_12_pxf_write limit 5;
/*
Error occurred during SQL query execution

Причина:
 SQL Error [42809]: ERROR: cannot read from a WRITABLE external table
  Подсказка: Create the table as READABLE instead.
 */
-- логично, т.к. таблица только для записи, а данные попадают в таблицу table12 :)

select * from table12 limit 5;
/*
id1|id2|gen    |now                    |
---+---+-------+-----------------------+
  5|  5|text5  |2022-02-21 15:13:32.355|
  6|  6|text6  |2022-02-21 15:13:32.355|
125|125|text125|2022-02-21 15:13:32.355|
 10| 10|text10 |2022-02-21 15:13:32.355|
 11| 11|text11 |2022-02-21 15:13:32.355|
 */

select count(*) from table12;
/*
count|
-----+
  100|
 */

