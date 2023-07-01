# Bitanmi Keycloak (Doesnt Work)

https://bitnami.com/stack/keycloak/helm
https://github.com/bitnami/charts/tree/main/bitnami/keycloak/

- Cant be installed through GUI until repo is added because Argo does not support creating OCI-based helm apps. See: https://github.com/argoproj/argo-cd/issues/10823

Log in to argocd:

```bash
argocd login argocd.vleermuis.tech --username admin \
     --grpc-web \
     --password $(bw get password argocd.vleermuis.tech)
```

Add the repo:

```bash
argocd repo add registry-1.docker.io/bitnamicharts/keycloak \
  --type helm \
  --name keycloak \
  --enable-oci
```

Create App:

```bash
argocd app create keycloak \
  --repo registry-1.docker.io/bitnamicharts/keycloak \
  --helm-chart keycloak --revision 1 \
  --dest-namespace keycloak \
  --dest-server https://kubernetes.default.svc  \
  --sync-policy auto 
```

Error:
> FATA[0000] rpc error: code = InvalidArgument desc = application spec for keycloak is invalid: InvalidSpecError: Unable to generate manifests in : rpc error: code = Unknown desc = helm pull oci://registry-1.docker.io/bitnamicharts/keycloak/keycloak --version 5.1.6 --destination /tmp/e404ed85-30e4-491a-b2e4-7155567cb4b2 failed exit status 1: Error: pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
