# Mastodon Argo CD ApplicationSet
Mastodon is social networking that's not for sale: https://joinmastodon.org/

![Screenshot of mastodon application in Argo CD's web interface. It shows tree view with a main mastodon app having the following children: mastodon-external-secrets-appset, mastodon-pvc-appset, mastodon-postgres-appset, valkey-appset, mastodon-web-app, mastodon-s3-pvc, and mastodon-seaweedfs. All apps show as healthy and successfully synced. The image is in dark mode so it used dark grey background, greyish blue tiles, and neon green pop colors.](https://github.com/user-attachments/assets/a6657495-02f0-41c9-b6e6-d6149549c7ab)

This is the networking view in Argo CD:

<img width="1278" alt="screenshot of the mastodon applicationset in Argo CD's web interface using the networking tree mode view. it shows the flow of cloud to ip address to mastodon ingress to two services mastodon-streaming and mastodon-web which each go to their respective pods. There's also additional services and pods outside of that flow. 2 elastic search services have the same elastic search pod child. and then there's an additional 3 matching elastic search service and pod pairs. finally, there is a mastodon-sidekiq-all-queues pod that is running" src="https://github.com/user-attachments/assets/463e6ac4-6404-49ad-a905-c9efe334e79f">


This Mastodon AppSet uses a fork of Mastodon called [glitch-soc](https://github.com/glitch-soc/mastodon). You can see the docker repo [small-hack/mastodon-glitch-soc-docker](https://github.com/small-hack/mastodon-glitch-soc-docker) whose image is published [here](https://hub.docker.com/repository/docker/jessebot/mastodon-glitch-soc/general).

:new: We now support setting up a [libretranslate](https://libretranslate.com/) endpoint and API key.


## Sync waves
In the [`./app_of_apps`](./app_of_apps) directory we create the manifests and helm chart in this sync wave order:
1. all required PVCs, and ExternalSecrets
2. SeaweedFS file system and s3 endpoint with two buckets, one for postgres backups and one for mastodon media
3. Postgresql Cluster
4. Mastodon web app (including elastic search and valkey)

## Creating Mastodon Secrets
This template relies on you already having created secrets. You can do that via [`smol-k8s-lab`](https://small-hack.github.io/smol-k8s-lab/k8s_apps/mastodon/) or manually.

### Creating secrets manually

For the secret key base, otp secret and vapid key:

```console
$ SECRET_KEY_BASE=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)
$ OTP_SECRET=$(docker run --rm -it tootsuite/mastodon:latest bin/rake secret)

$ docker run --rm -e "OTP_SECRET=$OTP_SECRET" \
    -e "SECRET_KEY_BASE=$SECRET_KEY_BASE" \
    -it tootsuite/mastodon:latest bin/rake mastodon:webpush:generate_vapid_key
```

For the active record encryption keys:

```console
$ docker run docker.io/tootsuite/mastodon:latest rails db:encryption:init
Add the following secret environment variables to your Mastodon environment (e.g. .env.production), ensure they are shared across all your nodes and do not change them after they are set:

ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=ig3iQLB5FAzU7500SJNdbsoncKBmrR7f
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=1laBmHjzGUJRpAbXLI1RJVmng7uZN8i1
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=10AfrwAKCgPVuzT8FuaSpSXoMGAFKIQk
```

# Troubleshooting Mastodon

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
