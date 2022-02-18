--
-- Лабораторная работа №3
--

/**
 * 1. Создайте таблицу table4 (колоночная, сжатие zstd уровня 1):
 *     id1 int,
 *     id2 int,
 *     gen1 text,
 *     gen2 text.
 */

create table table4 (
	id1 int,
    id2 int,
    gen1 text,
    gen2 text
)
with (
	appendonly = true,
	orientation = column, 
	compresstype = zstd, 
	compresslevel = 1
)
distributed by (id1);


/**
 * 2. Вставьте в таблицу данные:
 * INSERT INTO table4 SELECT gen, gen, 'text' || gen::text,'text' || gen::text FROM generate_series(1,2000000) gen;
 */

INSERT INTO table4 SELECT gen, gen, 'text' || gen::text,'text' || gen::text FROM generate_series(1,2000000) gen;


/**
 * 3. Создайте индексы, замеряя время их создания с помощью консольной утилиты time:
 * id1 – btree
 * id2 – bitmap
 * gen1 – btree
 * gen2 – bitmap
 */

-- adb-# \timing
-- Timing is on.

CREATE INDEX id1_indx ON table4 USING btree (id1);
--Time: 1122.402 ms

CREATE INDEX id2_indx ON table4 USING bitmap (id2);
-- Time: 28785.568 ms

CREATE INDEX gen1_indx ON table4 USING btree (gen1);
-- Time: 1452.411 ms

CREATE INDEX gen2_indx ON table4 USING bitmap (gen2);
--Time: 39825.134 ms

