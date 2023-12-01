# Community maintained MinIO Argo CD ApplicationSet

This is a Minio ApplicationSet that does not use the operator/tenant architecture helm charts.

The main difference, beyond the lack of an operator, is that the helm chart the ApplicationSet is built around is community maintained. When we found out about it, it was referred to as the "[vanilla helm chart](https://github.com/minio/charts/blob/800de17ed357580ef8db8b191d7ff90a6724fecd/README.md#a-vanilla-helm-chart-is-available-here-helm-chart-vanilla-without-the-operator)".

Here's the actual helm chart repo we're using: https://github.com/minio/minio/tree/master/helm/minio
