# Postgres Apps

## Bitnami 
  - Deploys a single inststance of postgres using the [Bitnami helm chart](https://bitnami.com/stack/postgresql/helm).
  - A full list of values is [Here](https://github.com/bitnami/charts/blob/main/bitnami/postgresql/README.md)

## Operators

### CloudNative Postgres
  - [Deploy the CloudNative Postgres Operator](https://cloudnative-pg.io/documentation/1.21/)
    
### Zalando (Deprecating)
   - Deploys the [Zalando Postgres Operator](https://github.com/zalando/postgres-operator) and [PGoperator Web UI](https://github.com/zalando/postgres-operator/blob/master/docs/operator-ui.md).
   - UI is pre-configured for use with Vouch.
