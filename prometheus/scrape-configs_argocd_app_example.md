```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scrape-configs
  namespace: argocd
spec:
  project: prometheus
  source:
    repoURL: 'https://github.com/small-hack/argocd-apps'
    targetRevision: main
    path: prometheus/scrape-configs/
  destination:
    server: "https://kubernetes.default.svc"
    namespace: prometheus
  syncPolicy:
    syncOptions:
      - Replace=true
      - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
```
