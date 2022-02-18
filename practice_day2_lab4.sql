--
-- Лабораторная работа №4
--
/*
1. Создайте таблицу table5: CREATE TABLE table5 (id int, state text);
2. Вставьте данные: INSERT INTO table5 VALUES (1,'insert 1'),(2, 'insert 2');
3. Откройте две транзакции.
4. В первой транзакции выведите содержимое таблицы table5.
5. Во второй транзакции проведите UPDATE: UPDATE table5 SET STATE = 'update 1 transaction 2' WHERE id=1;
6. В первой транзакции выведите содержимое таблицы table5.
7. Закоммитьте вторую транзакцию.
8. В первой транзакции выведите содержимое таблицы table5.
9. Завершите первую транзакцию любым способом.
*/


CREATE TABLE table5 (id int, state text);

INSERT INTO table5 
VALUES (1,'insert 1'), (2, 'insert 2');

-- Transaction #1
-- Step 3
begin;
-- Step 4
select * from table5;
/*
id|state   |
--+--------+
 2|insert 2|
 1|insert 1|
 */

-- Step 6
select * from table5;
/*
id|state   |
--+--------+
 2|insert 2|
 1|insert 1|
 */

-- Step 8
select * from table5;
/*
id|state                 |
--+----------------------+
 2|insert 2              |
 1|update 1 transaction 2|
 */
-- Step 9
commit;



-- Transaction #2
-- Step 3
begin;
-- Step 5
UPDATE table5 SET STATE = 'update 1 transaction 2' WHERE id=1;
-- Step 7
commit;





/*
1. Откройте две транзакции.
2. Переведите первую транзакцию в режим REPEATABLE READ.
3. В первой транзакции выведите содержимое таблицы table5.
4. Во второй транзакции проведите UPDATE: UPDATE table5 SET STATE = 'update 2 transaction 2' WHERE id=1;
5. Закоммитьте вторую транзакцию.
6. В первой транзакции выведите содержимое таблицы table5.
7. Завершите первую транзакцию любым способом.
8. Выведите содержимое таблицы table5.
*/

-- Transaction #1
-- Step 1
begin;
-- Step 2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ READ WRITE;

-- Step 3
select * from table5;
/*
id|state                 |
--+----------------------+
 2|insert 2              |
 1|update 1 transaction 2|
 */

-- Step 6
select * from table5;
/*
id|state                 |
--+----------------------+
 2|insert 2              |
 1|update 1 transaction 2|
 */

-- Step 7
commit;

-- Step 8
select * from table5;
/*
id|state                 |
--+----------------------+
 2|insert 2              |
 1|update 2 transaction 2|
*/



-- Transaction #2
-- Step 1
begin;
-- Step 4
UPDATE table5 SET STATE = 'update 2 transaction 2' WHERE id=1;
-- Step 5
commit;









