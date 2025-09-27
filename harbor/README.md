# Argo CD ApplicationSet for Harbor

This ApplicationSet deploys [Harbor](https://goharbor.io/), an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted. Harbor, a CNCF Graduated project, delivers compliance, performance, and interoperability to help you consistently and securely manage artifacts across cloud native compute platforms like Kubernetes and Docker.

We used to deploy this helm chart, [goharbor/harbor-helm](https://github.com/goharbor/harbor-helm/tree/main), however, after much issues with helm lookups (which are not supported by Argo CD at this time), we decided to go to with the [Bitnami Harbor Chart](https://github.com/bitnami/charts/tree/main/bitnami/harbor) - but then bitnami was bought by Broadcom and their service has been split up into paid/non-paid tiers which block access to the base docke rimages, so we are back to [goharbor/harbor-helm](https://github.com/goharbor/harbor-helm/tree/main). We may move to a community fork in the future.

## Sync Waves

1. External Secrets, Persistent Volumes
2. PostgreSQL Cluster, Valkey
3. Harbor helm chart

<img width="1168" height="583" alt="Screenshot 2025-09-27 at 17 10 22" src="https://github.com/user-attachments/assets/44f37b98-9d09-4cc0-9d66-a8282089a8f1" />

# Security issue

Valkey runs without a password untilt he following issues with the helm chart are fixed:
- https://github.com/goharbor/harbor-helm/issues/2148
- https://github.com/goharbor/harbor-helm/issues/2207
