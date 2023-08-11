```yaml
---
# b2 bucket key/key ID for k8up, backups for persistent volumes using restic
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: b2-creds-mastodon
  namespace: mastodon
spec:
  target:
    name: b2-creds-mastodon
    deletionPolicy: Delete
    template:
      type: Opaque
      data:
        AWS_ACCESS_KEY_ID: |-
          {{ .keyId }}
        AWS_SECRET_ACCESS_KEY: |-
          {{ .applicationKey }}
  data:
    - secretKey: keyId
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: mastodon-b2-credentials
        property: username

    - secretKey: applicationKey
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: mastodon-b2-credentials
        property: password
```
