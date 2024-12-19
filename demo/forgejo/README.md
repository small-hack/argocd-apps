# Forgejo helm chart

[Forgejo](https://forgejo.org/) is

> a self-hosted lightweight software forge. Easy to install and low maintenance, it just does the job. Brought to you by an inclusive community under the umbrella of Codeberg e.V., a democratic non-profit organization, Forgejo can be trusted to be exclusively Free Software. It includes and cooperates with hundreds of projects (Gitea, Git, ...) and is focused on scaling, federation and privacy.

We're using this [helm chart](https://code.forgejo.org/forgejo-contrib/forgejo-helm) to experiment right now.

## IMPORTANT

This uses an oci image repo which can only be used if it is added as a repo to argocd:

```bash
kns argocd
argocd repo add code.forgejo.org --type helm --name forgejo --enable-oci
```
