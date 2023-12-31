Previously on trying to create an appset for cert manager 😅:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-issuers-app-set
  namespace: argocd
spec:
  goTemplate: true
  # generator allows us to source specific values from an external k8s secret
  generators:
    - plugin:
        configMapRef:
          name: secret-var-plugin-generator
        input:
          parameters:
            secret_vars: ["cert_manager_email"]
  template:
    metadata:
      name: cluster-issuers
      namespace: ingress
      annotations:
        argocd.argoproj.io/sync-wave: "2"
    spec:
      project: default
      source:
        repoURL: https://github.com/small-hack/argocd-apps.git
        path: ingress/cert-manager/cluster-issuers/
        helm:
          values: |
            email: {{ .cert_manager_email }}
      destination:
        server: "https://kubernetes.default.svc"
        namespace: ingress
      syncPolicy:
        syncOptions:
          - ApplyOutOfSyncOnly=true
        automated:
          prune: true
          selfHeal: true
```
