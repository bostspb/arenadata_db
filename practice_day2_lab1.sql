--
-- Лабораторная работа №1
--

/**
 * 1. Используя таблицы table1 и table2 из предыдущих разделов (при необходимости модифицируя их), выведите:
 *     1) План запроса, который содержит redistribute motion;
 *     2) План запроса, который содержит nested loop.
 */

-- 1) План запроса, который содержит redistribute motion;
alter table table2 set distributed by (id2);

explain select *
from table1 t1
join table2 t2 on t1.id1 = t2.id1;

/*
QUERY PLAN                                                                                          |
----------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..992.73 rows=200000 width=60)                  |
  ->  Hash Join  (cost=0.00..952.59 rows=50000 width=60)                                            |
        Hash Cond: (table2.id1 = table1.id1)                                                        |
        ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..448.39 rows=100000 width=30)|
              Hash Key: table2.id1                                                                  |
              ->  Seq Scan on table2  (cost=0.00..433.42 rows=100000 width=30)                      |
        ->  Hash  (cost=432.65..432.65 rows=50000 width=30)                                         |
              ->  Seq Scan on table1  (cost=0.00..432.65 rows=50000 width=30)                       |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                |
*/


-- 2) План запроса, который содержит nested loop.
explain select *
from table1 t1
join table2 t2 on t1.id1 > t2.id2;

/*
QUERY PLAN                                                                                       |
-------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..14288611.46 rows=26666666667 width=60)     |
  ->  Nested Loop  (cost=0.00..8936611.46 rows=6666666667 width=60)                              |
        Join Filter: true                                                                        |
        ->  Broadcast Motion 4:4  (slice1; segments: 4)  (cost=0.00..604.15 rows=400000 width=30)|
              ->  Seq Scan on table2  (cost=0.00..433.42 rows=100000 width=30)                   |
        ->  Index Scan using table1_pkey on table1  (cost=0.00..7164000.00 rows=16667 width=30)  |
              Index Cond: (id1 > table2.id2)                                                     |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                             |
*/


/**
 * 2. Восстановите запрос по плану ниже:
Gather Motion 4:1 (slice2; segments: 4) (cost=0.00..512.49 rows=99939 width=60)
	-> Hash Join (cost=0.00..492.43 rows=24985 width=60)
		Hash Cond: (table1.id2 = table2.id2)
		-> Redistribute Motion 4:4 (slice1; segments: 4) (cost=0.00..27.62 rows=25014 width=30)
			Hash Key: table1.id2
				-> Index Scan using table1_pkey on table1 (cost=0.00..23.87 rows=25014 width=30)
					Index Cond: (id1 < 100000)
		-> Hash (cost=435.25..435.25 rows=24985 width=30)
			-> Seq Scan on table2 (cost=0.00..435.25 rows=24985 width=30)
				Filter: (id1 < 100000)
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0
(два или более ответа)
*/

explain select *
from table1
join table2 on table1.id2 = table2.id2
where 
	table1.id1 < 100000
	and table2.id1 < 100000;

/*
QUERY PLAN                                                                                              |
--------------------------------------------------------------------------------------------------------+
Gather Motion 4:1  (slice2; segments: 4)  (cost=0.00..515.96 rows=100779 width=60)                      |
  ->  Hash Join  (cost=0.00..495.74 rows=25195 width=60)                                                |
        Hash Cond: (table2.id2 = table1.id2)                                                            |
        ->  Seq Scan on table2  (cost=0.00..438.12 rows=25353 width=30)                                 |
              Filter: (id1 < 100000)                                                                    |
        ->  Hash  (cost=27.78..27.78 rows=25195 width=30)                                               |
              ->  Redistribute Motion 4:4  (slice1; segments: 4)  (cost=0.00..27.78 rows=25195 width=30)|
                    Hash Key: table1.id2                                                                |
                    ->  Index Scan using table1_pkey on table1  (cost=0.00..24.00 rows=25195 width=30)  |
                          Index Cond: (id1 < 100000)                                                    |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                                                    |
*/















