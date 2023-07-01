# Bitwarden + External Secrets Operator via ArgoCD

 An ArgoCD app for deploying the [External Secrets Operator](https://external-secrets.io/v0.8.3/) and a [Webhook provider]() for Bitwarden. It's based on https://external-secrets.io/v0.8.3/examples/bitwarden/ but it uses an api token instead. Also included is a docker image for running the bitwarden CLI as a service inside your K8s cluster. The image runs as non-root and includes a network policy to restrict connectivity to only allow traffic from the External Secrets Operator's namespace.

- [Dockerhub Link](https://hub.docker.com/repository/docker/deserializeme/bweso/general)

## Setup

- Have a bitwarden account and some secrets

- Have your Bitwarden API token

- Pupulate [credential.yaml](./credential.yaml) with your bitwarden credentials, then apply the file to create the secret

- Create the app in argocd using [argo-app.yaml](./argo-app.yaml)

- Customize the [example secret](example-secret.yaml) and apply.

