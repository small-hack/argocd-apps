This doesn't work yet, because the address_pool can still be a list and argocd go templates can't accept objects yet, only strings.
```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: metallb-appset
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  # this lets you use go templates like with helm templates
  goTemplate: true
  # not sure what this does
  goTemplateOptions: ["missingkey=error"]
  # generator allows us to source specific values from an external k8s secret
  generators:
    - plugin:
        configMapRef:
          name: secret-var-plugin-generator
        input:
          parameters:
            secret_vars: ["address_pool"]
  template:
    metadata:
      name: metallb-custom-crds
    spec:
      project: metallb
      destination:
        server: "{{.clusterName}}"
        namespace: metallb-system
      source:
        repoURL: 'https://github.com/small-hack/argocd-apps'
        targetRevision: main
        path: metallb/crds/
```
