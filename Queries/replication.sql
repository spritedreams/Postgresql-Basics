select now()-pg_last_xact_replay_timestamp() as replication_lag;
select * from pg_stat_activity where usename = 'replikator' ;
select pg_current_wal_lsn();
select pg_last_wal_replay_lsn();
select pg_walfile_name(pg_last_wal_receive_lsn());
select pg_is_in_recovery();

---useful views
pg_stat_replication
pg_stat_wal_receiver
pg_stat_archiver
pg_stat_bgwriter
