# Prometheus Push Gateway

Push metrics instead of scraping them
It should be used only for process that run infrequently or too quickly to be scraped properly.

## Resources:

Helm Chart Source:
- https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway

When to use the Push Gateway: 
- https://prometheus.io/docs/practices/pushing/

Pushing Metrics:
- https://prometheus.io/docs/instrumenting/pushing/

Push metrics from a unix shell:
- https://github.com/prometheus/pushgateway/blob/master/README.md

Use the push gateway with the kube-prometheus-stack: 
- https://github.com/prometheus-community/helm-charts/issues/2030#issuecomment-1585471558

## Copy/Patse deployment for Argo UI

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prometheus-push-gateway
spec:
  destination:
    name: ''
    namespace: monitoring
    server: 'https://kubernetes.default.svc'
  source:
    path: prometheus-push-gateway
    repoURL: 'https://github.com/small-hack/argocd-apps.git'
    targetRevision: HEAD
  sources: []
  project: prometheus
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```
