# gotosocial-eso-bitwarden-chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for gotosocial External Secrets using the Bitwarden ESO provider on Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| adminCredentialsBitwardenID | string | `""` |  |
| gotosocialSecretsBitwardenID | string | `""` |  |
| libretranslateApiKeybitwardenID | string | `""` | existing kubernetes secret with libretranslate API secret key |
| oidcCredentialsBitwardenID | string | `""` | OIDC Credentials |
| pgsqlCredentialsBitwardenID | string | `""` |  |
| provider | string | `""` |  |
| s3AdminCredentialsBitwardenID | string | `""` | existing kubernetes secret with s3 admin credentials |
| s3BackupCredentialsBitwardenID | string | `""` | existing kubernetes secret with s3 credentials for the remote backups |
| s3GotosocialCredentialsBitwardenID | string | `""` | existing kubernetes secret with s3 gotosocial credentials |
| s3PostgresCredentialsBitwardenID | string | `""` | existing kubernetes secret with s3 postgres credentials |
| s3_provider | string | `"seaweedfs"` | if set to seaweedfs we deploy a policy secret. can also be minio |
| smtpCredentialsBitwardenID | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
