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

>[!warning]
> Keycloak cant update the default scopes of a client after it has been created, they apparantly just forgot to code that function https://github.com/keycloak/keycloak/issues/16952 - and also then never fixed it for years. Ticket is still open.

```bash
cd /opt/bitnami/keycloak

export SERVER="http://localhost:8080/"
export ADMIN_REALM="master"
export ADMIN_USER="example"
export ADMIN_PASSWORD="Unspoiled2-Wow-Hydration-Economy"
export NEW_REALM="example-realm"
export NEW_CLIENT="example-client"
export NEW_SCOPE="example-scope"
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

# Create a client Scope
./bin/kcadm.sh create -x "client-scopes" -r $NEW_REALM \
  -s name=$NEW_SCOPE \
  -s protocol=openid-connect \
  -o \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create a new client
./bin/kcadm.sh create clients -r $NEW_REALM \
  -s clientId=$NEW_CLIENT \
  -s "defaultClientScopes=[ \"web-origins\", \"acr\", \"profile\", \"roles\", \"email\", \"$NEW_SCOPE\" ]" \
  -s 'optionalClientScopes=[ "address", "phone", "offline_access", "microprofile-jwt" ]' \
  -s enabled=true \
  -o \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# Get the clientId
CLIENT_ID=$(./bin/kcadm.sh get clients -r $NEW_REALM \
-q clientId=$NEW_CLIENT  \
-F id \
--format csv \
--noquotes \
--no-config \
--server $SERVER \
--realm $ADMIN_REALM \
--user $ADMIN_USER \
--password $ADMIN_PASSWORD)

# Create mapper
./bin/kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r $NEW_REALM \
	-s name=$NEW_SCOPE -s protocol=openid-connect \
	-s protocolMapper=oidc-hardcoded-claim-mapper \
	-s config="{\"claim.value\" : \"$NEW_REALM\",\"claim.name\" : \"$NEW_SCOPE\",\"jsonType.label\" : \"String\",\"access.token.claim\" : \"true\"}" \
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
