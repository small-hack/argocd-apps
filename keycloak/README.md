# Keycloak

> Depends on `external-secrets-operator`, and `bitwarden-external-secrets`

Keycloak is an Open Source Identity and Access Management solution which provides user federation, strong authentication, user management, fine-grained authorization, and more. Add authentication to applications and secure services with minimum effort. No need to deal with storing users or authenticating users.

Be sure to run the following to add the oci compliant repo to argocd first:

```bash
# see: https://github.com/argoproj/argo-cd/issues/10823#issuecomment-1620308484
argocd repo add registry-1.docker.io \
  --type helm \
  --name docker \
  --enable-oci
```

# Backups

According to the official keycloak [docs](https://www.keycloak.org/docs/latest/upgrading/index.html#_prep_migration), the following directories will need to be backed up:
- `/opt/bitnami/keycloak/conf` (most important)
- `/opt/bitnami/keycloak/providers`
- `/opt/bitnami/keycloak/themes` (least important)

You'll also want to backup the database by running:

```bash
# takes a dump of the keycloak database
kubectl exec -it keycloak-web-app-postgresql-0 -- PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean > /tmp/keycloak.sql

# copies it from the pod locally
kubectl cp keycloak-web-app-postgresql-0:tmp/keycloak.sql keycloak.sql
```

# Troubleshooting

## Debugging OIDC connections
Try adding https://oidcdebugger.com/debug as a "Valid redirect URI" under the client settings.

## If you need to troubleshoot something with the Postgres database

1. Deploy `argo-postgres-app` frist

2. Connect to postgres and create the DB

Deploy the following container and attach to the shell, then install `postgresql-client`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-client
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

3. Deploy `argo-keycloak-app`
