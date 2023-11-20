# SeaweedFS Backups and Recovery with k8up

This guide will walk you through the creation, backup, and recovery processes for a local [SeaweedFS](https://github.com/seaweedfs/seaweedfs) deployment and [CloudNative Postgres](https://cloudnative-pg.io/documentation/current/) cluster using [K8up](https://k8up.io/) and [Backblaze B2](https://www.backblaze.com/docs/cloud-storage). 

Recommended reading: [S3 as the universal infrastructure backend](https://medium.com/innovationendeavors/s3-as-the-universal-infrastructure-backend-a104a8cc6991) - Davis Treybig

> For the purposes of this demo, backups are set to run every minute. Plain-text passwords are also used for convenience - do NOT do that in production.
> 
## Outline

1. [K3s Cluster creation](#k3s-cluster-creation)
2. [SeaweedFS instance setup](#seaweedfs-instance-and-user-setup)
3. [Configure scheduled backups of SeaweedFS to B2](#configure-scheduled-backups-of-seaweedfs-to-b2)
4. [Restore SeaweedFS from B2 backups](#restore-seaweedfs-from-b2-backups)


## Requirements

- K8up CLI
- Kubectl
- Helm
- Restic
- S3 CLI tool of your choice, I'll be using awscli in this guide.

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

4. Expose the S3 endpoint

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

5. Configure the AWS CLI
   
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

 <h2 id="configure-scheduled-backups-of-seaweedf3-to-b2">Configure scheduled backups of SeaweedFS to B2</h2>

 1. Create a secret containing your external S3 credentials

    - You will need to get these from your provider (Backblaze, Wasabi etc..):
    
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
          endpoint: "<your-s3-url>"
          bucket: "<your-s3-backup-bucket>"
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

<h2 id="restore-seaweedfs-from-b2-backups">Restore SeaweedFS from B2 backups</h2>

1. Uninstall SeaweedFS and Postgres and delete your scheduled backup

   ```bash
   helm uninstall cnpg-cluster
   
   k delete -f manifests.yaml
   
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
      annotations:
        "k8up.io/backup": "true"
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
      annotations:
        "k8up.io/backup": "true"
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
      annotations:
        "k8up.io/backup": "true"
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
    EOF
    ```
  
  - Create the PVCs

    ```bash
    kubectl apply -f pvc.yaml
    ```

3. Setup your restic credentials

    ```bash
    # the password used in your restic-repo secret
    export RESTIC_PASSWORD=""
    
    # Your S3 credentials
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""
    RESTIC_REPOSITORY="s3://<backblaze bucket url>/<backups bucket>
    ```

4. Find your desired snapshot to restore

    ```bash
    restic snapshots
    repository fffd1d0e opened (version 2, compression level auto)
    created new cache in /home/friend/.cache/restic
    ID        Time                 Host        Tags        Paths
    --------------------------------------------------------------------------------------------
    656b5abe  2023-11-20 10:57:11  default                 /data/cnpg15-1
    98718e38  2023-11-20 10:57:16  default                 /data/data-default-seaweedfs-master-0
    8c2f8d99  2023-11-20 10:57:20  default                 /data/data-filer-seaweedfs-filer-0
    be86c2e5  2023-11-20 10:57:26  default                 /data/data-seaweedfs-volume-0
    --------------------------------------------------------------------------------------------
    4 snapshots
    ```

4. Use the K8up CLI or a declarative setup to restore data to the PVC. You will need to do this for each PVC that needs to be restored 
    
  - Example manifest for a S3-to-PVC restore job which uses the restic snapshots shown above. 

    ```bash
    /bin/cat << EOF > s3-to-pvc.yaml
    ---
    apiVersion: k8up.io/v1
    kind: Restore
    metadata:
      name: restore-volume-data
    spec:
      restoreMethod:
        folder:
          claimName: swfs-volume-data
      snapshot: "be86c2e5"
      backend:
        repoPasswordSecretRef:
          name: restic-repo
          key: password
        s3:
          endpoint: "<your-s3-url>"
          bucket: "<your-s3-bucket>"
          accessKeyIDSecretRef:
            name: backblaze-credentials
            key: ACCESS_KEY_ID
          secretAccessKeySecretRef:
            name: backblaze-credentials
            key: ACCESS_SECRET_KEY
    ---
    apiVersion: k8up.io/v1
    kind: Restore
    metadata:
      name: restore-master-data
    spec:
      restoreMethod:
        folder:
          claimName: swfs-master-data
      snapshot: "98718e38"
      backend:
        repoPasswordSecretRef:
          name: restic-repo
          key: password
        s3:
          endpoint: "<your-s3-url>"
          bucket: "<your-s3-bucket>"
          accessKeyIDSecretRef:
            name: backblaze-credentials
            key: ACCESS_KEY_ID
          secretAccessKeySecretRef:
            name: backblaze-credentials
            key: ACCESS_SECRET_KEY
    ---
    apiVersion: k8up.io/v1
    kind: Restore
    metadata:
      name: restore-filer-data
    spec:
      restoreMethod:
        folder:
          claimName: swfs-filer-data
      snapshot: "8c2f8d99"
      backend:
        repoPasswordSecretRef:
          name: restic-repo
          key: password
        s3:
          endpoint: "<your-s3-url>"
          bucket: "<your-s3-bucket>"
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
      enablePVC: true
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

