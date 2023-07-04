# Common ArgoCD templates we use for self hosted cloud stuff
Check out each app directory's README for more info.

# Social Media and chat

| ArgoCD App               | Description                                                                      |
|:------------------------:|:---------------------------------------------------------------------------------|
| [mastodon](./mastodon)   | Selfhosted social media site, includes [postgres], [elastic search] (for full text searching), and [redis] (in memory caching) |
| [matrix](./matrix)       | Selfhosted chat app 🚧 UNDER CONSTRUCTION |
| [nextcloud](./nextcloud) | File storage solution (and a chat)        |

## Backups

| ArgoCD App       | Description                                                                      |
|:----------------:|:---------------------------------------------------------------------------------|
| [k8up](./k8up)   | k8s native backups done via restic, so you can sync your persistent volumes to external s3 compliant storage | 

## Database

| ArgoCD App             | Description                                               |
|:----------------------:|:----------------------------------------------------------|
| [postgres](./postgres) | Just postgres on k8s, in case you need that for something |

## Email

| ArgoCD App       | Description                                                     |
|:----------------:|:----------------------------------------------------------------|
| [mailu](./mailu) | A k8s native approach to an email server and antivirus (clamav) |

## Auth and Identity Management

| ArgoCD App                   | Description                                                                                           |
|:----------------------------:|:------------------------------------------------------------------------------------------------------|
| [keycloak](./keycloak)       | An Identity Access Management tool with built in OpenIDConnect for authenticating to self hosted apps |
| [vouch-proxy](./vouch-proxy) | Oauth2 proxy that works with |

## Monitoring

| ArgoCD App                     | Description                                                                      |
|:------------------------------:|:---------------------------------------------------------------------------------|
| [kube-prometheus-stack](./kube-prometheus-stack) | [promtheus], [alertmanager], [grafana] for collecting metrics for monitoring/alerting, and dashboards/charts |
| [loki-stack](./loki-stack)     | [loki] and [promtail] for collecting logs in prometheus |

## Security

| ArgoCD App                  | Description                                                                       |
|:---------------------------:|:---------------------------------------------------------------------------------:|
| [bitwarden-external-secrets](./bitwarden-external-secrets) | External Secrets Operator [Bitwarden] [secret store]()                          |
| [external-secrets-operator](./external-secrets-operator)   | [External Secrets Operator] used for sourcing k8s secrets from an external provider |

Bitwarden: https://bitwarden.com/
External Secrets Operator: https://external-secrets.io/latest/
