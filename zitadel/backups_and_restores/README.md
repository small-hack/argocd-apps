# Backing up and Restoring Zitadel

This Argo CD App of Apps for zitadel contains a consistent backup of the Postgresql database via barman to a local s3 endpoint, as well as a scheduled backup once a day to a remote s3 compliant endpoint.

The scheduled backup is created in the app of apps via [s3_pvc_appset.yaml](../app_of_apps/s3_pvc_appset.yaml) using [k8up](https://k8up.io) which wraps [restic](https://restic.net/), which uses the local [s3_persistence_and_backups helm chart](../../s3_persistence_and_backups). That helm chart includes [this scheduled backup template](../../s3_persistence_and_backups/templates/scheduled_backups.yaml).


## Checking your backups

To check on your backups, start by copying the `.sample-restic-env`:

```bash
cp .sample-restic-env .env
```

Then change the values for the endpoint, bucket, access id, and secret key to your own. Be sure to also create a file called `.zitadel-restic-password` with your restic password (also make sure the perms are 600 and ownership is set to your user). Then, you can check on your backups with:

```bash
source .env
restic snapshots
```

## Restoring a PostgreSQL Backup

Checkout the [postgres backup docs](../../postgres/backups/README.md) for more info.
