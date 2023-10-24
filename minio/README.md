# MinIO Operator (and optional Tenant) Argo CD Applications

We default deploy the operator (admin) console and a tenant console/api 

Operator helm chart: https://github.com/minio/operator/tree/master/helm/operator

Tenant helm chart: https://github.com/minio/operator/tree/master/helm/tenant

## Notes

### tenant API is not accessible
The easiest way to remedy this is to try accessing the user console with a letsencrypt-prod cert. The staging cert will always fail with x509 signed by unknown authority errors.
