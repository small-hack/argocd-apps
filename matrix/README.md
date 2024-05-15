# ArgoCD Template for Matrix helm chart

[Matrix](https://matrix.org/) is an open network for secure, decentralised communication :)

<img width="900" alt="matrix" src="https://github.com/small-hack/argocd-apps/assets/2389292/a31499f2-a12b-4c8c-b19f-018f68e53acc">

<details>
  <summary>Click for more Argo CD App screenshots</summary>

  ### Helm chart view
  <img width="900" alt="matrix-web-app" src="https://github.com/small-hack/argocd-apps/assets/2389292/f3940d42-46aa-4f90-9215-037364a5e8b5">

  ### Networking view
  <img width="1390" alt="matrix-networking" src="https://github.com/small-hack/argocd-apps/assets/2389292/07217b21-4945-4426-8ea9-d5f41f6ca7f7">
  
</details>


We're using [small-hack/matrix-chart](https://github.com/small-hack/matrix-chart), which is a fork of [Arkaniad/matrix-chart](https://github.com/Arkaniad), which is a fork of [typokign/matrix-chart](https://github.com/typokign/matrix-chart) (no longer maintained).

| Sync Wave | Description                             |
|:---------:|:----------------------------------------|
|     1     | External Secrets and Persistent volumes |
|     2     | Postgresql cluster                      |
|     3     | Matrix                                  |
