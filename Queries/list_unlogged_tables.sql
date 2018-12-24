SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
            and c.relpersistence = 'u';
