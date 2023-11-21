# Shared Argo CD templates for self hosted infra

A collection of <a href="https://argo-cd.readthedocs.io/en/stable/">Argo CD</a> templates for deploying helm apps or directories of <a href="https://kubernetes.io">Kubernetes</a> (k8s) manifests as <a href="https://argo-cd.readthedocs.io/en/stable/core_concepts/">Argo CD apps</a>. We're still working on full stability, but please feel free to ask questions or make suggestions :)

https://github.com/small-hack/argocd-apps/assets/2389292/76b0fe06-554e-4e46-856f-51a268ed170e

## Core Tenants
Here's some quick guidelines, but you if you'd like to contribute, please read the full contributing guidelines [here](./CONTRIBUTING.md) 😃!

- Follow a base [schema](./CONTRIBUTING.md#directory-and-filename-schemas) for all our files and directories so that we can easily make more of them faster.

- Make secure as we go to avoid the dreaded all-at-once security pass (but we may have missed something, in which case, please let us know).

- Be kind and if something doesn't work as it should, try to fix the upstream repo before introducing a good-enough fix here.

- NEVER FORGET THE BACKUPS. <sub>DO YOU REMEMBER WHAT HAPPENED LAST TIME WE DIDN'T HAVE THIS RULE? 😭</sub>

# All Apps

* [Continuous Deployment](#continuous-deployment)
* [Database](#database)
* [File Storage and Backups](#file-storage-and-backups)
    * [🚧 Under construction](#-under-construction)
* [Identity Providers and SSO](#identity-providers-and-sso)
    * [🚧 Under construction](#-under-construction-1)
* [Ingress](#ingress)
* [Monitoring](#monitoring)
* [Networking](#networking)
    * [🚧 Under construction](#-under-construction-2)
* [Security](#security)
* [Secrets Management](#secrets-management)
* [Social Media and chat](#social-media-and-chat)
* [Virtual Machines](#virtual-machines)
    * [🚧 Under construction](#-under-construction-3)
* [Troubleshooting Tips](#troubleshooting-tips)


## Continuous Deployment

|               App              | Description                                                                              |
|:------------------------------:|:-----------------------------------------------------------------------------------------|
| [argocd](./argocd) | The one, the only, [Argo CD](https://argoproj.github.io/cd/) is used for declarative continuous delivery to Kubernetes with a fully-loaded UI. This actually deploys all the other apps and manages itself too :3 |


## Database

| App                                      | Description                                                                                                       |
|:-----------------------------------------|:------------------------------------------------------------------------------------------------------------------|
| [postgres-operator](./postgres/operator) | PostgreSQL database management tool to spin up additional postgres instances, collect metrics, and create backups |
| [postgres](./postgres/bitnami)           | Just a bitnami PostgreSQL database helm chart on k8s, in case you need that for something                         |


## File Storage and Backups

| App                      | Description                                                                                                                                                        |
|:-------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [k8up](./k8up)           | [K8up](https://k8up.io/k8up/2.7/index.html) is a k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage      |
| [nextcloud](./nextcloud) | [Nextcloud](https://nextcloud.com/) is a self hosted file storage cloud solution. Replaces something like google drive/photos/notes/meets/calendar - mostly stable |


#### 🚧 Under construction
|           App          | Description                                                                                                                                  |
|:----------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------|
|   [Harbor](./harbor)   | Container Registry and OCI artifact store with built-in vulernability scanning via Trivy                                                     |
| [Longhorn](./longhorn) | [Longhorn](https://github.com/longhorn/longhorn) is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. |

## Identity Providers and SSO

|                  App                 | Description                                                                                                                                                                                                                                                                                                                                       |
|:------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [vouch-proxy](./vouch-proxy) | helm chart for [Vouch](https://github.com/vouch/vouch-proxy), an OAuth2 proxy that allows you to use ingress-nginx annotations to connect to a third party identity provider, giving you proper auth on websites that don't have auth. Currently works with the keycloak provider in this template, but also known to work with google and github |
|      [zitadel](./zitadel)      | helm chart for [Zitadel](https://zitadel.com/), an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps. Recommended over keycloak.|


#### 🚧 Under construction

|               App              | Description                                                                              |
|:------------------------------:|:-----------------------------------------------------------------------------------------|
| [keycloak](./alpha/keycloak)   | helm chart for [Keycloak](https://www.keycloak.org/), an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps  |
| [oauth2-proxy](./oauth2-proxy) | Oauth2 proxy that works with Google, however we're testing a keycloak provider right now |

## Ingress

|                    App                   | Description                                                                                                                                       |
|:----------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------|
|  [cert-manager](./cert-manager)  | helm chart for [cert-manager](https://cert-manager.io), for providing TLS certificates based on nginx ingress annotations                         |
| [ingress-nginx](./ingress-nginx) | helm chart for [ingress-nginx](https://github.com/kubernetes/ingress-nginx), an nginx ingress controller to allow external traffic to the cluster |


## Monitoring

| App                                                             | Description                                                                                                                                                                         |
|:----------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [kube-prometheus-stack](./prometheus/prometheus_argocd_appset.yaml)     | [prometheus](https://prometheus.io/docs/introduction/overview/), alertmanager, [grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./prometheus/loki_argocd_app.yaml)                           | [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for collecting logs in prometheus                                      |
| [prometheus-push-gateway](./prometheus/push-gateway_argocd_appset.yaml) | Installs the [Prometheus Push Gateway](https://prometheus.io/docs/instrumenting/pushing/) which enables pushing metrics from jobs that would be difficult or impossible to scrape   |


## Networking

|         App          | Description                                                       |
|:--------------------:|:------------------------------------------------------------------|
| [metallb](./metallb) | A helm chart for [metallb](https://metallb.universe.tf/) which will let you manager your own ip address pool for use with ingress |

#### 🚧 Under construction

|               App               | Description                                                                |
|:-------------------------------------:|:---------------------------------------------------------------------------|
| [cilium](./alpha/cilium)              | A helm chart for cilium, for transparently securing network connectivity/loadbalancing b/w app workloads such as app containers or processes |
| [wireguard](./alpha/wg-access-server) | A helm chart for wg-access-server which uses Wireguard®️ for a VPN          |
|     [headscale](./alpha/headscale)    | VPN, there isn't an official helm chart, so we're still working on this    |


## Other
Other useful tools that don't fit neatly into any one category.

#### 🚧 Under construction

|         App          | Description                                                       |
|:--------------------:|:------------------------------------------------------------------|
| [k8tz](./alpha/k8tz) | A helm chart for k8tz, to inject timezone info into cronjob pods  |


## Security

| App                        | Description                         |
|:---------------------------|:------------------------------------|
| [kyverno](./alpha/kyverno) | Kubernetes-native policy management |


## Secrets Management

| App                                                        | Description                                                                                                                          |
|:-----------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
| [external-secrets-operator](./external-secrets-operator)   | ESO ([External Secrets Operator](https://external-secrets.io/latest/)) used for sourcing k8s secrets from an external provider       |
| [bitwarden-external-secrets](./bitwarden-external-secrets) | ESO [Bitwarden](https://external-secrets.io/v0.9.1/examples/bitwarden/) SecretStore, for using secrets directly from bitwarden items |
| [infisical](./infisical) | [Infisical](https://infisical.com/docs/integrations/platforms/kubernetes) is an open source secrets management solution and it has a k8s secrets operator. |


## Social Media and chat

| App                    | Description                                                                                                                                          |
|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------|
| [coturn](./coturn)     | TURN/STUN server for connecting VoIP peers                               |   
| [mastodon](./mastodon) | Selfhosted social media site, includes [postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql), [elastic search] (for full text searching), and [redis](https://github.com/bitnami/charts/tree/main/bitnami/redis) (in memory caching) - mostly stable |
| [matrix](./matrix)     | Selfhosted chat server that plugs into a bunch of other chat apps                                |        


## Virtual Machines

| App                    | Description                                                                             |
|:-----------------------|:----------------------------------------------------------------------------------------|
| [kubevirt](./kubevirt) | [KubeVirt](https://kubevirt.io/) is a virtual machine management add-on for Kubernetes. |

#### 🚧 Under construction
|                      App                     | Description                                                                       |
|:--------------------------------------------:|:----------------------------------------------------------------------------------|
| [Nvidia GPU Operator](./nvidia/gpu-operator) | The GPU Operator allows administrators of Kubernetes clusters to manage GPU nodes |



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

## Art

<img src="https://github.com/small-hack/argocd-apps/assets/2389292/1e7e5902-d48f-440d-98f4-44028f4bd90e" width="250">
