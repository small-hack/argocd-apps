# quick notes on certs
if you're doing this on a home machine and using a fancy setup with wireguard and haproxy:

Be sure both are up before attempting to use certs

## quick example certificate resource

This should be automatically deployed by the values.yaml in the helm directory
of this repo. But this is an example just in case

```yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nextcloud
  namespace: nextcloud
spec:
  isCA: true
  secretName: nextcloud-tls
  dnsNames:
    - YOURDOMAIN.TLD
  issuerRef:
    name: letsencrypt-staging
    kind: Issuer
    group: cert-manager.io
```
