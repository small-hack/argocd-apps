# metallb manifests
Installs [metallb](https://github.com/metallb/metallb/) and configures your ip pool and l2 advertisement.

## Sync Waves
1. metallb controller and custom resource definitions

## To Deploy
you can paste this in the "Edit as YAML" section when creating a new Argo CD app:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: metallb
  namespace: argocd
spec:
  project: metallb
  source:
    repoURL: 'https://github.com/small-hack/argocd-apps'
    targetRevision: main
    path: metallb/
  destination:
    server: "https://kubernetes.default.svc"
    namespace: metallb-system
  syncPolicy:
    syncOptions:
      - Replace=true
    automated:
      prune: true
      selfHeal: true
```
