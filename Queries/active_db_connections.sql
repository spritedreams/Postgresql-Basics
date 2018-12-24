-- count of active connections per database
select datname,count(*) from pg_stat_activity where datname is not null group by datname;
