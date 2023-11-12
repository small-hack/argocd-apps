# Mino/Postgres Backups, Recovery, and Major-Upgrades

This guide will walk you through the full deployment, backup, and recovery process for a local Minio deployment and postgres cluster using k8up and Backblaze B2. For the purposes of this demo, backups are set to run every minute. Plain-text passwords are also used for convenience - do NOT do that in production.

Recommended reading: [S3 as the universal infrastructure backend](https://medium.com/innovationendeavors/s3-as-the-universal-infrastructure-backend-a104a8cc6991) - Davis Treybig

## Outline

1. K3s Cluster creation
2. Minio instance and user setup
3. Deploy Postgres cluster
4. Seed Postgres with sample data
5. Configure scheduled backups of Minio to B2
6. Restore Minio from B2 backups
7. Restore CNPG from Minio Backups
8. Major Version Upgrades

## Requirements

- K8up CLI
- Kubectl
- Helm
- Restic
- Minio Client CLI (mc)
   
## K3s Cluster creation

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

## Minio instance and user setup

1. install the MinIO client

    Docs: https://min.io/docs/minio/linux/reference/minio-mc.html

    ```bash
    mkdir -p $HOME/minio-binaries

    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O $HOME/minio-binaries/mc

    chmod +x $HOME/minio-binaries/mc

    export PATH=$PATH:$HOME/minio-binaries/
    ```

2. Download Minio helm chart

    ```bash
    helm repo add minio https://charts.min.io/
    ```

3. Deploy Minio via Helm

    - Set a username and password for the initial user
   
      ```bash
      echo "Enter User Name : " && \
      read USERNAME && \
      echo "Enter User Password : " && \
      read PASSWORD
      ```

    - Create a helm values file
   
      ```bash
      /bin/cat << EOF > minio-values.yaml
      mode: standalone
      rootUser: "$USERNAME"
      rootPassword: "$PASSWORD"
      replicas: 1
      persistence:
        enabled: true
        annotations:
          "k8up.io/backup": "true"
        size: 5Gi
      service:
        type: NodePort
      consoleService:
        type: LoadBalancer
        port: "80"
      resources:
        requests:
          memory: 512Mi
      EOF
      ```

    - Install Minio
    
      ```bash
      helm install \
        --values minio-values.yaml \
        --generate-name minio/minio
      ```

5. Get the LoadBalancer's External-IP address and export it

    ```console
    friend@vm0:~$ kubectl get svc
    NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)          AGE
    kubernetes                 ClusterIP      10.43.0.1       <none>           443/TCP          6h31m
    minio-1697277405           NodePort       10.43.124.40    <none>           9000:32000/TCP   6h31m
    minio-1697277405-console   LoadBalancer   10.43.116.107   192.168.50.160   80:31179/TCP     6h31m
    ```

    ```bash
    export LOADBALANCER_IP="<your-LB-IP-here>"
    ```

6. Set an alias for your server:

    ```bash
    mc alias set myminio http://$LOADBALANCER_IP:32000 $USERNAME $PASSWORD
    ```

7. Test the connection:

    ```bash
    mc admin info myminio
    ```

8. Create a Postgres user

    ```bash
    mc admin user add myminio postgres
    ```

    Enter a password when prompted:

    ```console
    Enter Secret Key:
    Added user `postgres` successfully.
    ```

9. Create an Access Key

    ```bash
    mc admin user svcacct add myminio postgres
    ```

10. base64 encode the Access Key and Secret Key    
    
    ```bash
    export ACCESS_KEY_ID=$(echo -n "" | base64)

    export ACCESS_SECRET_KEY=$(echo -n "" |base64)
    ```
    
11. use the following templates to create your secrets.
  
    ```bash
    /bin/cat << EOF > access_key.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: minio-credentials
    type: Opaque
    data:
      "ACCESS_KEY_ID": "$ACCESS_KEY_ID"
      "ACCESS_SECRET_KEY": "$ACCESS_SECRET_KEY"
    EOF

    kubectl apply -f access_key.yaml
    ```

12. Create the backups storage bucket

    ```bash
    mc mb myminio/backups --with-versioning
    ```

13. Grant Postgres account access

    ```bash
    mc admin policy attach myminio readwrite --user postgres
    ```

## Deploy Postgres cluster

1. Create an example values.yaml for the Postgres cluster

    ```bash
    /bin/cat << EOF > test-values.yaml
    name: "cnpg"
    instances: 1
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
        username: "app"
    backup:
      retentionPolicy: "30d"
      barmanObjectStore:
        destinationPath: "s3://backups"
        endpointURL: "http://$LOADBALANCER_IP:32000"
        s3Credentials:
          accessKeyId:
            name: "minio-credentials"
            key: "ACCESS_KEY_ID"
          secretAccessKey:
            name: "minio-credentials"
            key: "ACCESS_SECRET_KEY"
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
    helm install cnpg-cluster cnpg-cluster/cnpg-cluster --values test-values.yaml
    ```

## Seed Postgres with sample data

1. Get the user's `tls.key`, `tls.crt`, and `ca.crt` from secrets

    ```bash
    kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.key"' |base64 -d > tls.key
    chmod 600 tls.key
    kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.crt"' |base64 -d > tls.crt
    chmod 600 tls.crt
    ```

2. Get the servers `ca.crt` from secrets

    ```bash
    kubectl get secrets cnpg-server-cert -o yaml |yq '.data."ca.crt"' |base64 -d > ca.crt
    chmod 600 ca.crt
    ```

3. Expose Postgres with a service:

  - Create a manifest for the service

    ```bash
    /bin/cat << EOF > service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: cnpg-service
      labels:
        cnpg.io/cluster: cnpg
    spec:
      type: NodePort
      ports:
      - port: 5432
        nodePort: 30000
        protocol: TCP
      selector:
        cnpg.io/cluster: cnpg
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
          host=$LOADBALANCER_IP
          port=30000 
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
            host=$LOADBALANCER_IP
            port=30000
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
 
 ## Configure scheduled backups of Minio to B2

 1. Create a secret containing your external S3 credentials

    - You will need to get these from your provider:
    
      ```bash
      export ACCESS_KEY_ID=$(echo -n "" | base64)
      
      export ACCESS_SECRET_KEY=$(echo -n "" |base64)
      ```
      
      ```bash
      /bin/cat << EOF > backblaze.yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: backblaze-credentials
      type: Opaque
      data:
        "ACCESS_KEY_ID": "$ACCESS_KEY_ID"
        "ACCESS_SECRET_KEY": "$ACCESS_SECRET_KEY"
      EOF

      kubectl apply -f backblaze.yaml
      ```

    - Create a second secret with different keys to support the K8up CLI if you plan to use it.

      ```bash
      /bin/cat << EOF > k8up.yaml
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
    cat << EOF > backup.yaml
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

## Restore Minio from B2 backups

1. Uninstall minio and postgres and delete your scheduled backup

   ```bash
   helm uninstall cnpg-cluster
   
   helm uninstall minio-<some number>
   
   kubectl delete -f backup.yaml 
   ```

2. Create a PVC to hold our restored data

  - Create a manifest for the PVC

    ```bash
    /bin/cat << EOF > pvc.yaml
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
      name: backup-restore
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          # Must be sufficient to hold your data
          storage: 5Gi
    EOF
    ```
  
  - Create the PVC

    ```bash
    kubectl apply -f pvc.yaml
    ```

3. Find your desired snapshot to restore

    ```bash
    restic snapshots
    repository bac0980d opened (version 2, compression level auto)
    ID        Time                 Host        Tags        Paths
    -----------------------------------------------------------------------------
    704f5d77  2023-11-12 10:51:14  default                 /data/minio-1699782386
    b17c7bb1  2023-11-12 10:52:12  default                 /data/minio-1699782386
    -----------------------------------------------------------------------------
    2 snapshots
    ```

4. Use the K8up CLI or a declarative setup to restore data to the PVC. 

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
      --snapshot b17c7bb1 \
      --claimName backup-restore \
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
          claimName: backup-restore
      podSecurityContext:
        runAsUser: 1000
      snapshot: b17c7bb1
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

## Restore CNPG from Minio Backups

1. Create a values file that targets your Minio instance for backups

   > Backups are disabled during the recovery process and will be re-enabled in the next step.

    ```bash
    /bin/cat << EOF > restore-values.yaml
    name: "cnpg"
    instances: 1
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
        username: "app"
    backup: []
    #   retentionPolicy: "30d"
    #   barmanObjectStore:
    #     destinationPath: "s3://backups"
    #     endpointURL: "http://85.10.207.26:32000"
    #     s3Credentials:
    #       accessKeyId:
    #         name: "minio-credentials"
    #         key: "ACCESS_KEY_ID"
    #       secretAccessKey:
    #         name: "minio-credentials"
    #         key: "ACCESS_SECRET_KEY"
    # scheduledBackup:
    #   name: cnpg-backup
    #   spec:
    #     schedule: "0 * * * * *"
    #     backupOwnerReference: self
    #     cluster:
    #       name: cnpg
    externalClusters:
      - name: cnpg
        barmanObjectStore:
          destinationPath: "s3://backups/"
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

## Major Version Upgrades


 
