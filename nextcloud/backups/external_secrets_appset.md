---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: nextcloud-backups-external-secrets-app-set
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
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
              - nextcloud_backups_credentials_bitwarden_id
              - global_external_secrets
  template:
    metadata:
      name: nextcloud-backups-external-secrets
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
          selfHeal: true
      source:
        repoURL: 'https://github.com/small-hack/argocd-apps.git'
        path: nextcloud/backups/bitwarden_external_secrets/
        targetRevision: eso-helm-chart-test
        helm:
          values: |
            useExternalSecrets: {{ .Values.global_external_secrets }}
            backupS3CredentialsBitwardenID: {{ .Values.nextcloud_backups_credentials_bitwarden_id }}
