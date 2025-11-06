

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
 

# Caveats

* Neither postgres nor mysql migrate the users/roles, these need creating in advance, up front, with all the required permissions, for postgres you ALSO have to create the database first too

# Database survey:

## MySQL

Caveats:

* AWS DMS homogeneous data migrations creates unencrypted MySQL and MariaDB objects on the target Amazon RDS instances even if the source objects were encrypted. RDS for MySQL doesn't support the MySQL keyring_aws AWS Keyring Plugin required for encrypted objects. Refer to the MySQL Keyring Plugin not supported documentation in the Amazon RDS User Guide
* AWS DMS does not use Global Transaction Identifiers (GTIDs) for for data replication even if the source data contains them.
* In Amazon RDS, when you turn on automated backup for a MySQL/Maria database instance, you also turn on binary logging. When these settings are enabled, your data migration task may fail with the following error while creating secondary objects such as functions, procedures, and triggers on the target database. If your target database has binary logging enabled, then set log_bin_trust_function_creators to true in the database parameter group before starting the task.
  ```
    ERROR 1419 (HY000): You don't have the SUPER privilege and binary logging is enabled (you might want to use the less safe log_bin_trust_function_creators variable)
  ```

## PostgreSQL


