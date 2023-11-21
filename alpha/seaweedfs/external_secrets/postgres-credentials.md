```gotmpl
{{- if eq .Values.provider "bitwarden" }}
---
# secret for a seaweedfs postgres DB
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: seaweedfs-pgsql-credentials
  namespace: seaweedfs
spec:
  target:
    # Name of the kubernetes secret
    name: seaweedfs-pgsql-credentials
    deletionPolicy: Delete
    template:
      type: Opaque
      data:
        # Key-names within the kubernetes secret
        password: |-
          {{ `{{ .password }}` }}
        postgresPassword: |-
          {{ `{{ .postgresPassword }}` }}

  data:
    # `secretKey` relates to the key name defined within the kubernetes secret
    - secretKey: password
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        # key-id of the bitwarden secret
        key: {{ .Values.pgsqlCredentialsBitwardenID }}
        # property within the bitwarden secret we want
        property: password

    # `secretKey` relates to the key name defined within the kubernetes secret
    - secretKey: postgresPassword
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        # key-id of the bitwarden secret
        key: {{ .Values.pgsqlCredentialsBitwardenID }}
        # property within the bitwarden secret we want
        property: postgresPassword
{{- end }}
```
