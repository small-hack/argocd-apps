# Mastodon ArgoCD Template
Mastodon is social networking that's not for sale: https://joinmastodon.org/

Here we rangle the helm chart into ArgoCD :) We create PVCs, query a private secrets repo, setup postgres and then attempt to deploy the web app :shrug:


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
  -d mastodon_production \
  -h mastodon-postgres-postgresql.mastodon.svc.cluster.local \
  -p 5432
```
