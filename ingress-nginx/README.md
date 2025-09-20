# Ingress Nginx Controller
This installs [ingress-nginx](https://github.com/kubernetes/ingress-nginx) which is the Kubernetes hosted ingress controller using nginx, not to be confused with _nginx_-ingress, which is the ingress controller using nginx that is hosted _by nginx itself_.

<img width="906" alt="Screenshot 2024-06-21 at 16 57 53" src="https://github.com/small-hack/argocd-apps/assets/2389292/52d2cc0b-1dd5-4859-8b7e-a44a4da076fe">

We pass in values to helm chart to:

- use 2 ingress replicas, for increasing availability during high traffic times
- ensure we get the real IP in the logs, and not the cluster network IPs using:
  - `controller.config.enable-reali-ip=true`
  - `controller.config.use-forwarded-headers=true`
  - `controller.service.externalTrafficPolicy='Local'`
- use `TZ` env var to use your own time zone via the `controller.extraEnvs` parameter
- allow snippet annotations in individual ingress reosurces using `controller.allowSnippetAnnotations=true`
- enable metrics via a serviceMonitor via `controller.metrics.serviceMonitor.enabled=true`
- enabled ModSecurity as a WAF (Web Application Firewall). Check out this [blog post](https://systemweakness.com/nginx-ingress-waf-with-modsecurity-from-zero-to-hero-fa284cb6f54a) for some pointers. From that post:


## ModSecurity

> And you can further tweak the configuration at the Ingress level, even fully disable it, using the nginx.ingress.kubernetes.io/modsecurity-snippet annotation. For example, to disable the WAF in a specific Ingress:

```yaml
nginx.ingress.kubernetes.io/modsecurity-snippet: |
  SecRuleEngine Off
```

All ModSecurity rule exception files are kept in the [modsecurity_configmap/modsecurity_exception_files](./modsecurity_configmap/modsecurity_exception_files) directory and are deployed via a simple helm chart. They live in a special directory so you can still easily use syntax highlighting to read them.

Since ModSecurity might not keep going (because F5/Nginx no longer support it), it's important to keep note of [Coraza SecLang engine](https://owasp.org/blog/2021/12/22/announcing-coraza).

## Grafana Dashboards

We also utilize a few dashboards via Grafana to get some high level overview of what's going on. You can view these dashboards in the [prometheus/dashbaords](../prometheus/dashboards) directory, but here's a sample:

- [Ingress Nginx Dashboard](../prometheus/dashboards/ingress-nginx-dashboard-configmap.yaml)
- [ModSecurity (WAF - Web App Firewall)](../prometheus/dashboards/modsecurity-dashboard-configmap.yaml)
