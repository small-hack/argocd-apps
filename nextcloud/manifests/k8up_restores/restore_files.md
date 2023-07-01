how to restore:
```yaml
---
apiVersion: k8up.io/v1
kind: Restore
metadata:
  name: nextcloud-files
  namespace: nextcloud
spec:
  podSecurityContext:
    runAsUser: 33
  # This is optional to specify a specific snapshot to restore from
  # snapshot: 8549dhs
  restoreMethod:
    folder:
      claimName: nextcloud-files
  backend:
    repoPasswordSecretRef:
      name: k8up-restic-b2-repo-pw-nextcloud
      key: password
    s3:
      endpoint: s3.eu-central-003.backblazeb2.com
      bucket: k3s-nextcloud
      accessKeyIDSecretRef:
        name: k8up-b2-creds-nextcloud
        key: application-key-id
      secretAccessKeySecretRef:
        name: k8up-b2-creds-nextcloud
        key: application-key
```
