--
-- Лабораторная работа №6 - UDF
--

/**
 * 1. Создайте пустую таблицу table13 (id int)
 * 2. Вставьте в таблицу данные:
 * insert into table13 select gen from generate_series(1,20) gen;
 * 3. Создайте функцию:
 *    create or replace function get_host_pyt() returns text
 *    as $$
 *      import socket
 *      return 'I am running on host: ' + socket.gethostname()
 *    $$
 *    volatile
 *    language plpythonu execute on all segments;
 * 4. Выполните запрос:
 * select get_host_pyt();
 * 5. В функции get_host_pyt() поменяйте «execute on all segments» на «execute on master»
 * 6. Выполните запрос:
 * select get_host_pyt();
 */

create table table13 (id integer)
with (
	appendoptimized = true,
	compresstype = zstd,
	compresslevel = 1
)
distributed by (id);


insert into table13 select gen from generate_series(1,20) gen;


create or replace function get_host_pyt() returns text
as $$
	import socket
	return 'I am running on host: ' + socket.gethostname()
$$
volatile
language plpythonu execute on all segments;


select get_host_pyt();
/*
get_host_pyt              |
--------------------------+
I am running on host: sdw1|
I am running on host: sdw1|
I am running on host: sdw2|
I am running on host: sdw2|
 */


create or replace function get_host_pyt() returns text
as $$
	import socket
	return 'I am running on host: ' + socket.gethostname()
$$
volatile
language plpythonu -- запуск питона на хосте
execute on master; 


select get_host_pyt();
/*
get_host_pyt             |
-------------------------+
I am running on host: mdw|
 */



/**
 * 1. Создайте функцию:
 *    create or replace function get_host_cont() returns text
 *    as $$
 *      # container: plc_py
 *      import socket
 *      return 'I am running on host: ' + socket.gethostname()
 *    $$
 *    volatile
 *    language plcontainer execute on all segments;
 * 2. Выполните запрос:
 * select get_host_cont();
 * 3. В функции get_host_cont() поменяйте «execute on all segments» на «execute on master»
 * 4. Выполните запрос:
 * select get_host_cont();
 */

create or replace function get_host_cont() returns text
as $$
	# container: plc_py
	import socket
	return 'I am running on host: ' + socket.gethostname()
$$
volatile
language plcontainer -- запуск питона в докер-контейнере
execute on all segments;


select get_host_cont();
/*
get_host_cont                     |
----------------------------------+
I am running on host: 174d1fc3a4b9|
I am running on host: 417a0eaf79d6|
I am running on host: 6acad277f628|
I am running on host: 50eb4467c2d3|
 */


create or replace function get_host_cont() returns text
as $$
	# container: plc_py
	import socket
	return 'I am running on host: ' + socket.gethostname()
$$
volatile
language plcontainer execute on master;


select get_host_cont();
/*
get_host_cont                     |
----------------------------------+
I am running on host: 449c86f81027|
 */

