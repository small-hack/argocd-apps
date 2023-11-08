# CNPG Operator Backup and Restore Procedure

- Download the k3s installer

  ```bash
  curl -sfL https://get.k3s.io > k3s-install.sh
  ```

- install k3s

  ```bash
  bash k3s-install.sh --disable=traefik
  ```

- Wait for node to be ready

  ```bash
  sudo k3s kubectl get node
  NAME   STATUS   ROLES                  AGE   VERSION
  vm0    Ready    control-plane,master   1m   v1.27.4+k3s1
  ```

- Make an accessible version of the kubeconfig

  ```bash
  mkdir -p ~/.config/kube

  sudo cp /etc/rancher/k3s/k3s.yaml ~/.config/kube/config

  sudo chown $USER:$USER ~/.config/kube/config

  export KUBECONFIG=~/.config/kube/config

  ```

- Install CNPG Operator

  ```bash
  helm repo add cnpg https://cloudnative-pg.github.io/charts
  helm upgrade --install cnpg \
    --namespace cnpg-system \
    --create-namespace \
    cnpg/cloudnative-pg \
    --version 0.19.0
  ```


- install CertManager

  ```bash
  helm repo add jetstack https://charts.jetstack.io
  helm repo update

  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml

  helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.2
  ```

- create an example values.yaml for the postgres cluster

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

- create the postgres cluster

  ```bash
  helm repo add cnpg-cluster https://small-hack.github.io/cloudnative-pg-tenant-chart
  helm repo update

  helm install cnpg-cluster cnpg-cluster/cnpg-cluster \
    --values test-values.yaml
  ```

- get the user's `tls.key`, `tls.crt`, and `ca.crt` from secrets

  ```bash
  kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.key"' |base64 -d > tls.key
  kubectl get secrets cnpg-app-cert -o yaml |yq '.data."tls.crt"' |base64 -d > tls.crt
  ```

- get the servers `ca.crt` from secrets

  ```bash
  kubectl get secrets cnpg-server-cert -o yaml |yq '.data."ca.crt"' |base64 -d > ca.crt
  ```

- expose postgres with a service:

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

- connect to postgres:

  ```bash
   psql 'sslkey=./tls.key sslcert=./tls.crt sslrootcert=./ca.crt host=<HostIP> port=30000 dbname=app user=app'
  ```

- create a table for the demo data:

  ```bash
  psql 'sslkey=./tls.key 
        sslcert=./tls.crt 
        sslrootcert=./ca.crt 
        host=192.168.50.161 
        port=30000 
        dbname=app 
        user=app' -c 'CREATE TABLE processors (data JSONB);'
  ```

- use script populate the table

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

- make a test query

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
