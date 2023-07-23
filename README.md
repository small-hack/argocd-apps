# Shared Argo CD templates for self hosted infra
A collection of [Argo CD](https://argo-cd.readthedocs.io/en/stable/) templates for deploying helm apps or directories of [Kubernetes](https://kubernetes.io) (k8s) manifests as [Argo CD apps](https://argo-cd.readthedocs.io/en/stable/core_concepts/).

## All Apps

<!-- vim-markdown-toc GFM -->

* [Auth and Identity Management](#auth-and-identity-management)
* [Database](#database)
* [Virtual Machines](#virtual-machines)
* [File Storage and Backups](#file-storage-and-backups)
* [Email](#email)
* [Monitoring](#monitoring)
* [Security](#security)
* [Social Media and chat](#social-media-and-chat)

<!-- vim-markdown-toc -->


### Auth and Identity Management

|               App              | Description                                                                                                                                                                                                                                                                                                 |
|:------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     [keycloak](./keycloak)     | helm chart for [Keycloak], an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps                                                                                                                                                                            |
|  [vouch-proxy](./vouch-proxy)  | helm chart for [Vouch], an OAuth2 proxy that allows you to use ingress-nginx annotations to connect to a third party identity provider, giving you proper auth on websites that don't have auth. Currently works with the keycloak provider in this template, but also known to work with google and github |
| [oauth2-proxy](./oauth2-proxy) | 🏗️ Under construction. Oauth2 proxy that works with Google, however we're testing a keycloak provider right now                                                                                                                                                                                             |


### Database

| App                                      | Description                                                                                                       |
|:-----------------------------------------|:------------------------------------------------------------------------------------------------------------------|
| [postgres-operator](./postgres/operator) | PostgreSQL database management tool to spin up additional postgres instances, collect metrics, and create backups |
| [postgres](./postgres/bitnami)           | Just a bitnami PostgreSQL database helm chart on k8s, in case you need that for something                         |

### Virtual Machines

| App                                      | Description                                                                                                       |
|:-----------------------------------------|:------------------------------------------------------------------------------------------------------------------|
| [kubevirt](./kubevirt) | KubeVirt is a virtual machine management add-on for Kubernetes.                                                                     |
| [Nvidia GPU Operator](./nvidia/gpu-operator) | 🚧 UNDER CONSTRUCTION The GPU Operator allows administrators of Kubernetes clusters to manage GPU nodes       |


### File Storage and Backups

| App                      | Description                                                                                                                  |
|:-------------------------|:-----------------------------------------------------------------------------------------------------------------------------|
| [k8up](./k8up)           | k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage                 |
| [nextcloud](./nextcloud) | Self hosted file storage cloud solution. Replaces something like google drive/photos/notes/meets/calendar - mostly stable    |
| [Harbor](./harbor)       | 🚧 UNDER CONSTRUCTION - Container Registry and OCI artifact store with built-in vulernability scanning via Trivy             |
| [Longhorn](./longhorn)   | Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. |


### Monitoring

| App                                              | Description                                                                                                                                                                         |
|:-------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [kube-prometheus-stack](./kube-prometheus-stack) | [prometheus](https://prometheus.io/docs/introduction/overview/), alertmanager, [grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./loki-stack)                       | [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for collecting logs in prometheus                                      |


### Security

| App                                                        | Description                                                                                                                    |
|:-----------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------|
| [external-secrets-operator](./external-secrets-operator)   | ESO ([External Secrets Operator](https://external-secrets.io/latest/)) used for sourcing k8s secrets from an external provider |
| [bitwarden-external-secrets](./bitwarden-external-secrets) | ESO [Bitwarden](https://external-secrets.io/v0.9.1/examples/bitwarden/) SecretStore, for using secrets directly from bitwarden items                                                   |
| [wireguard](./wg-access-server)                            | A helm chart for wg-access-server which uses Wireguard®️ for a VPN                                                              |
| [headscale](./headscale)                                   | VPN, 🏗️ there isn't an official helm chart, so we're still working on this                                                     |


### Social Media and chat

| App                    | Description                                                                                                                                          |
|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------|
| [mastodon](./mastodon) | Selfhosted social media site, includes [postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql), [elastic search] (for full text searching), and [redis](https://github.com/bitnami/charts/tree/main/bitnami/redis) (in memory caching) - mostly stable |
| [matrix](./matrix)     | 🚧 UNDER CONSTRUCTION - Selfhosted chat app                                |        

## Troubleshooting Tips

- Namespace stuck in terminating state
  ```bash
  kubectl get namespace "<NAMESPACE>" -o json   | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/<NAMESPACE>/cdi/finalize -f -
  ```

- Find all items in a namespace
  ```bash
  kubectl api-resources --verbs=list --namespaced -o name   | xargs -n 1 kubectl get --show-kind --ignore-not-found -n <NAMESPACE>
  ```
  
- be sure to check for and remove `Mutatingwebhookconfiguration` and `Validatingwebhookconfiguration`

- Patching a resource you found via the Xargs search
  ```bash
  kubectl patch <CLASS>/<NAME>-p '{"metadata":{"finalizers":[]}}' --type=merge -n <NAMESPACE>
  ```

## Some Guidelines to aim for
Each Argo CD template directory should:

1. Use [sync waves](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/) if they have extenral secrets, persistent volumes, or database requirements. This ensures no apps run into order of operations issues and we can ensure statefulness of core unique components. If the app is quite large, consider putting the CRDs in their own sync wave as we've done for the [kube-prometheus-stack app](https://github.com/small-hack/argocd/blob/e88fe6184c46c96d8446422ae51e936bfe9ba8fc/kube-prometheus-stack/argocd_prometheus_app.yaml#L8).

2. Add a basic description of what the app is, and how it works in the `README.md` of the root app directory. Be sure any sync waves are documented and explain why they're necessary. Please also feature a screenshot or two of what the app looks like deployed in the web interface. Remove any IP addresses or other sensitive info first. Also, add a shorter blurb in a table in the repo root `README.md` under the rough category under [All Apps](#all-apps).

3. Make sure all k8s resources are in an app specific [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) (e.g. ingress-nginx in a namespace called ingress). Grouping is fine if the services are highly related such as Prometheus being in the same namespace as Loki.

4. Be in an app specific [Argo CD project](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/). Grouping some services together in similar namespaces is fine, but this helps make the GUI interface more managable and allows good practice for proper IAM and RBAC priniciples.

5. Ensure all secrets are created as external secrets using the [external secrets operator](https://external-secrets.io/). Those external secrets should also be in a private repo, but we should include examples of how to create them if we do.

6. Have absolutely _no plain text secrets_, including but not limited to: passwords, tokens, client secrets, keys of any sort (private or public), certificates. If the upstream helm chart/manifests don't support this, you should fork the chart/manifest repo and patch it to accept existing secrets for use in container [env variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables). Offer a PR to the upstream repo, and use your fork unless/until the upstream repo patches their manifests/templates.

7. Run as non-root via [k8s Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). If this isn't supported, please follow the same steps as you would a plain text password and create a fork.

8. Ensure all ingress resources have SSL certs. Using a fake cert from a `letsencrypt-staging` Issuer is fine while testing, but when the template is marked as ready for production, you must switch to `letsencrypt-prod`.

9. Ensure all apps have authentication enabled, and use OIDC if possible. If authentication is not possible, (e.g. the k8s dashboard) setup SSO via Vouch. On this same note, make sure you have at least one MFA option enabled if available (ideally provide both TOTP/Webauthn). If it's not possible to configure this securely entirely open source (e.g. you need to have an external secret in a private repo), include a sanitized example of how to create the external resources.

### Future Goals
Beyond just ensuring everything meets basic reliability and security needs, we also hope to:
- Figure out a way to have variables for these templates! Right now your best bet for reuse is to clone this repo, and search and replace "vleermuis.tech" and "enby.city" with whatever your domain is. That's combersome and makes merging in changes kinda gross. We need to figure out if there's an Argo CD friendly way to have some sort of evironment variables.
  - on this note, perhaps we check out vault to perhaps utilize the (Argo CD Vault Plugin)[https://argocd-vault-plugin.readthedocs.io/en/stable/).
- Create ArgoCD project configs declaritively, as right now we manually create the projects and roles
