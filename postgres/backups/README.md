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

 - Get the password for the DB (if you used the operator)
   
   ```bash
   kubectl get secret k8up.longhorn-test.credentials.postgresql.acid.zalan.do \
   -o json |jq -r .data.password |base64 -d
   ```

2. Log in via password prompt to an interractive shell using one of the following methods:

- Via interractive shell w/ password prompt
  
  ```bash
  psql postgres://<user>:<password>@<ip>:<port>/<database>
  ```

- Run command as a one-liner

  ```bash
  
  export id=0
  export machine_name="bradley"
  export vendor="on-prem"
  export cpu_alias="i7-11700"
  export baseline_info=$(yq -o=json -I=0 '.BaselineInfo' results_all.yml)
  export version=$(yq -o=json -I=0 '.Version' results_all.yml)
  export results=$(yq -o=json -I=0 '.Results' results_all.yml)
  export system_info=$(yq -o=json -I=0 '.SystemInformation' results_all.yml)


  psql \
    --username=k8up  \
    --port=6432  \
    --no-password  \
    --host=localhost  \
    --dbname=pcmark  \
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
   -t -c \
   "SELECT vendor AS vendor,
    machine_name AS machine_name,
    cpu_alias AS cpu_alias,
    system_info->>'Processor' AS cpu,
    results->>'CPU_SINGLETHREAD' AS single_threaded FROM pcmark;"
  ```

## Prepare external Storage in B2

1. Create a new bucket
2. Create a new application key
3. Save the bucket's endpoint URL and Name for the next step

## Prepare the External Secrets

- See [example](examples/external-secret.yaml).

## Prepare the backup job

- See [example](examples/backup-job.yaml).

## Run the backup job

- Log into argocd
  
- deploy the backup app

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

## Delete data in the database

```bash
psql  --username=k8up  \
 --port=6432 \
 --no-password \
 --host=localhost \
 --dbname=test -t -c \
 "DROP TABLE pcmark;"
```

## Restore Data

1. Get list of snapshots

  ```bash
  # list snapshots in namespace
  kubectl get snapshots -n default
  ```

2. Get Snapshot's ID
   
  ```bash
  # inspect specific snapshot and get it's ID using jq
  kubectl get snapshots -n default e3e9ab1b -o json |jq -r '.spec.id'
  ```

3. Run the restore

  ```bash
  export KUBECONFIG=""
  export NAMESPACE=""
  export BUCKET=""
  export ENDPOINT=""
  export REPO_SECRET=""
  export BUCKET_SECRET=""
  export PVC=""
  export SNAPSHOT=""

  k8up cli restore --restoreMethod pvc \
   --kubeconfig "$KUBECONFIG" \
   --secretRef "REPO_SECRET" \
   --namespace "$NAMESPACE" \
   --s3endpoint "$ENDPOINT" \
   --s3bucket "$BUCKET" \
   --s3secretRef "BUCKET_SECRET" \
   --snapshot "$SNAPSHOT" \
   --claimName "$PVC" \
   --runAsUser 0
 ```  
