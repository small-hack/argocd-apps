# Shared Argo CD templates for self hosted infra
A collection of [Argo CD](https://argo-cd.readthedocs.io/en/stable/) templates for deploying helm apps or directories of [Kubernetes](https://kubernetes.io) (k8s) manifests as [Argo CD apps](https://argo-cd.readthedocs.io/en/stable/core_concepts/).

If you're interested in contributing, checkout our guidelines [here](./CONTRIBUTING.md) 😃!

## All Apps

* [Auth and Identity Management](#auth-and-identity-management)
* [Database](#database)
* [Virtual Machines](#virtual-machines)
* [File Storage and Backups](#file-storage-and-backups)
* [Monitoring](#monitoring)
* [Security](#security)
* [Social Media and chat](#social-media-and-chat)

### Auth and Identity Management

|               App              | Description                                                                                                                                                                                                                                                                                                 |
|:------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     [keycloak](./keycloak)     | helm chart for [Keycloak](https://www.keycloak.org/), an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps                                                                                                                                                                            |
|  [vouch-proxy](./vouch-proxy)  | helm chart for [Vouch](https://github.com/vouch/vouch-proxy), an OAuth2 proxy that allows you to use ingress-nginx annotations to connect to a third party identity provider, giving you proper auth on websites that don't have auth. Currently works with the keycloak provider in this template, but also known to work with google and github |
| [oauth2-proxy](./oauth2-proxy) | 🏗️ Under construction. Oauth2 proxy that works with Google, however we're testing a keycloak provider right now                                                                                                                                                                                             |


### Database

| App                                      | Description                                                                                                       |
|:-----------------------------------------|:------------------------------------------------------------------------------------------------------------------|
| [postgres-operator](./postgres/operator) | PostgreSQL database management tool to spin up additional postgres instances, collect metrics, and create backups |
| [postgres](./postgres/bitnami)           | Just a bitnami PostgreSQL database helm chart on k8s, in case you need that for something                         |

### Virtual Machines

| App                                      | Description                                                                                                       |
|:-----------------------------------------|:------------------------------------------------------------------------------------------------------------------|
| [kubevirt](./kubevirt) | [KubeVirt](https://kubevirt.io/) is a virtual machine management add-on for Kubernetes.                                                                     |
| [Nvidia GPU Operator](./nvidia/gpu-operator) | 🚧 UNDER CONSTRUCTION The GPU Operator allows administrators of Kubernetes clusters to manage GPU nodes       |


### File Storage and Backups

| App                      | Description                                                                                                                  |
|:-------------------------|:-----------------------------------------------------------------------------------------------------------------------------|
| [k8up](./k8up)           | [K8up](https://k8up.io/k8up/2.7/index.html) is a k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage                 |
| [nextcloud](./nextcloud) | [Nextcloud](https://nextcloud.com/) is a self hosted file storage cloud solution. Replaces something like google drive/photos/notes/meets/calendar - mostly stable    |
| [Harbor](./harbor)       | 🚧 UNDER CONSTRUCTION - Container Registry and OCI artifact store with built-in vulernability scanning via Trivy             |
| [Longhorn](./longhorn)   | [Longhorn](https://github.com/longhorn/longhorn) is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. |


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
| [coturn](./coturn)     | 🚧 UNDER CONSTRUCTION - TURN/STUN server for connecting VoIP peers                               |   
| [mastodon](./mastodon) | Selfhosted social media site, includes [postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql), [elastic search] (for full text searching), and [redis](https://github.com/bitnami/charts/tree/main/bitnami/redis) (in memory caching) - mostly stable |
| [matrix](./matrix)     | Selfhosted chat server that plugs into a bunch of other chat apps                                |        

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
