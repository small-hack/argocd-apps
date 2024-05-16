# Argo CD with Argo CD Vault plugin

We're currently experimenting with making vault the primary secret store for our kubernetes clusters. To do that, we're playing with the [Argo CD Vault Plugin].

## The implementation we choose so far

We're using the [initContainer and configuration via sidecar] installation method.

We're also making use of the custom helm vault plugin listed in [argoproj-labs/argocd-vault-plugin:issues#566].

Everything else is still up in the air as we do research.

### Quick links

- [Argo CD helm chart repo server parameters doc](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#argo-repo-server)
- [Argo CD helm chart values.yaml - repo server params](https://github.com/argoproj/argo-helm/blob/7be9b016fb061e325cc5a4751739242c3bc45d59/charts/argo-cd/values.yaml#L2258)


[argoproj-labs/argocd-vault-plugin:issues#566]: https://github.com/argoproj-labs/argocd-vault-plugin/issues/566
[initContainer and configuration via sidecar]: https://argocd-vault-plugin.readthedocs.io/en/stable/installation/#initcontainer-and-configuration-via-sidecar
[Argo CD Vault Plugin]: https://argocd-vault-plugin.readthedocs.io/en/stable/
