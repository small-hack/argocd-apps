Untested.
```yaml
---
apiVersion: k8up.io/v1
kind: Backup
metadata:
  name: www-data-backup-nextcloud-s3
  namespace: nextcloud
spec:
  podSecurityContext:
    runAsUser: 33
  failedJobsHistoryLimit: 10
  successfulJobsHistoryLimit: 10
  backend:
    repoPasswordSecretRef:
      name: nextcloud-backups-credentials
      key: resticRepoPassword
    s3:
      endpoint: s3.eu-central-003.backblazeb2.com
      bucket: testing-ncloud-backups-september
      accessKeyIDSecretRef:
        name: nextcloud-backups-credentials
        key: applicationKeyId
      secretAccessKeySecretRef:
        name: nextcloud-backups-credentials
        key: applicationKey
