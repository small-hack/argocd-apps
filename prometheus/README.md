# Monitoring Stack App of Apps
Everything you need for a fully functioning monitoring stack managed by renovatebot and Argo CD. This doesn't seem like a big deal, but trust me, it is very much a pain to do otherwise.

## Sync Waves
1. Full Kube Prometheus Stack - Prometheus, Grafana, and Alert Manager
2. Loki stack, including promtail, and the prometheus push gateway

## To deploy this app of Apps
Either create this file, and do a `kubectl apply -f` or through the GUI, select "ceate new app" and then "edit as YAML" and paste this in:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring-app-of-apps
  namespace: argocd
spec:
  project: prometheus
  source:
    repoURL: 'https://github.com/small-hack/argocd-apps'
    targetRevision: main
    path: prometheus/
  destination:
    server: "https://kubernetes.default.svc"
    namespace: monitoring
  syncPolicy:
    syncOptions:
      - Replace=true
    automated:
      prune: true
      selfHeal: true
```
