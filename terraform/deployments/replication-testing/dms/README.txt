

Engine | From | to 
---|---|---
Postgres | jfharden-test-content-data-api-001-postgres | jfharden-test-content-data-api-empty-001-postgres
MySQL | jfharden-test-whitehall-001-postgres | jfharden-test-whitehall-empty-001-postgres


Notes:

* Need to set some params which require a db reboot
* materialised view support is limited, need to check the issues
* Sequences will have incorrect next values :(

## Steps:

### On the source

* Create a DMS user if we don't want to use the master
* Change rds params:
  * Enable logical replication `rds.logical_replication = "1"`
  * Set wal sender timeout `wal_sender_timeout = "300000"`, this is 5 mins
  * Set `max_worker_processes` equal to, or greate than total of max_logical_replication_workers + autovacuum_max_workers + max_parallel_workers (We have it set to the greater of "vCPUs * 2, or 8" so we need to up this since max_parallel is the same.
    so set to `GREATEST(${DBInstanceVCPU*2},14)`
  * Set shared_preload_libraries to 'pg_stat_statements,pglogical' (it's already pg_stat_statements so we need to add pglogical to it)
* Restart the RDS instance
* Connect as super user and run `CREATE EXTENSION pglogical`

### On the target

* Create a DMS user if we don't want to use the master
* Connect as super user and run `CREATE EXTENSION pglogical`
* Change rds params:wq

* For the initial load:
  * Change rds params:
    * session_replication_role = replica

### Dump and restore the schema

* Create the database on the target
* Create the database app role and permissions on the target
* pg_dump the schema on the source
* psql apply the schma

### After full load on the target

* Change rds params:
    * Remove session_replication_role so it goes back to the default of "origin"
 

