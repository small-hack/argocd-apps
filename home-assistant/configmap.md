apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
  name: home-assistant
  namespace: home-assistant
data:
  configuration.yaml: |
    http:
      trusted_proxies:
      - 10.0.0.0/8
      use_x_forwarded_for: true
