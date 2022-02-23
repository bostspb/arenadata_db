--
-- Лабораторная работа №5 - MVCC (MultiVersion Concurrency Control)
--
-- Цели. Реализация. Bloat. VACUUM. VACUUM FULL. Пример. Регламенты.
--
/*
1. Создайте таблицу table6: create table table6 (id int, state text);
2. Вставьте данные: INSERT INTO table6 values (1,'insert 1'),(2, 'insert 2');
3. Откройте две транзакции.
4. В первой транзакции выполните update: update table6 set state='update 1 transaction 1' where id=1;
5. В первой транзакции выполните update: update table6 set state='update 2 transaction 1' where id=1;
6. В первой транзакции включите режим просмотра закрытых строк.
7. В первой транзакции получите вывод xmin, xmax и остальных столбцов.
8. Во второй транзакции получите вывод xmin, xmax и остальных столбцов.
9. Откатите первую транзакцию, закройте вторую транзакцию и сессию.
10. Получите вывод xmin, xmax и остальных столбцов.
11. Включите режим просмотра закрытых строк.
12. Получите вывод xmin, xmax и остальных столбцов.
13. Выполните update: update table6 set state='update 3 transaction 1' where id=1;
14. Получите вывод xmin, xmax и остальных столбцов. Постарайтесь объяснить его.
*/


create table table6 (id int, state text);
INSERT INTO table6 values (1,'insert 1'), (2, 'insert 2');

-- Transaction #1
-- Step 3
begin;
-- Step 4
update table6 set state='update 1 transaction 1' where id=1;
-- Step 5
update table6 set state='update 2 transaction 1' where id=1;
-- Step 6
SET gp_select_invisible = TRUE;
-- Step 7
select xmin, xmax, * from table5;
/*
xmin|xmax|id|state                 |
----+----+--+----------------------+
3527|0   | 2|insert 2              |
3528|3534| 1|insert 1              |
3534|3552| 1|update 1 transaction 2|
3552|0   | 1|update 2 transaction 2|
 */
-- Step 9
rollback;


-- Transaction #2
-- Step 3
begin;
-- Step 8
select xmin, xmax, * from table5;
/*
xmin|xmax|id|state                 |
----+----+--+----------------------+
3527|0   | 2|insert 2              |
3552|0   | 1|update 2 transaction 2|
 */
-- Step 9
commit;

-----------------------------------

SET gp_select_invisible = FALSE;
select xmin, xmax, * from table5;
/*
xmin|xmax|id|state                 |
----+----+--+----------------------+
3527|0   | 2|insert 2              |
3552|0   | 1|update 2 transaction 2|
 */

SET gp_select_invisible = TRUE;
select xmin, xmax, * from table5;
/*
xmin|xmax|id|state                 |
----+----+--+----------------------+
3528|3534| 1|insert 1              |
3534|3552| 1|update 1 transaction 2|
3552|0   | 1|update 2 transaction 2|
3527|0   | 2|insert 2              |
 */

update table6 set state='update 3 transaction 1' where id=1;

select xmin, xmax, * from table5;
/*
xmin|xmax|id|state                 |
----+----+--+----------------------+
3527|0   | 2|insert 2              |
3528|3534| 1|insert 1              |
3534|3552| 1|update 1 transaction 2|
3552|0   | 1|update 2 transaction 2|
*/











