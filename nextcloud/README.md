# NextCloud ArgoCD App of Apps
A NextCloud k8s repo for those who want to get started quickly with nextcloud on k3s the way we use it :) This project uses the official [nextcloud helm chart](https://github.com/nextcloud/helm/tree/master/charts/nextcloud) version 3.5.15, and it uses the nextcloud:27.0.0-fpm docker image.

# Tech Stack

NextCloud would be running ontop of Kubernetes (we use k3s) and using the following additional k8s apps:

|       app/tool              |    what is it?       | Description                             |
|:----------------------------|:---------------------|:------------------------------------------------------------|
| [Ingress Nginx controller]  |  Ingress controller  | for routing external traffic to nextcloud                   |
| [External Secrets Operator] |  Secrets Management  | This allows us to keep secrets in Bitwarden                 |
| [k8up]                      |  Backups             | Use restic to backup k8s persistent volumes to Backblaze B2 |

(If you need a local cluster on linux, checkout [smol-k8s-lab] to try out both KIND and k3s)

## Argo CD Nextcloud app of apps

Here's a quick peak at what we're deploying with Argo CD.

#### Sync wave 1
- **External Secrets** are the actual secrets populated from the external secrets store. This includes things like the admin password.
- **Persistence** are the two persistent volumes needed to persist nextcloud data. This includes the postgresql database as well as the actual files we're storing in nextcloud

#### Sync wave 2
- **Nextcloud WebApp** is the actual nextcloud webapp deployed using Nginx. We're also using the bundled Bitnami Postgresql helm chart.

#### Sync wave 3
- **K8up B2 Backups** are the cronjobs needed for putting nextcloud into maintanence mode, as well as custom resource for backups, using Restic.

The Nextcloud WebApp also includes a metrics pod, postgres statefulset, and a redis cluster.

<img src='./screenshots/nextcloud_app.png' width='800'>


## Quick start (with a k8s cluster already running Argo CD)
You should be able to just set argo to use this repo. There's an example template, `nextcloud_argocd_template.yaml`, for you to get started :) You can run this from the cli:

```bash
argocd app create nextcloud -f nextcloud_argocd_template.yaml
```

## Tips
Check out the admin manual:
https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#scan

### Backups
Make sure that you follow this process for backups:

1. Run command to sync the files:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ files:scan --all"
   ```

2. Put nextcloud into maintanence mode:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --on"
   ```

3. Run the backup:
   You can run `kubectl apply -f root_backup.yaml` with [root_backup.yaml](./manifests/k8up_backups/root_backup.yaml)

4. Take nextcloud out of maintanence mode:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --off"
   ```

#### Manual backups
Just in case you need to do a manual postgresql backup:
```bash
PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean
```

### Restoring from backups
In the case of restores, please refer to the doc, [`manifests/restores/README.md`](./manifests/k8s_restores/README.md).

You may need to drop a table or two, requiring a psql shell and credentials. Connect to the postgresql pod and run:

```bash
PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" psql
```

## Argo CD Project
```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  labels:
    env: prod
  name: nextcloud
  namespace: argocd
spec:
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  description: all nextcloud apps
  destinations:
    - name: in-cluster
      namespace: nextcloud
      server: https://kubernetes.default.svc
    - name: '*'
      namespace: argocd
      server: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  orphanedResources: {}
  roles:
    - description: nextcloud admins
      name: nextcloud
      policies:
        - p, proj:nextcloud:nextcloud, applications, *, nextcloud/*, allow
  sourceRepos:
    - registry-1.docker.io
    - https://github.com/small-hack/vleermuis-external-secrets.git
    - https://nextcloud.github.io/helm
    - https://github.com/small-hack/argocd-apps.git
```

## Argo CD App

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nextcloud
spec:
  destination:
    name: ''
    namespace: nextcloud
    server: 'https://kubernetes.default.svc'
  source:
    path: nextcloud/
    repoURL: 'https://github.com/small-hack/argocd-apps.git'
    targetRevision: HEAD
  sources: []
  project: nextcloud
  syncPolicy:
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=true
```
---

# Known issues

## Video Tumbnails

By default videos won't get thumbnails. 

Requires installing smbclient and ffmpeg into the web-app container, then edit a file to trigger the thumbnail generation, be patient though it takes a minute or so.

See: https://help.nextcloud.com/t/show-thumbnails-for-videos/71251/14

## Image Recognition

You can use the [recognize](https://github.com/nextcloud/recognize) app to track faces, objects, common landmarks, and music. Recognize uses open source machine learning models that run entirely self contained on your Nextcloud instance. It does not come with models pre-downloaded though, so you may have to run:

```bash
kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ recognize:download-models"
```

## Maps

The maps app can sometimes have an issue where it won't enable. You need to delete this file:
```
/var/www/html/custom_apps/maps/appinfo/application.php
```
Then it seems to allow an update and enable via the console 🤷 See [issue#1069](https://github.com/nextcloud/maps/issues/1069).


## TODO/Bugs to fix
Still Under construction, so we're working out a few kinks.
- overall infosec overhaul and threatmodel <-- active task
- make prometheus work??? - on pause till security is under wraps
- install default apps to [directory listed here](https://github.com/nextcloud/docker/blob/8cfb0e50ef8a42ee366d1413df969ac801cac30c/24/fpm/config/apps.config.php)... :thinking: but we might be able to just have those mounted on their own volume, and that volume could be public, which would be nice

<!-- link references -->
[Debian]: https://www.debian.org/
[Kuberentes]: https://kubernetes.io/
[smol-k8s-lab]: https://github.com/small-hack/smol-k8s-lab
[External Secrets Operator]: https://external-secrets.io/v0.9.0/examples/bitwarden/
[k8up]: https://k8up.io
