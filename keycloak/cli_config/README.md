# Docs on running Keycloak init scripts via helm


## Kustomize for configuring Keycloak

This kustomize directly uses the `config.json` in this directory to generate a Kubernetes `ConfigMap` to be passed into a [keycloak-config-cli](https://github.com/adorsys/keycloak-config-cli/) Kubernetes job to create our Keycloak configuration (realms, clients, users, groups, and scopes). The json schema for `config.json` is taken from the example config, [moped.json](https://github.com/adorsys/keycloak-config-cli/blob/main/contrib/example-config/moped.json), provided by keycloak-config-cli. You can also checkout their features [doc](https://github.com/adorsys/keycloak-config-cli/blob/main/docs/FEATURES.md) for more info.


### To test applying this kustomize

```bash
kustomize build | kubectl apply -f -
```

If you're already running Keycloack, you'll need to delete the keycloak pod after applying the ConfigMap.

### Passing this config into the (Bitnami) Keycloak helm chart
You can apply this kustomize beofore the helm chart by using appending `--set keycloakConfigCli.existingConfigmap=keycloak-config-cli` to your existing `helm install/upgrade` command, or like this in your `values.yaml`:

```yaml
keycloakConfigCli:
  existingConfigmap: keycloak-config-cli
```

Read more about the Bitnami helm chart's `keycloak-config-cli` params at [bitnami/keycloak/#keycloak-config-cli](https://github.com/bitnami/charts/tree/main/bitnami/keycloak/#keycloak-config-cli-parameters).

Should we not be able to use the config.json with the keycloak-config-cli we can consider using the official Keycloak Admin CLI as documented here:
https://www.keycloak.org/docs/latest/server_admin/index.html#client-operations

good luck.

## Default Realm Name

- https://github.com/keycloak/keycloak/discussions/12594

TLDR: you can pass an env-var to the keycloak container:

```yaml
...
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak
        args: ["start-dev"]
        env:
        ...
        - name: KC_SPI_ADMIN_REALM
          value: "default-realm-name"
```

## CLI Usage

```bash
cd /opt/bitnami/keycloak

export SERVER="http://localhost:8080/"
export ADMIN_REALM="default-realm-name"
export ADMIN_USER="test"
export ADMIN_PASSWORD="YOUR-PASSWORD-HERE"
export NEW_REALM="example-realm"
export NEW_CLIENT="example-client"
export NEW_USER="user"
export NEW_USER_PASSWORD="YOUR-PASSWORD-HERE"

# Creae a new realm
./bin/kcadm.sh create realms -s \
  realm=$NEW_REALM \
  -s enabled=true \
  -o \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create a new client
kcadm.sh create clients -r $NEW_REALM \
  -s clientId=$NEW_CLIENT \
  -s enabled=true \
  -o \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create a new user
kcadm.sh create users -r $NEW_REALM \
  -s username=$NEW_USER \
  -s enabled=true \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# set the user's password
kcadm.sh set-password -r $NEW_REALM \
  --username $NEW_USER \
  --new-password $NEW_USER_PASSWORD \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

```
