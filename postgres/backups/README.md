# Postgres Bakups Test Process
 - TODO: bitnami example

## Connecting to postgres

 1. deploy maintenance container into the same namespace as postgres
 2. install dnsutils and postgres client
  ```bash
  sudo apt install dnsutils postgresql-client
  ```
 3. run nslookup on the name of the service
    ```bash
    nslookup web-app-postgresql
    Server:         10.43.0.10
    Address:        10.43.0.10#53
    Name:   web-app-postgresql.nextcloud.svc.cluster.local    
    Address: 10.43.142.53
    ```
 5. connect to postgres using the full DNS name
    ```bash
    export FULL_DNS_NAME=$(nslookup web-app-postgresql |grep Name: |awk '{print $2}')
    
    psql -h $FULL_DNS_NAME -p 5432 -U <username> -W
    ```
6. Enter password from bitwarden
   
## Create a Postgres Database
 
 1. Use the postgres operator to create a database via the Web UI (typically something like https://pgops.example.com/#/list), or [manifest](examples/operator-database.yaml).
 
 2. Add an annotation for k8up to the database's PVC:

    ```yaml
    annotations:
      k8up.io/backupcommand: sh -c 'PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean'
      k8up.io/file-extension: .sql
    ```

## Prepare the test database

1. Expose the DB if you didnt use a LoadBalancer or NodePort.

   ```bash
   # find your postgres pod
   kubectl get pods -n default
   NAME              READY   STATUS    RESTARTS   AGE
   longhorn-test-0   1/1     Running   0          9m15s

   # forward the port
   kubectl port-forward longhorn-test-0 6432:5432 -n default
   ```

 - Get the password for the DB (if you used the operator)
   
   ```bash
   export PGPASSWORD=$(kubectl get secret k8up.longhorn-test.credentials.postgresql.acid.zalan.do \
   -n default \
   -o json |jq -r .data.password |base64 -d)
   ```

2. Log in via password prompt to an interractive shell using one of the following methods:

  - Via interractive shell w/ password prompt
  
    ```bash
    psql postgres://k8up:$PGPASSWORD@localhost:6432/test
    ```

  - Run commands as one-liners

    ```bash
    psql --username=k8up  \
      --port=6432  \
      --no-password  \
      --host=localhost  \
      --dbname=pcmark  \
      -t  \
      -c "SELECT * FROM <table>"
    ```

2. create a table

    ```sql
    psql --username k8up  \
      --port 6432  \
      --no-password  \
      --host localhost  \
      --dbname test  \
      -t  \
      -c "CREATE TABLE pcmark (
       id INTEGER NOT NULL,
       vendor TEXT NOT NULL,
       machine_name TEXT NOT NULL,
       cpu_alias TEXT,
       baseline_info JSONB,
       version JSONB,
       results JSONB,
       system_info JSONB
    );"
    ```

4. Insert data into table:

    ```bash
    export id=0
    export machine_name="bradley"
    export vendor="on-prem"
    export cpu_alias="i7-11700"
    export baseline_info=$(yq -o=json -I=0 '.BaselineInfo' test-data.yaml)
    export version=$(yq -o=json -I=0 '.Version' test-data.yaml)
    export results=$(yq -o=json -I=0 '.Results' test-data.yaml)
    export system_info=$(yq -o=json -I=0 '.SystemInformation' test-data.yaml)

    psql --username k8up  \
      --port 6432  \
      --no-password  \
      --host localhost  \
      --dbname test  \
      -t  \
      -c "INSERT INTO pcmark VALUES (
       $id,
       '$vendor',
       '$machine_name',
       '$cpu_alias',
       '$baseline_info',
       '$version',
       '$results',
       '$system_info');"
    ```

5. Query the table

    ```bash
    psql --username k8up  \
      --port 6432  \
      --no-password  \
      --host localhost  \
      --dbname test  \
      -x \
      -c "SELECT vendor AS vendor,
         machine_name AS machine_name,
         cpu_alias AS cpu_alias,
         system_info->>'Processor' AS cpu,
         results->>'CPU_SINGLETHREAD' AS single_threaded FROM pcmark;"
    ```
  
  - Expected Output:
    
    ```bash
    -[ RECORD 1 ]---+---------------------------------------
    vendor          | on-prem
    machine_name    | bradley
    cpu_alias       | i7-11700
    cpu             | 11th Gen Intel Core i7-11700 @ 2.50GHz
    single_threaded | 3447.1733723816888
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
      repoURL: 'https://github.com/small-hack/argocd-apps.git'
      targetRevision: HEAD
    sources: []
    project: default
  ```

- Verify Data in B2

- Delete data in the database

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
