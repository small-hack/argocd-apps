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

We've also included a very basic restore job you can run in this directory to get started. Below are the values that you must change before you can run this restore job:

This must be changed to YOUR S3 endpoint and home assistant backup bucket:
```yaml
value: s3:my.s3.endpoint/my-home-assistant-bucket
```

Replace the word TIMESTAMP with an actual timestamp:
```yaml
name: home-assistant-restic-restore-TIMESTAMP
```

Replace the snapshot ID "latest" with the ID of the snapshot you actually want to use:
```yaml
 - name: SNAPSHOT_ID
   value: latest
```

If you're NOT using affinity and tolerations remove these two sections, otherwise, change the keys, values, operators, and effect to match your own needs:
```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: home-assistant
                operator: In
                values:
                - true
      tolerations:
        - effect: NoSchedule
          key: home-assistant
          operator: Equal
          value: true
```
