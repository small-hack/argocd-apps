# Garage Argo CD Application

[Garage](https://git.deuxfleurs.fr/Deuxfleurs/garage) is an S3 compatible Object Store.

We're experimenting with using this [helm chart](https://git.deuxfleurs.fr/Deuxfleurs/garage/src/branch/main/script/helm/garage).

So far we're inclined to not use this, as we'd need to maintain one of the following:
- a special set of K8s RBAC config and K8s job with an Argo CD resource hook to execute all the commands in the config.sh in this directory.
- our own docker container and helm chart to provide shell access
