---
# Dynamic persistent volume claim for nexctcloud data (/var/www/html) to persist
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: nextcloud
  name: nextcloud-files
  annotations:
    k8up.io/backup: 'true'
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 400Gi
