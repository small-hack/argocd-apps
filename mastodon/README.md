# Mastodon ArgoCD Template
Mastodon is social networking that's not for sale: https://joinmastodon.org/

Here we rangle the helm chart into ArgoCD :)

## Creating Mastodon Secrets

```bash
SECRET_KEY_BASE=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)
OTP_SECRET=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)

docker run --rm -e "OTP_SECRET=$OTP_SECRET" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -it tootsuite/mastodon:latest bin/rake mastodon:webpush:generate_vapid_key 
```

## Deploy postgres DB

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mastodon-postgres-app
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

Deploy the following container and attach to the shell, then run:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug-container
  namespace: mastodon
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

Run the following to install utilities

```bash
apt-get update && apt-get install -y postgresql-client dnsutils curl
```

connection string format:

```bash
psql -U mastodon \
  -d mastodon_production \
  -h mastodon-postgres-postgresql.mastodon.svc.cluster.local \
  -p 5432
```
