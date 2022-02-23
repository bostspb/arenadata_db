--
-- Лабораторная работа №4 - Создание таблицы в БД
--
-- Основные правила создания таблиц. Типы данных. Распределение таблицы.
-- Skew. Констрейнты. Тип хранения данных. Сжатие.
--

-----
-- 1. Создайте таблицу table1:
-- id1 int
-- id2 int
-- gen1 text
-- gen2 text
-- Первичным ключом сделайте поля id1,id2,gen1;
-- Ключом распределения сделайте поле id1 .
-- • Какого типа может быть таблица?
-- • Какая компрессия может использоваться в таблице?
--
create table table1 (
	id1 integer,
	id2 integer,
	gen1 text,
	gen2 text,
	primary key (id1, id2, gen1)
)
with (appendoptimized = false)
distributed by (id1);

-- Таблица может быть только типа Heap, т.к. в требованиях указано обязательное наличие первичного ключа
-- Для таблиц типа Heap не может использоваться никакая компрессия


-----
-- 2. Создайте таблицу table2:
-- • Возьмите набор полей table1 с помощью директивы LIKE;
-- • Храните таблицу колоночно, сожмите таблицу с помощью ZSTD уровня 1;
-- • Распределите таблицу по полю id2.
--
create table table2 (
	like table1
)
with (
	appendoptimized = true,
	orientation = column,
	compresstype = zstd,
	compresslevel = 1
)
distributed by (id2);


-----
-- 3. Сгенерируйте данные и вставьте их в обе таблицы:
-- insert into table1 select gen,gen, gen::text || 'text1', gen::text || 'text2' from
-- generate_series(1,200000) gen;
-- insert into table2 select gen,gen, gen::text || 'text1', gen::text || 'text2' from
-- generate_series(1,400000) gen;
insert into table1 
select gen, gen, gen::text || 'text1', gen::text || 'text2' 
from generate_series(1,200000) gen;

insert into table2 
select gen,gen, gen::text || 'text1', gen::text || 'text2' 
from generate_series(1,400000) gen;



-----
-- 4. С помощью директивы EXPLAIN просмотрите план соединения таблиц table1 и table2 по ключу id1.
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



-----
-- 5. Оптимизируйте ситуацию, убрав REDISTRIBUTE MOTION.
alter table table2 set distributed by (id1);

explain select *
from table1 t1
join table2 t2 on t1.id1 = t2.id1;

/*
QUERY PLAN                                                                        |
----------------------------------------------------------------------------------+
Gather Motion 4:1  (slice1; segments: 4)  (cost=0.00..983.34 rows=200000 width=60)|
  ->  Hash Join  (cost=0.00..943.20 rows=50000 width=60)                          |
        Hash Cond: (table2.id1 = table1.id1)                                      |
        ->  Seq Scan on table2  (cost=0.00..433.42 rows=100000 width=30)          |
        ->  Hash  (cost=432.65..432.65 rows=50000 width=30)                       |
              ->  Seq Scan on table1  (cost=0.00..432.65 rows=50000 width=30)     |
Optimizer: Pivotal Optimizer (GPORCA) version 3.88.0                              |
*/



-- Проверка распределения по сегмент-хостам
select gp_segment_id, count(*) 
from table2
group by gp_segment_id;

