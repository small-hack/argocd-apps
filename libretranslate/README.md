# LibreTranslate ArgoCD Application

An Argo CD Application to deploy [LibreTranslate](https://libretranslate.com/), a self-hosted language translate tool with a web interface and API.

<img width="936" alt="Screenshot of the Argo CD web interface viewing the libre translate Application in tree mode using a light purple for the nodes in the tree on a dark background. On the farthlest left is the libretranslate-app which branches into two config maps: libretranslate-app-settings and libretranslate-config. It also branches into three other resources, each with their own branches as well: a Service, a StatefulSet, and an Ingress resource. The service branches into an endpoint and endpoint slice both named libre-translate. The StatefulSet branches into a pod and controller revision both named libre-translate, along with two persistent volume claims: db-volumne-libre-translate-1 and models-volume-libre-translate-0. Finally, the Ingress resource branches into a certificate." src="https://github.com/user-attachments/assets/70cc771a-124c-43c2-8472-6a2de88bf60d">

## Sync Waves

1. ExternalSecret (from [Bitwarden](https://github.com/small-hack/bitwarden-eso-provider/)) for a default API key using the [External Secrets Operator](https://external-secrets.io).
2. the [LibreTranslate helm chart](https://github.com/small-hack/libretranslate-helm-chart)

<img width="948" alt="Screenshot of the Argo CD web interface viewing the libre translate Application (app of apps) in tree mode using a light purple for the nodes in the tree on a dark background. On the far left is an app called libretranslate that branches into two other Application Sets: libretranslate-app-set and libretranslate-bitwarden-eso, which both then branch into thier respective Argo CD applications." src="https://github.com/user-attachments/assets/78bb551d-c90f-4d56-b229-2a0e7a98d7aa">

## Example Config

To deploy this app of apps into your cluster using Argo CD, you could use something like this:

```yaml
project: default
source:
  repoURL: https://github.com/small-hack/argocd-apps
  path: libretranslate/app_of_apps/
  targetRevision: main
destination:
  server: https://kubernetes.default.svc
  namespace: libretranslate
syncPolicy:
  automated:
    selfHeal: true
  syncOptions:
    - ApplyOutOfSyncOnly=true
```

**Note**: This LibreTranslate Applciation in [`app_of_apps/libre_translate_argocd_appset.yaml`](./app_of_apps/libre_translate_argocd_appset.yaml) requires the use of the [Application Secret Plugin](https://github.com/small-hack/appset-secret-plugin), but you're always free to use a different generator if you fork this repo :)
