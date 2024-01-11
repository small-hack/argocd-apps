# Rancher

Rancher is a complete software stack for teams adopting containers. It addresses the operational and security challenges of managing multiple Kubernetes clusters, while providing DevOps teams with integrated tools for running containerized workloads.

## Manually Deploy to Argocd

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rancher-argo-app
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: rancher
  destination:
    server: "https://kubernetes.default.svc"
    namespace: cattle-system
  source:
    repoURL: https://github.com/small-hack/argocd-apps.git
    path: demo/rancher/
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
    automated:
      selfHeal: true
```
