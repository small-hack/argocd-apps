# Postgres Bakups Test Process

## Create a Postgres Database
 
 - TODO
 
 - Add annotation to PVC

    ```yaml
    annotations:
      k8up.io/backupcommand: sh -c 'PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean'
      k8up.io/file-extension: .sql
    ```

## Connect to postgres

- Log in via password prompt to an interractive shell:

  ```bash
  psql postgres://<user>:<password>@<ip>:<port>/<database>
  ```

- Login + Query:

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

## Create a B2 Bucket

- Create a new bucket
- Create a new application key
- Create an external secret

## Create an External Secret

```yaml
---
# b2 bucket key/key ID for k8up, backups for persistent volumes using restic
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: k8up-b2-creds-pg-backup
  namespace: default
spec:
  target:
    name: k8up-b2-creds-pg-backup
    deletionPolicy: Delete
    template:
      type: Opaque
      data:
        applicationKeyId: |-
          {{ .applicationKeyId }}
        applicationKey: |-
          {{ .applicationKey }}
  data:
    - secretKey: applicationKeyId
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: <bitwarden secret id>
        property: username

    - secretKey: applicationKey
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: <bitwarden secret id>
        property: password

---
# repo secret for k8up, backups for persistent volumes using restic
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: k8up-restic-b2-repo-pw-pg-backup
  namespace: default
spec:
  target:
    # Name for the secret to be created on the cluster
    name: k8up-restic-b2-repo-pw-pg-backup
    deletionPolicy: Delete
    template:
      type: Opaque
      data:
        password: |-
          {{ .password }}

  data:
    - secretKey: password
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: <bitwarden secret id>
        property: password
```

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
