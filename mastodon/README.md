# Mastodon ArgoCD Template
Mastodon is social networking that's not for sale: https://joinmastodon.org/

Here we rangle the helm chart into ArgoCD :)

We create in the manifests and helm chart in this sync wave order:
- all required PVCs, ConfigMap, and Secrets (secrets are external secrets in a private repo)
- Postgresql stateful set
- DB migrate job as per suggestion in [issue#18](https://github.com/mastodon/chart/issues/18#issuecomment-1369804876)
- mastodon web app (including elastic search and redis)

## Creating Mastodon Secrets
This template relies on you already having created secrets using the below method and then creating those as k8s secrets.

```bash
SECRET_KEY_BASE=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)
OTP_SECRET=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)

docker run --rm -e "OTP_SECRET=$OTP_SECRET" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -it tootsuite/mastodon:latest bin/rake mastodon:webpush:generate_vapid_key 
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
  -d mastodon \
  -h mastodon-postgres.mastodon.svc.cluster.local \
  -p 5432
```
