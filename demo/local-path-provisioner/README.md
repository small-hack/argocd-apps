# Local Path Provisioner

Custom ConfigMap and StorageClasses to add our storage defaults for nodes

Storage Classes:

- local-path (always /var/lib/rancher/k3s/storage)
- fast-raid (always /mnt/raid1)
- slow-raid (always /mnt/raid0)

Performance Charactaristics:

## Host: Bradley

Fast-Raid: 
- 2x Crucial MX500 1TB SSD
- RAID1
<img width="581" alt="Screenshot 2024-10-20 at 09 33 06" src="https://github.com/user-attachments/assets/cebcd365-4204-46f4-8987-2bfbca4b1541">

Slow-Raid: 
- 3x Seagate HDD 3.5" 2TB ST2000DM008 Barracuda 
- RAID5
<img width="581" alt="Screenshot 2024-10-20 at 09 29 47" src="https://github.com/user-attachments/assets/32e4633b-fca0-4ac7-8fe8-22f64c899d31">

## Host: Node0
Fast-raid: 
- 2x Crucial P3 Plus 4TB 
- RAID1
