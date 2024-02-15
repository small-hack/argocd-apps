---
# Dynamic Persistent volume claim for postgresql specifically to persist
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: home-assistant
  name: home-assistant
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 15Gi
