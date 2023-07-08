# Common ArgoCD templates for self hosted infra
Check out each app directory's README for more info.

## Auth and Identity Management

|  | |
|:------------------------------:|:------------------------------------------------------------------------------------------------------|
| [keycloak](./keycloak)         | An Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps |
| [vouch-proxy](./vouch-proxy)   | Oauth2 proxy that allows you to use ingress-nginx annotations to connect to a third party identity provider, giving you proper auth on websites that don't have auth. Currently works with the keycloak provider in this template, but also known to work with google and github |
| [oauth2-proxy](./oauth2-proxy) | 🏗️ Under construction. Oauth2 proxy that works with Google, however we're testing a keycloak provider right now |

## Backups

|  | |
|:----------------:|:---------------------------------------------------------------------------------|
| [k8up](./k8up)   | k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage | 

## Database

|  | |
|:----------------------:|:----------------------------------------------------------|
| [postgres](./postgres) | Just a bitnami PostgreSQL database helm chart on k8s, in case you need that for something |

## Email

|  | |
|:----------------:|:----------------------------------------------------------------|
| [mailu](./mailu) | A k8s native approach to an email server and antivirus (clamav) |

## Monitoring

|  | |
|:------------------------------:|:---------------------------------------------------------------------------------|
| [kube-prometheus-stack](./kube-prometheus-stack) | [prometheus](https://prometheus.io/docs/introduction/overview/), alertmanager, [grafana](https://grafana.com) for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./loki-stack)                       | [loki](https://grafana.com/oss/loki/) and [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) for collecting logs in prometheus |

## Security

|  | |
|:----:|:---------------------------------------------------:|
| [external-secrets-operator](./external-secrets-operator)   | ESO ([External Secrets Operator](https://external-secrets.io/latest/)) used for sourcing k8s secrets from an external provider |
| [bitwarden-external-secrets](./bitwarden-external-secrets) | ESO [Bitwarden] SecretStore, for using secrets directly from bitwarden items    |
| [headscale](./headscale)                                   | VPN, 🏗️ coming soon |

## Social Media and chat

|  | |
|:------------------------:|:---------------------------------------------------------------------------------|
| [mastodon](./mastodon)   | Selfhosted social media site, includes [postgres], [elastic search] (for full text searching), and [redis] (in memory caching) |
| [matrix](./matrix)       | Selfhosted chat app 🚧 UNDER CONSTRUCTION |
| [nextcloud](./nextcloud) | File storage solution (and a chat)        |
