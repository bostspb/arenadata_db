--
-- Лабораторная работа №1 - Внешние таблицы
--
/**
 * Создайте две внешние таблицы, которые выводили бы содержимое файла «/etc/hosts» с каждого сегмент-сервера:
 * - С помощью EXECUTE, используя WEB External Table
 * - C помощью протокола file://, используя External Table 
 */



CREATE EXTERNAL WEB TABLE ext_web_hosts (name text)
EXECUTE 'cat /etc/hosts' on host --чтобы не выполнялась операция дважды на одном сегмент-хосте (т.е. на одном сегмент-хосте разполагаются мастер-сегмент и зеркало-сегмент)
FORMAT 'TEXT' (DELIMITER 'OFF');


CREATE EXTERNAL TABLE ext_file_hosts (name text)
LOCATION ('file://sdw1/etc/hosts', 'file://sdw2/etc/hosts')
FORMAT 'TEXT' (DELIMITER 'OFF');


