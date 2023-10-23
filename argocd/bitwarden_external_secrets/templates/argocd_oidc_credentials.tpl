---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: argocd-oidc-credentials
spec:
  target:
    # Name for the secret to be created on the cluster
    name: argocd-oidc-credentials
    deletionPolicy: Delete
    template:
      type: Opaque
      metadata:
        labels:
          app.kubernetes.io/part-of: "argocd"
      data:
        oidc.clientID: |-
          {{ `{{ .username }}` }}
        oidc.clientSecret: |-
          {{ `{{ .password }}` }}

  data:
    # oidc client ID
    - secretKey: username
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.bitwardenItemID }}
        property: username

    # oidc client secret
    - secretKey: password
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.bitwardenItemID }}
        property: password
