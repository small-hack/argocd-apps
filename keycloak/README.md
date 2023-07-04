# Keycloak

> Depends on `external-secrets-operator`, and `bitwarden-external-secrets`

Keycloak is an Open Source Identity and Access Management solution which provides user federation, strong authentication, user management, fine-grained authorization, and more. Add authentication to applications and secure services with minimum effort. No need to deal with storing users or authenticating users.

Be sure to run the following to add the oci compliant repo to argocd first:

```bash
argocd repo add registry-1.docker.io \
  --type helm \
  --name docker \
  --enable-oci
```

## 1. Deploy `argo-postgres-app` frist

## 2. Connect to postgres and create the DB

Deploy the following container and attach to the shell, then install `postgresql-client`.

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: mastodon-postgres-client
    namespace: mastodon
  spec:
    containers:
    - name: postgres-client
      image: ubuntu:latest
      command:
        - sleep
        - "3600"
      imagePullPolicy: IfNotPresent
    restartPolicy: Always
  ```

Install psql client:

  ```bash
  apt-get update && apt-get install -y postgresql-client dnsutils curl
  ```

Connect to the server, and craete the keycloak DB:

  ```bash
  psql -U admin -d postgres -h keycloak-postgres-postgresql.keycloak.svc.cluster.local -p 5432
  CREATE DATABASE keycloak;
  ```


## 3. Deploy `argo-keycloak-app`
