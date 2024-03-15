# Cloud-Native Postgres Operator

CloudNativePG is the Kubernetes operator that covers the full lifecycle of a highly available PostgreSQL database cluster with a primary/standby architecture, using native streaming replication. 

| Description | Link                                             |
|-------------|--------------------------------------------------|
| Website     | https://cloudnative-pg.io/                       |
| GitHub      | https://github.com/cloudnative-pg/cloudnative-pg |
| Helm chart  | https://github.com/cloudnative-pg/charts         |
| Docs        | https://cloudnative-pg.io/documentation/1.21/.   |

## Connecting with TLS
 
  1. Create a user certificate

```bash
krew install cnpg

kubectl cnpg certificate cluster-app \
        --cnpg-cluster cluster-example \
        --cnpg-user app
```

  2. Get the client cert and cluster-ca from secrets

  3. Connect to the database using the certificates

```bash 
psql sslkey=tls.key \
      sslcert=tls.crt \
      sslrootcert=ca.crt \
      host=cluster-example-rw.default.svc \
      dbname=app \
      user=app \
      sslmode=verify-full
```
