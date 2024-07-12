This prometheus stack is just like the one in the above directory, however, it includes:

- Alertmanger uses a webhook to post alerts to a matrix channel
- Grafana uses direct direct oauth against Zitadel instead of using vouch-proxy (see: [grafana/helm-charts#2896](https://github.com/grafana/helm-charts/issues/2896) for more info)
