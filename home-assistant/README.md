# Argo CD app for Home Assistant

[Home Assistant](https://home-assistant.io) is a home IOT management solution.

<a href="https://github.com/small-hack/argocd-apps/assets/2389292/57a88af0-6124-41e1-a7e2-9195c944dea7">
<img width="850" alt="home-assistant" src="https://github.com/small-hack/argocd-apps/assets/2389292/57a88af0-6124-41e1-a7e2-9195c944dea7">
</a>

<details>
  <summary>Home Assistant Argo CD helm chart app</summary>

<a href="https://github.com/small-hack/argocd-apps/assets/2389292/24832836-d17e-46a9-9d5a-a134bc6d8359">
<img width="850" alt="home-assistant-helm" src="https://github.com/small-hack/argocd-apps/assets/2389292/24832836-d17e-46a9-9d5a-a134bc6d8359">
</a>

</details>

This app is just a single ApplicationSet using the [small-hack/home-assistant-chart](https://github.com/small-hack/home-assistant-chart/) helm chart that just takes a hostname and cluster issuer (for the TLS cert) for templating. It also includes default dark mode catppucin themes ready to go.

If you'd like to pass in devices, such as USB devices consider the app in the [toleration_and_affinity](./toleration_and_affinity) directory. (NOTE: still requires the [generic device plugin](../generic-device-plugin))
