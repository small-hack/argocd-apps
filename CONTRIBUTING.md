# Guidelines for each Argo CD app directory

1. Use [sync waves](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/) if your app of apps has extenral secrets, persistent volumes, or database requirements. This ensures no apps run into order of operations issues and we can ensure statefulness of core unique components. If the app is quite large, consider putting the CRDs in their own sync wave as we've done for the [kube-prometheus-stack app](https://github.com/small-hack/argocd-apps/blob/e88fe6184c46c96d8446422ae51e936bfe9ba8fc/kube-prometheus-stack/argocd_prometheus_app.yaml#L8).

2. Add a basic description of what the app is, and how it works in the `README.md` of the root app directory. Be sure any sync waves are documented and explain why they're necessary. Please also feature a screenshot or two of what the app looks like deployed in the web interface. Remove any IP addresses or other sensitive info first. Also, add a shorter blurb in a table in the repo root `README.md` under the rough category under [All Apps](./README.md#all-apps).

3. Make sure all k8s resources are in an app specific [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) (e.g. ingress-nginx in a namespace called ingress). Grouping is fine if the services are highly related such as Prometheus being in the same namespace as Loki.

4. Make sure all Argo CD apps are in an app specific [Argo CD project](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/). Grouping some services together in similar namespaces is fine, but this helps make the GUI interface more managable and allows good practice for proper IAM and RBAC priniciples.

5. Ensure all secrets are created as external secrets using the [external secrets operator](https://external-secrets.io/).

6. Have absolutely _no plain text secrets_, including but not limited to: passwords, tokens, client secrets, keys of any sort (private or public), certificates. If the upstream helm chart/manifests don't support this, you should fork the chart/manifest repo and patch it to accept existing secrets for use in container [env variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables). Offer a PR to the upstream repo, and use your fork unless/until the upstream repo patches their manifests/templates.

7. All pods/containers should run as non-root via [k8s Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). If this isn't supported, please follow the same steps as you would a plain text password and create a fork.

8. Ensure all ingress resources have SSL certs. Using a fake cert from a `letsencrypt-staging` Issuer is fine while testing, but when the template is marked as ready for production, you must switch to `letsencrypt-prod`.

9. Ensure all apps have authentication enabled, and use [OIDC](https://en.wikipedia.org/wiki/OpenID) (OpenID Connect), perferably keycloak, if possible. If authentication is not possible, (e.g. the k8s dashboard) setup SSO (Single Sign On) via Vouch. On this same note, make sure you have at least one MFA option enabled if available (ideally provide both TOTP (time-based one time password)/Webauthn). If it's not possible to configure this securely entirely open source (e.g. if you need to have an external secret in a private repo), include a sanitized example of how to create the external resources.

10. All *Applications* should be in files called `APP-NAME_argocd_app.yaml`. All *ApplicationSets* should be in files called `APP-NAME_argocd_appset.yaml`. All external secrets should be in a directory called `external_secrets` directly inside the app directory. All other manifests should be in a directory called manifests inside the app directory. This is so that we can use the CRD json schema validation based on file name. (If you're using neovim, checkout an example of the yaml language server [here](https://github.com/jessebot/dot_files/blob/main/.config/nvim/lua/user/lsp-configs.lua#L122-L137))

## Future Goals
Beyond just ensuring everything meets basic reliability and security needs, we also hope to:

- Create ArgoCD project configs/roles declaritively, as right now we manually create the projects and roles <--- this has been started

- create pre-commit hooks <-- we need a good official json schema <-- we should submit ours, when it's done, to the argoCD repo!
