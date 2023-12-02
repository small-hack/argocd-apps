# Argo CD app
ArgoCD app for ArgoCD so that ArgoCD can manage itself, ArgoCD 🧡

<img alt="argocd app of apps" src="./docs/screenshots/argocd_app.png">

<details>
  <summary>Example screenshot of Argo CD ingress</summary>

<img alt="argocd helm chart ingress" src="./docs/screenshots/argo_ingress.png">

</details>

<details>
  <summary>Example screenshot of Argo CD AppSet secret-plugin</summary>

<img width="1284" alt="argocd app for argocd-appset-secret-plugin" src="https://github.com/small-hack/argocd-apps/assets/2389292/1213310e-a1df-4346-a202-078b2d40ebbf">

</details>

## Sync Waves

For the Argo CD App of Apps in [./app_of_apps](./app_of_apps):

1. External Secret and [Argo CD appset secret plugin](https://jessebot.github.io/argocd-appset-secret-plugin)
2. Argo CD


## External secrets

We use an external secret for the OIDC credentials.

<img width="949" alt="argocd app for external secrets" src="https://github.com/small-hack/argocd-apps/assets/2389292/f750a2fb-8aff-42ef-bac6-7f815c22eb75">

When creating external secrets for argocd, don't forget to set `spec.target.template.metadata.labels` like:

```yaml
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: argocd-oidc
spec:
  target:
    # Name for the secret to be created on the cluster
    name: argocd-oidc
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

Reference on external secrets labels: https://github.com/external-secrets/external-secrets/issues/2041


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

# Setting up OIDC

## Keycloak
Checkout out the [README](./keycloak) in the keycloak directory relative this this one for more info on how to setup an ArgoCD client for Keycloak.

This was put together from these older docs:
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#example_1

## Zitadel
These were really helpful guides on configuring a zitadel argocd app:
- https://github.com/argoproj/argo-cd/discussions/11855
- https://github.com/argoproj/argo-cd/pull/15029
