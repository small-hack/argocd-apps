# Ghost Argo CD Application

This is an Argo CD Application to deploy [ghost](https://ghost.org/).

We're currently using the [Bitnami Ghost helm chart](https://github.com/bitnami/charts/tree/main/bitnami/ghost), but we use the official [ghost docker image](https://hub.docker.com/_/ghost/tags).

<img width="1053" alt="Screenshot of the the ghost app in the Argo CD web interface using tree view mode. You can see the ghost app branches into 4 appsets that all have their own corresponding apps, including: ghost-app-set, ghost-bitwarden-eso, ghost-mysql-app-set, and ghost-pvc-appset" src="https://github.com/user-attachments/assets/cf7db9e9-0ae6-4e04-8433-fb6cf0a0dc43" />


## Sync Waves

1. External Secrets and PVCs
2. MySQL
3. ghost docker web app
