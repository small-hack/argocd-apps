examples for additional scrape configs:
```yaml
- job_name: "nginx-ingress"
  static_configs:
  - targets: ["ingress-nginx-controller-metrics.ingress.svc.cluster.local:10254"] 
- job_name: "opnsense"
  static_configs:
  - targets: ["yourddnsdomain.tld:9100"]
```
