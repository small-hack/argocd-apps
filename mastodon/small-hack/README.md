# Mastodon ArgoCD Template
Mastodon is social networking that's not for sale: https://joinmastodon.org/

In the `./mastodon_app_of_apps/` directory we create the manifests and helm chart in this sync wave order:
- all required PVCs, and Secrets (secrets are external secrets in a private repo)
- Postgresql stateful set
- Mastodon web app (including elastic search and redis)

You can optionally also use [directory recursion](https://argo-cd.readthedocs.io/en/stable/user-guide/directory/#enabling-recursive-resource-detection) with your Mastodon app of apps, to use the MinIO operator to create an isolated tenant for S3 storage.

This helm chart was retired for a bit till it became clear that there was no other immediate alternative, so now it's back 🤷

## Creating Mastodon Secrets
This template relies on you already having created secrets using the below method and then creating those as k8s secrets.

```bash
SECRET_KEY_BASE=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)
OTP_SECRET=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)

docker run --rm -e "OTP_SECRET=$OTP_SECRET" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -it tootsuite/mastodon:latest bin/rake mastodon:webpush:generate_vapid_key 
```

## Connect to PostgreSQL with worker container
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

## `relation "accounts" does not exist` error in the logs:

You may need to generate a DB migrate job from a `helm template` command as per suggestion in [issue#18](https://github.com/mastodon/chart/issues/18#issuecomment-1369804876)

## Unsupported value for canned acl 'public-read'
redacted exact paths for security
```bash
[paperclip] saving accounts/avatars/../original/5eb5eab423667b38.png

method=PUT path=/settings/profile format=html controller=Settings::ProfilesController action=update status=500 error='Aws::S3::Errors::InvalidArgument: Unsupported value for canned acl 'public-read'' duration=368.45 view=0.00 db=1.15

Aws::S3::Errors::InvalidArgument (Unsupported value for canned acl 'public-read'):
```

pretty sure this was due to the bucket not having public read :)

## admin commands

To get a shell into the main mastodon container:
```bash
kubectl exec deploy/mastodon-web-app -- /bin/bash
```

`tootctl` commands can then be run as normal. Checkout the [mastodon docs](https://docs.joinmastodon.org/admin/tootctl/) for more!
