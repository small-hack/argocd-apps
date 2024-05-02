This app is already backed up on a schedule, however, you can also trigger a manual backup through the TUI.

We've included an example `.sample-restic-env` that you can use to get started filling out the correct info for exporting your environment variables.

```bash
# copy the sample file, and then use vi, vim, nvim, or nano to edit
# the file with your s3 credentials and restic password command
cp .sample-restic-env .restic-env
```

You can also check your backups with

```bash
source .restic-env
restic snapshots
```
