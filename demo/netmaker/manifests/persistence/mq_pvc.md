---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: netmaker
  name: netmaker-mq-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
