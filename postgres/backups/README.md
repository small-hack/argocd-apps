# Postgres Bakups Test Process
 - TODO: bitnami example


## Create a Postgres Database
 
 1. Use the postgres operator to create a database via the [Web UI](https://pgops.vleermuis.tech/#/list), or [manifest](examples/operator-database.yaml).
 
 2. Add an annotation for k8up to the database's PVC:

    ```yaml
    annotations:
      k8up.io/backupcommand: sh -c 'PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean'
      k8up.io/file-extension: .sql
    ```

## Prepare the test database

1. Expose the DB if you didnt use a LoadBalancer or NodePort.

   ```bash
   kubectl port-forward k8up-test-0 6432:5432 -n default
   ```

2. Log in via password prompt to an interractive shell using one of the following methods:

- Via interractive shell w/ password prompt
  
  ```bash
  psql postgres://<user>:<password>@<ip>:<port>/<database>
  ```

- Run command as a one-liner

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

2. create a table

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

4. Insert data into table:

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

5. Query the table

  ```bash
  psql  --username=k8up \
   --port=6432 \
   --no-password \
   --host=localhost \
   --dbname=test \
   -t -c\
   "SELECT vendor AS vendor,
    machine_name AS machine_name,
    cpu_alias AS cpu_alias,
    system_info->>'Processor' AS cpu,
    results->>'CPU_SINGLETHREAD' AS single_threaded FROM pcmark";
  ```

## Prepare external Storage in B2

1. Create a new bucket
2. Create a new application key
3. Save the bucket's endpoint URL and Name for the next step

## Prepare the External Secrets

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

## Prepare the backup job

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

## Run the backup job

- Log into argocd
- deploy the app

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8up-pg-backup-test-app
spec:
  destination:
    name: ''
    namespace: default
    server: 'https://kubernetes.default.svc'
  source:
    path: postgres/backups/k8up-test/
    repoURL: 'https://github.com/small-hack/argocd.git'
    targetRevision: HEAD
  sources: []
  project: default
```

## Verify Data in B2

## 
