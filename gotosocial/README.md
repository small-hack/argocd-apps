# Argo CD GoToSocial App of Apps

The `app_of_apps` directory deploys a [GoToSocial] Argo CD App of Apps which features [0hlov3's GoToSocial helm chart].

<img width="943" alt="Screenshot of the GoToSocial app of apps in the Argo CD web interface in tree view mode. It shows the main helm chart appset, the external secrets appset, the postgresql app set, the PVC appset, the S3 provider app set, and hte S3 PVC appset" src="https://github.com/user-attachments/assets/45e7eb05-9843-4534-bb04-8a48cb8cb8d3" />

## Sync Waves

In the [`./app_of_apps`](./app_of_apps) directory we create the manifests and helm chart in this sync wave order:

1. all required PVCs, and ExternalSecrets, Themes Secret
2. SeaweedFS file system and s3 endpoint with two buckets, one for Postgres backups and one for GoToSocial media
3. Postgresql Cluster
4. GoToSocial helm app
  <img width="1274" alt="Screenshot of the GoToSocial Argo CD helm chart app in the web inteface using tree view mode. It shows a branching structured flow map that goes from left to right: gotosocial-web-app to gotosocial secret, gotosocial service (which branches to a gotosocial endpoint end endpoint slice), gotosocial service account, gotosocial deployment (which branches to a gotosocial replica set which branches to a gotosocial pod), and finally a gotosocial ingress which branches to a gotosocial TLS certificate" src="https://github.com/user-attachments/assets/e07af4db-5c55-4142-90c8-6fe61d5b684b" />

## Additional Info

You can find more docs for GoToSocial configuration here:
https://docs.gotosocial.org/en/latest/configuration

<!-- link references -->
[GoToSocial]: https://docs.gotosocial.org/en/latest/
[0hlov3's GoToSocial helm chart]: https://github.com/0hlov3/charts/tree/main/charts/gotosocial
