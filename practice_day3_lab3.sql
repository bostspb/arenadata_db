--
-- Лабораторная работа №3 - GPLOAD
--

/**
 * (Все действия под gpadmin)
 * 1. Создайте таблицу table10 с двумя полями (id,gen)
 * 2. Создайте файл /tmp/gpfdist_test/gpload_config.yaml так, 
 *    чтобы загрузить содержимое файлов sample_1.csv и sample_2.csv 
 *    в таблицу table10 методом INSERT
 * 3. Загрузите данные
 */


/*
---
VERSION: 1.0.0.1
DATABASE: adb
USER: gpadmin
HOST: mdw
PORT: 5432
GPLOAD:
   INPUT:
    - SOURCE:
         LOCAL_HOSTNAME:
           - mdw
         PORT: 5566
         FILE:
           - /tmp/gpfdist_test/sample*
    - COLUMNS:
           - id: int
           - gen: text
    - FORMAT: CSV
    - DELIMITER: ','
    - ERROR_LIMIT: 25
    - LOG_ERRORS: true
   OUTPUT:
    - TABLE: table10
    - MODE: INSERT
   PRELOAD:
    - REUSE_TABLES: true
*/


create table table10 (
	id integer,
	gen text
)
distributed by (id);

-- gpload -f /tmp/gpfdist_test/gpload_config.yaml

select * from table10 limit 5;
/*
id|gen  |
--+-----+
 2|foo2 |
 9|foo9 |
16|foo16|
17|foo17|
24|foo24|
*/

