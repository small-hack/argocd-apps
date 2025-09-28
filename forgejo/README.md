# Forgejo helm chart

[Forgejo](https://forgejo.org/) is

> a self-hosted lightweight software forge. Easy to install and low maintenance, it just does the job. Brought to you by an inclusive community under the umbrella of Codeberg e.V., a democratic non-profit organization, Forgejo can be trusted to be exclusively Free Software. It includes and cooperates with hundreds of projects (Gitea, Git, ...) and is focused on scaling, federation and privacy.

We're using this [helm chart](https://code.forgejo.org/forgejo-contrib/forgejo-helm) to experiment right now.

<img width="1042" alt="Screenshot of the the forgejo app in the Argo CD web interface using tree view mode. You can see the forgejo app branches into 4 appsets that all have their own corresponding apps, including: forgejo-bitwarden-eso, forgejo-postgres-app-set, forgejo-valkey-cluster-appset, and forgejo-web-app-set" src="https://github.com/user-attachments/assets/e712db42-8241-41ab-8a3d-ae05daa8991a" />


## IMPORTANT

1. An OIDC user must have a zitadel authorization for `forgejo_admins`. After the initial login your account will not have admin access - You mush log out and then back-in before Forgejo will switch your account to be an admin.

2. This uses an oci image repo which can only be used if it is added as a repo to argocd:

    ```bash
    kns argocd
    argocd repo add code.forgejo.org --type helm --name forgejo --enable-oci
    ```

TODO:

1. convert existing secrets to external secrets or random passwords
2. add seaweedfs backups
3. add zitadel auth
4. Create an App-of-Apps
5. Add to smol-k8s-lab config
