# Postgres Setup

Add annotation to PVC

```yaml
  annotations:
    k8up.io/backupcommand: sh -c 'PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean'
    k8up.io/file-extension: .sql
```

## Connection Strings

Log in via password prompt to an interractive shell:

```bash
psql postgres://<user>:<password>@<ip>:<port>/<database>
```

Login + Query:

```bash
PGPASSWORD= \
psql \
 --username=admin  \
 --port=5432  \
 --no-password  \
 --host=85.10.207.24  \
 --dbname=benchmarks  \
 -t  \
 -c "SELECT * FROM <table>"
```

## create a table

```sql
CREATE TABLE <table> (
  id INTEGER NOT NULL,
  vendor TEXT NOT NULL,
  machine_name TEXT NOT NULL,
  cpu_alias TEXT,
  baseline_info JSONB,
  version JSONB,
  results JSONB,
  system_info JSONB
);
```

## Insert data into table:

```bash
INSERT INTO <table> VALUES (
  $id,
'$vendor',
'$machine_name',
'$cpu_alias',
'$baseline_info',
'$version',
'$results',
'$system_info')"
```

psql postgres://admin:<password>@<ip>:5432/postgres

CREATE DATABASE benchmarks;

\c benchmarks

CREATE TABLE pcmark (
  id INTEGER NOT NULL,
  vendor TEXT NOT NULL,
  machine_name TEXT NOT NULL,
  cpu_alias TEXT,
  baseline_info JSONB,
  version JSONB,
  results JSONB,
  system_info JSONB
);


## Create a backup job

```yaml
---
apiVersion: k8up.io/v1
kind: Backup
metadata:
  name: root-backup-to-b2
  namespace: default
spec:
  podSecurityContext:
    runAsUser: 0
  failedJobsHistoryLimit: 10
  successfulJobsHistoryLimit: 10
  backend:
    repoPasswordSecretRef:
      name: name-of-your-secret
      key: password
    s3:
      endpoint: s3.<region>.backblazeb2.com
      bucket: <bucket name>
      accessKeyIDSecretRef:
        name: your-secret-name
        key: applicationKeyId
      secretAccessKeySecretRef:
        name: your-other-secret-name
        key: applicationKey
```
