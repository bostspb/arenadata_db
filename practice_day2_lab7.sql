--
-- Лабораторная работа №7
--
/*
1. Убедитесь, что таблицы table1 и table2 существуют в базе данных с помощью команды \d+
2. Установите значение выделенной памяти для запроса в рамках сессии: set statement_mem = 20000;
3. Вставьте данные в таблицу table1: INSERT INTO table1 SELECT gen, gen, gen::text || 'text1', gen::text || 'text2'
FROM generate_series (1000000,4000000) gen;
4. Постройте план выполнения запроса с помощью EXPLAIN ANALYZE следующего запроса: SELECT * FROM table1 t1 join table2 t2
on t1.id1 = t2.id1;
5. Выполните сбор статистики для таблицы table1.
6. Снова постройте план выполнения запроса с помощью EXPLAIN ANALYZE следующего запроса: SELECT * FROM table1 t1 join table2
t2 on t1.id1 = t2.id1;
7. Сравните полученные планы. Обратите внимание на ожидаемое число строк в плане и сравните его с актуальным (rows out) для таблицы
table1. Также обратит внимание по какой таблице строится hash.
8. Обратите внимание на показатели Memory used и Memory wanted в первом плане и во втором.
*/

set statement_mem = 20000;

INSERT INTO table1 SELECT gen, gen, gen::text || 'text1', gen::text || 'text2'
FROM generate_series (1000000,4000000) gen;

EXPLAIN ANALYZE
SELECT * FROM table1 t1 join table2 t2 on t1.id1 = t2.id1;
/*
QUERY PLAN                                                                                                                                           |
-----------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..992.73 rows=200000 width=60) (actual time=380.622..786.049 rows=200000 loops=1)                |
  ->  Hash Join  (cost=0.00..952.59 rows=50000 width=60) (actual time=386.530..714.352 rows=50093 loops=1)                                           |
        Hash Cond: (table2.id1 = table1.id1)                                                                                                         |
        Extra Text: (seg2)   Initial batch 0:                                                                                                        |
(seg2)     Wrote 30189K bytes to inner workfile.                                                                                                     |
(seg2)     Wrote 3219K bytes to outer workfile.                                                                                                      |
(seg2)   Overflow batches 1..3:                                                                                                                      |
(seg2)     Read 37890K bytes from inner workfile: 12630K avg x 3 nonempty batches, 17778K max.                                                       |
(seg2)     Wrote 7702K bytes to inner workfile.                                                                                                      |
(seg2)     Read 3219K bytes from outer workfile: 1073K avg x 3 nonempty batches, 1081K max.                                                          |
(seg2)   Hash chain length 3.2 avg, 14 max, using 249663 of 262144 buckets.                                                                          |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..448.39 rows=100000 width=30) (actual time=0.090..140.339 rows=100268 loops=1)|
              Hash Key: table2.id1                                                                                                                   |
              ->  Seq Scan on table2  (cost=0.00..433.42 rows=100000 width=30) (actual time=0.928..25.506 rows=100268 loops=1)                       |
        ->  Hash  (cost=432.65..432.65 rows=50000 width=30) (actual time=385.804..385.804 rows=800850 loops=1)                                       |
              ->  Seq Scan on table1  (cost=0.00..432.65 rows=50000 width=30) (actual time=0.050..65.229 rows=800850 loops=1)                        |
Planning time: 24.689 ms                                                                                                                             |
  (slice0)    Executor memory: 584K bytes.                                                                                                           |
  (slice1)    Executor memory: 636K bytes avg x 4 workers, 636K bytes max (seg0).                                                                    |
* (slice2)    Executor memory: 25408K bytes avg x 4 workers, 25408K bytes max (seg0).  Work_mem: 19057K bytes max, 49662K bytes wanted.              |
Memory used:  19456kB                                                                                                                                |
Memory wanted:  50161kB                                                                                                                              |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                                                                 |
Execution time: 814.895 ms                                                                                                                           |
 */

analyze table1;

EXPLAIN ANALYZE
SELECT * FROM table1 t1 join table2 t2 on t1.id1 = t2.id1;
/*
QUERY PLAN                                                                                                                                                |
----------------------------------------------------------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..1291.67 rows=400000 width=62) (actual time=80.464..406.604 rows=200000 loops=1)                     |
  ->  Hash Join  (cost=0.00..1208.72 rows=100000 width=62) (actual time=78.993..314.393 rows=50093 loops=1)                                               |
        Hash Cond: (table1.id1 = table2.id1)                                                                                                              |
        Extra Text: (seg2)   Hash chain length 1.9 avg, 10 max, using 51301 of 65536 buckets.                                                             |
        ->  Seq Scan on table1  (cost=0.00..458.28 rows=800001 width=32) (actual time=0.070..53.051 rows=800850 loops=1)                                  |
        ->  Hash  (cost=448.39..448.39 rows=100000 width=30) (actual time=78.462..78.462 rows=100268 loops=1)                                             |
              ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..448.39 rows=100000 width=30) (actual time=1.799..56.356 rows=100268 loops=1)|
                    Hash Key: table2.id1                                                                                                                  |
                    ->  Seq Scan on table2  (cost=0.00..433.42 rows=100000 width=30) (actual time=0.644..23.335 rows=100268 loops=1)                      |
Planning time: 24.351 ms                                                                                                                                  |
  (slice0)    Executor memory: 584K bytes.                                                                                                                |
  (slice1)    Executor memory: 636K bytes avg x 4 workers, 636K bytes max (seg0).                                                                         |
  (slice2)    Executor memory: 8824K bytes avg x 4 workers, 8824K bytes max (seg0).  Work_mem: 5484K bytes max.                                           |
Memory used:  19456kB                                                                                                                                     |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                                                                      |
Execution time: 433.479 ms                                                                                                                                |
*/