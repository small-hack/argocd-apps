# SeaweedFS Backups and Recovery with k8up

This guide will walk you through the creation, backup, and recovery processes for a local [SeaweedFS](https://github.com/seaweedfs/seaweedfs) deployment and [CloudNative Postgres](https://cloudnative-pg.io/documentation/current/) cluster using [K8up](https://k8up.io/) and [Backblaze B2](https://www.backblaze.com/docs/cloud-storage). 

Recommended reading: [S3 as the universal infrastructure backend](https://medium.com/innovationendeavors/s3-as-the-universal-infrastructure-backend-a104a8cc6991) - Davis Treybig

> For the purposes of this demo, backups are set to run every minute. Plain-text passwords are also used for convenience - do NOT do that in production.
> 
## Outline

1. [K3s Cluster creation](#k3s-cluster-creation)
2. [SeaweedFS instance and user setup](#seaweedfs-instance-and-user-setup)
3. [Deploy Postgres cluster](#deploy-postgres-cluster)
4. [Seed Postgres with sample data](#seed-postgres-with-sample-data)
5. [Configure scheduled backups of Minio to B2](#configure-scheduled-backups-of-minio-to-b2)
6. [Restore Minio from B2 backups](#restore-minio-from-b2-backups)
7. [Restore CNPG from Minio Backups](#restore-cnpg-from-minio-backups)
8. [Major Version Upgrades](#major-version-upgrades)

## Requirements

- K8up CLI
- Kubectl
- Helm
- Restic
- Minio Client CLI (mc)

<h2 id="k3s-cluster-creation">K3s Cluster creation</h2>

1. Download the k3s installer

    ```bash
    curl -sfL https://get.k3s.io > k3s-install.sh
    ```

2. install k3s

    ```bash
    bash k3s-install.sh --disable=traefik
    ```

3. Wait for node to be ready

    ```bash
    sudo k3s kubectl get node
    NAME   STATUS   ROLES                  AGE   VERSION
    vm0    Ready    control-plane,master   1m   v1.27.4+k3s1
    ```

4. Make an accessible version of the kubeconfig

    ```bash
    mkdir -p ~/.config/kube

    sudo cp /etc/rancher/k3s/k3s.yaml ~/.config/kube/config

    sudo chown $USER:$USER ~/.config/kube/config

    export KUBECONFIG=~/.config/kube/config
    ```

4. Install CertManager

    ```bash
    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

    helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.13.2
    ```
    
5. Install CNPG Operator

    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm upgrade --install cnpg \
      --namespace cnpg-system \
      --create-namespace \
      cnpg/cloudnative-pg \
      --version 0.19.0
    ```
    
6. Install the CNPG cluster chart

   ```bash
    helm repo add cnpg-cluster https://small-hack.github.io/cloudnative-pg-cluster-chart
    helm repo update
    ```

7. Install k8up

    ```bash
    repo add k8up-io https://k8up-io.github.io/k8up
    helm repo update
    
    kubectl apply -f https://github.com/k8up-io/k8up/releases/download/k8up-4.4.3/k8up-crd.yaml
    helm install k8up k8up-io/k8up
    ```


<h2 id="seaweedfs-instance-and-user-setup">SeaweedFS instance and user setup</h2>

1. install the AWS cli

    ```bash
    pip install awscli
    ```

2. Clone repo and get the right branch

    ```bash
    git clone https://github.com/cloudymax/seaweedfs
    cd seaweedfs/k8s/charts/seaweedfs
    git checkout helm-add-existingClaim
    ```

3. Create a values file

```yaml
/bin/cat << EOF > test-values.yaml
master:
  data:
    type: "persistentVolumeClaim"
    size: "5Gi"
    storageClass: "local-path"
    annotations:
      "k8up.io/backup": "true"
volume:
  data:
    type: "persistentVolumeClaim"
    size: "5Gi"
    storageClass: "local-path"
    annotations:
      "k8up.io/backup": "true"
filer:
  enablePVC: true
  storage: 5Gi
  data:
    type: "persistentVolumeClaim"
    size: "5Gi"
    storageClass: "local-path"
    annotations:
  s3:
    enabled: true
    port: 8333
    httpsPort: 0
    allowEmptyFolder: false
    domainName: ""
    enableAuth: false
    skipAuthSecretCreation: false
    auditLogConfig: {}
EOF
```

3. Deploy via Helm

   ```bash
   helm template . -f test-values.yaml > manifests.yaml
   kubectl apply -f manifests.yaml
   ```

4. Expose the s3 enpoint

```bash
/bin/cat << EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: swfs-s3-nodeport
  labels:
    "app.kubernetes.io/name": "seaweedfs"
spec:
  type: NodePort
  ports:
  - port: 8333
    nodePort: 30000
    protocol: TCP
  selector:
    "app.kubernetes.io/name": "seaweedfs"
EOF
```

5. Configure the aws cli
   
    - get the `admin_access_key_id` and `admin_secret_access_key` from the secret `seaweedfs-s3-secret`
    
    - run `aws configure`
    
    - Populate the `AWS Access Key ID` and `AWS Secret Access Key` fileds, all other values can be blank

6. Export your NodeIP as an env var

   ```bash
   export NODE_IP=""
   ```

7. Create a bucket for backups
   
    - The endpoint-url is the IP of our node + the nodePort form our service

      ```bash
      aws --endpoint-url http://$NODE_IP:30000 s3 mb s3://postgres15-backups
      ```

<h2 id="deploy-postgres-cluster">Deploy Postgres cluster</h2>

1. Create an example values.yaml for the Postgres cluster

    ```bash
    /bin/cat << EOF > pg-test-values.yaml
    name: "cnpg15"
    instances: 1
    imageName: ghcr.io/cloudnative-pg/postgresql:15.4
    bootstrap:
      initdb:
        database: app
        owner: app
        secret:
          name: null
    certificates:
      server:
        enabled: true
        generate: true
        serverTLSSecret: ""
        serverCASecret: ""
      client:
        enabled: true
        generate: true
        clientCASecret: ""
        replicationTLSSecret: ""
      user:
        enabled: true
        username:
          - "app"
    backup:
      retentionPolicy: "30d"
      barmanObjectStore:
        destinationPath: "s3://postgres15-backups"
        endpointURL: "http://$NODE_IP:30000"
        s3Credentials:
          accessKeyId:
            name: "seaweedfs-s3-secret"
            key: "admin_access_key_id"
          secretAccessKey:
            name: "seaweedfs-s3-secret"
            key: "admin_secret_access_key"
    scheduledBackup:
      name: cnpg-backup
      spec:
        schedule: "0 * * * * *"
        backupOwnerReference: self
        cluster:
          name: cnpg
    monitoring:
      enablePodMonitor: false
    postgresql:
      pg_hba:
        - hostssl all all all cert
    storage:
      size: 1Gi
    testApp:
      enabled: true
    EOF
    ```

4. Create the Postgres cluster

    ```bash
    helm install cnpg-cluster cnpg-cluster/cnpg-cluster --values pg-test-values.yaml
    ```


<h2 id="seed-postgres-with-sample-data">Seed Postgres with sample data</h2>

1. Get the user's `tls.key`, `tls.crt`, and `ca.crt` from secrets

    ```bash
    kubectl get secrets cnpg15-app-cert -o yaml |yq '.data."tls.key"' |base64 -d > tls.key
    chmod 600 tls.key
    kubectl get secrets cnpg15-app-cert -o yaml |yq '.data."tls.crt"' |base64 -d > tls.crt
    chmod 600 tls.crt
    ```

2. Get the servers `ca.crt` from secrets

    ```bash
    kubectl get secrets cnpg15-server-cert -o yaml |yq '.data."ca.crt"' |base64 -d > ca.crt
    chmod 600 ca.crt
    ```

3. Expose Postgres with a service:

  - Create a manifest for the service

    ```bash
    /bin/cat << EOF > service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: cnpg15-service
      labels:
        cnpg.io/cluster: cnpg15
    spec:
      type: NodePort
      ports:
      - port: 5432
        nodePort: 30001
        protocol: TCP
      selector:
        cnpg.io/cluster: cnpg15
        role: primary
    EOF
    ```

  - Create the service:

    ```bash
    kubectl apply -f service.yaml
    ```

4. Create a table for the demo data:

    ```bash
    psql "sslkey=./tls.key 
          sslcert=./tls.crt 
          sslrootcert=./ca.crt 
          host=$NODE_IP
          port=30001 
          dbname=app 
          user=app" -c 'CREATE TABLE processors (data JSONB);'
    ```

5. Download demo data and use script to populate the table

    - Grab a copy of the demo data
   
      ```bash
      wget https://raw.githubusercontent.com/small-hack/argocd-apps/main/postgres/operators/cloud-native-postgres/backups/demo-data.json
      ```

    - Create a script to add the demo data to your table
    
      ```
      /bin/cat << 'EOF' > populate.sh 
      #!/bin/bash
      
      COUNT=$(jq length demo-data.json)

      for (( i=0; i<$COUNT; i++ ))
      do
          JSON=$(jq ".[$i]" demo-data.json)
          psql "sslkey=./tls.key
            sslcert=./tls.crt
            sslrootcert=./ca.crt
            host=$NODE_IP
            port=30001
            dbname=app
            user=app" -c "INSERT INTO processors VALUES ('$JSON');"
      done
      EOF
      ```
    
    - Run the script

      ```bash  
      bash populate.sh
      ```

6. Perform a test query against the DB

    ```bash
    psql "sslkey=./tls.key 
         sslcert=./tls.crt 
         sslrootcert=./ca.crt 
         host=$NODE_IP 
         port=30001 
         dbname=app 
         user=app" -c "SELECT data -> 'cpu_name' AS Cpu,
                              data -> 'cpu_cores' AS Cores,
                              data -> 'cpu_threads' AS Threads,
                              data -> 'release_date' AS ReleaseDate,
                              data -> 'cpumarkSingleThread' AS SingleCorePerf
                              FROM processors
                              ORDER BY SingleCorePerf DESC;"
    ```

    Expected Output:
    
    > ```console
    >               cpu           | cores | threads | releasedate | singlecoreperf
    > ------------------------+-------+---------+-------------+----------------
    >  "Xeon E-2378G"         | 8     | 16      | 2021        | 3477
    >  "Xeon E-2288G"         | 8     | 16      | 2019        | 2783
    >  "EPYC 7713"            | 64    | 128     | 2021        | 2721
    >  "EPYC 7763v"           | 64    | 128     | 2021        | 2576
    >  "Xeon Gold 6338"       | 32    | 64      | 2021        | 2446
    >  "Xeon Platinum 8375C"  | 32    | 64      | 2021        | 2439
    >  "Xeon 2696v4"          | 22    | 44      | 2016        | 2179
    >  "Xeon 2696v3"          | 18    | 36      | 2014        | 2145
    >  "Xeon E5-2690V4"       | 14    | 28      | 2016        | 2066
    >  "Xeon Platinum 8173M"  | 28    | 56      | 2017        | 2003
    >  "EPYC 7402P"           | 24    | 48      | 2019        | 1947
    >  "Xeon Platinum 8175M"  | 24    | 48      | 2018        | 1796
    >  "Xeon Platinum 8259CL" | 24    | 48      | 2020        | 1781
    >  "Xeon 2696v3"          | 12    | 24      | 2013        | 1698
    >  "Xeon Platinum 8370C"  | 32    | 64      | 2021        | 0
    > ```

 <h2 id="configure-scheduled-backups-of-minio-to-b2">Configure scheduled backups of Minio to B2</h2>

 1. Create a secret containing your external S3 credentials

    - You will need to get these from your provider:
    
      ```bash
      export ACCESS_KEY_ID=$(echo -n "" | base64)
      
      export ACCESS_SECRET_KEY=$(echo -n "" |base64)
      ```
      
      ```bash
      /bin/cat << EOF > backblaze-secret.yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: backblaze-credentials
      type: Opaque
      data:
        "ACCESS_KEY_ID": "$ACCESS_KEY_ID"
        "ACCESS_SECRET_KEY": "$ACCESS_SECRET_KEY"
      EOF

      kubectl apply -f backblaze-secret.yaml
      ```

    - Create a second secret with different keys to support the K8up CLI if you plan to use it.

      ```bash
      /bin/cat << EOF > k8up-secret.yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: k8up-credentials
      type: Opaque
      data:
        "username": "$ACCESS_KEY_ID"
        "password": "$ACCESS_SECRET_KEY"
      EOF

      kubectl apply -f k8up.yaml
      ```
 
 2. Create a secret containing a random password for restic

  - Generate a password and base64 encode it.
    
    ```bash
    export RESTIC_PASS=$(openssl rand -base64 32)
    ```
    
  - Create a secret manifest

    ```bash
    /bin/cat << EOF > restic.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: restic-repo
    type: Opaque
    data:
      "password": "$RESTIC_PASS"
    EOF
    ```
    
  - Create the secret

    ```bash
    kubectl apply -f restic.yaml
    ```

3. Create a scheduled backups

  - Create a manifest for the backup 

    ```bash
    /bin/cat << EOF > backup.yaml
    apiVersion: k8up.io/v1
    kind: Schedule
    metadata:
      name: schedule-backups
    spec:
      backend:
        repoPasswordSecretRef:
          name: restic-repo
          key: password
        s3:
          endpoint: "s3.us-west-004.backblazeb2.com"
          bucket: "buildstars-minio-backup"
          accessKeyIDSecretRef:
            name: backblaze-credentials
            key: ACCESS_KEY_ID
          secretAccessKeySecretRef:
            name: backblaze-credentials
            key: ACCESS_SECRET_KEY
      backup:
        schedule: '* * * * *'
        keepJobs: 4
      check:
        schedule: '0 1 * * 1'
      prune:
        schedule: '0 1 * * 0'
        retention:
          keepLast: 5
          keepDaily: 14
    EOF
    ```

  - Create the backup

    ```bash
    kubectl apply -f backup.yaml
    ```

<h2 id="restore-minio-from-b2-backups">Restore Minio from B2 backups</h2>

1. Uninstall minio and postgres and delete your scheduled backup

   ```bash
   helm uninstall cnpg-cluster
   
   k delete -f seaweedfs/k8s/charts/seaweedfs/manifests.yaml
   
   kubectl delete -f backup.yaml 
   ```

2. Create PVCs to hold our restored data

  - Create a manifest for the PVCs

```bash
/bin/cat << EOF > pvc.yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: swfs-volume-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: swfs-master-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: swfs-filer-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF
```
  
  - Create the PVC

    ```bash
    kubectl apply -f pvc.yaml
    ```
3. Setup your restic redentials

```bash
# the password used in your restic-repo secret
export RESTIC_PASSWORD=""

# Your backblaze credentials
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
RESTIC_REPOSITORY="s3://<backblaze bucket url>/<backups bucket>
```

4. Find your desired snapshot to restore

```bash
restic snapshots
repository 650596ff opened (version 2, compression level auto)
created new cache in /home/friend/.cache/restic
ID        Time                 Host        Tags        Paths
--------------------------------------------------------------------------------------------
4db7cb29  2023-11-19 12:24:11  default                 /data/cnpg15-1
4de08d63  2023-11-19 12:24:14  default                 /data/data-default-seaweedfs-master-0
fe4ffc6f  2023-11-19 12:24:20  default                 /data/data-filer-seaweedfs-filer-0
912e6cde  2023-11-19 12:24:24  default                 /data/data-seaweedfs-volume-0
55a2f1ee  2023-11-19 12:25:07  default                 /data/cnpg15-1
48be1efb  2023-11-19 12:25:13  default                 /data/data-default-seaweedfs-master-0
d27abb43  2023-11-19 12:25:17  default                 /data/data-filer-seaweedfs-filer-0
e3c88621  2023-11-19 12:25:21  default                 /data/data-seaweedfs-volume-0
a01c6a17  2023-11-19 12:26:07  default                 /data/cnpg15-1
30b4678b  2023-11-19 12:26:13  default                 /data/data-default-seaweedfs-master-0
675b5ebe  2023-11-19 12:26:18  default                 /data/data-filer-seaweedfs-filer-0
cbcd7def  2023-11-19 12:26:23  default                 /data/data-seaweedfs-volume-0
1d7b48b0  2023-11-19 12:27:07  default                 /data/cnpg15-1
bf2305b0  2023-11-19 12:27:13  default                 /data/data-default-seaweedfs-master-0
034405a2  2023-11-19 12:27:18  default                 /data/data-filer-seaweedfs-filer-0
b09694ed  2023-11-19 12:27:22  default                 /data/data-seaweedfs-volume-0
4971c8cd  2023-11-19 12:28:08  default                 /data/cnpg15-1
4e6502f4  2023-11-19 12:28:13  default                 /data/data-default-seaweedfs-master-0
d2177064  2023-11-19 12:28:18  default                 /data/data-filer-seaweedfs-filer-0
ff056fdf  2023-11-19 12:28:23  default                 /data/data-seaweedfs-volume-0
f6be0d73  2023-11-19 12:29:08  default                 /data/cnpg15-1
328df749  2023-11-19 12:29:14  default                 /data/data-default-seaweedfs-master-0
b26460ff  2023-11-19 12:29:19  default                 /data/data-filer-seaweedfs-filer-0
a4904f73  2023-11-19 12:29:26  default                 /data/data-seaweedfs-volume-0
7a853211  2023-11-19 12:30:08  default                 /data/cnpg15-1
921fe874  2023-11-19 12:30:14  default                 /data/data-default-seaweedfs-master-0
cb3612fb  2023-11-19 12:30:19  default                 /data/data-filer-seaweedfs-filer-0
1bbde1a5  2023-11-19 12:30:24  default                 /data/data-seaweedfs-volume-0
--------------------------------------------------------------------------------------------
28 snapshots
```

4. Use the K8up CLI or a declarative setup to restore data to the PVC. You will need to do this for each PVC that needs to be restored 

    > Minio requires you to run the restore as user `1000`

  - Example of restoring from S3 to a PVC using the K8up CLI. 

    ```bash
    k8up cli restore \
      --restoreMethod pvc \
      --kubeconfig "$KUBECONFIG" \
      --secretRef restic-repo \
      --namespace default \
      --s3endpoint s3.us-west-004.backblazeb2.com \
      --s3bucket buildstars-minio-backup \
      --s3secretRef k8up-credentials \
      --snapshot 1bbde1a5 \
      --claimName swfs-volume-data \
      --runAsUser 1000
    ```
    
  - Example manifest for a S3-to-PVC restore job 

    ```bash
    /bin/cat << EOF > s3-to-pvc.yaml
    apiVersion: k8up.io/v1
    kind: Restore
    metadata:
      name: restore-from-b2
    spec:
      restoreMethod:
        folder:
          claimName: swfs-volume-data
      podSecurityContext:
        runAsUser: 1000
      snapshot: 1bbde1a5
      backend:
        repoPasswordSecretRef:
          name: restic-repo
          key: password
        s3:
          endpoint: s3.us-west-004.backblazeb2.com
          bucket: buildstars-minio-backup
          accessKeyIDSecretRef:
            name: backblaze-credentials
            key: ACCESS_KEY_ID
          secretAccessKeySecretRef:
            name: backblaze-credentials
            key: ACCESS_SECRET_KEY
    EOF
    ```

  - Apply manifest
    ```bash
    kubectl apply -f s3-to-pvc.yaml
    ```
    
5. Re-deploy Seaweedfs from the existing PVCs

```yaml
cd seaweedfs/k8s/charts/seaweedfs/

/bin/cat << EOF > restore-values.yaml
master:
  data:
    type: "existingClaim"
    claimName: "swfs-master-data"
volume:
  data:
    type: "existingClaim"
    claimName: "swfs-volume-data"
filer:
  enablePVC: false
  data:
    type: "existingClaim"
    claimName: "swfs-filer-data"
  s3:
    enabled: true
    port: 8333
    httpsPort: 0
    allowEmptyFolder: false
    domainName: ""
    enableAuth: false
    skipAuthSecretCreation: false
    auditLogConfig: {}
EOF
```

- Deploy via Helm

   ```bash
   helm template . -f restore-values.yaml > manifests.yaml
   kubectl apply -f manifests.yaml
   ```

<h2 id="restore-cnpg-from-minio-backups">Restore CNPG from Minio Backups</h2>

1. Create a values file that targets your Minio instance for backups

   > Backups are disabled during the recovery process and will be re-enabled in the next step.

    ```bash
    /bin/cat << EOF > restore-values.yaml
    name: "cnpg"
    instances: 1
    imageName: ghcr.io/cloudnative-pg/postgresql:15.4
    bootstrap:
      initdb: []
      recovery:
        source: cnpg
    certificates:
      server:
        enabled: true
        generate: true
        serverTLSSecret: ""
        serverCASecret: ""
      client:
        enabled: true
        generate: true
        clientCASecret: ""
        replicationTLSSecret: ""
      user:
        enabled: true
        username:
          - "app"
    backup: []
    #   retentionPolicy: "30d"
    #   barmanObjectStore:
    #     destinationPath: "s3://postgres15-backups"
    #     endpointURL: "http://85.10.207.26:32000"
    #     s3Credentials:
    #       accessKeyId:
    #         name: "minio-credentials"
    #         key: "ACCESS_KEY_ID"
    #       secretAccessKey:
    #         name: "minio-credentials"
    #         key: "ACCESS_SECRET_KEY"
    scheduledBackup: []
    #   name: cnpg-backup
    #   spec:
    #     schedule: "0 * * * * *"
    #     backupOwnerReference: self
    #     cluster:
    #       name: cnpg
    externalClusters:
      - name: cnpg
        barmanObjectStore:
          destinationPath: "s3://postgres15-backups/"
          endpointURL: "http://85.10.207.26:32000"
          s3Credentials:
            accessKeyId:
              name: "minio-credentials"
              key: "ACCESS_KEY_ID"
            secretAccessKey:
              name: "minio-credentials"
              key: "ACCESS_SECRET_KEY"
          wal:
            maxParallel: 8
    monitoring:
      enablePodMonitor: false
    storage:
      size: 1Gi
    testApp:
      enabled: false
    EOF
    ```

4. Re-install Postgres

    ```bash
    helm install cnpg-cluster cnpg-cluster/cnpg-cluster --values restore-values.yaml
    ```

5. Verify that your data is restored

    ```bash
    psql "sslkey=./tls.key 
         sslcert=./tls.crt 
         sslrootcert=./ca.crt 
         host=$LOADBALANCER_IP
         port=30000 
         dbname=app 
         user=app" -c "SELECT data -> 'cpu_name' AS Cpu,
                              data -> 'cpu_cores' AS Cores,
                              data -> 'cpu_threads' AS Threads,
                              data -> 'release_date' AS ReleaseDate,
                              data -> 'cpumarkSingleThread' AS SingleCorePerf
                              FROM processors
                              ORDER BY SingleCorePerf DESC;"
    ```

    Expected Output:
     
    > ```console
    >           cpu           | cores | threads | releasedate | singlecoreperf
    > ------------------------+-------+---------+-------------+----------------
    >  "Xeon E-2378G"         | 8     | 16      | 2021        | 3477
    >  "Xeon E-2288G"         | 8     | 16      | 2019        | 2783
    >  "EPYC 7713"            | 64    | 128     | 2021        | 2721
    >  "EPYC 7763v"           | 64    | 128     | 2021        | 2576
    >  "Xeon Gold 6338"       | 32    | 64      | 2021        | 2446
    >  "Xeon Platinum 8375C"  | 32    | 64      | 2021        | 2439
    >  "Xeon 2696v4"          | 22    | 44      | 2016        | 2179
    >  "Xeon 2696v3"          | 18    | 36      | 2014        | 2145
    >  "Xeon E5-2690V4"       | 14    | 28      | 2016        | 2066
    >  "Xeon Platinum 8173M"  | 28    | 56      | 2017        | 2003
    >  "EPYC 7402P"           | 24    | 48      | 2019        | 1947
    >  "Xeon Platinum 8175M"  | 24    | 48      | 2018        | 1796
    >  "Xeon Platinum 8259CL" | 24    | 48      | 2020        | 1781
    >  "Xeon 2696v3"          | 12    | 24      | 2013        | 1698
    >  "Xeon Platinum 8370C"  | 32    | 64      | 2021        | 0
    > ```

6. Re-enable backups

   Uncomment the backups sections of the restore-values, and upgrade the deployment
   
   ```bash
   helm upgrade -f restore-values.yaml cnpg-cluster cnpg-cluster/cnpg-cluster
   ```

<h2 id="major-version-upgrades">Major Version Upgrades</h2>

Major upgrades must be perfomed by importing data from a running database. Additionally, the existing database must accept password authentication as SSL Certificates are not a supported method of connecting to an external cluster for import purposes.

To get around these issues we will:

- Assume the upgrade in question is v15.4 to v16.0
- Create a new 15.4 cluster from backups which can will accept password authentication.
- Create a new 16.0 cluster which targets our 15.4 cluster
- Delete the 15.4 cluster

1. Create a new bucket for backups of the new major version

    ```bash
    mc mb myminio/postgres16-backups --with-versioning
    ```
2. Create a manifest for the 15.4 cluster that accepts password authentication

```bash
/bin/cat << EOF > password-cluster.yaml
name: "cnpg-15"
instances: 1
imageName: ghcr.io/cloudnative-pg/postgresql:15.4
bootstrap:
  initdb: []
  recovery:
    source: cnpg
certificates:
  server:
    enabled: true
    generate: true
    serverTLSSecret: ""
    serverCASecret: ""
  client:
    enabled: true
    generate: true
    clientCASecret: ""
    replicationTLSSecret: ""
  user:
    enabled: true
    username:
      - "app"
backup: []
scheduledBackup: []
externalClusters:
  - name: cnpg
    barmanObjectStore:
      destinationPath: "s3://postgres15-backups/"
      endpointURL: "http://85.10.207.26:32000"
      s3Credentials:
        accessKeyId:
          name: "minio-credentials"
          key: "ACCESS_KEY_ID"
        secretAccessKey:
          name: "minio-credentials"
          key: "ACCESS_SECRET_KEY"
      wal:
        maxParallel: 8
monitoring:
  enablePodMonitor: false
postgresql:
  pg_hba:
    - host all all all md5
storage:
  size: 1Gi
testApp:
  enabled: false
EOF
```
   
4. Uninstall your current postgres deployment

5. Create a manifest to bootstrap a new cluster from a backup.

    ```bash
    /bin/cat << EOF > upgrade.yaml
    name: "cnpg-16"
    imageName: ghcr.io/cloudnative-pg/postgresql:16.0
    instances: 1
    bootstrap:
      initdb:
        import:
          type: microservice
          databases:
            - app
          source:
            externalCluster: cnpg-15
    certificates:
      server:
        enabled: true
        generate: true
        serverTLSSecret: ""
        serverCASecret: ""
      client:
        enabled: true
        generate: true
        clientCASecret: ""
        replicationTLSSecret: ""
      user:
        enabled: true
        username:
          - "app"
    backup: []
    scheduledBackup: []
    externalClusters:
      - name: cnpg-15
        connectionParameters:
          host: "cnpg-15-rw.default.svc"
          user: app
          dbname: app
        password:
          name: cnpg-15-app
          key: password
    monitoring:
      enablePodMonitor: false
    postgresql:
      pg_hba:
        - host all all all md5
    storage:
      size: 1Gi
    testApp:
      enabled: false
    EOF
    ```

```bash
helm install cnpg-15 cnpg-cluster/cnpg-cluster --values password-cluster.yaml
```

 - Create a manifest for the service

    ```bash
    /bin/cat << EOF > cnpg-15-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: cnpg-15-service
      labels:
        cnpg.io/cluster: cnpg-15
    spec:
      type: NodePort
      ports:
      - port: 5432
        nodePort: 30015
        protocol: TCP
      selector:
        cnpg.io/cluster: cnpg-15
        role: primary
    EOF
    ```

  - Create the service:

    ```bash
    kubectl apply -f cnpg-15-service.yaml
    ```
    
5. Deploy a new postgres cluster on the latest version using a backup as a source

```bash
/bin/cat << EOF > upgrade.yaml
name: "cnpg-16"
imageName: ghcr.io/cloudnative-pg/postgresql:16.0
instances: 1
bootstrap:
  initdb:
    import:
      type: microservice
      databases:
        - app
      source:
        externalCluster: cnpg-15
certificates:
  server:
    enabled: true
    generate: true
    serverTLSSecret: ""
    serverCASecret: ""
  client:
    enabled: true
    generate: true
    clientCASecret: ""
    replicationTLSSecret: ""
  user:
    enabled: true
    username:
      - "app"
backup: []
scheduledBackup: []
externalClusters:
  - name: cnpg-15
    connectionParameters:
      host: "cnpg-15-rw.default.svc"
      user: app
      dbname: app
    password:
      name: cnpg-15-app
      key: password
monitoring:
  enablePodMonitor: false
postgresql:
  pg_hba:
    - host all all all md5
storage:
  size: 1Gi
testApp:
  enabled: false
EOF
```

   ```bash
   helm install cnpg-16 cnpg-cluster/cnpg-cluster --values upgrade.yaml
   ```

 - Create a manifest for the service

    ```bash
    /bin/cat << EOF > cnpg-16-service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: cnpg-16-service
      labels:
        cnpg.io/cluster: cnpg-16
    spec:
      type: NodePort
      ports:
      - port: 5432
        nodePort: 30016
        protocol: TCP
      selector:
        cnpg.io/cluster: cnpg-16
        role: primary
    EOF
    ```

  - Create the service:

    ```bash
    kubectl apply -f cnpg-16-service.yaml
    ```

- check data
  
  ```bash
  psql "sslkey=./tls.key
     sslcert=./tls.crt
     sslrootcert=./ca.crt
     host=$LOADBALANCER_IP
     port=30016
     dbname=app
     user=app" -c "SELECT data -> 'cpu_name' AS Cpu,
                          data -> 'cpu_cores' AS Cores,
                          data -> 'cpu_threads' AS Threads,
                          data -> 'release_date' AS ReleaseDate,
                          data -> 'cpumarkSingleThread' AS SingleCorePerf
                          FROM processors
                          ORDER BY SingleCorePerf DESC;"
  ```
