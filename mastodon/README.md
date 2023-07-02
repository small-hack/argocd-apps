# Mastodon ArgoCD Template
Social networking that's not for sale:
https://joinmastodon.org/

## Deploy postgres DB

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keycloak-postgres
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: '2'
spec:
  destination:
    namespace: mastodon
    server: 'https://kubernetes.default.svc'
  source:
    path: mastodon/postgres/
    repoURL: 'https://github.com/small-hack/argocd.git'
  project: default
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
```

## Connect to postgres with worker container

Deploy the following container and attach to the shell, then install `postgresql-client`.

  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: postgres-client
    namespace: keycloak
  spec:
    containers:
    - name: postgres-client
      image: ubuntu:latest
      command:
        - sleep
        - "3600"
      imagePullPolicy: IfNotPresent
    restartPolicy: Always
  ```

connection string format:
  ```bash
  psql postgresql://mastodon:<password>@mastodon-postgresql.keycloak.svc.cluster.local:5432/mastodon
  ```


