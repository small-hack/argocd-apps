# Argo CD GoToSocial App of Apps

This directory deploys a [GoToSocial] Argo CD App of Apps.
<img width="943" alt="Screenshot of the GoToSocial app of apps in the Argo CD web interface in tree view mode. It shows the main helm chart appset, the external secrets appset, the postgresql app set, the PVC appset, the S3 provider app set, and hte S3 PVC appset" src="https://github.com/user-attachments/assets/45e7eb05-9843-4534-bb04-8a48cb8cb8d3" />

## Sync Waves

In the [`./app_of_apps`](./app_of_apps) directory we create the manifests and helm chart in this sync wave order:

1. all required PVCs, and ExternalSecrets
2. SeaweedFS file system and s3 endpoint with two buckets, one for Postgres backups and one for GoToSocial media
3. Postgresql Cluster
4. GoToSocial helm app

[GoToSocial]: https://docs.gotosocial.org/en/latest/
