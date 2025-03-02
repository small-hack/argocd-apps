# Elk Argo CD ApplicationSet

This is an Argo CD ApplicationSet to deploy [Elk](https://github.com/elk-zone/elk), a [GoToSocial](https://gotosocial.org/) and Mastodon web client using the [0hlov3/charts:elk-frontend](https://github.com/0hlov3/charts/tree/main/charts/elk-frontend) helm chart.

<img width="1238" alt="Screenshot of all deployed Elk resources in the Argo CD web interface using tree mode. It features the main app, elk-frontend, which branches into a pvc, elk-frontend-data, a secret elk-env, a service elk-frontend, a service account, elk-frontend, a deployment, elk-frontend, and an ingress, elk-frontend. The service branches into an endpoint, elk-frontend, and an endpoint slice, elk-frontend-randomcharacters. The deployment branches into 3 replica history versions with one of them branching into an elk-frontend pod. The ingress branches into a certificate, elk-tls, which branches into a certificate request, elk-tls-1, which branches into an order, elk-tls-randomcharacters" src="https://github.com/user-attachments/assets/a8fc8ed8-38eb-45b1-bff9-026b0df38c40" />

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
