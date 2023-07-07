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
        oidc.keycloak.clientID: |-
          {{ .username }}
        oidc.keycloak.clientSecret: |-
          {{ .password }}
...
```

ref: https://github.com/external-secrets/external-secrets/issues/2041


# setting up keycloak
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#example_1
