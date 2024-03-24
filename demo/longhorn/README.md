# Longhorn

Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. Longhorn is free, open source software. Originally developed by Rancher Labs, it is now being developed as a incubating project of the Cloud Native Computing Foundation.

## Prereqs

- Check host system for required pacakages
  ```bash
  curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/scripts/environment_check.sh | bash
  ```

## Deploy
Make sure you create a longhorn project in Argo CD first, and then you can paste in this when you create a new app in Argo CD and select the "Edit as YAML" button:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: longhorn
spec:
  destination:
    namespace: longhorn-system
    server: 'https://kubernetes.default.svc'
  source:
    path: demo/longhorn/helm/
    repoURL: 'https://github.com/small-hack/argocd-apps.git'
    targetRevision: HEAD
  project: longhorn
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
    syncOptions:
      - CreateNamespace=true
```

note: we're still testing both the helm files and direct manifests. YMMV.
