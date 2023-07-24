# Guidelines for each Argo CD app directory

1. Use [sync waves](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/) if they have extenral secrets, persistent volumes, or database requirements. This ensures no apps run into order of operations issues and we can ensure statefulness of core unique components. If the app is quite large, consider putting the CRDs in their own sync wave as we've done for the [kube-prometheus-stack app](https://github.com/small-hack/argocd-apps/blob/e88fe6184c46c96d8446422ae51e936bfe9ba8fc/kube-prometheus-stack/argocd_prometheus_app.yaml#L8).

2. Add a basic description of what the app is, and how it works in the `README.md` of the root app directory. Be sure any sync waves are documented and explain why they're necessary. Please also feature a screenshot or two of what the app looks like deployed in the web interface. Remove any IP addresses or other sensitive info first. Also, add a shorter blurb in a table in the repo root `README.md` under the rough category under [All Apps](#all-apps).

3. Make sure all k8s resources are in an app specific [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) (e.g. ingress-nginx in a namespace called ingress). Grouping is fine if the services are highly related such as Prometheus being in the same namespace as Loki.

4. Be in an app specific [Argo CD project](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/). Grouping some services together in similar namespaces is fine, but this helps make the GUI interface more managable and allows good practice for proper IAM and RBAC priniciples.

5. Ensure all secrets are created as external secrets using the [external secrets operator](https://external-secrets.io/). Those external secrets should also be in a private repo, but we should include examples of how to create them if we do.

6. Have absolutely _no plain text secrets_, including but not limited to: passwords, tokens, client secrets, keys of any sort (private or public), certificates. If the upstream helm chart/manifests don't support this, you should fork the chart/manifest repo and patch it to accept existing secrets for use in container [env variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables). Offer a PR to the upstream repo, and use your fork unless/until the upstream repo patches their manifests/templates.

7. Run as non-root via [k8s Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). If this isn't supported, please follow the same steps as you would a plain text password and create a fork.

8. Ensure all ingress resources have SSL certs. Using a fake cert from a `letsencrypt-staging` Issuer is fine while testing, but when the template is marked as ready for production, you must switch to `letsencrypt-prod`.

9. Ensure all apps have authentication enabled, and use OIDC if possible. If authentication is not possible, (e.g. the k8s dashboard) setup SSO via Vouch. On this same note, make sure you have at least one MFA option enabled if available (ideally provide both TOTP/Webauthn). If it's not possible to configure this securely entirely open source (e.g. you need to have an external secret in a private repo), include a sanitized example of how to create the external resources.

## Future Goals
Beyond just ensuring everything meets basic reliability and security needs, we also hope to:

- Figure out a way to have variables for these templates! Right now your best bet for reuse is to clone this repo, and search and replace "social-media-for-dogs.com" and "enby.city" with whatever your domain is. That's combersome and makes merging in changes kinda gross. We need to figure out if there's an Argo CD friendly way to have some sort of evironment variables.
  - on this note, perhaps we check out vault to perhaps utilize the (Argo CD Vault Plugin)[https://argocd-vault-plugin.readthedocs.io/en/stable/).

- Create ArgoCD project configs/roles declaritively, as right now we manually create the projects and roles

- create pre-commit hooks
