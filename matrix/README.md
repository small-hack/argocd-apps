# Argo CD Application for Matrix helm chart

[Matrix](https://matrix.org/) is an open network for secure, decentralised communication :)

<img width="900" alt="screenshot of the Argo CD web interface showing the matrix app of apps in tree view mode, which shows the following children: external secrets appset, postgres appset, matrix PVC appset, s3 provider appset, s3 pvc app set, and matrix web app set." src="https://github.com/small-hack/argocd-apps/assets/2389292/a31499f2-a12b-4c8c-b19f-018f68e53acc">

<details>
  <summary>Click for more Argo CD App screenshots</summary>

  ### Helm chart view
  <img width="900" alt="screenshot of the Argo CD web interface showing the matrix web app in tree view mode." src="https://github.com/small-hack/argocd-apps/assets/2389292/f3940d42-46aa-4f90-9215-037364a5e8b5">

  ### Networking view
  <img width="1390" alt="screenshot of the Argo CD web interface showing the matrix web app in networking view mode. It shows a cloud on the left flowing into a box that says 192.168.168.168 which branches off into three ingress resources: matrix stack element, matrix stack synapse, and matrix stack synapse federation. The ingress resource for element, branches off into a service of the same name and then a pod of the same name. The synapse and synapse federation ingress resources branch off into two respective services that branch off into one shared pod called matrix stack synapse." src="https://github.com/small-hack/argocd-apps/assets/2389292/07217b21-4945-4426-8ea9-d5f41f6ca7f7">

</details>

We're using [small-hack/matrix-chart](https://github.com/small-hack/matrix-chart), which is a fork of [Arkaniad/matrix-chart](https://github.com/Arkaniad), which is a fork of [typokign/matrix-chart](https://github.com/typokign/matrix-chart) (no longer maintained).

| Sync Wave | Description                             |
|:---------:|:----------------------------------------|
|     1     | External Secrets and Persistent volumes |
|     2     | Postgresql cluster                      |
|     3     | Matrix                                  |

# Notes

## Stable vs Beta

To use the stable version of synapse and element, use the [`app_of_apps`](./app_of_apps) directory, however if you'd like to try to the new [element-x](https://matrix.org/ecosystem/clients/element-x/), you'll want to use the [`app_of_apps_beta`](./app_of_apps_beta) directory until all is declared live and stable.

`app_of_apps_beta` will use [matrix authentication service](https://matrix-org.github.io/matrix-authentication-service) for OIDC instead of the current OIDC implementation baked into synapse, which you can read more about on the [matrix.org blog](https://matrix.org/blog/2023/09/better-auth/#upgrading-to-use-matrix-authentication-service). We've experimented a bit with this, but we don't feel element-x is production ready yet, as it also doesn't have a lot of features yet, but we're excited for when it does :)

## Bridges

We're currently experimenting with turning on bridges in the [`app_of_apps_with_bridge`](./app_of_apps_with_bridge) directory. We've started with the alertmanager bridge for getting prometheus alerts directly in matrix. This is semi stable, but should only be used for testing.

## Security

Currently, we add trusted key servers per federated instance, and we also use ModSecurity as our Web Application Firewall, which uses the OWASP Core Rule Set and then we use the plugin to allow rule exclusion for legitimate traffic. You can see our exact ModSecurity config in the [`ingress-nginx/ingress-nginx_argocd_appset.yaml`](../ingress-nginx/ingress-nginx_argocd_appset.yaml) and [`ingress-nginx/plugins/plugins-configmap.yaml`](../ingress-nginx/plugins/plugins-configmap.yaml).
