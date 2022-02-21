--
-- Лабораторная работа №2 - GPFDIST
--
/**
 * (Все действия под gpadmin)
 * 1. Создайте директорию на мастер-сервере: mkdir /tmp/gpfdist_test
 * 2. Сгенерируйте два файла с синтетикой:
 *   for i in $(seq 1 10000); do echo "$i,foo$i"; done > /tmp/gpfdist_test/sample_1.csv
 *   for i in $(seq 10001 20000); do echo "$i,foo$i"; done > /tmp/gpfdist_test/sample_2.csv
 * 3. Запустите сервер gpfdist на директории /tmp/gpfdist_test на порту 5555
 * 4. Создайте внешнюю таблицу external_table1 с двумя полями (id,gen), которая будет читать оба файла через gpfdist
 * 5. Прочитайте данные из таблицы
 */

-- Запускаем gpfdist на мастер-хосте
-- gpfdist -d /tmp/gpfdist_test/ -p 5555
 
CREATE EXTERNAL TABLE external_table1 (
	id integer,
	gen text
)
LOCATION ('gpfdist://mdw:5555/sample_*.csv')
FORMAT 'CSV';

select * from external_table1 limit 10;
/*
id|gen  |
--+-----+
 1|foo1 |
 2|foo2 |
 3|foo3 |
 4|foo4 |
 5|foo5 |
 6|foo6 |
 7|foo7 |
 8|foo8 |
 9|foo9 |
10|foo10|
*/


/** 
 * (Все действия под gpadmin)
 * 1. Создайте скрипт /tmp/gpfdist_test/foobar.sh: cat $1 |sed 's/foo/bar/g'
 * 2. Создайте файл /tmp/gpfdist_test/config.yaml:
 * ---
 * VERSION: 1.0.0.1
 * TRANSFORMATIONS:
 *   foobar:
 *     TYPE: input
 *     COMMAND: /bin/bash /tmp/gpfdist_test/foobar.sh %filename%
 * 3. Запустите сервер gpfdist на директории /tmp/gpfdist_test на порту 5555 c созданным конфигом
 * 4. Создайте внешнюю таблицу external_table2 с двумя полями (id,gen), которая будет читать оба файла
 * через gpfdist с трансформом foobar
 * 5. Прочитайте данные из таблицы
 */

-- Запускаем gpfdist на мастер-хосте
-- gpfdist -d /tmp/gpfdist_test/ -p 5555 -c /tmp/gpfdist_test/config.yaml
 
CREATE EXTERNAL TABLE external_table2 (
	id integer,
	gen text
)
LOCATION ('gpfdist://mdw:5555/sample_*.csv#transform=foobar')
FORMAT 'CSV';

select * from external_table2 limit 10;
/*
id|gen  |
--+-----+
 1|bar1 |
 2|bar2 |
 3|bar3 |
 4|bar4 |
 5|bar5 |
 6|bar6 |
 7|bar7 |
 8|bar8 |
 9|bar9 |
10|bar10|
 */

