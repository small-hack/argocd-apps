---
# Dynamic Persistent volume claim for postgresql specifically to persist
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: nextcloud
  name: nextcloud-postgresql
  annotations:
    k8up.io/backupcommand: sh -c 'PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean'
    k8up.io/file-extension: .sql
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
