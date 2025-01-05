# Peertube Argo CD App of Apps

This directory contains the resources to deploy [Peertube](https://joinpeertube.org/en_US), a tool for sharing online videos developed by the french non-profit Framasoft.
We deploy it using our standard Cloud-Native Postgres, Valkey, and SeaweedFS appsets.

<img width="1141" alt="A Screenshot of this Peertube Argo CD App of Apps in the web interface using tree mode. You can see the main peertube appset, the postgresql app set, the s3 provider appset, the s3 pvc appset, and the valkey appset." src="https://github.com/user-attachments/assets/2c501b40-08b6-4267-9c20-c4f09909da90" />

## Sync Waves

1. External Secrets and PVCs
2. S3 and Valkey
3. PostgreSQL
4. Peertube helm chart

## ToDo

- Find and add monitoring resources like dashboards for grafana

## Example of deploying this app

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: peertube-app-of-apps
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: default
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
    automated:
      selfHeal: true
  # where to deploy this to
  destination:
    server: "https://kubernetes.default.svc"
    namespace: peertube
  # where to deploy this from
  source:
    repoURL: https://github.com/small-hack/argocd-apps.git
    path: peertube/app_of_apps/
```
