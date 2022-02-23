--
-- Лабораторная работа №3 - Пользователи и группы
--
-- Роль и пользователь, группы. Доступы.
-- Создание пользователей, управление.
--

-- 1. Создайте суперпользователя adb_super с правами входа в систему, ресурсной группой admin_group и паролем "superpassword"
CREATE ROLE adb_super SUPERUSER LOGIN 
PASSWORD 'superpassword' 
RESOURCE GROUP admin_group;

-- 2. Создайте группу adb_group без прав входа в систему
CREATE ROLE adb_group NOLOGIN;

-- 3. Создайте пользователя adb_1 с правом входа в систему добавьте его в группу adb_group
CREATE ROLE adb_1 LOGIN 
IN ROLE adb_group;

-- 4. Создайте пользователя adb_2 с правом входа в систему
CREATE ROLE adb_2 LOGIN;

-- 5. Добавьте пользователя adb_2 в группу adb_group
GRANT adb_group TO adb_2;

-- 6. Дайте полные права на протокол PXF группе adb_group
GRANT ALL ON PROTOCOL 'PXF' TO adb_group

-- 7. Дайте права на чтение таблицы arenadata_toolkit.db_files_current группе adb_group
grant select on table arenadata_toolkit.db_files_current to adb_group;
grant usage on schema arenadata_toolkit to adb_group;

-- 8. Смените пароль пользователю adb_1 на “password_1”
alter role adb_1 with password 'password_1';

