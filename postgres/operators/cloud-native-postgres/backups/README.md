# CNPG Operator Backup and Restore Procedure

## Set up a demo cluster

### Setup Kubernetes

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

### Setup Minio

1. install the MinIO client

    Docs: https://min.io/docs/minio/linux/reference/minio-mc.html

    ```bash
    mkdir -p $HOME/minio-binaries

    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O $HOME/minio-binaries/mc

    chmod +x $HOME/minio-binaries/mc

    export PATH=$PATH:$HOME/minio-binaries/
    ```


2. Download minio helm chart

    ```bash
    helm repo add minio https://charts.min.io/
    ```


3. Deploy Minio via Helm

    ```bash
    echo "Enter User Name : " && \
    read USERNAME && \
    echo "Enter User Password : " && \
    read PASSWORD && \
    helm install \
      --set resources.requests.memory=512Mi \
      --set replicas=1 \
      --set persistence.size=32Gi \
      --set mode=standalone \
      --set rootUser=$USERNAME,rootPassword=$PASSWORD \
      --set consoleService.type=LoadBalancer \
      --set consoleService.port=80 \
      --set service.type=NodePort \
      --generate-name minio/minio
    ```

4. Get the LoadBalancer's External-IP address

    ```console
    friend@vm0:~$ kubectl get svc
    NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)          AGE
    kubernetes                 ClusterIP      10.43.0.1       <none>           443/TCP          6h31m
    minio-1697277405           NodePort       10.43.124.40    <none>           9000:32000/TCP   6h31m
    minio-1697277405-console   LoadBalancer   10.43.116.107   192.168.50.160   80:31179/TCP     6h31m
    ```

5. Set an alias for your server:

    ```bash
    mc alias set myminio http://$LOADBALANCER_IP:32000 $USERNAME $PASSWORD
    ```

6. Test the connection:

    ```bash
    mc admin info myminio
    ```

7. Create a postgres user

    ```bash
    mc admin user add myminio postgres
    ```

    Enter a password when prompted:

    ```console
    Enter Secret Key:
    Added user `postgres` successfully.
    ```

8. Create an Access Key

    ```bash
    mc admin user svcacct add myminio postgres
    ```

9. Create the backups storage bucket

    ```bash
    mc mb myminio/backups --with-versioning
    ```

10. Grant postgres account access

    ```bash
    mc admin policy attach myminio readwrite --user postgres
    ```

### Setup CNPG + CertManager

1. Install CNPG Operator

    ```bash
    helm repo add cnpg https://cloudnative-pg.github.io/charts
    helm upgrade --install cnpg \
      --namespace cnpg-system \
      --create-namespace \
      cnpg/cloudnative-pg \
      --version 0.19.0
    ```

2. Install CertManager

    ```bash
    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

    helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.13.2
    ```

3. Create an example values.yaml for the postgres cluster

    ```bash
    cat << EOF > test-values.yaml
    name: "cnpg"
    instances: 1
    superuserSecret:
      name: null
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
          destinationPath: "backups"
          s3Credentials:
            accessKeyId:
              name: "aws-creds"
              key: "ACCESS_KEY_ID"
            secretAccessKey:
              name: "aws-creds"
              key: "ACCESS_SECRET_KEY"
      scheduledBackup:
        name: example-backup
        spec:
          schedule: "0 0 0 * * *"
          backupOwnerReference: self
          cluster:
            name: pg-backup
    monitoring:
      enablePodMonitor: false
    postgresql:
      pg_hba:
        - hostnossl all all 0.0.0.0/0 reject
        - hostssl all all 0.0.0.0/0 cert clientcert=verify-full
    storage:
      size: 1Gi
    testApp:
      enabled: true
    EOF          
    ```

4. Create the postgres cluster

    ```bash
    helm repo add cnpg-cluster https://small-hack.github.io/cloudnative-pg-tenant-chart
    helm repo update

    helm install cnpg-cluster cnpg-cluster/cnpg-cluster \
      --values test-values.yaml
    ```

## Add Demo Data to postgres

1. get the user's `tls.key`, `tls.crt`, and `ca.crt` from secrets

  ```bash
  kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.key"' |base64 -d > tls.key
  kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.crt"' |base64 -d > tls.crt
  ```

2. get the servers `ca.crt` from secrets

  ```bash
  kubectl get secrets cnpg-server-cert -o yaml |yq '.data."ca.crt"' |base64 -d > ca.crt
  ```

3. expose postgres with a service:

  ```bash
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
  ```

4. connect to postgres:

  ```bash
   psql 'sslkey=./tls.key sslcert=./tls.crt sslrootcert=./ca.crt host=<HostIP> port=30000 dbname=app user=app'
  ```

5. create a table for the demo data:

  ```bash
  psql 'sslkey=./tls.key 
        sslcert=./tls.crt 
        sslrootcert=./ca.crt 
        host=192.168.50.161 
        port=30000 
        dbname=app 
        user=app' -c 'CREATE TABLE processors (data JSONB);'
  ```

6. use script populate the table

  ```bash
  #!/bin/bash
  COUNT=$(jq length demo-data.json)
  for (( i=0; i<$COUNT; i++ ))
  do
      JSON=$(jq ".[$i]" demo-data.json)
      psql 'sslkey=./tls.key
        sslcert=./tls.crt
        sslrootcert=./ca.crt
        host=192.168.50.161
        port=30000
        dbname=app
        user=app' -c "INSERT INTO processors VALUES ('$JSON');"
  done
  ```

7. make a test query

  ```bash
  psql 'sslkey=./tls.key 
       sslcert=./tls.crt 
       sslrootcert=./ca.crt 
       host=192.168.50.161 
       port=30000 
       dbname=app 
       user=app' -c "SELECT data -> 'cpu_name' AS cpu,
                            data -> 'cpu_cores' AS cores,
                            data -> 'cpu_threads' AS threads,
                            data -> 'release_date' AS releaseDate 
                            FROM processors
                            ORDER BY releaseDate DESC;"
  ```

- Expected Output:
  ```console
              cpu           | cores | threads | releasedate
  ------------------------+-------+---------+-------------
                          |       |         |
   "EPYC 7763v"           | 64    | 128     | 2021
   "Xeon Platinum 8375C"  | 32    | 64      | 2021
   "Xeon Gold 6338"       | 32    | 64      | 2021
   "EPYC 7713"            | 64    | 128     | 2021
   "Xeon E-2378G"         | 8     | 16      | 2021
   "Xeon Platinum 8370C"  | 32    | 64      | 2021
   "Xeon Platinum 8259CL" | 24    | 48      | 2020
   "Xeon E-2288G"         | 8     | 16      | 2019
   "EPYC 7402P"           | 24    | 48      | 2019
   "Xeon Platinum 8175M"  | 24    | 48      | 2018
   "Xeon Platinum 8173M"  | 28    | 56      | 2017
   "Xeon E5-2690V4"       | 14    | 28      | 2016
   "Xeon 2696v4"          | 22    | 44      | 2016
   "Xeon 2696v3"          | 18    | 36      | 2014
   "Xeon 2696v3"          | 12    | 24      | 2013
  ```
