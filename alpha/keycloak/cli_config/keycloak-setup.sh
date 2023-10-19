#!/bin/env bash

export SERVER="http://localhost:8080/"
export ADMIN_REALM="default-realm-name"
export ADMIN_USER="test"
export ADMIN_PASSWORD="YOUR-PASSWORD-HERE"
export NEW_REALM="example-realm"
export NEW_CLIENT="example-client"
export NEW_USER="user"
export NEW_USER_PASSWORD="YOUR-PASSWORD-HERE"

# Creae a new realm
/opt/bitnami/keycloak/kcadm.sh create realms -s realm=$NEW_REALM \
  -s enabled=true \
  -o \
  --no-config \
  --server $SERVER \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create a new client
/opt/bitnami/keycloak/kcadm.sh create clients -r $NEW_REALM \
  -s clientId=$NEW_CLIENT \
  -s enabled=true \
  -o \
  --no-config \
  --server $SERVER \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# create a new user
/opt/bitnami/keycloak/kcadm.sh create users -r $NEW_REALM \
  -s username=$NEW_USER \
  -s enabled=true \
  --no-config \
  --server $SERVER \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD

# set the user's password
/opt/bitnami/keycloak/kcadm.sh set-password -r $NEW_REALM \
  --username $NEW_USER \
  --new-password $NEW_USER_PASSWORD \
  --no-config \
  --server $SERVER \
  --user $ADMIN_USER \
  --password $ADMIN_PASSWORD
