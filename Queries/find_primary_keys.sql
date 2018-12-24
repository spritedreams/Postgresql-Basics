WITH t as (
    SELECT table_name
        FROM information_schema.tables
    WHERE table_schema='public'
)
select
    t.table_name,
    temp.attname
from
    t
    left join lateral (
        SELECT
            a.attname
        FROM    pg_attribute a
        JOIN    pg_index i ON a.attrelid = i.indrelid and a.attnum = ANY(i.indkey) and i.indisprimary
        where t.table_name::regclass = i.indrelid
    ) temp on (true)
order by 2,1 desc;

----------------------
WITH t as (
    SELECT table_name
        FROM information_schema.tables
    WHERE table_schema='public'
        AND table_type='BASE TABLE'
)
SELECT t.table_name,a.attname as primary_key_column, format_type(a.atttypid, a.atttypmod) AS data_type
    FROM    pg_index i
    JOIN    pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
    JOIN    t on t.table_name::regclass = i.indrelid
WHERE
    i.indisprimary
ORDER BY t.table_name;

------------------------------
WITH t as (
    SELECT table_name
        FROM information_schema.tables
    WHERE table_schema='public'
        AND table_type='BASE TABLE'
),
x as (
    SELECT t.table_name
        FROM    pg_index i
        JOIN    pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        JOIN    t on t.table_name::regclass = i.indrelid
    WHERE
        i.indisprimary
    GROUP BY t.table_name
)
select t.table_name,x.table_name
from
    t left outer join x on x.table_name = t.table_name
where
    x.table_name is null;
