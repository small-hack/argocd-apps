# Ghost Argo CD Application

This is an Argo CD Application to deploy [ghost](https://ghost.org/).

We're currently using the [small-hack Ghost helm chart](https://github.com/small-hack/ghost-helm-chart), and we use the official [ghost docker image](https://hub.docker.com/_/ghost/tags).

<img width="1040" height="388" alt="Screenshot of the the ghost app in the Argo CD web interface using tree view mode. You can see the ghost app branches into 4 appsets that all have their own corresponding apps, including: ghost-app-set, ghost-bitwarden-eso, ghost-mysql-app-set, ghost-activitypub-mysql-app-set, and ghost-pvc-appset" src="https://github.com/user-attachments/assets/dcc0f0a6-b24c-4635-b0fa-86aeec49e169" />

## Sync Waves

These are the Argo CD Sync waves for both the `app_of_apps` and `app_of_apps_with_tolerations` directories:

1. External Secrets and PVCs
2. MySQL (one for ActivityPub and one for Ghost)
3. Ghost web app (includes ActivityPub deployment as well)

## Directories

| directory                                                      | purpose                                                                                                         |
|----------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| [app_of_apps](./app_of_apps)                                   | Point your Argo CD app at this directory if you don't have any tolerations or affinity to be mindful of         |
| [app_of_apps_with_tolerations](./app_of_apps_with_tolerations) | Point your Argo CD app at this directory if you tolerations and affinitys to be mindful of                      |
| [external_secrets](./external_secrets)                         | ExternalSecrets using the bitwarden provider (used by both app_of_apps and app_of_apps_with_tolerations)        |
| [storage](./storage)                                           | Persistent Volume configuration for Ghost and MySQL (used by both app_of_apps and app_of_apps_with_tolerations) |

