# Argo CD ApplicationSet for Harbor

This ApplicationSet deploys [Harbor](https://goharbor.io/), an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted. Harbor, a CNCF Graduated project, delivers compliance, performance, and interoperability to help you consistently and securely manage artifacts across cloud native compute platforms like Kubernetes and Docker.

We deploy this helm chart, [https://github.com/goharbor/harbor-helm](https://github.com/goharbor/harbor-helm/tree/main).

## Sync Waves

1. External Secrets, Persistent Volumes
2. PostgreSQL Cluster, Valkey
3. Harbor helm chart
