- CREATE ROLE
-- SUPERUSER | NOSUPERUSER | CREATEDB | NOCREATEDB | CREATEROLE | NOCREATEROLE | INHERIT | NOINHERIT | LOGIN | NOLOGIN | REPLICATION | NOREPLICATION | BYPASSRLS | NOBYPASSRLS
-- CONNECTION LIMIT connlimit | [ ENCRYPTED ] PASSWORD 'password' | VALID UNTIL 'timestamp'
-- DB specific permissions cannot be set in a template (such as connect)

-- General
REVOKE ALL ON DATABASE db_name FROM PUBLIC; -- Options DATABASE: CREATE | CONNECT | TEMPORARY | ALL
REVOKE ALL ON SCHEMA public FROM PUBLIC; -- Options SCHEMA: CREATE | USAGE | ALL
grant usage on schema public to public;

-- Readonly 
create role readonly nologin; -- select
grant SELECT ON ALL tables in schema public to readonly; -- Options TABLES: SELECT | INSERT | UPDATE | DELETE | TRUNCATE | REFERENCES | TRIGGER | ALL [also can set table/column permissions]

-- Read/write 
create role readwrite nologin; -- select,insert,update,delete
grant select, insert, update, delete on all tables in schema public to readwrite;
grant usage on all sequences in schema public to readwrite; -- Options SEQUENCES: USAGE | SELECT | UPDATE | ALL

-- Admin group
create role admin_group NOSUPERUSER CREATEROLE CREATEDB NOLOGIN NOREPLICATION BYPASSRLS;
grant all on schema public to admin_group;
grant all on DATABASE db_name to admin_group;
alter default privileges for role admin_group in schema public grant select on tables to readonly;
alter default privileges for role admin_group in schema public grant select, insert, update, delete on tables to readwrite;
alter default privileges for role admin_group in schema public grant usage on sequences to readwrite;
create role admin_connect nologin noiherit; -- set db connection to admin group (so not set directly to user)
grant admin_group to admin_connect;
grant connect on database db_name to admin_connect;

-- Application group
create role app_group inherit nologin; -- apps users
grant readwrite to app_group;
grant connect,temporary on DATABASE db_name to app_group;

-- Readonly group
create role readonly_group inherit nologin;
grant readonly to readonly_group;
grant connect on DATABASE db_name to readonly_group;

-- Users (Login)
create role some_admin_user inherit login;
grant admin_connect to some_admin_user; -- allows user to connect and inherit admin privileges after setting role as admin_group
create role some_app_user inherit login; -- app user
grant app_group to some_app_user;
create role some_ro_user inherit login; -- readonly user
grant readonly_group to some_ro_user;






