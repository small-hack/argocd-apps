# NextCloud k8s Homelab
A NextCloud k8s repo for those who want to get started quickly with nextcloud on k3s the way I use it :) This project uses the official [nextcloud helm chart](https://github.com/nextcloud/helm/tree/master/charts/nextcloud).

This uses nextcloud helm chart version 3.5.15, and it launches nextcloud version 27.0.0-fpm

### Why are we here?
Because I'm a Systems Engineer (with a speciality in DevOps and Kubernetes) by trade and so what started as a homelab project quickly grew into my actual daily driver, and to work well as a Google/Microsoft/Apple/Samsung cloud replacement, it needed to be highly available, failure tolerant, and hopefully also secure *enough*, oh, and I wanted it all open source.

*We should be able to be transparent about our infrastructure without compromising security.*

In my day job, I work mostly with cloud technologies and, although I got my start in datacenters with metal and k8s runs on metal, I hadn't really spent any time with k8s locally on metal. My experience with k8s was always on AWS, GCP, or Azure. What happens if I try to take back my data on the cheap though? Apparently a huge speed increase and you get plugged into a really cool community of all sorts of FOSS apps. Win win.

Finally, Why do you want to use this instead of just the helm chart directly? This is going to be helping you setup all the little stuff you need, that nextcloud doesn't really have a direct tutorial for at this time, and that's worth something :)

# Tech Stack

NextCloud would be running ontop of the following
*(Further Below we teach you how to create all of this 💙)*

|           app/tool          |            what is it?           | Description                                                       |
|:---------------------------:|:--------------------------------:|:------------------------------------------------------------------|
|           [Debian]          |                OS                | Debian seems to be the most (easy) FOSS aligned Linux Distro      |
|         [Kuberentes]        | Container Orchestration Platform | Scale docker containers/more failure tolerance via [smol-k8s-lab] |
| [External Secrets Operator] |        Secrets Management        | This allows us to keep secrets in Bitwarden                       |
|            [k8up]           |              Backups             | Use restic to backup k8s persistent volumes to Backblaze B2       |

## Argo CD Nextcloud app of apps

Here's a quick peak at what we're deploying with Argo CD.
- **External Secrets** are the actual secrets populated from the external secrets store. This includes things like the admin password.
- **Persistence** are the two persistent volumes needed to persist nextcloud data. This includes the postgresql database as well as the actual files we're storing in nextcloud
- **K8up B2 Backups** are the cronjobs needed for putting nextcloud into maintanence mode, as well as custom resource for backups, using Restic.
- **Nextcloud WebApp** is the actual nextcloud webapp deployed using Nginx. We're also using the bundled Bitnami Postgresql helm chart.

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
   you can do a `kubectl apply -f backup.yaml` with [backup.yaml](manifests/k8up_restores/testing_tools/)

4. Take nextcloud out of maintanence mode:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --off"
   ```

### Restoring from backups
In the case of restores, please refer to the doc, [`manifests/restores/README.md`](./manifests/restores/README.md).

## Argo App

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
    repoURL: 'https://github.com/small-hack/argocd.git'
    targetRevision: main
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
    syncOptions:
      - CreateNamespace=true
```
---

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
[k8up]: https://k8up.io/k8up/2.5/index.html
