how to restore if using seperate pvc for datadir:

```yaml
---
apiVersion: k8up.io/v1
kind: Restore
metadata:
  name: nextcloud-datadir
  namespace: nextcloud
spec:
  podSecurityContext:
    runAsUser: 33
  # This is optional to specify a specific snapshot to restore from
  # snapshot: 8549dhs
  restoreMethod:
    folder:
      claimName: nextcloud-datadir
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
