# External Secrets Operator

The [External Secrets Operator](https://external-secrets.io/latest/) (ESO) is a Kubernetes operator that integrates external secret management systems like AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault, IBM Cloud Secrets Manager, and many more. The operator reads information from external APIs and automatically injects the values into a Kubernetes Secret.

This Argo CD app of apps deploys both ESO and a [provider](./providers) of your choice, with [Bitwarden ESO Provider](https://github.com/small-hack/bitwarden-eso-provider/) being the first option we support, so that you can use Bitwarden as your remote secret store.

<img src="./screenshots/eso.png">
<img src="./screenshots/bweso.png">

## Sync waves
1. ESO
2. ESO provider (Bitwarden) - depends on ESO

## Notes
If you'd like to deploy *only* the Bitwarden ESO Provider, please see [./providers/bitwarden/bitwarden_argocd_app.yaml](./providers/bitwarden/bitwarden_argocd_app.yaml).
