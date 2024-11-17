# LibreTranslate ArgoCD Application

An Argo CD Application to deploy [LibreTranslate](https://libretranslate.com/), a self-hosted language translate tool with a web interface and API.

<img width="937" alt="Screenshotof the Argo CD web interface viewing the libre translate Application in tree mode using a light purple for the nodes in the tree on a dark background. On the farthlest left is the libretranslate-app which branches into one secret, libretransalte-auth, and two config maps: libretranslate-app-settings and libretranslate-config. It also branches into three other resources, each with their own branches as well: a Service, a StatefulSet, and an Ingress resource. The service branches into an endpoint and endpoint slice both named libre-translate. The StatefulSet branches into a pod and controller revision both named libre-translate, along with two persistent volume claims: db-volumne-libre-translate-1 and models-volume-libre-translate-0. Finally, the Ingress resource branches into a certificate." src="https://github.com/user-attachments/assets/ba857ec4-6456-41a5-b513-72005709b932">


## Sync Waves

1. ExternalSecret (from Bitwarden) for a default API key
2. the [LibreTranslate helm chart](https://github.com/small-hack/libretranslate-helm-chart)

<img width="948" alt="Screenshot of the Argo CD web interface viewing the libre translate Application (app of apps) in tree mode using a light purple for the nodes in the tree on a dark background. On the far left is an app called libretranslate that branches into two other Application Sets: libretranslate-app-set and libretranslate-bitwarden-eso, which both then branch into thier respective Argo CD applications." src="https://github.com/user-attachments/assets/78bb551d-c90f-4d56-b229-2a0e7a98d7aa">
