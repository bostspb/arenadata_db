# Лабораторная работа №1 - Подключение к БД
> Реквизиты. Доступы. psql.

**1. Подключитесь к пользователю `gpadmin` по SSH на мастер-сервере.**

Заходим на хост `10.129.0.87` через MobaXterm с логином `admin`

Перелогиниваемся под `gpadmin`
```shell
sudo su - gpadmin
```

**2. Подключитесь к БД `adb` под пользователем `gpadmin`.**
```shell
psql -d adb -h mdw -U gpadmin
# или
psql adb
```
Так же подключаемся через DBeaver


**3. Выполните запрос: `select * from pg_catalog.pg_class where relname = 'pg_class';`**

Выполняем в DBeaver
```sql
select * from pg_catalog.pg_class where relname = 'pg_class';
```
```
relname |relnamespace|reltype|reloftype|relowner|relam|relfilenode|reltablespace|relpages|reltuples|relallvisible|reltoastrelid|relhasindex|relisshared|relpersistence|relkind|relstorage|relnatts|relchecks|relhasoids|relhaspkey|relhasrules|relhastriggers|relhassubclass|relispopulated|relreplident|relfrozenxid|relminmxid|relacl      |reloptions|
--------+------------+-------+---------+--------+-----+-----------+-------------+--------+---------+-------------+-------------+-----------+-----------+--------------+-------+----------+--------+---------+----------+----------+-----------+--------------+--------------+--------------+------------+------------+----------+------------+----------+
pg_class|          11|     83|        0|      10|    0|          0|            0|       7|    459.0|            7|            0|true       |false      |p             |r      |h         |      30|        0|true      |false     |false      |false         |false         |true          |n           |702         |1         |{=r/gpadmin}|NULL      |
```


**4. Просмотрите информацию о структуре таблицы `pg_catalog.pg_class`**

Из DBeaver через вкладку DDL:
```
CREATE TABLE pg_catalog.pg_class (
	relname name NOT NULL,
	relnamespace oid NOT NULL,
	reltype oid NOT NULL,
	reloftype oid NOT NULL,
	relowner oid NOT NULL,
	relam oid NOT NULL,
	relfilenode oid NOT NULL,
	reltablespace oid NOT NULL,
	relpages int4 NOT NULL,
	reltuples float4 NOT NULL,
	relallvisible int4 NOT NULL,
	reltoastrelid oid NOT NULL,
	relhasindex bool NOT NULL,
	relisshared bool NOT NULL,
	relpersistence char NOT NULL,
	relkind char NOT NULL,
	relstorage char NOT NULL,
	relnatts int2 NOT NULL,
	relchecks int2 NOT NULL,
	relhasoids bool NOT NULL,
	relhaspkey bool NOT NULL,
	relhasrules bool NOT NULL,
	relhastriggers bool NOT NULL,
	relhassubclass bool NOT NULL,
	relispopulated bool NOT NULL,
	relreplident char NOT NULL,
	relfrozenxid xid NOT NULL,
	relminmxid xid NOT NULL,
	relacl _aclitem NULL,
	reloptions _text NULL
)
WITH (
	OIDS=TRUE
)
DISTRIBUTED RANDOMLY;
CREATE UNIQUE INDEX pg_class_oid_index ON pg_catalog.pg_class USING btree (oid);
CREATE UNIQUE INDEX pg_class_relname_nsp_index ON pg_catalog.pg_class USING btree (relname, relnamespace);
CREATE INDEX pg_class_tblspc_relfilenode_index ON pg_catalog.pg_class USING btree (reltablespace, relfilenode);
```


Через консоль `psql`
```shell
adb=# \d+ pg_catalog.pg_class
```
```
                          Table "pg_catalog.pg_class"
     Column     |   Type    | Modifiers | Storage  | Stats target | Description
----------------+-----------+-----------+----------+--------------+-------------
 relname        | name      | not null  | plain    |              |
 relnamespace   | oid       | not null  | plain    |              |
 reltype        | oid       | not null  | plain    |              |
 reloftype      | oid       | not null  | plain    |              |
 relowner       | oid       | not null  | plain    |              |
 relam          | oid       | not null  | plain    |              |
 relfilenode    | oid       | not null  | plain    |              |
 reltablespace  | oid       | not null  | plain    |              |
 relpages       | integer   | not null  | plain    |              |
 reltuples      | real      | not null  | plain    |              |
 relallvisible  | integer   | not null  | plain    |              |
 reltoastrelid  | oid       | not null  | plain    |              |
 relhasindex    | boolean   | not null  | plain    |              |
 relisshared    | boolean   | not null  | plain    |              |
 relpersistence | "char"    | not null  | plain    |              |
 relkind        | "char"    | not null  | plain    |              |
 relstorage     | "char"    | not null  | plain    |              |
 relnatts       | smallint  | not null  | plain    |              |
 relchecks      | smallint  | not null  | plain    |              |
 relhasoids     | boolean   | not null  | plain    |              |
 relhaspkey     | boolean   | not null  | plain    |              |
 relhasrules    | boolean   | not null  | plain    |              |
 relhastriggers | boolean   | not null  | plain    |              |
 relhassubclass | boolean   | not null  | plain    |              |
 relispopulated | boolean   | not null  | plain    |              |
 relreplident   | "char"    | not null  | plain    |              |
 relfrozenxid   | xid       | not null  | plain    |              |
 relminmxid     | xid       | not null  | plain    |              |
 relacl         | aclitem[] |           | extended |              |
 reloptions     | text[]    |           | extended |              |
Indexes:
    "pg_class_oid_index" UNIQUE, btree (oid)
    "pg_class_relname_nsp_index" UNIQUE, btree (relname, relnamespace)
    "pg_class_tblspc_relfilenode_index" btree (reltablespace, relfilenode)
Has OIDs: yes
```


**5. Просмотрите информацию о структуре таблицы `gp_toolkit.__gp_log_master_ext`**

Из DBeaver через вкладку DDL:
```
CREATE EXTERNAL WEB TABLE adb.gp_toolkit.__gp_log_master_ext (
	logtime timestamptz,
	loguser text,
	logdatabase text,
	logpid text,
	logthread text,
	loghost text,
	logport text,
	logsessiontime timestamptz,
	logtransaction int4,
	logsession text,
	logcmdcount text,
	logsegment text,
	logslice text,
	logdistxact text,
	loglocalxact text,
	logsubxact text,
	logseverity text,
	logstate text,
	logmessage text,
	logdetail text,
	loghint text,
	logquery text,
	logquerypos int4,
	logcontext text,
	logdebug text,
	logcursorpos int4,
	logfunction text,
	logfile text,
	logline int4,
	logstack text
)
EXECUTE 'cat $GP_SEG_DATADIR/pg_log/*.csv' ON MASTER
FORMAT 'CSV' ( delimiter ',' null '' escape '"' quote '"' )
ENCODING 'UTF8';
```

Через консоль `psql`
```shell
adb=# \d+ gp_toolkit.__gp_log_master_ext
```
```
                        External table "gp_toolkit.__gp_log_master_ext"
     Column     |           Type           | Modifiers | Storage  | Stats target | Description
----------------+--------------------------+-----------+----------+--------------+-------------
 logtime        | timestamp with time zone |           | plain    |              |
 loguser        | text                     |           | extended |              |
 logdatabase    | text                     |           | extended |              |
 logpid         | text                     |           | extended |              |
 logthread      | text                     |           | extended |              |
 loghost        | text                     |           | extended |              |
 logport        | text                     |           | extended |              |
 logsessiontime | timestamp with time zone |           | plain    |              |
 logtransaction | integer                  |           | plain    |              |
 logsession     | text                     |           | extended |              |
 logcmdcount    | text                     |           | extended |              |
 logsegment     | text                     |           | extended |              |
 logslice       | text                     |           | extended |              |
 logdistxact    | text                     |           | extended |              |
 loglocalxact   | text                     |           | extended |              |
 logsubxact     | text                     |           | extended |              |
 logseverity    | text                     |           | extended |              |
 logstate       | text                     |           | extended |              |
 logmessage     | text                     |           | extended |              |
 logdetail      | text                     |           | extended |              |
 loghint        | text                     |           | extended |              |
 logquery       | text                     |           | extended |              |
 logquerypos    | integer                  |           | plain    |              |
 logcontext     | text                     |           | extended |              |
 logdebug       | text                     |           | extended |              |
 logcursorpos   | integer                  |           | plain    |              |
 logfunction    | text                     |           | extended |              |
 logfile        | text                     |           | extended |              |
 logline        | integer                  |           | plain    |              |
 logstack       | text                     |           | extended |              |
Type: readable
Encoding: UTF8
Format type: csv
Format options: delimiter ',' null '' escape '"' quote '"'
External options: {}
Command: cat $GP_SEG_DATADIR/pg_log/*.csv
Execute on: master segment
```