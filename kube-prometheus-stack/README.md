# Repo for deploying Prometheus stack to k8s with ArgoCD

This will deploy:

- Prometheus
- Alert Manager for prometheus
- Grafana

Ref for prometheus giant chart of charts:
https://blog.ediri.io/kube-prometheus-stack-and-argocd-23-how-to-remove-a-workaround

## Enable Nginx Ingress metrics

- Patch the Nginx Ingress controller to enable the metrics exporter 

    ```bash
    helm upgrade ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.metrics.enabled=true \
    --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
    --set-string controller.podAnnotations."prometheus\.io/port"="10254"
    ```
## Adding additional scrape targets

- Create a yaml file containing your prometheus scrape configs

  ```yaml
  - job_name: "nginx-ingress"
    static_configs:
    - targets: ["ingress-nginx-controller-metrics.ingress-nginx.svc.cluster.local:10254"]
  - job_name: "postgres"
    static_configs:
    - targets: ["postgres-postgresql-metrics.default.svc.cluster.local:9187"]
  - job_name: "nvidia-smi"
    static_configs:
    - targets: ["nvidia-dcgm-exporter.default.svc.cluster.local:9400"]
  ```
  
- Convert the file to a secret.
  
  > name of secret must match what is set in the helm values.yaml
  
  ```bash
  kubectl create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml \
      --dry-run=client -oyaml > additional-scrape-configs.yaml
  ```
