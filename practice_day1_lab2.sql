--
-- Лабораторная работа №2 - Устройство БД
--
-- Шаблоны БД. Логическая схема данных. Обзор дефолтных схем.
-- Основные объекты для работы с БД.
--

-- 1. Выясните с помощью одного SQL-запроса, на каком сервере располагается зеркало сегмента с dbid=2.
select hostname 
from pg_catalog.gp_segment_configuration
where 
	"content" = (
	select "content"  
	from pg_catalog.gp_segment_configuration
	where dbid = 2)
and 
	dbid != 2; 
-- sdw2

-- 2. Выясните, сколько внешних таблиц содержится в БД.
select count(*)
from pg_catalog.pg_class
where relstorage = 'x';
-- 8
