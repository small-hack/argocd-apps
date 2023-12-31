```yaml
---
# webapp is deployed 2nd because we need secrets and persistent volumes up 1st
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: minio-pod-certs-app-set
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
              - minio_tenant_name
              - minio_api_hostname
              - minio_user_console_hostname
              
  template:
    metadata:
      name: minio-pod-certs
    spec:
      project: minio
      destination:
        server: https://kubernetes.default.svc
        namespace: minio
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
        automated:
          prune: true
      source:
        repoURL: 'https://github.com/small-hack/argocd-apps.git'
        path: minio/certs-helm-chart/
        targetRevision: main
        helm:
          releaseName: minio-pod-certs
          values: |
            tenant_name: {{ .minio_tenant_name }}
            hostname: {{ .minio_user_console_hostname }}
```
