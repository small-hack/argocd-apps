```yaml
# this is just for testing locally
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: nextcloud
spec:
  selfSigned: {}
```
