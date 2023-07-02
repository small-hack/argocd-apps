# Mastodon ArgoCD Template
Social networking that's not for sale:
https://joinmastodon.org/


# Deploy postgres DB

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keycloak-postgres
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: '2'
spec:
  destination:
    namespace: mastodon
    server: 'https://kubernetes.default.svc'
  source:
    path: mastodon/postgres/
    repoURL: 'https://github.com/small-hack/argocd.git'
  project: default
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
```
