Untested.
```yaml
---
apiVersion: k8up.io/v1
kind: Backup
metadata:
  name: www-data-backup-minio-s3
  namespace: minio
spec:
  podSecurityContext:
    runAsUser: 33
  failedJobsHistoryLimit: 10
  successfulJobsHistoryLimit: 10
  backend:
    repoPasswordSecretRef:
      name: minio-backups-credentials
      key: resticRepoPassword
    s3:
      endpoint: s3.eu-central-003.backblazeb2.com
      bucket: testing-minio-backups
      accessKeyIDSecretRef:
        name: minio-backups-credentials
        key: applicationKeyId
      secretAccessKeySecretRef:
        name: minio-backups-credentials
        key: applicationKey
