# An Argo CD App for Zitadel

[Zitadel](https://github.com/zitadel/zitadel/tree/main) and it's community have been really nice. We'll still support Keycloak for a while, because it's so widely used in enterprise environments.

Here's their [helm chart](https://github.com/zitadel/zitadel-charts/tree/main) that we're deploying here.

It's important to take a look at the [`defaults.yaml`](https://github.com/zitadel/zitadel/blob/main/cmd/defaults.yaml) to see what the default `ConfigMap` will look like for Zitadel.

## Sync waves
1. External Secrets for both cockroachdb and zitadel
   - includes cockroachdb secrets
   - includes Zitadel `masterkey`
2. cockroachdb helm chart
3. zitadel helm chart

## Zitadel OIDC for Argo CD SSO
Check out this [PR](https://github.com/argoproj/argo-cd/pull/15029)

## Using the Zitadel API

The API docs are [here](https://zitadel.com/docs/category/apis).

For Actions (needed for Argo CD and Zitadel to work nicely) you probably want this [link](https://zitadel.com/docs/category/apis/resources/mgmt/actions)

## Helm testing locally

Zitadel has an official guide for k8s deployments [here](https://zitadel.com/docs/self-hosting/deploy/kubernetes).
