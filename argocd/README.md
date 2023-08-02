# ArgoCD ArgoCD app
ArgoCD app for ArgoCD so that ArgoCD can manage itself, ArgoCD.

🧡

## external secrets
When creating external secrets for argocd, don't forget to set `spec.target.template.metadata.labels` like:

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: argocd-keycloak
spec:
  target:
    # Name for the secret to be created on the cluster
    name: argocd-keycloak
    deletionPolicy: Delete
    template:
      type: Opaque
      metadata:
        labels:
          app.kubernetes.io/part-of: "argocd"
      data:
        oidc.keycloak.clientSecret: |-
          {{ .password }}
...
```

ref on extenral secrets labels: https://github.com/external-secrets/external-secrets/issues/2041

## Argo CD Vault Plugin
We're currently demoing the [Argo CD Vault plugin](https://argocd-vault-plugin.readthedocs.io) with the [Kubernetes Secret backend](https://argocd-vault-plugin.readthedocs.io/en/stable/backends/#kubernetes-secret). We're using the suggested manifests [here](https://github.com/argoproj-labs/argocd-vault-plugin/tree/main/manifests/cmp-sidecar) to deploy the plugin as a side car.

To get started with this, before deploying this directory, you'll need the [example](./example/hostname_secret.yaml) set your hostname and applied before you start using Argo CD:

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: hostname-replacer-secret
type: Opaque
data:
  # NOTE: this hostname key is base64 encoded
  hostname: dmxlZXJtdWlzLnRlY2g=
```


# Creating the Argo CD app
To deploy this, create a new Argo CD app, and select "Edit as YAML". Copy and paste this into the input field:
```yaml
project: default
source:
  repoURL: 'https://github.com/small-hack/argocd.git'
  path: argocd/
  targetRevision: main
destination:
  server: 'https://kubernetes.default.svc'
  namespace: argocd
syncPolicy:
  syncOptions:
    - ApplyOutOfSyncOnly=true
```

# setting up keycloak
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#example_1
