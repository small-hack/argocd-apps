# Ingress Argo CD App of Apps

<img src="./screenshots/ingress-nginx-namespace.png">
<img src="./screenshots/ingress-nginx.png">

To apply this, select "Create New App" in your Argo CD interface and select "Edit as YAML", then paste the following in:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ingress-apps
  namespace: argocd
spec:
  project: ingress
  source:
    repoURL: 'https://github.com/small-hack/argocd-apps'
    targetRevision: main
    path: ingress/
  destination:
    server: "https://kubernetes.default.svc"
    namespace: ingress
  syncPolicy:
    syncOptions:
      - Replace=true
    automated:
      prune: true
      selfHeal: true
```

## Nginx Mod Security + Metrics

- Update the Nginx Config Map:

    ```sh
    kubectl edit configmap -n ingress-nginx ingress-nginx-controller
    ```

- Example snippets:

    ```yaml
    apiVersion: v1
    data:
      # ...
      allow-snippet-annotations: "true"
      enable-modsecurity: "true"
      enable-owasp-modsecurity-crs: "true"
      load-balance: ewma
      modsecurity-snippet: |-
        SecRuleEngine DetectionOnly
        SecAuditEngine RelevantOnly
        SecStatusEngine On
        SecRequestBodyAccess On
        SecAuditLog /dev/stdout
        SecAuditLogFormat JSON
        SecRequestBodyLimitAction ProcessPartial
        SecResponseBodyLimitAction ProcessPartial
        SecRequestBodyLimit 13107200
        SecRequestBodyNoFilesLimit 131072
        SecResponseBodyLimit 524288
        SecPcreMatchLimit 250000
        SecPcreMatchLimitRecursion 250000
        SecCollectionTimeout 600
        SecRuleRemoveById 920420
        SecRuleRemoveById 920350
      # ...
    ```

- Enable metrics and MOD Security

    ```bash
    helm upgrade ingress-nginx ingress-nginx \ 
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.metrics.enabled=true \
    --set-string controller.podAnnotations."prometheus\.io/scrape"="true" \
    --set-string controller.podAnnotations."prometheus\.io/port"="10254"
    ```
