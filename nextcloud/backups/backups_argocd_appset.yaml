---
# webapp is deployed 2nd because we need secrets and persistent volumes up 1st
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: scheduled-backups-app-set
  namespace: argocd
spec:
  syncPolicy:
    preserveResourcesOnDeletion: false
  goTemplate: true
  # generator allows us to source specific values from an external k8s secret
  generators:
    - plugin:
        configMapRef:
          name: secret-var-plugin-generator
        input:
          parameters:
            secret_vars:
              - nextcloud_hostname
              - nextcloud_backup_method
              - nextcloud_backup_mount_path
              - nextcloud_backup_s3_bucket
              - nextcloud_backup_s3_endpoint
  template:
    metadata:
      name: nextcloud-scheduled-backups
    spec:
      project: nextcloud
      destination:
        server: https://kubernetes.default.svc
        namespace: nextcloud
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
        automated:
          prune: true
      source:
        repoURL: 'https://github.com/small-hack/argocd-apps.git'
        path: nextcloud/backups/helm/
        targetRevision: main
        helm:
          values: |
            backup_name: "nightly-backup"

            backup_type: {{ .nextcloud_backup_method }}

            s3:
              bucket: {{ .nextcloud_backup_s3_bucket }}
              endpoint: {{ .nextcloud_backup_s3_endpoint }}
              accessKeyIDSecretRef:
                name: nextcloud-backups-credentials
                key: applicationKeyId
              secretAccessKeySecretRef:
                name: nextcloud-backups-credentials
                key: applicationKey

            local:
              mountPath: {{ .nextcloud_backup_mount_path }}

            # -- secret for your restic repo
            repoPasswordSecretRef:
              name: 'nextcloud-backups-credentials'
              key: resticRepoPassword

            # -- url to push to for prometheus gateway
            prometheus_url: http://push-gateway.prometheus:9091/

            # -- user to run the backups as
            podSecurityContext:
              runAsUser: 0

            # -- schedules for backups, checks, and prunes
            schedules:
              backup: '10 2 * * *'
              check: '30 2 * * *'
              prune: '35 2 * * *'
