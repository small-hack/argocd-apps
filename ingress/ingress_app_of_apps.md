# Ingress Argo CD App of Apps

To apply this, select "Create New App" in your Argo CD interface and select "Edit as YAML", then paste the following in:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ingress-apps
  namespace: argocd
spec:
  project: ingress
  source:
    repoURL: 'https://github.com/small-hack/argocd-apps'
    targetRevision: main
    path: ingress/
  destination:
    server: "https://kubernetes.default.svc"
    namespace: ingress
  syncPolicy:
    syncOptions:
      - Replace=true
    automated:
      prune: true
      selfHeal: true
```

## Sync Waves
1. install ingress-nginx and cert-manager
2. install vouch (depends on ingress and certs)
