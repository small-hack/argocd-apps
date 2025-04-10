# Nextcloud Argo CD App of Apps

A Nextcloud k8s Argo CD "App of apps" for those who want to get started quickly with Nextcloud on k3s the way we use it :) This project uses the official [nextcloud helm chart](https://github.com/nextcloud/helm/tree/main/charts/nextcloud). See the current version in [nextcloud_argocd_appset.yaml](./app_of_apps/nextcloud_argocd_appset.yaml).

<img width="942" alt="screenshot of nextcloud Argo CD app of apps including nextcloud-appset, nextcloud-external-secrets-appset, nextcloud-install-apps-appset, nextcloud-maintenance-cron-appset, nextcloud-postgres-app-set, nextcloud-pvc-appset, nextcloud-s3-provider-app-set, and nextcloud-s3-pvc-app-set." src="https://github.com/user-attachments/assets/d8f225a1-4c5c-4bb3-8653-11f680e6a918" />

<details>
  <summary>More Nextcloud Argo CD App screenshots</summary>

   ### Helm chart app view
   <img width="900" alt="nextcloud-web-app" src="https://github.com/small-hack/argocd-apps/assets/2389292/9a9827d9-240b-471b-bce4-9c0c403e051f">

   ### Networking view
   <img width="1392" alt="nextcloud-networking" src="https://github.com/small-hack/argocd-apps/assets/2389292/0907707b-cbf0-4767-8a0d-29920a43e112">

</details>

# Tech Stack

NextCloud would be running ontop of Kubernetes (we use k3s) and using the following additional k8s apps:

|       app/tool              |    what is it?       | Description                             |
|:----------------------------|:---------------------|:------------------------------------------------------------|
| [Ingress Nginx controller]  |  Ingress controller  | for routing external traffic to nextcloud                   |
| [External Secrets Operator] |  Secrets Management  | This allows us to keep secrets in Bitwarden                 |
| [k8up]                      |  Backups             | Use restic to backup k8s persistent volumes to Backblaze B2 |

(If you need a local cluster on linux, checkout [smol-k8s-lab] to try out both KIND and k3s)

## Argo CD Nextcloud app of apps

Here's a quick peak at what we're deploying with Argo CD. We support deploying with or without node affinity + tolerations. The default behavior is to not include tolerations/affinity settings in the `app_of_apps` directory, but you are also free to use the `app_of_apps_with_tolerations` directory.

#### Sync wave 1

- **External Secrets** are the actual secrets populated from the external secrets store. This includes things like the admin password.
- **Persistence** are the two persistent volumes needed to persist nextcloud data. This includes the postgresql database as well as the actual files we're storing in nextcloud

#### Sync wave 2

- **Cloud native postgresql cluster** check deploys the PostgreSQL with automatic minor and patch version updates.

#### Sync wave 3

- **Nextcloud App** is the actual helm chart deployment of Nextcloud.
The Nextcloud App also includes a metrics pod, a [Collabora Online] deployment, and a Redis (soon to be [Valkey]) cluster.

#### Sync wave 4

- **K8up B2 Backups** are the cronjobs needed for putting nextcloud into maintanence mode, as well as custom resource for backups, using Restic.


## Quick start (with a k8s cluster already running Argo CD)

You should be able to just set argo to use this repo. There's an example template, `nextcloud_argocd_template.yaml`, for you to get started :) You can run this from the cli:

```bash
argocd app create nextcloud -f nextcloud_argocd_template.yaml
```

## Tips


## Login with Zitadel button not showing up at /login page

This sometimes happens when the argocd postSync hook job for installing apps doesn't run or runs too early. You can just hit sync on the main nextcloud Argo CD app called `nextcloud` and it will rerun the job and install the OIDC login nextcloud app.


## OCC
`occ` is the Nextcloud admin CLI. It can only be run on the system running Nextcloud, so in this case that would the pod in the deployment that gets deployed via the helm chart that our Argo CD ApplicationSet .

Check out the Nextcloud `occ` [docs](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html#scan) for more info.


### Backups
Make sure that you follow this process for backups:

1. Run command to sync the files:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ files:scan --all"
   ```

2. Put nextcloud into maintenance mode:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --on"
   ```

3. Run the backup:
   You can run `kubectl apply -f root_backup.yaml` with [root_backup.yaml](./manifests/k8up_backups/root_backup.yaml)

4. Take nextcloud out of maintenance mode:
   ```bash
   kubectl exec $NEXTCLOUD_POD -- su -s /bin/bash www-data -c "php occ maintenance:mode --off"
   ```

#### Manual backups

Just in case you need to do a manual PostgreSQL database backup:
```bash
PGDATABASE="$POSTGRES_DB" PGUSER="$POSTGRES_USER" PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean
```

### Restoring from backups

In the case of restores, please refer to the doc, [`manifests/restores/README.md`](./manifests/k8s_restores/README.md).

You may need to drop a table or two, requiring a `psql` shell and credentials. Connect to the PostgreSQL pod and run:

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
    namespace: nextcloud
    server: 'https://kubernetes.default.svc'
  source:
    path: nextcloud/app_of_apps/
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

# Known issues and Tips

## Video Thumbnails

By default videos won't get thumbnails.

Requires installing `smbclient` and `ffmpeg` into the web-app container, then edit a file to trigger the thumbnail generation, be patient though it takes a minute or so.

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

## OIDC SSO via Zitadel
We found the best luck using the [OpenID Connect Login app](https://github.com/pulsejet/nextcloud-oidc-login).

You can install it with the following occ command via your nextcloud pod:
```bash
kubectl exec -n nextcloud $YOUR_NEXTCLOUD_POD -c nextcloud -- su -s /bin/sh www-data -c "php occ app:install oidc_login"
```

On the zitadel side, setup a code type application with basic auth as you normally would, but set the redirect URL to be:
`yournextclouddomain.com/apps/oidc_login/oidc`

![nexcloud_oidc zitadel app screenshot showing response type code, application type web, auth method basic, grant types authorization code, and refresh token unchecked](https://github.com/small-hack/argocd-apps/assets/2389292/ed53cfb3-be71-4a35-ab21-57cf178bd76e)

![nextcloud_oidc zitadel app redirect_urls screenshot showing redirect settings with a redirect URI called https://yournextclouddomain.com/apps/oidc_login/oidc and a post logout uri showing https://yournextclouddomain.com](https://github.com/small-hack/argocd-apps/assets/2389292/6b8a4ed7-665f-481c-9299-16e0333a4987)

Since Nextcloud can technically take any string type config.php variable from an env var, you can use environment variables to pass in secret info such as the Zitadel endpoint, client ID, and client secret. Here's examples of how we do this via the helm chart from an existing Kubernetes Secret:

```yaml
nextcloud:
  extraEnv:
    - name: "NC_oidc_login_provider_url"
      valueFrom:
        secretKeyRef:
          name: nextcloud-oidc-credentials
          key: issuer

    - name: "NC_oidc_login_client_id"
      valueFrom:
        secretKeyRef:
          name: nextcloud-oidc-credentials
          key: client_id

    - name: "NC_oidc_login_client_secret"
      valueFrom:
        secretKeyRef:
          name: nextcloud-oidc-credentials
          key: client_secret
```

The above variables are from a Kubernetes Secret called `nextcloud-oidc-credentials` with keys called `issuer`, `client_id`, and `client_secret`.

Here's the PHP config file we dropped into the Nextcloud config directory via the helm chart since it doesn't contain any secret info:

```php
<?php
$CONFIG = array (
  // Some Nextcloud options that might make sense here
  'allow_user_to_change_display_name' => true,
  'lost_password_link' => 'disabled',

  // Automatically redirect the login page to the provider
  'oidc_login_auto_redirect' => false,

  // Redirect to this page after logging out the user
  // we are using gotemplating in the Argo CD ApplicationSet for this one,
  // but you could easily fill in your nextcloud hostname in plain text here
  'oidc_login_logout_url' => '{{ .nextcloud_hostname }}',

  // If set to true the user will be redirected to the
  // logout endpoint of the OIDC provider after logout
  'oidc_login_end_session_redirect' => false,

  // Login button text
  'oidc_login_button_text' => 'Log in with ZITADEL',

  // Hide the NextCloud password change form.
  'oidc_login_hide_password_form' => false,

  // Use ID Token instead of UserInfo
  'oidc_login_use_id_token' => false,

  // Attribute map for OIDC response.
  // NOTE: the is_admin key uses the nextcloud_admins group membership
  //       to determine if the user should be added to the admin group
  'oidc_login_attributes' => array (
      'id' => 'preferred_username',
      'name' => 'name',
      'mail' => 'email',
      'login_filter' => 'groups',
      'photoURL' => 'picture',
      'is_admin' => 'groups_nextcloud_admins',
  ),

  // Allow only users in configured value(s) to access Nextcloud. In this instance,
  // we only allow users that have either the nextcloud_admins or nextcloud_users roles.
  // all other users are denied
  'oidc_login_filter_allowed_values' => array('nextcloud_admins', 'nextcloud_users'),

  // Set OpenID Connect scope
  'oidc_login_scope' => 'openid profile email',

  // Run in LDAP proxy mode
  'oidc_login_proxy_ldap' => false,

  // Disable creation of users new to Nextcloud from OIDC login
  // if a user is known to the IdP but not (yet) known to Nextcloud.
  'oidc_login_disable_registration' => false,

  // Fallback to direct login if login from OIDC fails
  // Note that no error message will be displayed if enabled
  'oidc_login_redir_fallback' => false,

  // If you get your groups from the oidc_login_attributes, you might want
  // to create them if they are not already existing, Default is `false`.
  'oidc_create_groups' => false,

  // Enable use of WebDAV via OIDC bearer token.
  'oidc_login_webdav_enabled' => false,

  // Enable authentication with user/password for DAV clients that do not
  // support token authentication (e.g. DAVx⁵)
  'oidc_login_password_authentication' => true,

  // The time in seconds used to cache public keys from provider.
  // The default value is 1 day.
  'oidc_login_public_key_caching_time' => 86400,

  // The time in seconds used to cache the OIDC well-known configuration from the provider.
  // The default value is 1 day.
  'oidc_login_well_known_caching_time' => 86400,

  // If true, nextcloud will download user avatars on login.
  // This may lead to security issues as the server does not control
  // which URLs will be requested. Use with care.
  'oidc_login_update_avatar' => false,

  // Code challenge method for PKCE flow.
  'oidc_login_code_challenge_method' => 'S256',
  );
```

## More info on collabora online

The helm chart is here: https://github.com/CollaboraOnline/online/tree/master/kubernetes/helm/collabora-online

Here's the docs: https://sdk.collaboraonline.com/docs/installation/Kubernetes.html

Here's an exmaple helm chart config:
https://gitlab.opencode.de/bmi/opendesk/deployment/opendesk/-/blob/e4d9106c457e018922dcc730df0570d41f3ec2aa/helmfile/apps/collabora/values.yaml.gotmpl

<!-- link references -->
[Collabora Online]: https://sdk.collaboraonline.com/docs/installation/Kubernetes.html
[Debian]: https://www.debian.org/
[External Secrets Operator]: https://external-secrets.io/v0.9.0/examples/bitwarden/
[Ingress Nginx controller]: https://kubernetes.github.io/ingress-nginx/
[k8up]: https://k8up.io
[Kuberentes]: https://kubernetes.io/
[smol-k8s-lab]: https://github.com/small-hack/smol-k8s-lab
[Valkey]: https://valkey.io/
