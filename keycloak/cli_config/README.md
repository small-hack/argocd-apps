# Kustomize for configuring Keycloak
This should generate a `ConfigMap` for configuring Keycloak for use in the keycloak helm chart under the helm chart key:
`keycloakConfigCli.existingConfigmap`

Read more about the bitnami helm chart keycloak-config-cli params here:
https://github.com/bitnami/charts/tree/main/bitnami/keycloak/#keycloak-config-cli-parameters

Read more about configuring the keycloak-config-cli itself here:
https://github.com/adorsys/keycloak-config-cli/blob/main/docs/FEATURES.md


## To test this kustomize

```bash
kustomize build | kubectl apply -f -
```
