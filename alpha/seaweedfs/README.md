# Argo CD Applications for deploying SeaweedFS

We are currently experimenting with SeaweedFS on Kubernetes.

## Sync Waves

1. persistent volumes for filer, volume server, and master server
2. SeaweedFS helm chart

## Persistence

This is to deploy a pre-existing persistent volume.

- [persistent volumes](./persistence/seaweedfs_data_pvc.yaml)

### Backups

Docs on backing up SeaweedFS.

- [Regular docs](./backups/backups.md)
- [S3 docs](./backups/s3-backups.md)

## Operator

This is the new SeaweedFS operator helm chart for using the SeaweedFS CRDs. Still in experimental phase.

