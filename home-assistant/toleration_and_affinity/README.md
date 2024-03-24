# Home Assistant Argo CD App (with extras)

This app is a ApplicationSet using the [small-hack/home-assistant-chart](https://github.com/small-hack/home-assistant-chart/) helm chart.

![screenshot of the home-assistant-app in Argo CD showing a tree featuring a configmap, pvc, service, service account, deployment, and ingress resource all called home-assistant.](../home-assistant-argocd-app.png)

- Sets node affinity (to attract your pod to a node)

- Sets tolerations to allow home assistant to be scheduled on its own isolated node. (Useful if you have bluetooth or USB devices on a specific node)

- Allows ingress with TLS vis a configurable cert-manager ClusterIssuer

- Sets up basic home assistant configuration.yaml with time zone, proxy settings, and mobile_app integration enabled

- Setups up a USB device, such as conbee II. (NOTE: requires the [generic device plugin](../../generic-device-plugin) to work)

- includes default dark mode catppucin themes ready to go
