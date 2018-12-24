SELECT   quote_ident(n.nspname) as schema , quote_ident(p.proname) as function
FROM   pg_catalog.pg_proc p
JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE  n.nspname not like 'pg%'
    and n.nspname not like 'information_schema%'
;

-- show owner/filter out owned by postgres
SELECT   quote_ident(n.nspname) as schema , quote_ident(p.proname) as function, pg_get_userbyid(p.proowner) as owner
FROM   pg_catalog.pg_proc p
JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE  n.nspname not like 'pg%'
    and n.nspname not like 'information_schema%'
    and pg_get_userbyid(p.proowner) <> 'postgres'


