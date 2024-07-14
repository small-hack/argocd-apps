# Local Path Provisioner

Custom ConfigMap and StorageClasses to add our storage defaults for nodes

Storage Classes:

- local-path (always /var/lib/rancher/k3s/storage)
- fast-raid (always /mnt/raid1)
- slow-raid (always /mnt/raid0)
