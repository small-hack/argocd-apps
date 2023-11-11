# Mastodon Argo CD Application(Set)s Templates
[Mastodon](https://joinmastodon.org/) is social networking that's not for sale.

NOTE: This chart is still now working due to [#20901](https://github.com/bitnami/charts/pull/20901) not being merged, and the issues [#20904](https://github.com/bitnami/charts/issues/20904) and [#20902](https://github.com/bitnami/charts/issues/20902). After those are fixed, we'll take another stab at making the bitnami chart work.

We create in the manifests and helm chart in this sync wave order:
- All External Secrets
- postgresql, redis, elasticsearch
- Mastodon Web Appset

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
