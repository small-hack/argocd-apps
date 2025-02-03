# notes on environment promotion

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: example-app-set
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "4"
spec:
  # enable go templating
  goTemplate: true

  # this generator allows us to values from an external k8s secret
  generators:

    # dev environment
    - clusters:
        selector:
          matchLabels:
            environment: "dev"
        # values to be templated into the Argo CD application
        values:
          # gets updated on push to main
          version: 0.2.0

    # prod environment
    - clusters:
        selector:
          matchLabels:
            environment: "prod"
        # values to be templated into the Argo CD application
        values:
          # gets updated after user clicks approve button after main is successfully rolled out
          version: 0.1.0

  template:
    metadata:
      name: example-web-app
      annotations:
        argocd.argoproj.io/sync-wave: "4"
        argocd.argoproj.io/sync-options: ApplyOnly=true
    spec:
      project: example
      # where the app is going
      destination:
        server: https://kubernetes.default.svc
        namespace: example
      # reconciliation policy
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
        automated:
          prune: true
          selfHeal: true
      # where the is coming from
      source:
        repoURL: https://small-hack.github.io/example-chart
        targetRevision: "{{ .values.version }}"
        chart: example
        helm:
          releaseName: "my-app-{{ .metadata.labels.environment }}"
```
