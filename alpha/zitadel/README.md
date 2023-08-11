# An Argo CD App for Zitadel

We don't know much about [Zitadel](https://github.com/zitadel/zitadel/tree/main) yet as we just learned about it. We'll still support Keycloak for a bit, but if Zitadel is more modern and easier to configure, we'll switch. Here's their [helm chart](https://github.com/zitadel/zitadel-charts/tree/main).


## Sync waves
1. cockroachdb
2. zitadel


## Helm testing locally

They have an official guide for k8s deployments [here](https://zitadel.com/docs/self-hosting/deploy/kubernetes).

```bash
helm repo add cockroachdb https://charts.cockroachdb.com/
helm repo add zitadel https://zitadel.github.io/zitadel-charts
helm repo update cockroachdb zitadel
helm uninstall my-zitadel
helm install crdb cockroachdb/cockroachdb --version 11.0.1 --set fullnameOverride=crdb
helm install my-zitadel zitadel/zitadel --values ./my-zitadel-values.yaml
```
