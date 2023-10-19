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
export ADMIN_PASSWORD=""
export NEW_REALM="default"
export NEW_CLIENT="argocd"
export NEW_SCOPE="groups"
export NEW_USER="argocd"
export NEW_USER_PASSWORD="ChangeMe!"
export NEW_GROUP="argocd-admins"

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
  -s description="example scope" \
  -s protocol=openid-connect \
  -s attributes='{ "include.in.token.scope" : "true", "display.on.consent.screen" : "true", "consent.screen.text" : "${emailScopeConsentText}" }' \
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

# Get Scope ID
SCOPE_ID=$(./bin/kcadm.sh get "client-scopes" -r $NEW_REALM \
-F id,name \
--format csv \
--noquotes \
--no-config \
--server $SERVER   \
--realm $ADMIN_REALM   \
--user $ADMIN_USER   \
--password $ADMIN_PASSWORD |\
grep $NEW_SCOPE |\
awk -F',' '{print $1}')

# Create mapper
./bin/kcadm.sh create clients/$CLIENT_ID/protocol-mappers/models -r $NEW_REALM \
-s name=$NEW_SCOPE \
-s protocol=openid-connect \
-s protocolMapper=oidc-group-membership-mapper \
-s consentRequired=false \
-s config='{ "full.path" : "true", "id.token.claim" : "true", "access.token.claim" : "true", "userinfo.token.claim" : "true" }' \
--no-config \
--server $SERVER \
--realm $ADMIN_REALM \
--user $ADMIN_USER \
--password $ADMIN_PASSWORD

# create a new user
export USER_ID=$(./bin/kcadm.sh create users -r $NEW_REALM \
  -s username=$NEW_USER \
  -s enabled=true \
  -s totp=false \
  -s emailVerified=true \
  -s "requiredActions=[]" -i \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD)

# set the user's password
./bin/kcadm.sh set-password -r $NEW_REALM \
  --username $NEW_USER \
  --new-password $NEW_USER_PASSWORD \
  --no-config \
  --server $SERVER \
  --realm $ADMIN_REALM \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create group
export GROUP_ID=$(./bin/kcadm.sh create groups -r $NEW_REALM \
-s name=$NEW_GROUP -i \
--no-config \
--server $SERVER \
--realm $ADMIN_REALM \
--user $ADMIN_USER \
--password $ADMIN_PASSWORD)

# Add User to Group
./bin/kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r $NEW_REALM \
-s realm=$NEW_REALM \
-s userId=$USER_ID \
-s groupId=$GROUP_ID -n \
--no-config \
--server $SERVER \
--realm $ADMIN_REALM \
--user $ADMIN_USER \
--password $ADMIN_PASSWORD

# Add roles (W.i.P
./bin/kcadm.sh add-roles -r $NEW_REALM \
--uid $USER_ID \
--cid $CLIENT_ID \
--rolename manage-realm \
--no-config \
--server $SERVER \
--realm $ADMIN_REALM \
--user $ADMIN_USER \
--password $ADMIN_PASSWORD
```
