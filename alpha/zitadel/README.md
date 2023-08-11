# An Argo CD App for Zitadel

We don't know much about [Zitadel](https://github.com/zitadel/zitadel/tree/main) yet as we just learned about it. We'll still support Keycloak for a bit, but if Zitadel is more modern and easier to configure, we'll switch. Here's their [helm chart](https://github.com/zitadel/zitadel-charts/tree/main).

It's important to take a look at the [`defaults.yaml`](https://github.com/zitadel/zitadel/blob/main/cmd/defaults.yaml) to see what the default configMap will look like for zitadel.

## Zitadel OIDC for Argo CD
Check out this [Argo CD Discussions thread](https://github.com/argoproj/argo-cd/discussions/11855), and this recent [Zitadel Discussions thread](https://github.com/zitadel/zitadel-charts/discussions/116) for updates.

## Using the Zitadel API

The API docs are [here](https://zitadel.com/docs/category/apis). For actions you probably want this link:

https://zitadel.com/docs/category/apis/resources/mgmt/actions


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
