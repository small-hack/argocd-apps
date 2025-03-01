# Elk Argo CD ApplicationSet

This is an Argo CD ApplicationSet to deploy [Elk](https://github.com/elk-zone/elk), a [GoToSocial](https://gotosocial.org/) and Mastodon web client using the [0hlov3/charts:elk-frontend](https://github.com/0hlov3/charts/tree/main/charts/elk-frontend) helm chart.

## Sync Waves

1. Elk helm chart

## Argo CD App

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: elk
spec:
  destination:
    namespace: elk
    server: 'https://kubernetes.default.svc'
  source:
    path: elk/
    repoURL: 'https://github.com/small-hack/argocd-apps.git'
    targetRevision: main
  sources: []
  project: elk
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=true
```
