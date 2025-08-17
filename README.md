# Shared Argo CD templates for self hosted infra

A collection of <a href="https://argo-cd.readthedocs.io/en/stable/">Argo CD</a> templates for deploying helm apps or directories of <a href="https://kubernetes.io">Kubernetes</a> (k8s) manifests as <a href="https://argo-cd.readthedocs.io/en/stable/core_concepts/">Argo CD apps</a>. We're still working on full stability, but please feel free to ask questions or make suggestions 🧡

https://github.com/small-hack/argocd-apps/assets/2389292/76b0fe06-554e-4e46-856f-51a268ed170e

These Argo CD apps were originally designed to be compatible with [`smol-k8s-lab`](https://github.com/small-hack/smol-k8s-lab), but they can be used anywhere :)

## Core Tenants

Here's some quick guidelines, but you if you'd like to contribute, please read the full contributing guidelines [here](./CONTRIBUTING.md) 😃!

- Follow a base [schema](./CONTRIBUTING.md#directory-and-filename-schemas) for all our files and directories so that we can easily make more of them faster.

- Make secure as we go to avoid the dreaded all-at-once security pass (but we may have missed something, in which case, please let us know).

- Be kind and if something doesn't work as it should, try to fix the upstream repo before introducing a good-enough fix here.

- NEVER FORGET THE BACKUPS. <sub>DO YOU REMEMBER WHAT HAPPENED LAST TIME WE DIDN'T HAVE THIS RULE? 😭</sub>

# All Apps

* [Continuous Deployment](#continuous-deployment)
* [Database and Key Value Stores](#database-and-key-value-stores)
* [File Storage and Backups](#file-storage-and-backups)
  * [Experimental](#experimental)
* [Identity Providers and SSO](#identity-providers-and-sso)
  * [Experimental](#experimental-1)
* [Ingress](#ingress)
* [Monitoring](#monitoring)
  * [Experimental](#experimental-2)
  * [Deprecated](#deprecated)
* [Networking](#networking)
  * [Experimental](#experimental-3)
* [Other](#other)
  * [Experimental](#experimental-4)
* [Security](#security)
  * [Experimental](#experimental-5)
* [Secrets Management](#secrets-management)
  * [Experimental](#experimental-6)
* [Social Media and chat](#social-media-and-chat)
* [Virtual Machines](#virtual-machines)
  * [Experimental](#experimental-7)
* [Troubleshooting Tips](#troubleshooting-tips)
* [Art](#art)
  * [Argo CD Squid riding a Docker whale](#argo-cd-squid-riding-a-docker-whale)

## Continuous Deployment

|    App Directory   | Description                                                                                                                                                                                                       |
|:------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [argocd](./argocd) | The one, the only, [Argo CD](https://argoproj.github.io/cd/) is used for declarative continuous delivery to Kubernetes with a fully-loaded UI. This actually deploys all the other apps and manages itself too :3 |


## Database and Key Value Stores

| App Directory                                                       | Description                                                                                                |
|:--------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|
| [cloud-native-postgres](./postgres/operators/cloud-native-postgres) | PostgreSQL database management operator to spin up postgres instances, collect metrics, and create backups |
| [postgresql](./postgres/bitnami)                                    | Just a bitnami PostgreSQL database helm chart on k8s, in case you need that for something                  |
| [valkey](./valkey)                                                  | Bitnami Valkey helm chart on k8s. Valkey is a more FOSS alternative to Redis.                              |
| [valkey Cluster](./valkey_cluster)                                  | Bitnami Valkey Cluster helm chart on k8s. Valkey is a more FOSS alternative to Redis Cluster.              |


## File Storage and Backups

| App Directory                          | Description                                                                                                                                                           |
|:---------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Collabora Online](./collabora_online) | [Collabora Online](https://www.collaboraonline.com/) is a powerful online document editing suite                                                                      |
| [k8up](./k8up)                         | [K8up](https://k8up.io/k8up/2.7/index.html) is a k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage         |
| [nextcloud](./nextcloud)               | [Nextcloud](https://nextcloud.com/) is a self hosted file storage cloud solution. Replaces something like google drive/photos/notes/meets/calendar - mostly stable    |
| [minio](./minio)                       | [MinIO](https://min.io) is a secure self hosted S3 compatible Object Store.                                                                                           |
| [SeaweedFS](./seaweedfs)               | [SeaweedFS](https://github.com/seaweedfs/seaweedfs) is a secure and very fast self hosted S3 compatible Object Store specialized for either many files or large files |


#### Experimental

|        App Directory        | Description                                                                                                                                                                          |
|:---------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|   [garage](./demo/garage)   | [Garage](https://git.deuxfleurs.fr/Deuxfleurs/garage/src/branch/main) is a self hosted S3 compatible Object Store                                                                    |
|      [harbor](./harbor)     | Container Registry and OCI artifact store with built-in vulernability scanning via Trivy                                                                                             |
| [longhorn](./demo/longhorn) | [Longhorn](https://github.com/longhorn/longhorn) is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. (not currently actively in development) |

## Identity Providers and SSO

|         App Directory        | Description                                                                                                                                                                                                                                                                                                                                                 |
|:----------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [vouch-proxy](./vouch-proxy) | helm chart for [Vouch](https://github.com/vouch/vouch-proxy), an OAuth2 proxy that allows you to use ingress-nginx annotations to connect to a third party identity provider, giving you proper auth on websites that don't have auth. Currently works with the zitadel provider in this template, but also known to work with keycloak, google, and github |
|     [zitadel](./zitadel)     | helm chart for [Zitadel](https://zitadel.com/), an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps. Recommended over keycloak.                                                                                                                                                                           |


#### Experimental

|          App Directory         | Description                                                                                                                                                 |
|:------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------|
|   [keycloak](./demo/keycloak)  | helm chart for [Keycloak](https://www.keycloak.org/), an Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps |
| [oauth2-proxy](./oauth2-proxy) | Oauth2 proxy that works with Google, however we're testing a keycloak provider right now                                                                    |

## Ingress

|           App Directory          | Description                                                                                                                                       |
|:--------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------|
|  [cert-manager](./cert-manager)  | helm chart for [cert-manager](https://cert-manager.io), for providing TLS certificates based on nginx ingress annotations                         |
| [ingress-nginx](./ingress-nginx) | helm chart for [ingress-nginx](https://github.com/kubernetes/ingress-nginx), an nginx ingress controller to allow external traffic to the cluster |


## Monitoring

The main thing we deploy is the Grafana Stack which includes:
- Alloy
- Mimir
- Loki
- Grafana

We also offer Tempo for telemetry.

| App Directory                    | Description                                                                                                                                                                                                                                           |
|:---------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [grafana_stack](./grafana_stack) | [Alloy](https://grafana.com/docs/alloy/latest/), [Mimir](https://grafana.com/docs/mimir/latest/), [Loki](https://grafana.com/docs/loki/latest/), [Grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |


#### Experimental

|      App Directory      | Description                                                                                                                                                                                                                                                                                                               |
|:-----------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [kepler](./demo/kepler) | helm chart for [Kepler](https://github.com/sustainable-computing-io/kepler), (Kubernetes-based Efficient Power Level Exporter), which uses eBPF to probe performance counters and other system stats, use ML models to estimate workload energy consumption based on these stats, and exports them as Prometheus metrics. |
|     [tempo](./tempo)    | [Tempo](https://grafana.com/docs/tempo/latest/) for collecting telemetry and exposing it through Grafana. Useful for supporting developers who make heavy use of tracing.                                                                                                                                                 |

#### Deprecated

We used to deploy the Kube Prometheus Stack, but these days we focus on the Grafana stack above, and so this is just left for legacy setups that might be using this repo. This includes:
- promtail (now Deprecated upstream)
- Prometheus
- Alertmanager
- Grafana
- Loki

| App Directory                                                                       | Description                                                                                                                                                                         |
|:------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [kube-prometheus-stack](./prometheus/app_of_apps/)                                  | [prometheus](https://prometheus.io/docs/introduction/overview/), alertmanager, [grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./prometheus/app_of_apps/loki_argocd_app.yaml)                         | [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for collecting logs in prometheus                                      |
| [prometheus-push-gateway](./prometheus/app_of_apps/push-gateway_argocd_appset.yaml) | Installs the [Prometheus Push Gateway](https://prometheus.io/docs/instrumenting/pushing/) which enables pushing metrics from jobs that would be difficult or impossible to scrape   |

## Networking

|     App Directory    | Description                                                                                                                       |
|:--------------------:|:----------------------------------------------------------------------------------------------------------------------------------|
| [metallb](./metallb) | A helm chart for [metallb](https://metallb.universe.tf/) which will let you manager your own ip address pool for use with ingress |

#### Experimental

|             App Directory             | Description                                                                                                                                  |
|:-------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------|
|        [cilium](./demo/cilium)       | A helm chart for cilium, for transparently securing network connectivity/loadbalancing b/w app workloads such as app containers or processes  |
|     [headscale](./demo/headscale)    | VPN, there isn't an official helm chart, so we're still working on this                                                                       |
|     [netmaker](./demo/netmaker)      | VPN utilizing wiregaurd on the backend                                                                                                        |
| [wireguard](./demo/wg-access-server) | A helm chart for wg-access-server which uses Wireguard®️ for a VPN                                                                            |


## Other
Other useful tools that don't fit neatly into any one category.

#### Experimental

|            App Directory           | Description                                                      |
|:----------------------------------:|:-----------------------------------------------------------------|
|         [k8tz](./demo/k8tz)        | A helm chart for k8tz, to inject timezone info into cronjob pods |
| [LibreTranslate](./libretranslate) | A helm chart for LibreTranslate, to self host a translation tool |


## Security

#### Experimental

| App Directory             | Description                         |
|:--------------------------|:------------------------------------|
| [kyverno](./demo/kyverno) | Kubernetes-native policy management |
| [opa](./opa)              | Open Policy Agent Gatekeeper        |


## Secrets Management

| App Directory                                                                 | Description                                                                                                                          |
|:------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
| [external-secrets-operator](./external-secrets-operator)                      | ESO ([External Secrets Operator](https://external-secrets.io/latest/)) used for sourcing k8s secrets from an external provider       |
| [bitwarden-external-secrets](./external-secrets-operator/providers/bitwarden) | ESO [Bitwarden](https://external-secrets.io/v0.9.1/examples/bitwarden/) SecretStore, for using secrets directly from bitwarden items |

#### Experimental

| App Directory                 | Description                                                                                                                                                |
|:------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| [infisical](./demo/infisical) | [Infisical](https://infisical.com/docs/integrations/platforms/kubernetes) is an open source secrets management solution and it has a k8s secrets operator. |
| [openbao](./demo/openbao)     | [OpenBao](https://github.com/openbao/openbao) is an open source secrets management solution forked from Vault and supported by the Linux Foundation.       |
| [vault](./demo/vault)         | [Vault](https://github.com/hashicorp/vault) is an open source secrets management solution by Hashicorp.                                                    |

## Social Media and chat

| App Directory                | Description                                                                                                                                                                                                                                                                                                                                                                                               |
|:-----------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [coturn](./coturn)           | TURN/STUN server for connecting VoIP peers                                                                                                                                                                                                                                                                                                                                                                |
| [elk](./elk)                 | [Elk](https://github.com/elk-zone/elk) is a selfhosted frontend to Mastodon and GoToSocial.                                                                                                                                                                                                                                                                                                               |
| [ghost](./ghost)             | [Ghost](https://ghost.org/) is a selfhosted blogging platform.                                                                                                                                                                                                                                                                                                                                            |
| [gotosocial](./gotosocial)   | [GoToSocial](https://gotosocial.org) is a selfhosted social media site, includes postgresql. Advertised as lighter weight in requirements than Mastodon.                                                                                                                                                                                                                                                  |
| [mastodon](./mastodon)       | [Mastodon](https://en.wikipedia.org/wiki/Mastodon_(social_network)) is a selfhosted social media site, includes [postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql), [elastic search](https://github.com/bitnami/charts/tree/main/bitnami/elasticsearch) (for full text searching), and [valkey](https://github.com/bitnami/charts/tree/main/bitnami/valkey) (in memory caching) |
| [matrix](./matrix)           | [matrix](https://matrix.org) is a selfhosted chat server that plugs into a bunch of other chat apps                                                                                                                                                                                                                                                                                                       |
| [peertube](./peertube)       | [PeerTube](https://joinpeertube.org/en_US) is a selfhosted video hosting website that acts a replacement for YouTube. This app of apps includes postgresql, valkey, and S3 (via SeaweedFS).                                                                                                                                                                                                               |
| [writefreely](./writefreely) | [WriteFreely](https://writefreely.org/) is a slim selfhosted blogging platform.                                                                                                                                                                                                                                                                                                                           |

## Virtual Machines

| App Directory          | Description                                                                             |
|:-----------------------|:----------------------------------------------------------------------------------------|
| [kubevirt](./kubevirt) | [KubeVirt](https://kubevirt.io/) is a virtual machine management add-on for Kubernetes. |

#### Experimental
|                 App Directory                | Description                                                                       |
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

This part is just here for fun :) If you have open source fan art, consider submitting it to the project itself and/or us, and we'll display it with credit 💙


### Argo CD Squid riding a Docker whale
<img src="https://github.com/small-hack/argocd-apps/assets/2389292/1e7e5902-d48f-440d-98f4-44028f4bd90e" alt="The Argo CD mascot, an orange squid, riding a blue docker whale. The docker whale is holding a package. It's drawn in a simple cute flat style." width="250">

![same image as above but way smaller](https://github.com/small-hack/argocd-apps/assets/2389292/53a0df34-5d3a-4e84-8d09-26ad17a32ffd)


By @jessebot
