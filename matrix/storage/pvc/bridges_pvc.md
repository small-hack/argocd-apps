```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: matrix
  name: matrix-bridges
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Mi
```
