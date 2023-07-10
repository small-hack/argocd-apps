# Shared Argo CD templates for self hosted infra
A collection of [Argo CD] templates for deploying apps or manifests on Kubernetes.

#### Some Guidelines to aim for
Each Argo CD template directory should:
1. Use [sync waves] if they have extenral secrets, persistent volumes, or database requirements. This ensures no apps run into order of operations issues and we can ensure statefulness of core unique components.
2. Add a basic description of what the app is in the `README.md` of the root app directory, and a shorter blurb this `README.md` under the rough category under [All Apps](#all-apps).
3. Be in an app specific Kubernetes namespace (e.g. ingress-nginx in a namespace called ingress). Grouping is fine if the services are highly related such as Proometheus being in the same namespace as Loki.
4. Be in an app specific Argo CD [project]. Grouping some services together in similar namespaces is fine, but this helps make the GUI interface more managable and allows good practice for proper IAM and RBAC priniciples.


#### Future Goals
Beyond just ensuring everything meets basic reliability and security needs, we also hope to:
- Figure out a way to have variables for these templates! Right now your best bet for reuse is to clone this repo, and search and replace "social-media-for-dogs.com" and "wnby.city" with whatever your domain is. That's combersome and makes merging in changes kinda gross. We need to figure out if there's an Argo CD friendly way to have some sort of evironment variables.
- Create ArgoCD project configs declaritively, as right now we manually create the projects and roles

## All Apps

<!-- vim-markdown-toc GFM -->

* [Auth and Identity Management](#auth-and-identity-management)
* [Database](#database)
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


### File Storage and Backups

| App                      | Description                                                                                                                  |
|:-------------------------|:-----------------------------------------------------------------------------------------------------------------------------|
| [k8up](./k8up)           | k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage                 |
| [nextcloud](./nextcloud) | Self hosted file storage cloud solution. Replaces something like google drive/photos/notes/meets/calendar                    |
| [Harbor](./harbor)       | 🚧 UNDER CONSTRUCTION - Container Registry and OCI artifact store with built-in vulernability scanning via Trivy             |
| [Longhorn](./longhorn)   | 🚧 UNDER CONSTRUCTION - Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. |

### Email

| App              | Description                                                      |
|:-----------------|:-----------------------------------------------------------------|
| [mailu](./mailu) | A k8s native approach to an email server and antivirus (clamav)  |


### Monitoring

| App                                              | Description                                                                                                                                                                         |
|:-------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [kube-prometheus-stack](./kube-prometheus-stack) | [prometheus](https://prometheus.io/docs/introduction/overview/), alertmanager, [grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./loki-stack)                       | [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for collecting logs in prometheus                                      |


### Security

| App                                                        | Description                                                                                                                    |
|:-----------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------|
| [external-secrets-operator](./external-secrets-operator)   | ESO ([External Secrets Operator](https://external-secrets.io/latest/)) used for sourcing k8s secrets from an external provider |
| [bitwarden-external-secrets](./bitwarden-external-secrets) | ESO [Bitwarden] SecretStore, for using secrets directly from bitwarden items                                                   |
| [wireguard](./wg-access-server)                            | A helm chart for wg-access-server which uses Wireguard®️ for a VPN                                                              |
| [headscale](./headscale)                                   | VPN, 🏗️ there isn't an official helm chart, so we're still working on this                                                     |


### Social Media and chat

| App                    | Description                                                                                                                                          |
|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------|
| [mastodon](./mastodon) | Selfhosted social media site, includes [postgres], [elastic search] (for full text searching), and [redis] (in memory caching) 🚧 UNDER CONSTRUCTION |
| [matrix](./matrix)     | 🚧 UNDER CONSTRUCTION - Selfhosted chat app                                                                                                          |
