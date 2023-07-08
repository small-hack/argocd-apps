# Oauth2 Proxy ArgoCD template

This argocd app template installs external secrets (using the ExternalSecret CRD from the External Secrets Operator) from another private repo in sync wave 1.

Then, in sync wave 2, it installs the oauth2-proxy helm chart from this repo here:
[oauth2-proxy:/manifests/helm/oauth2-proxy](https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy)
