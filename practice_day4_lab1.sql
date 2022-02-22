--
-- Лабораторная работа №1 - Ключевые моменты и ограничения при загрузке данных
-- 
/*
1. Создайте 2 одинаковые таблицы foo1 и foo2 со структурой (id int, state text);
2. Добавьте по одной различающейся строке в каждую;
3. Создайте VIEW на первую таблицу (select * from foo1), выполните запрос
SELECT к VIEW;
4. Выполните в одной транзакции переименование таблиц друг в друга;
alter table foo1 rename to foo_tmp;
alter table foo2 rename to foo1;
alter table foo_tmp rename to foo2;
5. Выполните запрос SELECT к VIEW, изменились ли результаты?
6. Посмотрите DDL вьюхи.
 */


create table foo1 (
	id integer,
	state text
)
with (
	appendoptimized = true,
	compresstype = zstd,
	compresslevel = 1
)
distributed by (id);


create table foo2 (like foo1)
distributed by (id);

insert into foo1 values (1, 'foo1_val');
insert into foo2 values (1, 'foo2_val');

CREATE OR REPLACE view foo1_view as 
	select * from foo1;

select * from foo1_view;
/*
id|state   |
--+--------+
 1|foo1_val|
 */

begin;
alter table foo1 rename to foo_tmp;
alter table foo2 rename to foo1;
alter table foo_tmp rename to foo2;
commit;

select * from foo1_view;
/*
id|state   |
--+--------+
 1|foo1_val|
 */
