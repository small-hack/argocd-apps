This is for when mas is ready for for production
```yaml
---
# webapp is deployed 2nd because we need secrets and persistent volumes up 1st
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: mas-postgres-app-set
  namespace: argocd
spec:
  goTemplate: true
  # generator allows us to source specific values from an external k8s secret
  generators:
    - plugin:
        configMapRef:
          name: secret-var-plugin-generator
        input:
          parameters:
            secret_vars:
              - matrix_s3_endpoint
              - matrix_postgres_backup_schedule
  template:
    metadata:
      name: mas-postgres-cluster
      namespace: matrix
      annotations:
        argocd.argoproj.io/sync-wave: "2"
    spec:
      project: matrix
      destination:
        server: "https://kubernetes.default.svc"
        namespace: matrix
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
        automated:
          prune: true
          selfHeal: true
      source:
        repoURL: https://small-hack.github.io/cloudnative-pg-cluster-chart
        chart: cnpg-cluster
        targetRevision: 0.4.0
        helm:
          releaseName: mas-postgres-cluster
          valuesObject:
            name: mas-postgres
            instances: 1

            bootstrap:
              initdb:
                database: mas
                owner: mas
                secret:
                  name: mas-pgsql-credentials

            backup:
              # barman is a utility for backing up postgres to s3
              barmanObjectStore:
                destinationPath: "s3://mas"
                endpointURL: "https://{{ .matrix_s3_endpoint }}"
                s3Credentials:
                  accessKeyId:
                    name: s3-postgres-credentials
                    key: "accessKeyId"
                  secretAccessKey:
                    name: s3-postgres-credentials
                    key: "secretAccessKey"
                wal:
                  maxParallel: 8
              retentionPolicy: "2d"

            certificates:
              server:
                enabled: true
                generate: true
              client:
                enabled: true
                generate: true
              user:
                enabled: true
                username:
                  - mas

            scheduledBackup:
              name: mas-pg-backup
              spec:
                schedule: '{{ .matrix_postgres_backup_schedule }}'
                backupOwnerReference: self
                cluster:
                  name: mas

            monitoring:
              enablePodMonitor: false

            postgresql:
              pg_hba:
                - host all all 0.0.0.0/0 md5
```
