# Longhorn

Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. Longhorn is free, open source software. Originally developed by Rancher Labs, it is now being developed as a incubating project of the Cloud Native Computing Foundation.

## Prereqs

- Check host system for required pacakages
  ```bash
  curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.5.0/scripts/environment_check.sh | bash
  ```

## Deploy

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn-app
spec:
  destination:
    name: ''
    namespace: longhorn
    server: 'https://kubernetes.default.svc'
  source:
    path: longhorn/
    repoURL: 'https://github.com/small-hack/argocd.git'
    targetRevision: HEAD
  sources: []
  project: default
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: false
      selfHeal: true
```
