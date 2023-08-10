# Kustomize for configuring Keycloak

This kustomize directly uses the `config.json` in this directory to generate a Kubernetes `ConfigMap` to be passed into a [keycloak-config-cli](https://github.com/adorsys/keycloak-config-cli/) Kubernetes job to create our Keycloak configuration (realms, clients, users, groups, and scopes). The json schema for `config.json` is taken from the example config, [moped.json](https://github.com/adorsys/keycloak-config-cli/blob/main/contrib/example-config/moped.json), provided by keycloak-config-cli. You can also checkout their features [doc](https://github.com/adorsys/keycloak-config-cli/blob/main/docs/FEATURES.md) for more info.


## To test applying this kustomize

```bash
kustomize build | kubectl apply -f -
```

If you're already running Keycloack, you'll need to delete the keycloak pod after applying the ConfigMap.

## Passing this config into the (Bitnami) Keycloak helm chart
You can apply this kustomize beofore the helm chart by using appending `--set keycloakConfigCli.existingConfigmap=keycloak-config-cli` to your existing `helm install/upgrade` command, or like this in your `values.yaml`:

```yaml
keycloakConfigCli:
  existingConfigmap: keycloak-config-cli
```

Read more about the Bitnami helm chart's `keycloak-config-cli` params at [bitnami/keycloak/#keycloak-config-cli](https://github.com/bitnami/charts/tree/main/bitnami/keycloak/#keycloak-config-cli-parameters).
