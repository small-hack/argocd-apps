# Argo CD GoToSocial App of Apps

This directory deploys a [GoToSocial] Argo CD App of Apps.

## Sync Waves

In the [`./app_of_apps`](./app_of_apps) directory we create the manifests and helm chart in this sync wave order:

1. all required PVCs, and ExternalSecrets
2. SeaweedFS file system and s3 endpoint with two buckets, one for Postgres backups and one for GoToSocial media
3. Postgresql Cluster
4. GoToSocial helm app

[GoToSocial]: https://docs.gotosocial.org/en/latest/
