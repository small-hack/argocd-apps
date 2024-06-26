# home-assistance-persistence-chart

![Version: 1.2.0](https://img.shields.io/badge/Version-1.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for deploying a home assistant pvc on Kubernetes including backups using k8up

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| k8up.affinity | object | `{"key":"","value":""}` | for setting affinity to a specific node by matchExpressions |
| k8up.backup_name | string | `"home-assistant-nightly"` |  |
| k8up.backup_type | string | `"s3"` | can be set to 's3' or 'local' |
| k8up.local.mountPath | string | `""` |  |
| k8up.podSecurityContext | object | `{"runAsUser":0}` | user to run the backups as |
| k8up.prometheus_url | string | `""` | url to push to for prometheus gateway |
| k8up.repoPasswordSecretRef | object | `{"key":"","name":""}` | secret for your restic repo |
| k8up.repoPasswordSecretRef.key | string | `""` | key in secret to use for repo password |
| k8up.repoPasswordSecretRef.name | string | `""` | name of the secret to use |
| k8up.s3.accessKeyIDSecretRef.key | string | `""` | key in the secret to use for access key id |
| k8up.s3.accessKeyIDSecretRef.name | string | `""` | name of the secret to use |
| k8up.s3.accessKeyIDSecretRef.optional | bool | `false` |  |
| k8up.s3.bucket | string | `""` | s3 bucket to backup to |
| k8up.s3.endpoint | string | `""` | s3 endpoint to backup to |
| k8up.s3.secretAccessKeySecretRef.key | string | `""` | key in the secret to use for secret access key |
| k8up.s3.secretAccessKeySecretRef.name | string | `""` | name of the secret to use |
| k8up.s3.secretAccessKeySecretRef.optional | bool | `false` |  |
| k8up.schedules | object | `{"backup":"","check":"","prune":""}` | schedules for backups, checks, and prunes |
| k8up.securityContext | object | `{"runAsUser":0}` | set the pod security context for the backup job |
| k8up.tolerations | object | `{"effect":"","key":"","operator":"","value":""}` | for setting tolerations of node taints |
| pvc_capacity | string | `"10Gi"` |  |
| pvc_storageClassName | string | `"local-path"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
