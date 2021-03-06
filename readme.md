# ADBR: Arenadata DB для разработчиков
> **[Школа Больших Данных, авторизованные курсы Arenadata](https://www.bigdataschool.ru/courses/adb-for-developers)**

`Arenadata DB` `Greenplum` `MPP`

## Часть 1

### Обзор архитектуры ADB
Концепция MPP и её имплементация в ADB. Терминология и архитектура СУБД. <br>
Интерконнект. Выполнение запросов. Отказоустойчивость.

### Подключение к БД
Реквизиты. Доступы. psql. <br>
[Лабораторная работа](practice_day1_lab1.md)

### Устройство БД
Шаблоны БД. Логическая схема данных. Обзор дефолтных схем. Основные объекты для работы с БД. <br>
[Лабораторная работа](practice_day1_lab2.md)

### Пользователи и группы
Роль и пользователь, группы. Доступы. Создание пользователей, управление. <br>
[Лабораторная работа](practice_day1_lab3.md)

### Создание таблицы в БД
Основные правила создания таблиц. Типы данных. Распределение таблицы.  <br>
Skew. Констрейнты. Тип хранения данных. Сжатие. <br>
[Лабораторная работа](practice_day1_lab4.md)

### Дисковая квота
Информация о модуле. Настройка. Нюансы использования.


## Часть 2

### Выполнение запросов
Получение плана. Оптимизаторы. Статистика выполнения. Разбор плана запроса.  <br>
Redistribute и Broadcast. Поиск узких мест. <br>
[Лабораторная работа](practice_day2_lab1.sql)

### Партиционирование таблицы
Создание партиционированных таблиц. Ключ партиционирования. Разные типы хранения. Мульти-партиционирование. <br> 
Удаление. Разбиение. Обмен партиций. Внешние таблицы. Загрузка в партиционированные таблицы. <br>
[Лабораторная работа](practice_day2_lab2.sql)

### Индексы
Применимость индексов. Типы. Best practices. Управление индексами. <br>
Основные параметры управления индексами в запросе. <br>
[Лабораторная работа](practice_day2_lab3.sql)

### Транзакции
Обзор. Уровни изоляции. <br>
[Лабораторная работа](practice_day2_lab4.sql)

### MVCC (MultiVersion Concurrency Control)
Цели. Реализация. Bloat. VACUUM. VACUUM FULL. Пример. Регламенты. <br>
[Лабораторная работа](practice_day2_lab5.sql)

### Блокировки
Синтаксис. Пример. <br>
[Лабораторная работа](practice_day2_lab6.sql)

### Статистика
Цели. Сбор статистики. <br>
[Лабораторная работа](practice_day2_lab7.sql)


## Часть 3

### Внешние таблицы
Обычные внешние таблицы. Web-внешние таблицы. <br>
[Лабораторная работа](practice_day3_lab1.sql)

### GPFDIST
Сценарии. Сервер gpfdist. Создание внешних таблиц. Опции LOCATION. <br>
Достижение лучшей производительности. Параметры GUC. Примеры. <br>
[Лабораторная работа](practice_day3_lab2.sql)

### GPLOAD
Использование утилиты <br>
[Лабораторная работа](practice_day3_lab3.sql)

### PXF
Архитектура. Директории сервиса. Конфигурационные файлы. Логи.  <br>
Управление сервисом. HDFS. HBASE. Hive. JDBC. Pushdown. Batching. Pooling. User impersonation. <br>
[Лабораторная работа](practice_day3_lab4.sql)

### COPY
Синтаксис. Пример. <br>
[Лабораторная работа](practice_day3_lab5.sql)

### UDF
Цели. PL/SQL. PL/python. C-функции. PLContainer. Волатильность функций. Доверенность функций. <br>
[Лабораторная работа](practice_day3_lab6.sql)

### Продвинутые запросы
Встроенные функции и операторы. Оконные функции. Обработка запросов разными оптимизаторами. <br>
Особенности использования. Common Table Expressions.  <br>
Особенности работы с партиционированными таблицами. Работа с JSON и XML данными.

### Дополнительные модули и библиотеки
Встроенная аналитика на основе MADLib.  <br>
Работа с географическими данными и объектами с помощью PostGis.  <br>
Дополнительные модули и расширения поддерживаемые в GP.


## Часть 4 - Ключевые кейсы миграции из Oracle в Greenplum
Общие сведения<br>
Конструкции SQL<br>
Конструкции PL/SQL<br>


## Часть 5 - ETL vs ELT подходы

### Ключевые моменты и ограничения при загрузке данных
[Лабораторная работа](practice_day4_lab1.sql)

### Алгоритмы загрузки данных

### Загрузка данных из СУБД Oracle на примере PXF
[Лабораторная работа ч1](practice_day4_lab2-1.sql) <br>
[Лабораторная работа ч2](practice_day4_lab2-2.sql) <br>
[Лабораторная работа ч3](practice_day4_lab2-3.sql)
