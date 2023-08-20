# An Argo CD App for Zitadel

[ZITADEL](https://github.com/zitadel/zitadel/tree/main) is an identity management and provider application similar to Keycloak. It helps you manage your users acrross apps and acts as your OIDC provider. It's community have been really nice, so we'll be supporting some Argo CD apps here in favor of depracting Keycloak support down the line eventually. Here's the [Zitadel helm chart](https://github.com/zitadel/zitadel-charts/tree/main) that we're deploying here.

It's important to take a look at the [`defaults.yaml`](https://github.com/zitadel/zitadel/blob/main/cmd/defaults.yaml) to see what the default `ConfigMap` will look like for Zitadel.

This ArgoCD app of apps is designed to be pretty locked down to allow you to use **only** a default service account (that also can't log in through the UI) to do all the heavy lifting with terraform, pulumi, or your own self service script. We support both [cockroachdb](./zitadel_and_cockroachdb) _and_ [postgresql](./zitadel_and_postgresql) as the database backends.

## Sync waves

1. External Secrets for both your database (cockroachdb or postgresql) and zitadel
   - Zitadel database credentials
   - Zitadel `masterkey` secret
   Persistent volume for your database, including backups via [k8up](https://k8up.io)
2. postgres or cockraochdb helm chart
3. zitadel helm chart with ONLY a service account and registration DISABLED

## Zitadel OIDC for logging into Argo CD with Zitadel as the SSO

Check out this [PR](https://github.com/argoproj/argo-cd/pull/15029)

## Using the Zitadel API

The API docs are [here](https://zitadel.com/docs/category/apis).

For Actions (needed for Argo CD and Zitadel to work nicely) you probably want this [link](https://zitadel.com/docs/category/apis/resources/mgmt/actions)

## Helm testing locally

Zitadel has an official guide for k8s deployments [here](https://zitadel.com/docs/self-hosting/deploy/kubernetes).
