--list our custom functions and views

SELECT n.nspname as "Schema", 
    p.proname as "Name", 
    pg_catalog.pg_get_function_result(p.oid) as "Result data type", 
    pg_catalog.pg_get_function_arguments(p.oid) as "Argument data types", 
    CASE WHEN p.proisagg THEN 'agg' WHEN p.proiswindow THEN 'window' WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype THEN 'trigger' ELSE 'normal' END as "Type" 
FROM pg_catalog.pg_proc p 
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace 
WHERE n.nspname ~ '^(public)$' 
    and (
        pg_catalog.pg_get_function_result(p.oid) = 'trigger'
        or left(p.proname, 3) = 'sw_'
    )
ORDER BY 1, 2, 3;
