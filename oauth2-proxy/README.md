# Oauth2 Proxy Argo CD template

This Argo CD app template will install external secrets (using the ExternalSecret CRD from the External Secrets Operator) from another private repo in sync wave 1.

Then, in sync wave 2, it installs the oauth2-proxy helm chart from this repo here:
[oauth2-proxy:/manifests/helm/oauth2-proxy](https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy)

Currently trying to get it working with the Keycloak provider, which is in alpha support at time of writing. Out of the box, the helm chart already supports Google as the primary provider.
