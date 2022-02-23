--
-- Лабораторная работа №6 - Блокировки
--
-- Синтаксис. Пример.
--
/*
1. Убедитесь, что таблицы table5 и table6 присутствуют в базе данных;
2. Откройте две транзакции;
3. В первой транзакции выполните update: update table5 set state='lock 1 transaction 1' where id=1;
4. Во второй транзакции выполните select: SELECT * FROM table5;
5. Выполнилась ли операция Select?
6. Во второй транзакции выполните update: update table5 set state='lock 2 transaction 1' where id=1;
7. Выполнилась ли операция Update? Почему?
8. В первой транзакции выполните COMMIT;
9. Проверьте состояние операции Update во второй транзакции. Выполнилась ли эта операция? Почему?
10. Во второй транзакции выполните COMMIT;
*/

-- Transaction #1
-- Step 2
begin;
-- Step 3
update table5 set state='lock 1 transaction 1' where id=1;
-- Step 8
commit;

-- Transaction #2
-- Step 2
begin;
-- Step 4
SELECT * FROM table5;
-- Step 5, Выполнилась ли операция Select? 
-- да
-- Step 6
update table5 set state='lock 2 transaction 1' where id=1;
-- Step 7, Выполнилась ли операция Update? Почему?
-- нет, вот почему
select
	lock.locktype,
	lock.relation::regclass,
	lock.mode,
	lock.transactionid as tid,
	lock.virtualtransaction as vtid,
	lock.pid,
	lock.granted,
	lock.gp_segment_id
from pg_catalog.pg_locks lock
where lock.pid != pg_backend_pid()
	and lock.relation = 'table5'::regclass
order by lock.pid;
/*
locktype|relation|mode            |tid|vtid   |pid |granted|gp_segment_id|
--------+--------+----------------+---+-------+----+-------+-------------+
relation|table5  |AccessShareLock |   |12/1294|2837|true   |           -1|
relation|table5  |ExclusiveLock   |   |12/1294|2837|false  |           -1|
relation|table5  |RowExclusiveLock|   |2/4778 |3578|true   |            0|
relation|table5  |AccessShareLock |   |2/4778 |3578|true   |            0|
relation|table5  |RowExclusiveLock|   |2/4778 |3579|true   |            1|
relation|table5  |AccessShareLock |   |2/4778 |3579|true   |            1|
relation|table5  |RowExclusiveLock|   |1/4780 |4431|true   |            2|
relation|table5  |AccessShareLock |   |1/4780 |4431|true   |            2|
relation|table5  |RowExclusiveLock|   |1/4780 |4432|true   |            3|
relation|table5  |AccessShareLock |   |1/4780 |4432|true   |            3|
*/

-- Step 9, Проверьте состояние операции Update во второй транзакции. Выполнилась ли эта операция? Почему?
-- ???????????????

-- Step 10
commit;







/*
1. Откройте две транзакции;
2. В первой транзакции выполните update: update table6 set state= 'lock 1 transaction 1' where id=1;
3. Во второй транзакции выполните update: update table5 set state='lock 1 transaction 2' where id=1;
4. В первой транзакции выполните update: update table5 set state='lock 2 transaction 1' where id=1;
5. Во второй транзакции выполните update: update table6 set state='lock 2 transaction 2' where id=1;
6. Убедиться, что сработал механизм разрешения взаимных блокировок.
*/

-- Transaction #1
-- Step 1
begin;
-- Step 2
update table6 set state= 'lock 1 transaction 1' where id=1;
-- Step 4
update table5 set state='lock 2 transaction 1' where id=1;

commit;


-- Transaction #2
-- Step 1
begin;
-- Step 3
update table5 set state='lock 1 transaction 2' where id=1;
-- Step 5
update table6 set state='lock 2 transaction 2' where id=1;
/*
Причина:
 SQL Error [40P01]: ERROR: deadlock detected
  Подробности: Process 2837 waits for ExclusiveLock on relation 41658 of database 16384; blocked by process 6988.
Process 6988 waits for ExclusiveLock on relation 41652 of database 16384; blocked by process 2837.
  Подсказка: See server log for query details.
  Позиция: 8
*/


-------------------------------------------------


-- Step 6 Убедиться, что сработал механизм разрешения взаимных блокировок.

SELECT * FROM table5;
/*
id|state               |
--+--------------------+
 2|insert 2            |
 1|lock 2 transaction 1|
 */
 
 SELECT * FROM table6;
/*
id|state               |
--+--------------------+
 2|insert 2            |
 1|lock 1 transaction 1|
 */

-- Как видно из результата - прошла только 1я транзакция, а 2я откатилась



