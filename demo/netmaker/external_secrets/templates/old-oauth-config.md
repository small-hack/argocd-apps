{{- if eq .Values.provider "bitwarden" }}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: netmaker-oauth-config
spec:
  target:
    # Name for the secret to be created on the cluster
    name: netmaker-oauth-config
    deletionPolicy: Delete
    template:
      type: Opaque
      data:
        auth_provider: |-
          {{ `{{ .auth_provider }}` }}
        serverHttpHost: |-
          {{ `{{ .serverHttpHost }}` }}
        serverBrokerEndpoint: |-
          {{ `{{ .serverBrokerEndpoint }}` }}
        CLIENT_ID: |-
          {{ `{{ .username }}` }}
        CLIENT_SECRET: |-
          {{ `{{ .password }}` }}
        authUrl: |-
          {{ `{{ .authUrl }}` }}
        tokenUrl: |-
          {{ `{{ .tokenUrl }}` }}
        userInfoUrl: |-
          {{ `{{ .userInfoUrl }}` }}
        frontendUrl: |-
          {{ `{{ .frontendUrl }}` }}
        endSessionEndpoint: |-
          {{ `{{ .endSessionEndpoint }}` }}
  data:
    - secretKey: username
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: username

    - secretKey: password
      sourceRef:
        storeRef:
          name: bitwarden-login
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: password

    - secretKey: auth_provider
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: auth_provider
        
    - secretKey: authUrl
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: authUrl

    - secretKey: tokenUrl
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: tokenUrl

    - secretKey: userInfoUrl
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: userInfoUrl

    - secretKey: frontendUrl
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: frontendUrl

    - secretKey: serverHttpHost
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: serverHttpHost
        
    - secretKey: serverBrokerEndpoint
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: serverBrokerEndpoint

    - secretKey: endSessionEndpoint
      sourceRef:
        storeRef:
          name: bitwarden-fields
          kind: ClusterSecretStore
      remoteRef:
        key: {{ .Values.netmakerOauthConfigBitwardenID }}
        property: endSessionEndpoint
{{- end }}
